#!/usr/bin/env bash
# PreToolUse hook (Write|Edit|MultiEdit|NotebookEdit): enforces contract §20
# per-role record minimum content on writes reaching reflect's OWN record
# (`docs/reports/records/<subject>/reflect.md`, resolved by target path).
#
# Composes as a PEER to state-gate.sh — it never edits state-gate.sh and
# never touches reflect/state.md. state-gate.sh validates the state-file
# transition and the reflect-record's DEPENDS-ON pointer; THIS gate validates
# §20's minimum-content sections on the same proposed record content.
#
# Fail-closed: any malformed/missing/unresolvable input is a DENY, never a
# silent allow. Writes not reaching reflect's own record pass through.
#
# Kill switch: export REFLECT_CYCLE_OFF=1
set -uo pipefail

deny() { echo "reflect-cycle: refused — $1" >&2; exit 2; }

case "${REFLECT_CYCLE_OFF:-}" in
  ""|0|false|no|off) ;;
  *) exit 0 ;;
esac

command -v python3 >/dev/null 2>&1 || deny "record-fields-gate: python3 is required to evaluate the gate and is not on PATH."

payload="$(cat 2>/dev/null)"
[ -n "$payload" ] || deny "record-fields-gate: empty tool-use payload on stdin; cannot evaluate the record-fields gate."

REFLECT_PAYLOAD="$payload" \
REFLECT_CPD="${CLAUDE_PROJECT_DIR:-}" \
REFLECT_CWD="$(pwd -P 2>/dev/null || echo)" \
python3 <<'PY'
import json, os, posixpath, re, subprocess, sys

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
    deny("record-fields-gate: the tool-use payload is not valid JSON.")
if not isinstance(event, dict):
    deny("record-fields-gate: the tool-use payload is not a JSON object.")

tool = event.get("tool_name")
ti = event.get("tool_input")
if not isinstance(tool, str) or not tool:
    deny("record-fields-gate: payload has no tool_name.")
if not isinstance(ti, dict):
    deny("record-fields-gate: payload has no tool_input object.")

WRITE_TOOLS = ("Write", "Edit", "MultiEdit", "NotebookEdit")
if tool not in WRITE_TOOLS:
    allow()

path = ti.get("file_path") or ti.get("notebook_path")
if not isinstance(path, str) or not path:
    deny("record-fields-gate: %s call has no usable file_path/notebook_path." % tool)

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
cwd = os.environ.get("REFLECT_CWD", "")
norm = path.replace("\\", "/")
target_abs_guess = norm if posixpath.isabs(norm) else posixpath.join(cwd or ".", norm)

root = None
if plausible_root(cpd):
    root = os.path.realpath(cpd)
if root is None:
    root = git_toplevel(target_abs_guess)
if root is None and cwd:
    root = git_toplevel(cwd)
if not root:
    deny("record-fields-gate: no project root could be determined (CLAUDE_PROJECT_DIR unset/invalid and no git top-level for the target or cwd). Refusing rather than allowing an indeterminate-root write.")

real_root = posixpath.normpath(os.path.realpath(root).replace("\\", "/"))
absolute = posixpath.normpath(norm if posixpath.isabs(norm) else posixpath.join(real_root, norm))
resolved = posixpath.normpath(os.path.realpath(absolute).replace("\\", "/"))
if resolved != real_root and not resolved.startswith(real_root + "/"):
    allow()
rel = resolved[len(real_root) + 1:] if resolved.startswith(real_root + "/") else ""

RECORD_RE = re.compile(r'^docs/reports/records/([^/]+)/reflect\.md$')
if not RECORD_RE.match(rel):
    allow()

def read_existing():
    try:
        with open(resolved, encoding="utf-8-sig") as fh:
            return fh.read(1 << 20)
    except OSError:
        return None

