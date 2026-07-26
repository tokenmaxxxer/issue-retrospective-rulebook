#!/usr/bin/env bash
# PreToolUse hook (Bash matching `git commit`): enforces the handbook-trigger
# half of contract §21 — when a commit's staged change set introduces or
# changes an operational surface (an env var / config key, a dependency
# manifest, a Dockerfile/compose, a migration, or a run/setup/deploy script),
# the SAME commit must also touch docs/handbooks/<component>.md. A commit that
# changes operational surface without touching any handbook is refused.
#
# Sees the whole staged change set (git diff --cached), which is why it fires
# at commit time, not on a single Write. Additive sibling to state-gate.sh.
#
# Fail-closed: if the change set cannot be read, DENY. Kill switch:
# export REFLECT_CYCLE_OFF=1
set -uo pipefail

deny() { echo "reflect-cycle: refused — $1" >&2; exit 2; }

case "${REFLECT_CYCLE_OFF:-}" in
  ""|0|false|no|off) ;;
  *) exit 0 ;;
esac

command -v python3 >/dev/null 2>&1 || deny "handbook-trigger-gate: python3 is required to evaluate the gate and is not on PATH."
command -v git >/dev/null 2>&1 || deny "handbook-trigger-gate: git is required to evaluate the staged change set and is not on PATH."

payload="$(cat 2>/dev/null)"
[ -n "$payload" ] || deny "handbook-trigger-gate: empty tool-use payload on stdin; cannot evaluate the handbook-trigger gate."

REFLECT_PAYLOAD="$payload" \
REFLECT_CWD="$(pwd -P 2>/dev/null || echo)" \
python3 <<'PY'
import json, os, re, subprocess, sys

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
    deny("handbook-trigger-gate: the tool-use payload is not valid JSON.")
if not isinstance(event, dict):
    deny("handbook-trigger-gate: the tool-use payload is not a JSON object.")

tool = event.get("tool_name")
ti = event.get("tool_input")
if not isinstance(tool, str) or not tool:
    deny("handbook-trigger-gate: payload has no tool_name.")
if tool != "Bash":
    allow()  # only commit-time Bash is in scope
if not isinstance(ti, dict):
    deny("handbook-trigger-gate: payload has no tool_input object.")

command = ti.get("command")
if not isinstance(command, str) or not command.strip():
    deny("handbook-trigger-gate: Bash call has no usable command string.")

# Only a real `git commit` invocation is in scope. `git commit-tree`,
# `git commit --help`, and commit as a substring of another word are not.
if not re.search(r'\bgit\b[^\n;&|]*\bcommit\b(?!-)', command):
    allow()

cwd = os.environ.get("REFLECT_CWD", "") or "."
def git(*args):
    return subprocess.run(["git", "-C", cwd, *args], capture_output=True, text=True, timeout=15)

top = git("rev-parse", "--show-toplevel")
if top.returncode != 0 or not top.stdout.strip():
    deny("handbook-trigger-gate: could not resolve the git top-level for the commit; refusing rather than allowing an unverified commit. (%s)" % top.stderr.strip())

diff = git("diff", "--cached", "--name-only")
if diff.returncode != 0:
    deny("handbook-trigger-gate: could not read the staged change set (git diff --cached failed); refusing rather than allowing an unverified commit. (%s)" % diff.stderr.strip())

staged = [ln.strip() for ln in diff.stdout.splitlines() if ln.strip()]
if not staged:
    # Nothing staged (e.g. --amend with no new stage, or an empty commit).
    # No operational surface can have changed via this commit's stage set.
    allow()

# Operational-surface path heuristics (repo-declared list).
SURFACE_PATTERNS = [
    r'(^|/)package\.json$',
    r'(^|/)package-lock\.json$',
    r'(^|/)pnpm-lock\.yaml$',
    r'(^|/)yarn\.lock$',
    r'(^|/)pyproject\.toml$',
    r'(^|/)requirements(-[\w.]+)?\.txt$',
    r'(^|/)Pipfile(\.lock)?$',
    r'(^|/)poetry\.lock$',
    r'(^|/)go\.mod$',
    r'(^|/)go\.sum$',
    r'(^|/)Cargo\.(toml|lock)$',
    r'(^|/)Gemfile(\.lock)?$',
    r'(^|/)composer\.(json|lock)$',
    r'(^|/)Dockerfile[^/]*$',
    r'(^|/)docker-compose[^/]*\.ya?ml$',
    r'(^|/)compose\.ya?ml$',
    r'\.env(\.[\w.-]+)?(\.example|\.sample|\.template)?$',
    r'(^|/)migrations?/',
    r'(^|/)db/migrate/',
    r'(^|/)alembic/versions/',
    r'(^|/)\.github/workflows/[^/]+\.ya?ml$',
    r'(^|/)(deploy|setup|install|bootstrap|provision|start|run)[\w.-]*\.(sh|bash|ps1)$',
    r'(^|/)Makefile$',
    r'(^|/)Procfile$',
    r'(^|/)helm/', r'(^|/)charts?/',
    r'(^|/)k8s/', r'(^|/)kubernetes/',
    r'(^|/)terraform/', r'\.tf$',
]
SURFACE_RE = [re.compile(p) for p in SURFACE_PATTERNS]
HANDBOOK_RE = re.compile(r'(^|/)docs/handbooks/[^/]+\.md$')

def is_surface(p):
    return any(rx.search(p) for rx in SURFACE_RE)

surface_hits = [p for p in staged if is_surface(p)]
handbook_hits = [p for p in staged if HANDBOOK_RE.search(p)]

if surface_hits and not handbook_hits:
    deny(
        "this commit changes operational surface (%s) but does not touch any "
        "docs/handbooks/<component>.md. Per contract §21, a role that changes a component's "
        "operational surface must create or update that component's handbook in the same unit "
        "of work (same-turn-sync). Add or update the handbook, then commit."
        % ", ".join(surface_hits[:8]) + (" …" if len(surface_hits) > 8 else "")
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
