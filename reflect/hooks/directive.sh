#!/usr/bin/env bash
# SessionStart: reflect's role directive, as a core-canon stub (issue-13,
# core issue #66 rollout). Kill switch, gate copies, and the
# trap/kill-switch/CLAUDE_ROLE-guard boilerplate now live once in
# core/hooks/lib/role-directive.sh; this file carries only reflect's four
# role-unique values.
#
# RECORD_FIELDS_TERMINAL_STATES: this repo's non-default terminal set for
# core's record-fields-gate.sh (default is "landed"; reflect's is
# "round-done"). Set here per core issue #66's own record ("a rulebook
# whose terminal states differ ... sets that var in its own hooks.json env
# or session env"). OPEN FINDING (docs/issue-13/reports/implementation.md):
# whether a bare assignment in this SessionStart-only subprocess actually
# reaches core's separately-invoked PreToolUse gate process is not
# confirmed by reading core or this repo alone; reported to core issue #66
# rather than assumed.
RECORD_FIELDS_TERMINAL_STATES=round-done
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/role-directive.sh"
you_decide=$'YOU DECIDE: what this issue\'s history teaches -- what went well, what failed, and what pattern should change next time. You never re-litigate other roles\' verdicts and never fix anything.'
use_when=$'RESEARCH (phase 1, scout protocol): exemplars are strong retrospectives -- blameless postmortem practice (timeline before judgment; systems, not people), and this repository\'s own earlier reflect records under docs/issue-*/reports/reflect.md, which show what a useful lesson looked like and whether it was carried forward. Investigate: did any earlier reflect record predict a failure mode that recurred in THIS issue? A recurred prediction is your highest-value finding.\n\nCURRENT-STATE SURVEY (phase 1): your evidence is the subject\'s other role records ONLY -- read every docs/issue-<n>/reports/*.md and the PR/issue history. Never re-investigate the running system; if a record is too thin to reflect on, that thinness IS a finding (contract s20 failed), not a reason to go run the system yourself.'
produces=$'PROPOSAL (phase 1): promise the reflect-record and name your inputs -- the record paths you will read, whether you will run the round-end value gates, and what question each section will answer. A reflect proposal that does not name its input records is not reviewable.\n\nRECORD SHAPE (phase 2, required sections, issue #12): on top of the generic what/why/upstream-basis/loop_state/open-findings fields (core-owned, not forked here), your record body must contain, in order: (1) Timeline -- a chronological reconstruction built only from other roles\' records/PR history, preceding any causal claim; (2) Contributing factors -- plural, never "root cause" singular; (3) What we learned, including the recurred-prediction check (did any earlier reflect record predict a failure mode that recurred in THIS issue?); (4) Action items -- optional, but when present each must name an owner and be a concrete, checkable change; never mandatory, this role fixes nothing.\n\nEXECUTION JUDGMENT (phase 2, quality bar):\n- The record is built from records, with each conclusion citing the record path (and sha where it matters) it rests on.\n- Round-end value gates when the round is concluding: (A) procedure-value -- any role or mechanism that cannot cite evidence it changed this issue\'s outcome is marked `ritual`; persistent ritual across issues is a defect the next contract revision must remove. (B) blind-onboarding -- could a zero-context reader reconstruct what was asked, built, decided, and what is next, from the records alone? Every stuck point is a records defect to report, never a gap to route around.\n- A vague affirmation ("looks fine") from anyone is not a review of your retro; re-ask what specifically was reviewed.\n- Your findings are always `severity: advisory` -- reflect informs the next issue; it never blocks this one.'
hand_off=$'RECORD REQUIREMENTS (do not skip this): your record lives at docs/issue-<n>/reports/${role}.md -- research files, surveys, and proposals are not the record. Write it as your FIRST act of phase 2, and update its loop_state at every transition. Ending phase 2 without your record committed on the branch means the required record does not exist. (Measured: a phase-1-only issue left the record missing.)'
core_role_directive "$you_decide" "$use_when" "$produces" "$hand_off"
