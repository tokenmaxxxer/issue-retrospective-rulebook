#!/usr/bin/env bash
# PreToolUse hook (Write|Edit|MultiEdit|NotebookEdit): enforces contract §11
# per-role path ownership. reflect owns exactly one record kind:
# `docs/reports/records/<subject>/reflect.md`. Any write whose resolved
# target lands on a path §11 assigns to a DIFFERENT role (another role's
# record `docs/reports/records/<subject>/<other>.md`, another role's record
# subtree `docs/reports/records/<subject>/<other>/**`, or a proposal slot
# owned by product/coding) is refused-and-reported rather than overwritten
# or merged.
#
# Generalizes coding's warrant/scope-gate.sh write-set shape to §11's
# static, role-permanent owned-path table. Additive sibling to state-gate.sh;
# never edits it.
#
# Fail-closed: any malformed/missing/unresolvable input is a DENY.
# Kill switch: export REFLECT_CYCLE_OFF=1
set -uo pipefail

deny() { echo "reflect-cycle: refused — $1" >&2; exit 2; }

case "${REFLECT_CYCLE_OFF:-}" in
  ""|0|false|no|off) ;;
  *) exit 0 ;;
esac

command -v python3 >/dev/null 2>&1 || deny "path-ownership-gate: python3 is required to evaluate the gate and is not on PATH."

payload="$(cat 2>/dev/null)"
[ -n "$payload" ] || deny "path-ownership-gate: empty tool-use payload on stdin; cannot evaluate the path-ownership gate."

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

raw = os.environ.get("REFLECT_PAYLOAD", "")
try:
    event = json.loads(raw)
except ValueError:
    deny("path-ownership-gate: the tool-use payload is not valid JSON.")
if not isinstance(event, dict):
    deny("path-ownership-gate: the tool-use payload is not a JSON object.")

tool = event.get("tool_name")
ti = event.get("tool_input")
if not isinstance(tool, str) or not tool:
    deny("path-ownership-gate: payload has no tool_name.")
if not isinstance(ti, dict):
    deny("path-ownership-gate: payload has no tool_input object.")

WRITE_TOOLS = ("Write", "Edit", "MultiEdit", "NotebookEdit")
if tool not in WRITE_TOOLS:
    allow()

path = ti.get("file_path") or ti.get("notebook_path")
if not isinstance(path, str) or not path:
    deny("path-ownership-gate: %s call has no usable file_path/notebook_path." % tool)

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
    deny("path-ownership-gate: no project root could be determined (CLAUDE_PROJECT_DIR unset/invalid and no git top-level for the target or cwd). Refusing rather than allowing an indeterminate-root write.")

real_root = posixpath.normpath(os.path.realpath(root).replace("\\", "/"))
absolute = posixpath.normpath(norm if posixpath.isabs(norm) else posixpath.join(real_root, norm))
resolved = posixpath.normpath(os.path.realpath(absolute).replace("\\", "/"))
if resolved != real_root and not resolved.startswith(real_root + "/"):
    allow()
rel = resolved[len(real_root) + 1:] if resolved.startswith(real_root + "/") else ""

# §11 ownership classification.
FOREIGN_BUILD_PROPOSAL_RE = re.compile(r'^docs/proposals/(\d{4}-\d{2}-\d{2})-build-([A-Za-z0-9][A-Za-z0-9\-]*)\.md$')
FOREIGN_HYPOTHESIS_RE = re.compile(r'^docs/proposals/(\d{4}-\d{2}-\d{2})-(?!build-)([A-Za-z0-9][A-Za-z0-9\-]*)\.md$')
RECORD_FILE_RE = re.compile(r'^docs/reports/records/([^/]+)/([A-Za-z0-9\-]+)\.md$')
RECORD_SUBTREE_RE = re.compile(r'^docs/reports/records/([^/]+)/([^/]+)/.+$')

def foreign_owner(rel_path):
    """Return the owning role name if rel_path is a path §11 assigns to a
    role OTHER than reflect, else None."""
    if FOREIGN_BUILD_PROPOSAL_RE.match(rel_path):
        return "coding (build-proposal slot)"
    if FOREIGN_HYPOTHESIS_RE.match(rel_path):
        return "product (hypothesis proposal slot)"
    m = RECORD_FILE_RE.match(rel_path)
    if m:
        record_name = m.group(2)
        if record_name != "reflect":
            return "%s (its own record)" % record_name
        return None  # reflect's own record — allowed
    m = RECORD_SUBTREE_RE.match(rel_path)
    if m:
        seg = m.group(2)
        # reflect owns no subtree under its subject dir; any subtree segment
        # belongs to whichever role owns it (qa/, spikes/, postmortems/, ...).
        if seg == "reflect":
            return None
        return "%s (record subtree)" % seg
    return None

owner = foreign_owner(rel)
if owner is not None:
    deny(
        "path ownership conflict — '%s' is owned by role '%s' per contract §11, not by reflect. "
        "Report the conflict; do not overwrite or merge into another role's owned path." % (rel, owner)
    )
allow()
PY
status=$?
exit "$status"
