---
code_under_review:
  - issue-retrospective/hooks/directive.sh
  - README.md
  - docs/handbooks/round-end-value-gates.md
  - docs/handbooks/hooks.md
loop_state: landed
---

# Implementation record — issue #31

## What was done

Applied the approved phase-1 proposal (`docs/issue-31/proposals/implementation.md`)
verbatim, within its frozen write set:

- `issue-retrospective/hooks/directive.sh`:
  - `produces` (PHASE 2, STEP 2): added `retro_id` as the record's
    declared identity (satisfied by `issue-<n>`, already present via
    file path + commit trailer). Added `Impact summary` as a new
    required section between Timeline and Contributing factors.
    Changed `Action items` from "optional... never mandatory" to
    "structurally required (spec: `action_items` `required: true`) —
    the section must exist even when empty; content stays advisory-only
    and never blocks landing." Stated that `action_items`
    reference-resolution lives in `on-the-record`, outside this
    rulebook's write scope.
  - `RECORD_FIELDS_TERMINAL_STATES`: renamed `round-done` → `landed`
    (exact spec match).
  - `hand_off`/loop_state narrative: added `gathering` (records-only
    survey phase) and `writing` (record composition phase) progress
    states; added refusal state `blame-language-detected` and error
    state `timeline-unreachable`, each with a one-line trigger
    condition.
- `README.md`: updated the record vocabulary section to the five
  loop_state values (`gathering, writing, landed,
  blame-language-detected, timeline-unreachable`; terminal: `landed`);
  updated "What is here" prose and gate table description for
  `action-item-shape-gate` to note action items are structurally
  required (section) but advisory (content); added `Impact summary` to
  directive.sh's four-facet listing.
- `docs/handbooks/hooks.md`: updated the
  `RECORD_FIELDS_TERMINAL_STATES=round-done` reference to `landed`
  (found by the after-proposal warrant hunt; already listed in the
  proposal's own `files:` frontmatter as an approved write-set member).
- `docs/handbooks/round-end-value-gates.md`: added a one-line
  cross-reference noting `impact_summary`/`retro_id` are directive-level
  additions, not new round-end value-gate questions.

## Why

Upstream basis: `docs/issue-31/proposals/implementation.md`, approved by
issue comment `APPROVE issue-31/implementation` (single-account mode,
same account `JiwonJung94` as PR #32 author). The proposal's own
Rationale section explains why no new mechanical gate was added and why
`retro_id` was mapped onto `issue-<n>` rather than left unmapped.

## What did not work

None.

## Doc placement

- Env var value change (`RECORD_FIELDS_TERMINAL_STATES`) → the
  component's handbook, same turn: `docs/handbooks/hooks.md` (this
  commit).
- No new dependency, migration, or public signature/wire-format change
  → no `docs/issue-31/decisions/` entry required.
- No benchmark/investigation numbers produced → no
  `docs/issue-31/reports/` entry beyond this record itself.

## Open findings

None outstanding. The after-proposal warrant hunt's finding (hooks.md
stale `round-done` reference) is already folded into the proposal's own
frozen write set and resolved by this commit.

## How you'll know it worked

- `grep -ri 'retro_id\|impact_summary\|action_items\|timeline' docs/ README.md`
  — all four spec required-field names present (verified below).
- `grep -ri 'gathering\|writing\|landed\|blame-language-detected\|timeline-unreachable' issue-retrospective/hooks/directive.sh README.md`
  — all five loop_state values present, `round-done` absent repo-wide
  (verified below).
- Ran `tests/parse-check.sh issue-retrospective/hooks` and
  `tests/stub-check.sh issue-retrospective` (closest applicable sanity
  checks on the edited directive.sh) — both pass. Full
  acceptance-criterion `pytest`/`tests/*.sh` check:
  `unverifiable: no test suite present` for spec-vocabulary-specific
  tests — this proposal's write set adds no new gate script, per its own
  Out-of-scope.