if tool == "NotebookEdit":
    deny("record-fields-gate: reflect-record %s written via NotebookEdit; this gate cannot verify §20 sections in a notebook cell edit. Write the record as markdown." % rel)

if tool == "Write":
    content = ti.get("content")
    if not isinstance(content, str):
        deny("record-fields-gate: Write on %s has no string content." % rel)
    new_text = content
elif tool == "Edit":
    old_s = ti.get("old_string")
    new_s = ti.get("new_string")
    if not isinstance(old_s, str) or not isinstance(new_s, str):
        deny("record-fields-gate: Edit on %s is missing old_string/new_string." % rel)
    if old_s == "":
        new_text = new_s
    else:
        base = read_existing()
        if base is None:
            deny("record-fields-gate: Edit on %s but the existing record could not be read to compute the result; refusing rather than guessing." % rel)
        if old_s not in base:
            deny("record-fields-gate: Edit on %s — old_string was not found verbatim; cannot compute the resulting record." % rel)
        if ti.get("replace_all") is True:
            new_text = base.replace(old_s, new_s)
        else:
            new_text = base.replace(old_s, new_s, 1)
elif tool == "MultiEdit":
    edits = ti.get("edits")
    if not isinstance(edits, list) or not edits:
        deny("record-fields-gate: MultiEdit on %s has no usable edits list." % rel)
    base = read_existing()
    text = base if base is not None else ""
    for e in edits:
        if not isinstance(e, dict):
            deny("record-fields-gate: MultiEdit on %s has a non-object edit entry." % rel)
        os_ = e.get("old_string")
        ns_ = e.get("new_string")
        if not isinstance(os_, str) or not isinstance(ns_, str):
            deny("record-fields-gate: MultiEdit on %s has an edit missing old_string/new_string." % rel)
        if os_ == "":
            text = ns_
            continue
        if base is None or os_ not in text:
            deny("record-fields-gate: MultiEdit on %s — old_string not found verbatim at apply point; cannot compute the resulting record." % rel)
        if e.get("replace_all") is True:
            text = text.replace(os_, ns_)
        else:
            text = text.replace(os_, ns_, 1)
    new_text = text
else:
    deny("record-fields-gate: unrecognized write tool %s on %s." % (tool, rel))

t = new_text or ""

def has(pattern):
    return re.search(pattern, t, re.I | re.M) is not None

m = re.search(r'^\s*(?:loop_state|stage)\s*:\s*(\S+)', t, re.I | re.M)
loop_state = m.group(1).strip().lower() if m else None

missing = []
if not has(r'what\s+was\s+done'):
    missing.append("what was done")
if not (has(r'^\s*#{1,6}\s*.*\bwhy\b') or has(r'\bwhy\b.*\b(not taken|alternative|instead|chose|rejected)\b') or has(r'\balternative\b')):
    missing.append("why (with the alternative considered)")
if not (has(r'^\s*(?:records_read|upstream_records|upstream)\s*:') or has(r'\bupstream\b') or has(r'\b[0-9a-f]{7,40}\b')):
    missing.append("the concrete upstream basis (record path or commit sha)")
if loop_state is None:
    missing.append("the record's own loop_state")

TERMINAL = {"done", "cleared", "reported", "round-done"}
open_work = loop_state is not None and loop_state not in TERMINAL
if open_work:
    if not has(r'next[\s-]?steps|backlog'):
        missing.append("a next-steps backlog (record leaves work open)")
    if not (has(r'resolution[\s-]?path') or has(r'owns?\s+resolving') or has(r'open[\s-]?finding')):
        missing.append("an open-finding resolution path (record leaves work open)")

if missing:
    deny(
        "record is missing required section(s): %s. Per contract §20 every role record must "
        "state what was done, why (when a real choice was made), and the concrete upstream basis "
        "plus its own loop_state; a record that leaves work open additionally requires a "
        "next-steps backlog and an open-finding resolution path." % ", ".join(missing)
    )
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
