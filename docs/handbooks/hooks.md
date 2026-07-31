# Handbook — hooks & checks

## Gates

The three role-agnostic gates (`trailer-gate.sh`, `record-fields-gate.sh`,
`handbook-trigger-gate.sh`) are core canon (core issue #66): core's own
`hooks.json` fires them for every plugin install. This repo no longer
vendors copies or registers them in `reflect/hooks/hooks.json`.

`reflect`'s non-default terminal `loop_state` (`round-done`, vs core's
default `landed`) is set via `RECORD_FIELDS_TERMINAL_STATES=round-done` in
`reflect/hooks/directive.sh` — see `docs/issue-13/reports/implementation.md`
for the open question on whether that channel actually reaches core's
separately-invoked gate process.

## `directive.sh`

`reflect/hooks/directive.sh` is a stub: it sources
`core/hooks/lib/role-directive.sh` and calls `core_role_directive` with
reflect's four role-unique values (YOU DECIDE / USE WHEN / PRODUCES /
HAND-OFF). No local trap/kill-switch/`CLAUDE_ROLE`-guard boilerplate — that
lives once in the shared lib.

## Run the checks

    /bin/bash tests/parse-check.sh
    /bin/bash tests/stub-check.sh reflect
    /bin/bash tests/deny-only-check.sh

`tests/run-gate-tests.sh` is deleted — it only ever exercised the now-core
gate copies directly; core's own `run-role-gates-tests.sh` covers that
behavior now. `tests/stub-check.sh` is core's drift-recurrence detector,
vendored verbatim, and replaces it in this repo's check list.
