# tokenmaxxxer / reflect-agent-rulebook

The `issue-retrospective` role on contract v3. A session is spawned with
two plugin sets installed: this marketplace's six `issue-retrospective`
gate plugins, and the
[tokenmaxxxer-core](https://github.com/tokenmaxxxer/tokenmaxxxer-core)
plugins (`core`, `terse`, `freelunch`, `scout`). Core owns the interaction
protocol — issue in, two-phase PR out (research/survey/proposal → human
review Approve → execution), branch `issue-<n>/issue-retrospective`,
record at `docs/issue-<n>/reports/issue-retrospective.md`. This rulebook
owns only what is role-specific: how the role fills each lifecycle stage,
and the methodology gates that enforce the quality bar on its record.

## What `issue-retrospective` decides

What this issue's history teaches — what went well, what failed, and what
pattern should change next time — built from the subject's other role
records only, never from fresh re-investigation of the running system.
Findings are always `severity: advisory`: this role informs the next
issue; it never blocks this one.

## What is here

Six independent top-level plugin directories, each a single-methodology
`PreToolUse` gate (issue #18 plugin-set design) plus its own test file:

    timeline-order-gate/hooks/timeline-order-gate.sh
    contributing-factors-gate/hooks/contributing-factors-gate.sh
    recurred-prediction-gate/hooks/recurred-prediction-gate.sh
    action-item-shape-gate/hooks/action-item-shape-gate.sh
    freelunch-completeness-gate/hooks/freelunch-completeness-gate.sh
    proposal-order-gate/hooks/proposal-order-gate.sh

Each plugin has a matching `hooks/<name>-tests.sh`. Each gate is additive
to (never replaces) core's generic `record-fields-gate.sh`, and each
guards a specific methodology requirement on the record body:

- **timeline-order-gate** — the record's Timeline section must exist and
  precede any causal-claim language ("contributing factor(s)"/"root
  cause").
- **contributing-factors-gate** — a "Contributing factors" section must
  exist and contain plural, structural factor language; "root cause"
  (singular attribution) anywhere in the document without co-occurring
  in-section factors language is a violation.
- **recurred-prediction-gate** — the "What we learned" section must
  answer whether an earlier `issue-retrospective` record predicted a
  failure mode that recurred in this issue, including the explicit "no
  earlier record existed" case.
- **action-item-shape-gate** — action items are optional, but when
  present each must name an owner (a person/role, not "the team") and be
  a concrete, checkable change.
- **freelunch-completeness-gate** — inputs-read paths named, a synthesis
  section distinct from raw paste, and an adopted-norms-with-rationale
  section; wired into both the proposal and the record write surfaces.
- **proposal-order-gate** — guards the phase-2 record write by reading
  the subject's own phase-1 proposal off disk and requiring it to name a
  survey path plus either a scout-brief path or an explicit scout-skip
  statement (phase-1-before-phase-2, contract v3 s19).

Write surfaces: `docs/issue-<n>/reports/issue-retrospective.md` for all
six (the 산출물/record surface); `freelunch-completeness-gate` also
covers `docs/issue-<n>/proposals/*issue-retrospective*.md` (the 기획서/
proposal surface).

Additionally:

    reflect/hooks/directive.sh          SessionStart -- a core-canon stub
                                        (sources core/hooks/lib/role-directive.sh)
                                        carrying the role's four facets:
                                        research (exemplar retros; recurred
                                        predictions), survey (records-only),
                                        proposal (named inputs), judgment
                                        (round-end value gates, advisory-only)

## Kill switches

Each plugin has its own independent kill switch — no shared switch:

    ISSUE_RETROSPECTIVE_TIMELINE_ORDER_GATE_OFF=1
    ISSUE_RETROSPECTIVE_CONTRIBUTING_FACTORS_GATE_OFF=1
    ISSUE_RETROSPECTIVE_RECURRED_PREDICTION_GATE_OFF=1
    ISSUE_RETROSPECTIVE_ACTION_ITEM_SHAPE_GATE_OFF=1
    ISSUE_RETROSPECTIVE_FREELUNCH_COMPLETENESS_GATE_OFF=1
    ISSUE_RETROSPECTIVE_PROPOSAL_ORDER_GATE_OFF=1

## Implementation pattern

All six gates source `core/hooks/lib/gate-lib.sh` (bash side: fail-closed
trap, kill switch, path normalization) and load `core/hooks/lib/gate-lib.py`
via `importlib` in their Python payloads (JSON parsing, deny, and
Edit/MultiEdit write reconstruction) instead of hand-rolling that
machinery. This is canon-reference, not vendoring: no plugin keeps its own
copy of `gate-lib.sh`/`gate-lib.py` — each sources/imports the copy
installed by `core`.

## Record vocabulary

`loop_state`: `idle, reflecting, candidate-round-done, round-done`
(terminal: `round-done`, set only after the round-end value gates run —
contract s18). The record must always carry a non-empty pointer to the
role records it read.

## Install

    claude plugin marketplace add tokenmaxxxer/reflect-agent-rulebook
    claude plugin install timeline-order-gate@tokenmaxxxer-reflect
    claude plugin install contributing-factors-gate@tokenmaxxxer-reflect
    claude plugin install recurred-prediction-gate@tokenmaxxxer-reflect
    claude plugin install action-item-shape-gate@tokenmaxxxer-reflect
    claude plugin install freelunch-completeness-gate@tokenmaxxxer-reflect
    claude plugin install proposal-order-gate@tokenmaxxxer-reflect
    claude plugin install reflect@tokenmaxxxer-reflect

## Run the checks

Each plugin's own test suite:

    bash timeline-order-gate/hooks/timeline-order-gate-tests.sh
    bash contributing-factors-gate/hooks/contributing-factors-gate-tests.sh
    bash recurred-prediction-gate/hooks/recurred-prediction-gate-tests.sh
    bash action-item-shape-gate/hooks/action-item-shape-gate-tests.sh
    bash freelunch-completeness-gate/hooks/freelunch-completeness-gate-tests.sh
    bash proposal-order-gate/hooks/proposal-order-gate-tests.sh
