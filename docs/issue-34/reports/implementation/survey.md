# Survey — issue #34

## Convention source
`docs/specs/test-env-resolution.md` (on-the-record repo, issue #551)
defines: resolution order `$CLAUDE_PLUGIN_ROOT_CORE` (if it contains a
non-empty `hooks/lib/gate-lib.sh`) -> first caller-supplied sibling
candidate with the same file -> SKIP with message
`SKIP: core plugin unreachable — unverifiable outside spawn env` on
stderr and exit `75` (`EX_TEMPFAIL`). Reference implementation is
`gates/test_env_resolve.py` (Python, importable or run as
`python3 -m gates.test_env_resolve <candidates...>`). Adoption is
per-repo, explicitly out of scope of the convention doc itself.

The on-the-record repo is present locally at
`/home/jwjung/.tokenmaxxxer/work/on-the-record-issue-551-implementation`,
not inside this rulebook's tree — this rulebook has no dependency on
that repo today (no vendoring, no submodule, no import path to it).

## Current shape of this rulebook's test scripts

Six gate directories, each with a `hooks/<gate>.sh` (the gate) and a
`hooks/<gate>-tests.sh` (its test runner):
- `timeline-order-gate`
- `proposal-order-gate`
- `freelunch-completeness-gate`
- `contributing-factors-gate`
- `action-item-shape-gate`
- `recurred-prediction-gate`

Each `<gate>.sh` sources core's `hooks/lib/gate-lib.sh` on line 2 via:
```sh
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "...: cannot source gate-lib.sh" >&2; exit 2; }
```
This fallback assumes the *runtime install layout* (rulebook checked
out as a sibling of `core/`) — that assumption holds at gate-execution
time inside a real Claude Code install, so it is correctly left
untouched (issue #34 only asks for the *test* scripts).

Each `<gate>-tests.sh` runs its gate as a real subprocess (not by
sourcing gate-lib.sh directly) and currently hardcodes a personal dev
path as its resolution fallback:
```sh
export CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core}"
```
(present verbatim, same line shape, in all six `*-tests.sh` files —
`timeline-order-gate-tests.sh:12`, `proposal-order-gate-tests.sh:15`,
`freelunch-completeness-gate-tests.sh:13`,
`contributing-factors-gate-tests.sh:12`,
`action-item-shape-gate-tests.sh:12`,
`recurred-prediction-gate-tests.sh:12`).

On a plain checkout without that exact home directory, `gate-lib.sh`
does not exist at the fallback path, so every `runcase`/`rawcase`
subprocess call inside these six scripts fails to source it (`exit
2`), which the test harness's own `report()` records as `deny` — for
`allow`-expected cases this reads as a FAIL rather than an
environment SKIP, exactly the misleading-failure issue #34 (via #551)
describes.

Three more scripts live in `tests/`: `deny-only-check.sh`,
`parse-check.sh`, `stub-check.sh`. None of them source or invoke
`gate-lib.sh`, none reference `CLAUDE_PLUGIN_ROOT_CORE` or `core` at
all — they grep/parse hook files directly. These match the "Empty
state — known exception" carve-out in the convention doc
(`gates/test_skip_gate.py` analog): out of scope, no resolution to
adopt.

Each `*-tests.sh` also has one `runcase deny missing-core-source-guard
... CLAUDE_PLUGIN_ROOT_CORE=/nonexistent/core` case that intentionally
points at a bad path to assert the gate's own `exit 2` guard — this is
a real assertion of the gate's fail-closed behavior, not an
environment-resolution concern, and must keep working unchanged.

## Constraints observed
- No `python3 -m gates.test_env_resolve` module is vendored into this
  repo, and the convention doc states no network fetch is part of the
  canonical contract — so a pure-bash re-implementation of the same
  resolution order (env var -> sibling candidates -> SKIP with message
  + exit 75) is the only adoption path available without adding a new
  cross-repo dependency.
- The gate scripts themselves (`<gate>.sh`, not `-tests.sh`) are out of
  scope: issue #34's acceptance criteria name "test scripts" and "gate-test
  scripts" only; the gates' own runtime-fallback line is correct for
  the real install layout and touching it is not requested.
- Six files share the exact same 3-line block (comment + export line),
  so the fix is one identical patch applied six times, not six
  independent designs.

## Write set (frozen)
- `timeline-order-gate/hooks/timeline-order-gate-tests.sh`
- `proposal-order-gate/hooks/proposal-order-gate-tests.sh`
- `freelunch-completeness-gate/hooks/freelunch-completeness-gate-tests.sh`
- `contributing-factors-gate/hooks/contributing-factors-gate-tests.sh`
- `action-item-shape-gate/hooks/action-item-shape-gate-tests.sh`
- `recurred-prediction-gate/hooks/recurred-prediction-gate-tests.sh`
- `docs/issue-34/reports/implementation/survey.md` (this file)
- `docs/issue-34/proposals/*.md` (the proposal)

No `.env.example`, dependency manifest, or migration touches — this is
a shell-script-only change with no new dependency.
