#!/usr/bin/env bash
__fc(){ rc=$?; if [ "$rc" != 0 ] && [ "$rc" != 2 ]; then echo "fail-closed: gate aborted (rc=$rc)" >&2; exit 2; fi; }
trap __fc EXIT
# PreToolUse hook (Write|Edit|MultiEdit|NotebookEdit): enforces the bucket
# half of contract §21 — every file written under docs/ must land in one of
# the six doctrine buckets (decisions/, handbooks/, reports/, specs/,
# proposals/, _assets/). Only docs/README.md may sit at the docs/ root.
# Replicates coding's doctrine/placement-gate.sh shape (bucket membership),
# but fail-CLOSED per this proposal's reference (ops state-gate.sh), not
# fail-open. Additive sibling to state-gate.sh; never edits it.
#
# Fail-closed: any malformed/missing/unresolvable input is a DENY.
# Kill switch: export REFLECT_CYCLE_OFF=1
set -uo pipefail

deny() { echo "reflect-cycle: refused — $1" >&2; exit 2; }

case "${REFLECT_CYCLE_OFF:-}" in
  ""|0|false|no|off) ;;
  *) exit 0 ;;
esac

command -v python3 >/dev/null 2>&1 || deny "doc-bucket-gate: python3 is required to evaluate the gate and is not on PATH."

payload="$(cat 2>/dev/null)"
[ -n "$payload" ] || deny "doc-bucket-gate: empty tool-use payload on stdin; cannot evaluate the doc-bucket gate."

REFLECT_PAYLOAD="$payload" \
REFLECT_CPD="${CLAUDE_PROJECT_DIR:-}" \
REFLECT_CWD="$(pwd -P 2>/dev/null || echo)" \
python3 <<'PY'
import json, os, posixpath, subprocess, sys

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
    deny("doc-bucket-gate: the tool-use payload is not valid JSON.")
if not isinstance(event, dict):
    deny("doc-bucket-gate: the tool-use payload is not a JSON object.")

tool = event.get("tool_name")
ti = event.get("tool_input")
if not isinstance(tool, str) or not tool:
    deny("doc-bucket-gate: payload has no tool_name.")
if not isinstance(ti, dict):
    deny("doc-bucket-gate: payload has no tool_input object.")

WRITE_TOOLS = ("Write", "Edit", "MultiEdit", "NotebookEdit")
if tool not in WRITE_TOOLS:
    allow()

path = ti.get("file_path") or ti.get("notebook_path")
if not isinstance(path, str) or not path:
    deny("doc-bucket-gate: %s call has no usable file_path/notebook_path." % tool)

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
    deny("doc-bucket-gate: no project root could be determined (CLAUDE_PROJECT_DIR unset/invalid and no git top-level for the target or cwd). Refusing rather than allowing an indeterminate-root write.")

real_root = posixpath.normpath(os.path.realpath(root).replace("\\", "/"))
absolute = posixpath.normpath(norm if posixpath.isabs(norm) else posixpath.join(real_root, norm))
# NOTE: for a not-yet-existing file realpath resolves the leaf literally,
# which is what we want — bucket membership is decided on the target path,
# not on where a symlink might point.
resolved = posixpath.normpath(os.path.realpath(absolute).replace("\\", "/"))
if resolved != real_root and not resolved.startswith(real_root + "/"):
    allow()  # outside the repo; not this gate's concern
rel = resolved[len(real_root) + 1:] if resolved.startswith(real_root + "/") else ""

parts = rel.split("/")
if not parts or parts[0] != "docs":
    allow()  # not under docs/; out of scope

# docs/README.md is the one allowed file at the docs/ root.
if len(parts) == 2 and parts[1] == "README.md":
    allow()

BUCKETS = ("decisions", "handbooks", "reports", "specs", "proposals", "_assets")
if len(parts) >= 2 and parts[1] in BUCKETS:
    allow()

buckets = ", ".join(b + "/" for b in BUCKETS)
deny(
    "'%s' is under docs/ but not in one of the six doctrine buckets. Per contract §21, every "
    "file under docs/ belongs to a bucket — classify by lifetime: undecided -> proposals/; "
    "system design tied to code -> specs/; kept-current operational doc -> handbooks/; a "
    "hard-to-reverse choice -> decisions/; a measurement/investigation -> reports/; images and "
    "attachments -> _assets/. The buckets are: %s. Only docs/README.md may sit at the docs/ root."
    % (rel, buckets)
)
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
