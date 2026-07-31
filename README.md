# tokenmaxxxer / reflect-agent-rulebook

The `reflect` role on contract v3. A reflect session is spawned with two
plugin sets installed: this marketplace's `reflect` plugin, and the
[tokenmaxxxer-core](https://github.com/tokenmaxxxer/tokenmaxxxer-core)
plugins (`core`, `terse`, `freelunch`, `scout`). Core owns the interaction
protocol — issue in, two-phase PR out (research/survey/proposal → human
review Approve → execution), branch `issue-<n>/reflect`, record at
`docs/issue-<n>/reports/reflect.md`. This rulebook owns only what is
reflect-specific: how the role fills each lifecycle stage, and the quality
bar on its record.

## What `reflect` decides

What this issue's history teaches — what went well, what failed, and what
pattern should change next time — built from the subject's other role
records only, never from fresh re-investigation of the running system.
Findings are always `severity: advisory`: reflect informs the next issue;
it never blocks this one.

## What is here

    reflect/hooks/directive.sh          SessionStart — a core-canon stub
                                        (sources core/hooks/lib/role-directive.sh)
                                        carrying the role's four facets:
                                        research (exemplar retros; recurred
                                        predictions), survey (records-only),
                                        proposal (named inputs), judgment
                                        (round-end value gates, advisory-only)
    tests/                              repo-level checks (never installed
                                        into a session): stub-check.sh,
                                        parse-check.sh, deny-only-check.sh

Everything that used to live here for coordination — the state machine and
its injection, path ownership, docs-bucket layout, the per-repo contract
copy — is deleted: core's board-gate and approval-gate own all of it now.
The three role-agnostic gates (trailer-gate.sh, record-fields-gate.sh,
handbook-trigger-gate.sh) are core canon too (core issue #66): core's own
`hooks.json` fires them for every plugin install, so this rulebook no
longer vendors copies or registers them itself.

## Record vocabulary

`loop_state`: `idle, reflecting, candidate-round-done, round-done`
(terminal: `round-done`, set only after the round-end value gates run —
contract s18). The record must always carry a non-empty pointer to the
role records it read.

## Install

    claude plugin marketplace add tokenmaxxxer/reflect-agent-rulebook
    claude plugin install reflect@tokenmaxxxer-reflect

on-the-record installs it per role alongside the core marketplace; `install.sh`
does the same by hand. Kill switch: `REFLECT_CYCLE_OFF=1`.

## Run the checks

    /bin/bash tests/parse-check.sh
    /bin/bash tests/stub-check.sh reflect
    /bin/bash tests/deny-only-check.sh
