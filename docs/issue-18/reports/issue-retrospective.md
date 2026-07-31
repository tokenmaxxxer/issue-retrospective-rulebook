---
subject: issue-18
role: issue-retrospective
loop_state: round-done
---

# Retrospective record — issue #18

## What was done

Issue #18 asked this role to stop stating its own adopted methodology
(issue #12) as directive prose only, and instead build it into a
mechanical enforcement layer at the depth implementation-rulebook's own
hook machine reaches. Phase 1 produced
`docs/issue-18/reports/issue-retrospective/survey.md`,
`docs/issue-18/reports/issue-retrospective/scout-brief.md`, and
`docs/issue-18/proposals/issue-retrospective.md` (landed via a prior PR on
this branch, commit `25c6279`, then revised into a plugin-set structure
per approver FEEDBACK at commit `5a564c2`). The approver posted `APPROVE
issue-18/issue-retrospective` on the issue (single-account mode,
`JiwonJung94`), opening phase 2. Phase 2 (this session) built exactly the
plugin set the revised proposal named:

- Deepened `reflect/hooks/directive.sh`'s `use_when`/`produces` slots into
  explicit phase/step/judgment-criterion/prohibition structure (proposal
  (a)).
- Six independent gate scripts under `reflect/hooks/plugins/`:
  `timeline-order-gate.sh`, `contributing-factors-gate.sh`,
  `recurred-prediction-gate.sh`, `action-item-shape-gate.sh`,
  `freelunch-completeness-gate.sh`, `proposal-order-gate.sh` — each with
  its own fail-closed trap, its own `ISSUE_RETROSPECTIVE_<PLUGIN>_GATE_OFF`
  kill switch, and its own single-fact responsibility (proposal (b)).
  Wired into `reflect/hooks/hooks.json`'s `PreToolUse` matcher, additive to
  core's generic `record-fields-gate.sh`.
- Six matching test files under `tests/plugins/` (one per plugin, `run()`
  scaffold adapted from `implementation-rulebook/tests/run-gate-tests.sh`),
  covering each plugin's own allow/deny cases plus a foreign-path case and
  a kill-switch-independence case per plugin.
- `docs/handbooks/round-end-value-gates.md`, the two-question checklist
  proposal (d) chose over a dedicated agent (no sibling rulebook uses one
  for methodology enforcement; the round-end questions are judgment calls a
  keyword gate cannot verify).

This record is itself the first write to be checked by all six plugins,
and by `proposal-order-gate.sh` against this issue's own phase-1 proposal.

## Why

Per issue #18 and the approved (revised) proposal: issue #12's adopted
retrospective methodology lived only in `directive.sh` prose plus this
record's own quality — nothing mechanically verified a record actually
contained a Timeline before a causal claim, plural contributing factors
rather than a singular root cause, an answered recurred-prediction
question, or owned action items when claimed. The approver's FEEDBACK on
the prior single-`methodology-gate.sh` draft required a plugin-set model
specifically so that removing or replacing one methodology's check never
touches another's file or kill switch — the load-bearing difference from
pricing-rulebook's own one-script design, traded for six small files
instead of one.

## Upstream basis

- `docs/issue-18/reports/issue-retrospective/survey.md`
- `docs/issue-18/reports/issue-retrospective/scout-brief.md`
- `docs/issue-18/proposals/issue-retrospective.md` (commits `25c6279`,
  `5a564c2`)
- Issue #18 comments: approver FEEDBACK (plugin-set requirement) and
  `APPROVE issue-18/issue-retrospective`
- `docs/specs/approvers.md` (confirms `JiwonJung94` listed)
- `docs/issue-12/reports/issue-retrospective.md` and
  `docs/issue-12/proposals/issue-retrospective.md` (the record norms this
  issue enforces mechanically)
- Reference pattern only, not vendored:
  `pricing-rulebook/pricing/hooks/methodology-gate.sh`,
  `implementation-rulebook/coding/hooks/coding-progress-gate.sh`,
  `implementation-rulebook/tests/run-gate-tests.sh`
- `reflect/hooks/directive.sh`, `reflect/hooks/hooks.json` (pre- and
  post-edit, this session)

## Timeline

Reconstructed from the records above and PR/issue history only:

1. Issue #18 filed by `JiwonJung94`, asking for the adopted methodology to
   be reflected into a plugin system rather than left as directive prose.
2. Phase-1 work committed on branch `issue-18/issue-retrospective`
   (commit `25c6279`): current-state survey, scout brief, and a proposal
   for a single `methodology-gate.sh`.
3. Approver posted FEEDBACK on the open PR requiring a plugin-set model
   instead of one script; the proposal was revised (commit `5a564c2`) to
   name six independent plugins and the write-surface combinations they
   compose into.
4. Approver posted `APPROVE issue-18/issue-retrospective` on the issue —
   single-account mode, opening phase 2.
5. Phase 2 (this session): `directive.sh` deepened per-phase/per-step; six
   plugin gate scripts and six matching test files written and run green;
   `hooks.json` wired; `docs/handbooks/round-end-value-gates.md` added;
   this record written as phase 2's first act.

## Contributing factors

Not "root cause" — plural, structural conditions that shaped how this
issue unfolded:

- The generic `record-fields-gate.sh` is deliberately role-agnostic (core
  issue #66) and cannot carry retrospective-specific concepts without
  reforking it — this left a real mechanical gap between what `directive.sh`
  promised and what was actually checked, which is the gap this issue
  closes.
- The first proposal draft modeled enforcement as one script mirroring
  `methodology-gate.sh`'s literal shape; that shape does not itself compose
  well when a role owns several distinct methodologies, which only
  surfaced once the approver read the draft against issue #18's plural
  "채택 방법론 각각을" wording — the single-script shape was a plausible
  but wrong read of the issue text on the first pass.
- Six independent plugin files means six kill switches and six small
  scripts to keep in sync with `hooks.json` going forward, a maintenance
  cost the proposal named explicitly and the approver accepted as the
  trade for independence.

## What we learned

**Recurred-prediction check**: the only prior reflect record in this repo
is `docs/issue-12/reports/issue-retrospective.md`. Its own "what could
improve" section named a real prediction — that "prose-only fields in this
plugin can drift from the mechanism they describe for a full issue cycle
before anyone notices, because nothing surfaces the drift except a person
reading the file closely." Issue #18 is exactly that predicted drift
recurring: the retrospective methodology itself had been prose-only since
issue #12, and nothing mechanical caught the gap until this issue's own
filing. This is a recurred prediction, and this issue's plugin set is the
direct response to it — the fix issue #12 could not have built for itself
because no mechanism existed yet to build it with.

**What went well**: the approver's FEEDBACK loop worked as intended — a
structurally wrong first draft (one monolithic gate) was caught before
execution, not after, because phase 1 stops at a proposal and waits for
Approve. Revising the proposal in place, then re-requesting Approve,
avoided any execution-then-redo cost.

**What could improve**: the six-plugin shape trades one file for six,
which is more surface for a future change to miss one of. If a seventh
methodology fact is later adopted, the pattern is now proven and repeating
it should be cheap; whether it stays cheap at ten-plus plugins is an open
question this record flags forward rather than answers.

## Action items

None — this role is advisory-only and does not own fixing other roles'
processes. The one forward-looking note: `tests/deny-only-check.sh`'s
substance probe still targets the stale literal
`docs/issue-999/reports/reflect.md` (pre-existing, confirmed still present
and still failing before this session's changes) rather than
`issue-retrospective.md`; this is core-canon-distributed test tooling
(per the file's own header) outside this role's write scope to fix, not a
new defect introduced here.

## Open findings

None new. `loop_state: round-done` — this record concludes issue #18's
round; both round-end value gates apply (per
`docs/handbooks/round-end-value-gates.md`, itself a product of this
issue):

- **Procedure-value**: the scout-then-propose-then-approve-then-execute
  sequence, including the approver's mid-phase-1 FEEDBACK correction,
  cited its evidence chain end-to-end (survey → scout brief → proposal →
  revised proposal → six plugins + six tests + directive diff) — not
  `ritual` for this issue.
- **Blind-onboarding**: a zero-context reader can reconstruct what was
  asked (issue #18 body), what was built (the plugin set named above),
  what was decided (the approved, revised proposal's plugin-set model),
  and what is next (nothing — round-done) entirely from the records named
  in Upstream basis, with no stuck point.

**Next steps**: none for this role — `round-done` is this role's own
terminal state; no further reflect action is pending on issue #18.

**Open-finding resolution path**: the pre-existing open finding from
`docs/issue-13/reports/implementation.md` (whether
`RECORD_FIELDS_TERMINAL_STATES` set in the `SessionStart`-only subprocess
reaches the separately-invoked `PreToolUse` gate process) remains
unresolved; resolution sits with core issue #66, to be tracked there
rather than reopened here. This record's own gate interaction (writing
this file required next-steps/open-finding-resolution-path text even
under `round-done`) is additional first-hand evidence for that same open
finding, not a new one.
