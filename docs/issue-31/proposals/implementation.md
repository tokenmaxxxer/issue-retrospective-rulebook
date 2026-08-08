---
files:
  - issue-retrospective/hooks/directive.sh
  - README.md
  - docs/handbooks/round-end-value-gates.md
  - docs/handbooks/hooks.md
---

# Proposal — align rulebook with issue-retrospective.spec.json (#31)

## Request

Map each required field and loop_state value in the marketplace spec
`roles/specs/issue-retrospective.spec.json` onto this rulebook's existing
methodology docs/hooks, strengthening what exists rather than deleting
it, and say explicitly where a spec field has no natural home.

## Constraints

- Never delete existing methodology (issue text, explicit).
- `action_items` stays advisory in *content* (findings are always
  `severity: advisory` per this role's own contract) even though the
  spec now marks the field structurally required — required-to-exist,
  not required-to-block.
- Write scope is directive text + README + handbook cross-reference
  only; no new gate script is proposed in this write set (see Rationale).
- Terminal-state rename must not silently break `record-fields-gate.sh`
  compatibility — the env var mechanism already exists
  (`RECORD_FIELDS_TERMINAL_STATES`), so this is a value change, not a
  mechanism change.

## Rationale

Considered adding a brand-new seventh gate plugin
(`impact-summary-gate.sh` / `retro-id-gate.sh`) mirroring the existing
six PreToolUse gates, to mechanically enforce `impact_summary` and
`retro_id` presence the same way `timeline-order-gate.sh` enforces
`Timeline`. Rejected for this proposal: a new gate is exactly the kind
of write-set item the survey-order/warrant directives want frozen and
approved *before* being built, and this issue's own acceptance criteria
only require the field *names* to appear in docs after phase 2 (`grep -ri
<field> docs/`) — not a new mechanical gate. Building an unrequested gate
here would be scope creep past what #31 asks for. Instead this proposal
strengthens the existing single-source-of-truth (directive.sh's
`produces`/`hand_off` text, which every real record has followed to date
per the survey) to name the two new sections and the required-not-
optional status of action items; a follow-up issue can add mechanical
gates once real records show the prose-only requirement is being missed
(the same "evidence from real usage" bar the spec itself uses for its own
`recomputation.checked_by: TBD`).

Considered leaving `retro_id` unmapped (spec has no natural home,
declared explicitly) vs. mapping it onto the existing `issue-<n>`
identity. Rejected leaving it unmapped: the scout brief found `issue-<n>`
already flows through the file path and the mandatory `Subject: issue-<n>`
commit trailer — an unmapped `retro_id` would ignore an identifier this
rulebook already produces on every record. Mapped instead.

## What will be done

`issue-retrospective/hooks/directive.sh`:
- `produces` (PHASE 2, STEP 2 — record body order): add `retro_id` as
  the record's declared identity, satisfied by naming `issue-<n>`
  (the subject issue number, already present via file path + commit
  trailer) explicitly as the record's `retro_id` value at the top of the
  record. Add `Impact summary` as a new required section, positioned
  immediately after `Timeline` and before `Contributing factors` (impact
  is established from the timeline before causal analysis begins).
  Change `Action items` from "optional... never mandatory" to
  "structurally required (spec: `action_items` `required: true`) — the
  *section* must exist even when empty; its *content* stays
  advisory-only and never blocks landing." State plainly that
  `action_items` reference-resolution to real tracked issues
  (`role-spec-reference-guard.sh`, spec's own `checked_by`) lives outside
  this rulebook's write scope in `on-the-record` and is not duplicated
  here.
- `hand_off` / loop_state: rename `RECORD_FIELDS_TERMINAL_STATES` value
  from `round-done` to `landed` (exact spec match). Add explicit
  progress states `gathering` (records-only survey phase) and `writing`
  (record composition phase) to the directive text describing when
  loop_state changes. Add refusal state `blame-language-detected`
  (person-directed blame language, refused at write time — distinct from
  `contributing-factors-gate`'s existing singular-vs-plural causation
  check, which is left unchanged) and error state
  `timeline-unreachable` (timeline evidence cannot be reconstructed from
  the subject's records) to the directive text, each with a one-line
  trigger condition.

`README.md`:
- Update the record section list (adds `Impact summary`, notes
  `Action items` as spec-required) and the "What is here" prose to match.
- Add one paragraph naming the five loop_state values now in use
  (`gathering`, `writing`, `landed`, `blame-language-detected`,
  `timeline-unreachable`) and note the terminal-state rename.

`docs/handbooks/round-end-value-gates.md`:
- Read first; if (as survey found) it needs no content change because
  round-end value gates are untouched by the spec, add a one-line
  cross-reference noting `impact_summary`/`retro_id` are directive-level
  additions, not new round-end value-gate questions — keeps the handbook
  and directive from drifting apart on what each owns.

`docs/handbooks/hooks.md`:
- Update the `RECORD_FIELDS_TERMINAL_STATES=round-done` reference (lines
  ~10-11) to `landed`, matching the directive.sh rename. Found by the
  after-proposal warrant hunt (`docs/issue-31/reports/implementation/2026-08-09-hunt-implementation.md`):
  this file was outside the originally frozen write set and would have
  been left describing a stale terminal-state value, silently defeating
  the proposal's own "no `round-done` anywhere" verification check.

## Out of scope

- Building `impact-summary-gate.sh` / `retro-id-gate.sh` or any new
  PreToolUse gate plugin (see Rationale — deferred to a follow-up once
  real-usage evidence shows prose-only enforcement is insufficient,
  mirroring the spec's own stance on `recomputation.checked_by: TBD`).
- Implementing `role-spec-reference-guard.sh`-equivalent reference
  resolution inside this rulebook — the spec names that check as living
  in `on-the-record`, outside this repo's write scope.
- Changing `contributing-factors-gate.sh` to detect person-directed
  blame language — kept as a separate, later concern per the scout
  brief's "Skip" item (conflating singular-attribution and person-blame
  detection risks the gate missing person-directed blame not phrased as
  "root cause").
- Touching any of the six existing gate scripts' logic.

## How you'll know it worked

- `grep -ri 'retro_id\|impact_summary\|action_items\|timeline' docs/
  README.md` — all four spec required-field names present after phase 2
  (issue's own acceptance check).
- `grep -ri 'gathering\|writing\|landed\|blame-language-detected\|
  timeline-unreachable' issue-retrospective/hooks/directive.sh README.md`
  — all five spec loop_state values present, and `round-done` no longer
  appears anywhere (exact-match vocabulary, no stale/extra states).
- No test suite present in this repo beyond the gate `*-tests.sh` files,
  which this proposal's write set does not touch — phase 2 will state
  `unverifiable: no test suite present` for the acceptance criterion's
  `pytest`/`tests/*.sh` check, and additionally note whether the
  unmodified `*-gate-tests.sh` files still pass as a sanity check on the
  gate scripts this proposal leaves untouched.
