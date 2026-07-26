#!/usr/bin/env bash
# PreToolUse hook (Bash matching `git commit`): enforces contract §13's
# commit-trailer requirement for reflect-cycle. When a reflect unit is in
# progress (reflect/state.md exists with a NON-TERMINAL stage — i.e. not
# `done`), a commit landing that work must carry reflect's declared
# machine-checkable trailer identifying the subject:
#
#     Subject: <subject>
#
# (reflect's declared trailer key, per §13's "each rulebook's own concern".)
# A commit made while a unit is open that lacks this trailer is refused.
# When no unit is in progress (no reflect/state.md, or its stage is the
# terminal `done`), this gate does not apply.
#
# Additive sibling to state-gate.sh; never edits it.
# Fail-closed: a commit whose message cannot be read statically while a unit
# is open is DENIED (use `git commit -m` so the trailer is verifiable).
# Kill switch: export REFLECT_CYCLE_OFF=1
set -uo pipefail

deny() { echo "reflect-cycle: refused — $1" >&2; exit 2; }

case "${REFLECT_CYCLE_OFF:-}" in
  ""|0|false|no|off) ;;
  *) exit 0 ;;
esac

command -v python3 >/dev/null 2>&1 || deny "trailer-gate: python3 is required to evaluate the gate and is not on PATH."

payload="$(cat 2>/dev/null)"
[ -n "$payload" ] || deny "trailer-gate: empty tool-use payload on stdin; cannot evaluate the trailer gate."

REFLECT_PAYLOAD="$payload" \
REFLECT_CPD="${CLAUDE_PROJECT_DIR:-}" \
REFLECT_CWD="$(pwd -P 2>/dev/null || echo)" \
python3 <<'PY'
import json, os, posixpath, re, shlex, subprocess, sys

def deny(msg):
    sys.stderr.write("reflect-cycle: refused — %s\n" % msg)
    sys.exit(2)

def allow():
    sys.exit(0)

# --- fail-closed on internal error (frozen contract) -----------------------
# Any uncaught exception in this judge (e.g. os.path.realpath on a null-byte
# or undecodable path raising ValueError) must become a DENY (exit 2), never
# an uncaught exit 1 that PreToolUse treats as non-blocking (fail-open).
def _reflect_fail_closed(_t, _v, _tb):
    try:
        sys.stderr.write("reflect-cycle: refused — fail-closed: internal error (%s: %s)\n" % (_t.__name__, _v))
    except Exception:
        pass
    os._exit(2)
sys.excepthook = _reflect_fail_closed

raw = os.environ.get("REFLECT_PAYLOAD", "")
try:
    event = json.loads(raw)
except ValueError:
    deny("trailer-gate: the tool-use payload is not valid JSON.")
if not isinstance(event, dict):
    deny("trailer-gate: the tool-use payload is not a JSON object.")

tool = event.get("tool_name")
ti = event.get("tool_input")
if not isinstance(tool, str) or not tool:
    deny("trailer-gate: payload has no tool_name.")
if tool != "Bash":
    allow()
if not isinstance(ti, dict):
    deny("trailer-gate: payload has no tool_input object.")

command = ti.get("command")
if not isinstance(command, str) or not command.strip():
    deny("trailer-gate: Bash call has no usable command string.")

if not re.search(r'\bgit\b[^\n;&|]*\bcommit\b(?!-)', command):
    allow()

# --- root resolution -----------------------------------------------------
def git_toplevel(start):
    try:
        d = start if os.path.isdir(start) else os.path.dirname(start)
        if not d:
            return None
        out = subprocess.run(["git", "-C", d, "rev-parse", "--show-toplevel"],
                             capture_output=True, text=True, timeout=10)
        top = out.stdout.strip()
        return top or None
    except Exception:
        return None

