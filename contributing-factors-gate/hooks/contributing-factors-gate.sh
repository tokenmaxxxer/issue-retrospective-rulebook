#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "contributing-factors-gate.sh: cannot source gate-lib.sh" >&2; exit 2; }
gate_trap_fail_closed
# PreToolUse gate (Write|Edit|MultiEdit) -- one plugin, one methodology
# (issue #18 plugin-set design; adapted from
# pricing-rulebook/pricing/hooks/methodology-gate.sh's technique).
#
# Owns: plural structural causation, no singular attribution. A issue-retrospective
# record must name "contributing factor(s)"/"factors" inside its
# "Contributing factors" section; the phrase "root cause" (singular
# attribution) anywhere in the document without co-occurring in-section
# factors language is a methodology violation, not a style nit. Section-
# scoped (issue #21): a bare mention of "factors" elsewhere in the
# document (outside the section) no longer satisfies this check.
#
# Write surface: docs/issue-<n>/reports/issue-retrospective.md only (the
# 산출물/record surface). Additive to (never replacing) core's generic
# record-fields-gate.sh.
#
# Kill switch: export ISSUE_RETROSPECTIVE_CONTRIBUTING_FACTORS_GATE_OFF=1
set -uo pipefail

role="${CLAUDE_ROLE:-issue-retrospective}"
deny() { gate_deny "$role" "$1"; }

gate_kill_switch_active "${ISSUE_RETROSPECTIVE_CONTRIBUTING_FACTORS_GATE_OFF:-}" || { trap - EXIT; exit 0; }

command -v python3 >/dev/null 2>&1 || deny "contributing-factors-gate.sh requires python3, which is not on PATH; denying rather than guessing."

payload="$(cat 2>/dev/null || true)"
[ -n "$payload" ] || deny "contributing-factors-gate: empty tool-use payload on stdin; cannot evaluate the gate."

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
[ -z "$root" ] && deny "no project root could be determined; failing closed (contributing-factors check cannot run)."

PG_PAYLOAD="$payload" PG_ROOT="$root" \
python3 <<'PY'
import sys as _fc_sys  # fail-closed-on-internal-error
try:
    import json, os, re, sys, importlib.util

    _spec = importlib.util.spec_from_file_location("gate_lib", os.environ["GATE_LIB_PY"])
    gate_lib = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(gate_lib)

    def deny(m):
        sys.stderr.write("issue-retrospective: refused — %s\n" % m); sys.exit(2)

    raw = os.environ.get("PG_PAYLOAD", "")
    ev = gate_lib.gate_parse_json_or_deny(raw, deny)

    tool = ev.get("tool_name")
    ti = ev.get("tool_input")
    if not isinstance(ti, dict):
        deny("tool_input is missing or not a JSON object; the gate cannot judge a write it cannot parse (contributing-factors).")

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
            deny("%s exists but cannot be read; failing closed on contributing-factors phrasing." % rel)

    new_text, ok = gate_lib.gate_reconstruct_write(tool, ti, current)
    if not ok:
        deny(
            "this write targets %s but the gate cannot determine the resulting content "
            "from the tool input (tool=%r). Write the full document with Write, or use an "
            "Edit/MultiEdit whose old_string matches, so contributing-factors phrasing can "
            "be checked." % (rel, tool)
        )

    # Section-scoped (issue #21): anchor on the "Contributing factors"
    # heading and check only that section's body — a stray mention of
    # "factors" elsewhere in the document no longer satisfies this check.
    m = re.search(r'(?im)^\s*#{1,6}\s*contributing factors?\b', new_text)
    if not m:
        deny(
            "issue-retrospective record at %s has no 'Contributing factors' section. Per "
            "issue #12's record norm, the record body must contain a plural, "
            "structural Contributing factors section." % rel
        )
    rest = new_text[m.end():]
    next_heading = re.search(r'(?m)^\s*#{1,6}\s', rest)
    section = rest[: next_heading.start()] if next_heading else rest
    low_section = section.lower()
    has_factors = bool(re.search(r'\bcontributing factors?\b|\bfactors\b', low_section))

    if not has_factors:
        deny(
            "issue-retrospective record at %s has a 'Contributing factors' section that names no "
            "'contributing factor(s)'/'factors' language in its own body. Per issue "
            "#12's record norm, the section itself must carry plural, structural "
            "causation language, not just its heading." % rel
        )

    # A causal claim made ANYWHERE in the document (not only inside the
    # section) is still caught if the section has no in-section factors
    # language nearby -- closes the laundering path where "root cause" sits
    # outside the section entirely.
    has_root_cause = "root cause" in new_text.lower()
    if has_root_cause and not has_factors:
        deny(
            "issue-retrospective record at %s uses 'root cause' (singular attribution) without "
            "'contributing factor(s)'/'factors' language in its Contributing factors "
            "section. Per issue #12's record norm, causation must be plural and "
            "structural, never a single root cause." % rel
        )

    sys.exit(0)
except Exception as _fc_e:  # fail-closed-on-internal-error
    _fc_sys.stderr.write("contributing-factors-gate.sh: fail-closed: internal error: %r\n" % (_fc_e,))
    _fc_sys.exit(2)
PY
_fc_rc=$?  # fail-closed-on-internal-error
if [ "$_fc_rc" -ne 0 ] && [ "$_fc_rc" -ne 2 ]; then
  echo "contributing-factors-gate.sh: fail-closed: internal error (judge exited $_fc_rc)" >&2
  exit 2
fi
exit "$_fc_rc"
