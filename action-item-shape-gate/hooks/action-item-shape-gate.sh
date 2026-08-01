#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "action-item-shape-gate.sh: cannot source gate-lib.sh" >&2; exit 2; }
gate_trap_fail_closed
# PreToolUse gate (Write|Edit|MultiEdit) -- one plugin, one methodology
# (issue #18 plugin-set design; adapted from
# pricing-rulebook/pricing/hooks/methodology-gate.sh's technique).
#
# Owns: action items, when claimed, are owned + checkable. Action items are
# optional (this role fixes nothing); when a non-"none" action-items
# section exists, each item must name an owner (a person/role, not "the
# team") and be phrased as a concrete, checkable change.
#
# Write surface: docs/issue-<n>/reports/issue-retrospective.md only (the
# 산출물/record surface). Additive to (never replacing) core's generic
# record-fields-gate.sh.
#
# Kill switch: export ISSUE_RETROSPECTIVE_ACTION_ITEM_SHAPE_GATE_OFF=1
set -uo pipefail

role="${CLAUDE_ROLE:-reflect}"
deny() { gate_deny "$role" "$1"; }

gate_kill_switch_active "${ISSUE_RETROSPECTIVE_ACTION_ITEM_SHAPE_GATE_OFF:-}" || { trap - EXIT; exit 0; }

command -v python3 >/dev/null 2>&1 || deny "action-item-shape-gate.sh requires python3, which is not on PATH; denying rather than guessing."

payload="$(cat 2>/dev/null || true)"
[ -n "$payload" ] || deny "action-item-shape-gate: empty tool-use payload on stdin; cannot evaluate the gate."

_target="$(printf '%s' "$payload" | python3 -c '
import json,sys
try: e=json.loads(sys.stdin.read())
except Exception: sys.exit(0)
ti=e.get("tool_input") if isinstance(e,dict) else None
if isinstance(ti,dict):
    for k in ("file_path","notebook_path"):
        v=ti.get(k)
        if isinstance(v,str) and v: print(v); break
' 2>/dev/null || true)"

_plausible() { [ -n "$1" ] && [ -d "$1" ] && { [ -e "$1/.git" ] || [ -f "$1/docs/specs/role-handoff-contract.md" ]; }; }
_under() {
  [ -z "$2" ] && return 0
  python3 -c '
import os,posixpath,sys
r,t=sys.argv[1],sys.argv[2]
try: rr=posixpath.normpath(os.path.realpath(r).replace("\\","/"))
except Exception: sys.exit(1)
n=t.replace("\\","/"); a=n if posixpath.isabs(n) else posixpath.join(rr,n)
a=posixpath.normpath(a); real=posixpath.normpath(os.path.realpath(a).replace("\\","/"))
sys.exit(0 if (real==rr or real.startswith(rr+"/")) else 1)
' "$1" "$2"
}

root=""
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && _plausible "$CLAUDE_PROJECT_DIR" && _under "$CLAUDE_PROJECT_DIR" "$_target"; then
  root="$(cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && pwd -P)"
fi
if [ -z "$root" ]; then
  d="$_target"; [ -n "$d" ] || d="$(pwd -P)"; [ -d "$d" ] || d="$(dirname "$d")"
  root="$(git -C "$d" rev-parse --show-toplevel 2>/dev/null || true)"
fi
[ -z "$root" ] && root="$(git -C "$(pwd -P)" rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && deny "no project root could be determined; failing closed (action-item-shape check cannot run)."

PG_PAYLOAD="$payload" PG_ROOT="$root" \
python3 <<'PY'
import sys as _fc_sys  # fail-closed-on-internal-error
try:
    import json, os, re, sys, importlib.util

    _spec = importlib.util.spec_from_file_location("gate_lib", os.environ["GATE_LIB_PY"])
    gate_lib = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(gate_lib)

    def deny(m):
        sys.stderr.write("reflect: refused — %s\n" % m); sys.exit(2)

    raw = os.environ.get("PG_PAYLOAD", "")
    ev = gate_lib.gate_parse_json_or_deny(raw, deny)

    tool = ev.get("tool_name")
    ti = ev.get("tool_input")
    if not isinstance(ti, dict):
        deny("tool_input is missing or not a JSON object; the gate cannot judge a write it cannot parse (action-item shape).")

    root = os.environ["PG_ROOT"]
    RECORD_RE = re.compile(r'^docs/issue-[0-9]+/reports/issue-retrospective\.md$')

    path = None
    if tool in ("Write", "Edit", "MultiEdit"):
        p = ti.get("file_path")
        if isinstance(p, str) and p:
            path = p
    if path is None:
        sys.exit(0)

    rel = gate_lib.gate_normalize_path(root, path)
    if rel is None:
        sys.exit(0)
    if not RECORD_RE.match(rel):
        sys.exit(0)  # not the record write surface — not this plugin's business

    r = os.path.join(root, rel)

    current = None
    if os.path.isfile(r):
        try:
            with open(r, encoding="utf-8-sig") as fh:
                current = fh.read(1 << 20)
        except OSError:
            deny("%s exists but cannot be read; failing closed on action-item shape." % rel)

    new_text, ok = gate_lib.gate_reconstruct_write(tool, ti, current)
    if not ok:
        deny(
            "this write targets %s but the gate cannot determine the resulting content "
            "from the tool input (tool=%r). Write the full document with Write, or use an "
            "Edit/MultiEdit whose old_string matches, so action-item shape can be "
            "checked." % (rel, tool)
        )

    m = re.search(r'(?im)^\s*#{1,6}\s*action items\b', new_text)
    if not m:
        # No "Action items" section at all is not this plugin's business --
        # the generic section-presence norm is a different facet; action
        # items are explicitly optional (issue #12).
        sys.exit(0)

    rest = new_text[m.end():]
    next_heading = re.search(r'(?m)^\s*#{1,6}\s', rest)
    section = rest[: next_heading.start()] if next_heading else rest
    low = section.lower()

    if re.search(r'\bnone\b|\bno action items\b', low):
        sys.exit(0)  # explicit "none" — allow, no further checks fire

    if not section.strip():
        sys.exit(0)  # empty section body, nothing to judge as mis-shaped

    if "owner" not in low:
        deny(
            "reflect record at %s has a non-empty 'Action items' section with no "
            "'owner' naming a person/role. Per issue #12's record norm, when action "
            "items are present each must name an owner (not \"the team\") and be a "
            "concrete, checkable change." % rel
        )

    sys.exit(0)
except Exception as _fc_e:  # fail-closed-on-internal-error
    _fc_sys.stderr.write("action-item-shape-gate.sh: fail-closed: internal error: %r\n" % (_fc_e,))
    _fc_sys.exit(2)
PY
_fc_rc=$?  # fail-closed-on-internal-error
if [ "$_fc_rc" -ne 0 ] && [ "$_fc_rc" -ne 2 ]; then
  echo "action-item-shape-gate.sh: fail-closed: internal error (judge exited $_fc_rc)" >&2
  exit 2
fi
exit "$_fc_rc"
