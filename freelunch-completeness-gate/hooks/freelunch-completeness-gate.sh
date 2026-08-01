#!/usr/bin/env bash
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh"
gate_trap_fail_closed
# PreToolUse gate (Write|Edit|MultiEdit) -- one plugin, one methodology
# (issue #18 plugin-set design; adapted from
# pricing-rulebook/pricing/hooks/methodology-gate.sh's technique).
#
# Owns: freelunch completeness (기획서/산출물 공통 "완성도" methodology) --
# inputs-read paths named, a synthesis section distinct from raw paste, and
# an adopted-norms-with-rationale section. Wired into BOTH the 기획서
# (proposal) and 산출물 (record) write-surface combinations (issue #18
# proposal (b)), not duplicated as ad-hoc checks inside each surface.
#
# Write surfaces: docs/issue-<n>/proposals/*issue-retrospective*.md AND
# docs/issue-<n>/reports/issue-retrospective.md. Additive to (never
# replacing) core's generic record-fields-gate.sh.
#
# Kill switch: export ISSUE_RETROSPECTIVE_FREELUNCH_COMPLETENESS_GATE_OFF=1
set -uo pipefail

role="${CLAUDE_ROLE:-reflect}"
deny() { gate_deny "$role" "$1"; }

gate_kill_switch_active "${ISSUE_RETROSPECTIVE_FREELUNCH_COMPLETENESS_GATE_OFF:-}" || { trap - EXIT; exit 0; }

command -v python3 >/dev/null 2>&1 || deny "freelunch-completeness-gate.sh requires python3, which is not on PATH; denying rather than guessing."

payload="$(cat 2>/dev/null || true)"
[ -n "$payload" ] || deny "freelunch-completeness-gate: empty tool-use payload on stdin; cannot evaluate the gate."

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
[ -z "$root" ] && deny "no project root could be determined; failing closed (freelunch-completeness check cannot run)."

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
        deny("tool_input is missing or not a JSON object; the gate cannot judge a write it cannot parse (freelunch completeness).")

    root = os.environ["PG_ROOT"]
    PROPOSAL_RE = re.compile(r'^docs/issue-[0-9]+/proposals/.*issue-retrospective.*\.md$', re.I)
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
    is_proposal = bool(PROPOSAL_RE.match(rel))
    is_record = bool(RECORD_RE.match(rel))
    if not (is_proposal or is_record):
        sys.exit(0)  # not a freelunch-completeness write surface — not this plugin's business

    r = os.path.join(root, rel)
    current = None
    if os.path.isfile(r):
        try:
            with open(r, encoding="utf-8-sig") as fh:
                current = fh.read(1 << 20)
        except OSError:
            deny("%s exists but cannot be read; failing closed on freelunch completeness." % rel)

    new_text, ok = gate_lib.gate_reconstruct_write(tool, ti, current)
    if not ok:
        deny(
            "this write targets %s but the gate cannot determine the resulting content "
            "from the tool input (tool=%r). Write the full document with Write, or use an "
            "Edit/MultiEdit whose old_string matches, so freelunch completeness can be "
            "checked." % (rel, tool)
        )

    low = new_text.lower()

    def has_any(*needles):
        return any(nd in low for nd in needles)

    missing = []

    # 1. Inputs-read paths named -- an explicit "inputs read" heading, or at
    #    least two docs/issue-<n>/... path-like tokens actually named.
    inputs_named = bool(re.search(r'(?im)^\s*#{1,6}\s*inputs read\b', new_text)) or \
        len(re.findall(r'docs/issue-\d+/(?:reports|proposals)/', new_text)) >= 2
    if not inputs_named:
        missing.append("inputs-read")

    # 2. Synthesis section distinct from raw paste -- a heading naming
    #    findings/synthesis/why, separate from a bare "Upstream basis" list.
    synthesis_present = bool(re.search(
        r'(?im)^\s*#{1,6}\s*(what the survey|synthesis|why)\b', new_text
    ))
    if not synthesis_present:
        missing.append("synthesis-section")

    # 3. Adopted-norms-with-rationale -- "adopted" must appear within a
    #    small line-window of rationale language (issue #21: this was
    #    body-wide co-occurrence-anywhere before, which let "adopted" near
    #    the top and a stray "because" near the bottom, in an unrelated
    #    paragraph, launder the check; now require adjacency).
    RATIONALE_MARKERS = ("rationale", "per issue", "per the", "per approver", "because", "traced to")
    lines = new_text.lower().split("\n")
    adopted_with_rationale = False
    for i, ln in enumerate(lines):
        if "adopted" not in ln:
            continue
        lo = max(0, i - 3)
        hi = min(len(lines), i + 4)
        window = "\n".join(lines[lo:hi])
        if any(marker in window for marker in RATIONALE_MARKERS):
            adopted_with_rationale = True
            break
    if not adopted_with_rationale:
        missing.append("adopted-norms-with-rationale")

    if missing:
        surface = "phase-1 proposal" if is_proposal else "phase-2 record"
        deny(
            "this reflect %s at %s is missing required freelunch-completeness "
            "element(s): %s. Per issue #18's plugin-set design, every 기획서/산출물 "
            "must name its input record paths, carry a synthesis section distinct "
            "from raw paste, and state adopted norms with sourced rationale." %
            (surface, rel, ", ".join(missing))
        )

    sys.exit(0)
except Exception as _fc_e:  # fail-closed-on-internal-error
    _fc_sys.stderr.write("freelunch-completeness-gate.sh: fail-closed: internal error: %r\n" % (_fc_e,))
    _fc_sys.exit(2)
PY
_fc_rc=$?  # fail-closed-on-internal-error
if [ "$_fc_rc" -ne 0 ] && [ "$_fc_rc" -ne 2 ]; then
  echo "freelunch-completeness-gate.sh: fail-closed: internal error (judge exited $_fc_rc)" >&2
  exit 2
fi
exit "$_fc_rc"
