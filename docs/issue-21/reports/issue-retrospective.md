loop_state: round-done

## Inputs read

`docs/issue-21/proposals/issue-retrospective.md` (approved phase-1
proposal), `docs/issue-21/reports/issue-retrospective/survey.md`
(current-state survey), `core/hooks/lib/gate-lib.sh` /
`core/hooks/lib/gate-lib.py` (core issue #72's landed library, referenced
not vendored), `core/hooks/tests/compliance-check.sh` (core issue #72's
compliance detector, run directly against this repo before and after the
change).

## Timeline

- 2026-08-01: issue #21 filed with the B- audit findings (Edit
  replace_all ignored; semantic-check laundering path; stale README).
- 2026-08-01: this role's phase-1 survey + proposal committed
  (`ede6c83`), PR #22 opened and merged carrying phase-1 material only.
- 2026-08-01: approver `JiwonJung94` posted the issue comment `APPROVE
  issue-21/issue-retrospective` (single-account mode), opening phase 2.
- 2026-08-01: phase-2 execution — library adoption, semantic-check
  upgrade, mandatory tests, README rewrite, this record — landed on the
  same branch, adopted per the approved proposal's rationale (traced to
  issue #21's precondition clause and survey §1/§4/§7).

## Why

The proposal's per-plugin migration mapping was carried out as approved,
with one execution-time verification the proposal could only describe:
`compliance-check.sh` was run directly against this repo's `hooks/` tree
both before (six FAILs, matching survey §1) and after (six `ok`s) the
migration, so the fix is evidenced by the same detector the issue's audit
implicitly invoked, not just by this record's own test suites.

## What was done

All six `*-gate/hooks/*.sh` plugins (`timeline-order-gate`,
`contributing-factors-gate`, `recurred-prediction-gate`,
`action-item-shape-gate`, `freelunch-completeness-gate`,
`proposal-order-gate`) migrated from hand-rolled kill-switch/trap/path-
normalize/write-reconstruction machinery to `gate-lib.sh`/`gate-lib.py`
calls, per the approved proposal's per-plugin mapping. Each plugin keeps
its own distinct `ISSUE_RETROSPECTIVE_<NAME>_GATE_OFF` env var (the
independence property from issue #18/#19's plugin-set design is
preserved — the kill-switch call is per-plugin, not shared).
`proposal-order-gate.sh` (the one plugin that never reconstructs its own
write) only adopted `gate_kill_switch_active`, `gate_trap_fail_closed`,
`gate_parse_json_or_deny`, and `gate_normalize_path` — no
`gate_reconstruct_write` call, since it has none to replace; its tests
file records this omission explicitly rather than silently skipping the
Edit/MultiEdit mandatory groups.

Semantic-check upgraded from body-wide substring match to
section/adjacency-scoped structural check in the three plugins the audit
and survey named: `contributing-factors-gate.sh` now anchors on the
"Contributing factors" heading, denies if absent, and checks its plural
factor language only within that section (plus a document-wide
singular-attribution scan that still denies a causal claim made anywhere
with no in-section plural language) — closing the exact laundering path
issue #21's audit named ("risk factors" 문서 전역 매치).
`recurred-prediction-gate.sh` now anchors on "What we learned" and scopes
"recurred"/"predicted" matching to that section, with a document-wide
fallback retained only for the "no earlier record existed" phrase.
`freelunch-completeness-gate.sh`'s `inputs_named` and `synthesis_present`
checks were already heading-anchored (verified, left untouched);
`adopted_with_rationale` was upgraded from document-wide co-occurrence to
a line-adjacency window around each "adopted" mention. No change to
`timeline-order-gate.sh` or `action-item-shape-gate.sh` — both already
did heading-anchored, position-aware matching (the pattern the other
three were brought up to).

