---
code_under_review:
  - timeline-order-gate/hooks/timeline-order-gate-tests.sh
  - proposal-order-gate/hooks/proposal-order-gate-tests.sh
  - freelunch-completeness-gate/hooks/freelunch-completeness-gate-tests.sh
  - contributing-factors-gate/hooks/contributing-factors-gate-tests.sh
  - action-item-shape-gate/hooks/action-item-shape-gate-tests.sh
  - recurred-prediction-gate/hooks/recurred-prediction-gate-tests.sh
type: fix
breaking: false
verdict: pass
loop_state: landed
---

# Implementation record — issue #34

## What was done
Applied the canonical test-env resolution convention
(`docs/specs/test-env-resolution.md`, on-the-record #551) to all six
`*-tests.sh` scripts, replacing each script's hardcoded personal-path
fallback with a bash resolution block implementing the convention's
order: `CLAUDE_PLUGIN_ROOT_CORE` (if set and non-empty
`hooks/lib/gate-lib.sh` present) -> sibling candidates
(`$HERE/../../core`, `$HERE/../../../tokenmaxxxer-core/core`) -> SKIP
contract (`SKIP: core plugin unreachable — unverifiable outside spawn
env` on stderr, exit `75`). Each script's comment references
`docs/specs/test-env-resolution.md` by name.

Files changed (the frozen write set, unchanged from the proposal):
- timeline-order-gate/hooks/timeline-order-gate-tests.sh
- proposal-order-gate/hooks/proposal-order-gate-tests.sh
- freelunch-completeness-gate/hooks/freelunch-completeness-gate-tests.sh
- contributing-factors-gate/hooks/contributing-factors-gate-tests.sh
- action-item-shape-gate/hooks/action-item-shape-gate-tests.sh
- recurred-prediction-gate/hooks/recurred-prediction-gate-tests.sh

The `missing-core-source-guard` runcase in each script was left
untouched, per the proposal's constraint — it explicitly overrides
`CLAUDE_PLUGIN_ROOT_CORE` per-subprocess to assert the gate's own
fail-closed `exit 2` and does not go through the new resolution block.

## Doc-placement ladder
- [x] No new env var, config key, dependency, or migration introduced
  — nothing to add to a handbook.
- [x] No new library/format choice over a named alternative beyond
  what the proposal's Rationale already recorded (bash-vs-vendoring
  Python decision) — no new `docs/issue-34/decisions/` entry needed.
- [x] No benchmark/investigation numbers produced — no
  `docs/issue-34/reports/` entry beyond this record.

## Why
Per issue #34's Acceptance: gate-test scripts must SKIP with the
convention's exact contract outside the spawn env instead of failing
misleadingly, while every assertion that runs when core is reachable
keeps passing unchanged. Basis: approved phase-1 proposal
`docs/issue-34/proposals/2026-08-09-adopt-test-env-resolution.md`,
approved via `APPROVE issue-34/implementation` (single-account mode,
approver `JiwonJung94`, listed in `docs/specs/approvers.md`).

## What I ran
- Each of the 6 scripts run with `CLAUDE_PLUGIN_ROOT_CORE` unset and no
  reachable sibling candidate: all 6 printed the exact SKIP message on
  stderr and exited `75`, before any `runcase`/`rawcase` ran.
- Each of the 6 scripts run with `CLAUDE_PLUGIN_ROOT_CORE` pointed at a
  real local core checkout (`/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core`):
  all previously-passing assertions passed unchanged in every script
  (15/15, 13/13, 19/19, 17/17, 16/16, 17/17 — including
  `missing-core-source-guard` denying in all 6), 0 failed.
- `grep -l test-env-resolution` over the six scripts: all 6 matched.
- No script surfaced a real (non-environment) regression; empty-state
  finding not triggered.

## What did not work
None.

## Open findings
None.

## Closed checks
- closed_checks: skip-contract-all-six-scripts, code_sha=c1065dd9b17349c4beea79a67e70a7c69b83fed4
- closed_checks: core-reachable-full-pass-all-six-scripts, code_sha=c1065dd9b17349c4beea79a67e70a7c69b83fed4
- closed_checks: convention-doc-referenced-all-six-scripts, code_sha=c1065dd9b17349c4beea79a67e70a7c69b83fed4

## Next steps
None — commit and open PR closing #34.

## Resolution path
N/A — no open findings.
