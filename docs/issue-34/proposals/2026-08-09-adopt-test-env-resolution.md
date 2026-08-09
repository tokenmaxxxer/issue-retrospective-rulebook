---
status: proposed
files:
  - timeline-order-gate/hooks/timeline-order-gate-tests.sh
  - proposal-order-gate/hooks/proposal-order-gate-tests.sh
  - freelunch-completeness-gate/hooks/freelunch-completeness-gate-tests.sh
  - contributing-factors-gate/hooks/contributing-factors-gate-tests.sh
  - action-item-shape-gate/hooks/action-item-shape-gate-tests.sh
  - recurred-prediction-gate/hooks/recurred-prediction-gate-tests.sh
---

# Adopt the canonical test-env resolution convention (#34, on-the-record #551)

## Request
Apply the resolution order and SKIP contract defined at
`docs/specs/test-env-resolution.md` (on-the-record #551) to this
rulebook's six gate-test scripts, so that on a plain checkout without
`CLAUDE_PLUGIN_ROOT_CORE` set they SKIP with an explicit message and a
distinct exit code instead of failing misleadingly. No assertion that
runs when core is reachable may weaken.

## Constraints
- No network fetch — the convention doc states this explicitly; a
  network fallback is an opt-in extension, not part of the canonical
  contract, and is not adopted here.
- SKIP message and exit code must match the convention exactly:
  `SKIP: core plugin unreachable — unverifiable outside spawn env` on
  stderr, exit `75`.
- The `missing-core-source-guard` case in each script (which sets
  `CLAUDE_PLUGIN_ROOT_CORE=/nonexistent/core` deliberately, to assert
  the gate's own fail-closed `exit 2`) is a real assertion of gate
  behavior, not an environment-resolution concern — it must keep
  passing unchanged.
- Only the six `*-tests.sh` scripts are in scope; the gates'
  themselves (`<gate>.sh`) and the three `tests/*.sh` scripts
  (`deny-only-check.sh`, `parse-check.sh`, `stub-check.sh`) are out of
  scope — see Out of scope.

## Rationale
Two adoption paths exist per the convention doc's "Adoption per
consumer shape" section: vendor/import the reference Python module
(`gates.test_env_resolve`), or implement the equivalent resolution
order directly in bash. Vendoring the Python module was considered and
rejected: this repo has no existing dependency on the on-the-record
repo (no submodule, no vendored copy, no import path — confirmed in
the survey), and adding one to resolve a test-only environment check
would introduce a cross-repo coupling and a Python runtime dependency
into six previously pure-bash scripts, for logic that is ~15 lines of
straightforward bash. Implementing the same resolution order (env var
→ sibling candidates → SKIP contract) directly in bash keeps the
scripts self-contained and matches this repo's existing style (the
gates' own runtime fallback line already does this same
env-var-with-fallback pattern in bash), while still satisfying the
convention's actual contract (the resolution order and SKIP semantics,
not the specific reference implementation).

## What will be done
For each of the six `*-tests.sh` scripts, replace the current
hardcoded-personal-path fallback:
```sh
export CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core}"
```
with a resolution block implementing the convention's order in bash:
1. If `$CLAUDE_PLUGIN_ROOT_CORE` is set and
   `$CLAUDE_PLUGIN_ROOT_CORE/hooks/lib/gate-lib.sh` exists and is
   non-empty, use it as-is (already exported, no change needed).
2. Else, try sibling-checkout candidates (e.g.
   `../../core`, `../../../tokenmaxxxer-core/core`) relative to the
   test script's own location; the first one containing a non-empty
   `hooks/lib/gate-lib.sh` is exported as `CLAUDE_PLUGIN_ROOT_CORE`.
3. Else, print `SKIP: core plugin unreachable — unverifiable outside
   spawn env` to stderr and exit `75`, before any `runcase`/`rawcase`
   invocations run.

Each script references `docs/specs/test-env-resolution.md` in a
comment near the resolution block, satisfying the "scripts reference
the convention doc" acceptance check.

The `missing-core-source-guard` runcase in each script is left
untouched — it explicitly overrides `CLAUDE_PLUGIN_ROOT_CORE` to a bad
path for one subprocess call and asserts the gate's own `exit 2`; it
does not go through the new top-of-script resolution block.

If, while applying this identical patch, any script's failure turns
out not to be environment-related (a real regression in the gate under
test), it is recorded as a finding in the record rather than masked
with SKIP, per the issue's empty-state instruction.

## Out of scope
- The gates themselves (`<gate>.sh`) — their runtime fallback already
  correctly assumes the install layout; not part of issue #34.
- `tests/deny-only-check.sh`, `tests/parse-check.sh`,
  `tests/stub-check.sh` — none of them resolve or depend on core at
  all (grep/parse-only), matching the convention doc's own enumerated
  exception (`gates/test_skip_gate.py` analog); nothing to adopt.
- Vendoring or importing `gates.test_env_resolve` from the
  on-the-record repo (see Rationale).
- Any change to gate assertion logic/semantics beyond the
  env-resolution fallback line and its accompanying comment.

## How you'll know it worked
- On a plain checkout with `CLAUDE_PLUGIN_ROOT_CORE` unset and no
  reachable sibling `core` candidate, each of the six `*-tests.sh`
  scripts exits `75` with the SKIP message on stderr, before running
  any `runcase`/`rawcase`.
- With `CLAUDE_PLUGIN_ROOT_CORE` pointed at a real core checkout (or a
  reachable sibling candidate present), all previously-passing
  assertions in all six scripts still pass unchanged, including
  `missing-core-source-guard`.
- `grep -l test-env-resolution` over the six scripts returns all six.