def plausible_root(r):
    return bool(r) and os.path.isdir(r) and (
        os.path.exists(os.path.join(r, ".git"))
        or os.path.isfile(os.path.join(r, "docs/specs/role-handoff-contract.md")))

cpd = os.environ.get("REFLECT_CPD", "")
cwd = os.environ.get("REFLECT_CWD", "") or "."

root = None
if plausible_root(cpd):
    root = os.path.realpath(cpd)
if root is None:
    root = git_toplevel(cwd)
if not root:
    deny("trailer-gate: no project root could be determined for the commit; refusing rather than allowing an unverified commit.")

# --- is a reflect unit in progress? --------------------------------------
state_path = posixpath.join(root, "reflect/state.md")
if not os.path.exists(state_path):
    allow()  # no unit in progress
try:
    with open(state_path, encoding="utf-8-sig") as fh:
        state_text = fh.read(1 << 20)
except OSError as exc:
    deny("trailer-gate: reflect/state.md exists but could not be read (%s); refusing rather than allowing an unverified in-progress commit." % exc)

m = re.search(r'^\s*stage\s*:\s*(\S+)', state_text, re.M)
if not m:
    deny("trailer-gate: reflect/state.md exists but has no parseable `stage:` field; cannot determine whether a unit is in progress. Refusing rather than allowing an unverified commit.")
stage = m.group(1).strip().lower()

TERMINAL = {"done"}
if stage in TERMINAL:
    allow()  # unit concluded; §13 trailer requirement does not gate it

# --- unit in progress: require reflect's Subject: trailer ----------------
# Extract commit messages statically from -m/--message. If the commit
# supplies no inline message (editor or -F file), the trailer cannot be
# verified statically -> fail closed.
try:
    tokens = shlex.split(command)
except ValueError:
    deny("trailer-gate: the commit command could not be tokenized to verify its trailer; use `git commit -m` with the required `Subject:` trailer.")

messages = []
i = 0
uses_file_or_editor = False
while i < len(tokens):
    tok = tokens[i]
    if tok in ("-m", "--message"):
        if i + 1 < len(tokens):
            messages.append(tokens[i + 1])
            i += 2
            continue
    elif tok.startswith("--message="):
        messages.append(tok[len("--message="):])
    elif tok.startswith("-m") and len(tok) > 2:
        messages.append(tok[2:])
    elif tok in ("-F", "--file") or tok.startswith("--file=") or (tok.startswith("-F") and len(tok) > 2):
        uses_file_or_editor = True
    i += 1

joined = "\n".join(messages)

if not messages:
    if uses_file_or_editor:
        deny("trailer-gate: a reflect unit is in progress (reflect/state.md stage '%s') and this commit supplies its message via a file/editor, so the required `Subject:` trailer (contract §13) cannot be verified statically. Pass the message with `git commit -m` including a `Subject: <subject>` trailer." % stage)
    deny("trailer-gate: a reflect unit is in progress (reflect/state.md stage '%s') and this commit carries no inline `-m` message, so its `Subject:` trailer (contract §13) cannot be verified. Use `git commit -m` with a `Subject: <subject>` trailer." % stage)

if not re.search(r'(?im)^\s*Subject:\s*\S', joined):
    deny("trailer-gate: a reflect unit is in progress (reflect/state.md stage '%s') but this commit message lacks reflect's required `Subject: <subject>` trailer (contract §13, reflect-cycle's declared trailer key). Add the trailer identifying the subject this commit's reflect-record belongs to." % stage)

allow()
PY
rc=$?
# Fail-closed shell layer (frozen contract): the judge's exit code decides
# allow(0)/deny(2). ANY other exit code — a crash, an unguarded pipeline
# abort, a killed interpreter — maps to a DENY (exit 2), never passes through
# as a non-2 non-zero that PreToolUse would treat as non-blocking (fail-open).
if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
  echo "reflect-cycle: refused — fail-closed: internal error (gate judge exited $rc)" >&2
  exit 2
fi
exit "$rc"
