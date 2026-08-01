# Handbook — hooks & checks

## Gates

The three role-agnostic gates (`trailer-gate.sh`, `record-fields-gate.sh`,
`handbook-trigger-gate.sh`) are core canon (core issue #66): core's own
`hooks.json` fires them for every plugin install. This repo no longer
vendors copies or registers them in `issue-retrospective/hooks/hooks.json`.

`issue-retrospective`'s non-default terminal `loop_state` (`round-done`, vs core's
default `landed`) is set via `RECORD_FIELDS_TERMINAL_STATES=round-done` in
`issue-retrospective/hooks/directive.sh` — see `docs/issue-13/reports/implementation.md`
for the open question on whether that channel actually reaches core's
separately-invoked gate process.

## `directive.sh`

`issue-retrospective/hooks/directive.sh` is a stub: it sources
`core/hooks/lib/role-directive.sh` and calls `core_role_directive` with
issue-retrospective's four role-unique values (YOU DECIDE / USE WHEN / PRODUCES /
HAND-OFF). No local trap/kill-switch/`CLAUDE_ROLE`-guard boilerplate — that
lives once in the shared lib.

## Methodology gates — a plugin set, not one script (issue #18)

Per approver FEEDBACK on PR #20, each adopted methodology check is its own
independently installable plugin — its own `plugin.json`, its own
`hooks/hooks.json` `PreToolUse` entry, its own kill switch, its own test
file — registered in `.claude-plugin/marketplace.json` alongside `issue-retrospective`,
not folded into `issue-retrospective/hooks/plugins/`:

| Plugin dir | Methodology owned | Write surface(s) |
|---|---|---|
| `timeline-order-gate/` | Timeline-first ordering | 산출물 (record) |
| `contributing-factors-gate/` | Plural structural causation, no singular attribution | 산출물 (record) |
| `recurred-prediction-gate/` | Recurred-prediction question answered | 산출물 (record) |
| `action-item-shape-gate/` | Action items, when claimed, owned + checkable | 산출물 (record) |
| `freelunch-completeness-gate/` | Freelunch completeness (inputs-named, synthesis, adopted-norms-with-rationale) | 기획서 (proposal) + 산출물 (record) |
| `proposal-order-gate/` | Phase ordering (phase-1-before-phase-2) | 산출물 (record), reads the 기획서 it guards |

Each plugin's `hooks/<name>.sh` is independently deploy/disable-able
(`ISSUE_RETROSPECTIVE_<PLUGIN>_GATE_OFF=1`) — removing one plugin's
`hooks.json` entry never affects another plugin's checks. `install.sh`
installs all seven plugins (`issue-retrospective` + the six gates) from
`tokenmaxxxer-issue-retrospective` in one pass.

## Run the checks

    /bin/bash tests/parse-check.sh issue-retrospective/hooks
    /bin/bash tests/parse-check.sh timeline-order-gate/hooks
    /bin/bash tests/parse-check.sh contributing-factors-gate/hooks
    /bin/bash tests/parse-check.sh recurred-prediction-gate/hooks
    /bin/bash tests/parse-check.sh action-item-shape-gate/hooks
    /bin/bash tests/parse-check.sh freelunch-completeness-gate/hooks
    /bin/bash tests/parse-check.sh proposal-order-gate/hooks
    /bin/bash tests/stub-check.sh issue-retrospective
    /bin/bash tests/deny-only-check.sh .
    for d in timeline-order-gate contributing-factors-gate recurred-prediction-gate \
             action-item-shape-gate freelunch-completeness-gate proposal-order-gate; do
      /bin/bash tests/deny-only-check.sh "$d/hooks"
      /bin/bash "$d/hooks/$d-tests.sh"
    done

`tests/run-gate-tests.sh` is deleted — it only ever exercised the now-core
gate copies directly; core's own `run-role-gates-tests.sh` covers that
behavior now. `tests/stub-check.sh` is core's drift-recurrence detector,
vendored verbatim, and replaces it in this repo's check list.