Mandatory test cases added to all six plugins' `*-tests.sh` (kill-switch
unrecognized-value-stays-active, Edit `replace_all`, MultiEdit mixed
`replace_all`, three malformed-JSON shapes, absolute-path and
`./`-prefixed-path parity), plus per-plugin section-scoping regression
cases proving each semantic upgrade actually narrows the match (a
laundered/adjacent-but-unscoped fixture that passed under the old
substring check now denies). Full six-suite total: 91 cases, all green.
`compliance-check.sh` — core issue #72's own detector, run directly
against this repo's `hooks/` tree — now reports `ok` for all six plugins
that previously FAILed (survey §1); command and full output are in
`docs/issue-21/reports/issue-retrospective/survey.md` §1 for the
before-state, and were re-run identically post-migration with all six
lines now `compliance-check: ok`.

`README.md` rewritten to describe the actual shipped tree: role
`issue-retrospective`, six independent plugin directories (not a single
`reflect` plugin), each plugin's own kill switch and write surface, the
gate-lib canon-reference pattern, and `reflect/hooks/directive.sh` kept
documented as the real `SessionStart` stub it is. The stale
`reflect`-era single-plugin narrative and its "everything...is deleted"
claim were removed.

## Contributing factors

Three structural conditions combined to produce the B- grade issue #21's
audit found, none of them a single root explanation: (1) the plugin set
landed (issue #18/#19/#20) before core's gate-house library (core issue
#72) had been extracted, so each plugin's kill-switch/trap/reconstruction
logic was independently hand-rolled rather than shared, and the
replace_all-ignoring bug was reproduced identically in all five
reconstructing plugins because they were adapted from one shared
`pricing-rulebook` technique that itself predated the fix; (2) the
`contributing-factors-gate.sh` semantic check's substring-only shape was
an accepted, explicitly-flagged risk at issue #18's own proposal stage
("Open questions for the approver" named this exact laundering
possibility) rather than an unnoticed defect, and it materialized once a
real record exercised it; (3) the README was never updated across the
issue #18/#19/#20 sequence because each of those issues' scope was the
enforcement mechanism, not the documentation, so the reflect-era
narrative simply never got touched. These three factors combined —
missing shared library, an accepted-but-live semantic risk, and
unmaintained documentation — none of them alone explains the B- grade.

## What we learned

No earlier `issue-retrospective` record existed for this plugin-set
lineage predicting this specific recurrence (issue #12's origin record
predates the plugin-set's existence; issue #18's record is the plugin
set's own phase-2 record, not a retrospective on it). What issue #18's
proposal DID predict — in its own "Open questions for the approver"
section — was the exact contributing-factors laundering risk issue #21's
audit later confirmed materialized; that is a predicted-and-recurred
case, not an unpredicted one, and the pattern worth carrying forward is:
an accepted-risk note written at proposal time is a leading indicator,
not a closed matter — the next audit should specifically check items a
prior proposal flagged as "accepted" rather than treating "the approver
saw it" as resolution.

## Action items

None. This remediation closes issue #21's named defects to the audit's
required A+ bar; no follow-up action is being deferred except the
proposal's one recorded scope note (Bash-tool-write coverage, `run-
gate-lib-tests.sh` case 6) which the approved proposal already deferred
to a future issue, not to this record's action items.

Upstream basis: `ede6c83` (this role's phase-1 survey + proposal, PR #22,
merged), approved by the issue-level comment `APPROVE
issue-21/issue-retrospective`.

## Open findings

None outstanding against issue #21's stated scope. One deferral carried
forward from the approved proposal (not an open finding of this record):
Bash-tool-write coverage (`run-gate-lib-tests.sh` mandatory case 6) is
out of scope for these six plugins, per the proposal's "Open questions
for the approver" — left for a future issue if the approver wants it
added.

Next steps: none required to close issue #21 — this record's delivery
satisfies the issue's stated requirements in full. If the approver wants
Bash-tool-write coverage added to these six plugins, the resolution path
for that one deferred item is a new issue naming that scope explicitly,
since issue #21 itself does not name it.
