# Current-state survey — issue-31 (align rulebook with issue-retrospective.spec.json)

Subject: on-the-record marketplace spec `roles/specs/issue-retrospective.spec.json`
(read from `/home/jwjung/.claude/plugins/marketplaces/tokenmaxxxer/roles/specs/issue-retrospective.spec.json`,
this repo carries no local copy) vs. this rulebook's current docs/hooks.

## Spec content (verbatim facts)

- `required_fields`: `retro_id` (ref), `timeline` (string), `impact_summary`
  (string), `action_items` (ref[]) — all `required: true`.
- `reference_resolution`: action_items must each resolve to an actual
  tracked issue (issue-515 invariant 2); checked by
  `on-the-record/hooks/role-spec-reference-guard.sh` (lives outside this
  repo).
- `recomputation`: action_items is recomputed from timeline evidence,
  never pre-filled; blame language directed at a person is refused at
  write time. `checked_by: TBD` (explicit follow-up, out of scope per the
  spec itself).
- `write_scope`: `docs/issue-<n>/reports/issue-retrospective.md` — matches
  this rulebook's existing record path exactly.
- `loop_state`: progress = `gathering`, `writing`; terminal = `landed`;
  refusal = `blame-language-detected`; error = `timeline-unreachable`.
- `use_when`: a non-incident issue closes AND no issue-retrospective
  record exists yet.

## What this rulebook currently has

Record section order (from `issue-retrospective/hooks/directive.sh`
`produces`, confirmed against real records `docs/issue-27/reports/issue-retrospective.md`,
`docs/issue-24/reports/issue-retrospective.md`):
`Inputs read → Why → Timeline → Contributing factors → What we learned →
Adopted norms + rationale → Action items → Round-end value gates → Open
findings`.

Field-by-field match against the spec:

- **timeline** — present. `Timeline` is a required section, gated by
  `timeline-order-gate/hooks/timeline-order-gate.sh` (must exist, must
  precede causal-claim language).
- **action_items** — present as a section, gated by
  `action-item-shape-gate/hooks/action-item-shape-gate.sh`, but the
  directive text explicitly says action items are "optional... never
  mandatory". The spec marks `action_items` `required: true`. This is a
  direct optionality conflict, not a naming gap.
  - No gate anywhere in this repo checks reference resolution (action
    items resolving to actual tracked issues) — `role-spec-reference-guard.sh`
    is named in the spec as living in `on-the-record`, outside this
    rulebook's write scope.
- **retro_id** — absent. No section, gate, or directive text names a
  `retro_id` concept. The closest existing anchor is the record's own
  file path (`docs/issue-<n>/reports/issue-retrospective.md`, i.e. the
  subject issue number `n`) and the mandatory `Subject: issue-<n>` commit
  trailer (core contract v3 s13) — both already uniquely identify which
  issue a retro is "of", but neither is currently *named* `retro_id` or
  presented as a record field.
- **impact_summary** — absent. No section or gate covers a
  blast-radius/impact statement. `Why` (present in real records, not
  gated) partially overlaps in spirit but answers "why this retro is
  being written," not "what impact did the issue have."

Loop-state vocabulary match:

- Current: `RECORD_FIELDS_TERMINAL_STATES=round-done` (set in
  `directive.sh`), i.e. this repo's terminal state is literally the
  string `round-done`. The directive's `produces`/`hand_off` text tells
  the role to "update loop_state at every transition" but names no
  concrete progress/refusal/error states anywhere.
- Spec: terminal = `landed`, progress = `gathering`/`writing`, refusal =
  `blame-language-detected`, error = `timeline-unreachable`.
- Mismatch: the terminal state string differs (`round-done` vs
  `landed`), and this repo has zero progress/refusal/error states
  defined at all — a full vocabulary gap, not just a naming gap.
- `contributing-factors-gate.sh` bans singular "root cause" attribution
  (structural-plural framing) but does not check for language directed
  *at a person* — the spec's `blame-language-detected` refusal state
  targets a narrower, different thing (personal blame, not
  singular-vs-plural causation). No existing gate checks for
  person-directed blame language.

## Six independent gate plugins (unchanged by this survey, for reference)

`timeline-order-gate`, `contributing-factors-gate`,
`recurred-prediction-gate`, `action-item-shape-gate`,
`freelunch-completeness-gate`, `proposal-order-gate` — all PreToolUse,
all additive to core's generic `record-fields-gate.sh`, all scoped to
`docs/issue-<n>/reports/issue-retrospective.md` (write surface matches
spec's `write_scope` exactly already).

## Write set this proposal expects to touch (phase 2)

- `issue-retrospective/hooks/directive.sh` — add `retro_id` and
  `impact_summary` to the required record-section list; state
  `action_items` is now spec-required (not optional) while keeping the
  advisory-only/never-blocking role posture for its *content*; rename the
  terminal loop_state and add the missing progress/refusal/error states.
- `README.md` — reflect the updated section list, terminal state, and any
  new/renamed gate.
- Possibly one new or extended gate plugin for `impact_summary` /
  `retro_id` presence, and a loop_state vocabulary check — exact shape is
  a phase-1 design decision, deferred to the proposal.
- `docs/handbooks/round-end-value-gates.md` — no expected change (spec
  does not touch round-end value gates); confirmed by reading its content
  matches the existing `Round-end value gates` record section only.

## Skip-condition check (scout directive)

Neither scout skip condition applies outright: the spec leaves open
design decisions (where `retro_id`/`impact_summary` sections go, what
the new loop_state vocabulary strings look like in directive text, how
to reconcile `action_items: required` with the "never mandatory" advisory
posture). Scouting proceeds using this rulebook's own prior
issue-retrospective records as the best-in-class exemplar (per
`directive.sh`'s own `use_when` clause, which already treats this
repo's past records as the primary exemplar source) plus the spec's own
cited `source_standard` (blameless retrospective format, already the
methodology this rulebook implements) — see scout-brief.md.
