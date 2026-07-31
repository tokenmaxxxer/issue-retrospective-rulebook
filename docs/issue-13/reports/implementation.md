---
subject: issue-13
role: implementation
loop_state: landed
---

# Implementation record — core canon reference switch

Approved: issue comment (single-account mode), exact string `APPROVE
issue-13/implementation`, posted by `JiwonJung94` (listed in
`docs/specs/approvers.md`). Phase-1 PR (#14) was already merged to main
before this comment; phase 2 continues on the same branch
`issue-13/implementation` and reports through a new PR (the old PR closed
on merge).

## What was done

Executed the approved proposal's Phase-2 plan on branch
`issue-13/implementation`: deleted the three vendored role-agnostic gate
copies and their `hooks.json` registrations, rewrote `directive.sh` as a
core-canon stub, set `RECORD_FIELDS_TERMINAL_STATES=round-done`, vendored
`core/hooks/tests/stub-check.sh`, and confirmed it (plus the two surviving
repo checks) pass against the new tree. Details per item below.

## Why

Core issue #66 (and #63) landed the gates/library/detector as core canon,
role-agnostic and registered globally; keeping this repo's byte-diverged
copies and hand-written `directive.sh` boilerplate is exactly the drift
class core's rollout exists to eliminate, and core issue #66's own record
states the per-rulebook stub must land before this repo's own rulebook
maturation phase 2 to avoid duplicated work (issue #13's stated order
constraint).

upstream: docs/issue-13/proposals/implementation.md (approved via issue
comment `APPROVE issue-13/implementation`); core canon read from local
checkout `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core` at
`core/hooks/{hooks.json,lib/role-directive.sh,tests/stub-check.sh,
trailer-gate.sh,record-fields-gate.sh,handbook-trigger-gate.sh}` and
`docs/issue-66/reports/implementation.md`.

## What shipped, per the proposal's plan

1. **Gate copies + registrations deleted.** Removed
   `reflect/hooks/{trailer-gate.sh,record-fields-gate.sh,handbook-trigger-gate.sh}`
   and dropped `reflect/hooks/hooks.json`'s entire `PreToolUse` block (its
   only three entries were these files) — core's own `hooks.json` already
   fires all three role-agnostically for every plugin install, confirmed by
   reading `core/hooks/hooks.json` directly.
2. **`directive.sh` rewritten as a stub** — sources
   `core/hooks/lib/role-directive.sh` (via
   `${CLAUDE_PLUGIN_ROOT_CORE:-...}` fallback resolution, the pattern the
   lib's own header documents) and makes one `core_role_directive` call
   with reflect's four role-unique values. All prose from the old 5
   sections (RESEARCH / CURRENT-STATE SURVEY / PROPOSAL / EXECUTION
   JUDGMENT / RECORD REQUIREMENTS) carried over losslessly into core's 4
   slots per the proposal's mapping (YOU DECIDE = opening decision
   statement; USE WHEN = RESEARCH+SURVEY; PRODUCES = PROPOSAL+EXECUTION
   JUDGMENT; HAND-OFF = RECORD REQUIREMENTS) — confirmed by diffing the old
   heredoc body against the new argument strings sentence-by-sentence.
3. **Finding that changed the plan from the proposal's stated premise:**
   the proposal (citing core issue #66's own implementation record) said
   the `trap 'rc=$?; ...' EXIT` / `set -uo pipefail` pair "stays at the top
   of each rulebook's own file" because it "cannot be factored out." That
   prose is **wrong against core's own enforced check**: core's
   `stub-check.sh` structural pass rejects any non-blank/non-comment line
   that is not the source line, a plain `VAR=value` assignment, or the
   `core_role_directive` call — the trap line fails that test. Confirmed
   against core's own golden fixture for "a real stub" in
   `core/hooks/tests/run-role-gates-tests.sh:116-122`: it contains only
   shebang, source line, and the `core_role_directive` call — no trap, no
   `set -uo pipefail`. Built to the enforced fixture, not the prose:
   `reflect/hooks/directive.sh` carries no trap/pipefail lines. Reported
   here rather than silently reconciled — this is a structural correction,
   not a content cut; the trap/pipefail behavior itself now lives inside
   `core_role_directive`'s own EXIT handling in the shared lib.
4. **`RECORD_FIELDS_TERMINAL_STATES=round-done` set** in `directive.sh` as
   a bare variable assignment (this repo's actual pre-deletion value, was
   `reflect/hooks/record-fields-gate.sh:197`'s `TERMINAL = {"round-done"}`)
   — the one shape `stub-check.sh` permits alongside the source/call
   lines. **Open finding, not resolved here** (per the proposal's own
   instruction not to route around this silently): whether a bare
   assignment made inside this `SessionStart`-only, one-shot subprocess
   actually reaches core's separately-invoked `PreToolUse`
   `record-fields-gate.sh` process is not established by reading this repo
   or core alone — core's own hooks fire from `core/hooks/hooks.json`
   (`${CLAUDE_PLUGIN_ROOT}/hooks/record-fields-gate.sh`), a wholly separate
   process invocation per tool call, and a SessionStart hook's own shell
   variables do not, by the Claude Code hook execution model, persist into
   later hook subprocesses. Grepped the full local core canon checkout
   (all five plugins' `hooks.json` and `.claude-plugin/plugin.json` files)
   for any existing `"env"`-block precedent for a rulebook's own manifest
   feeding a core-registered hook's environment: none exists anywhere in
   the canon today. Reported back as a gap in core issue #66's rollout plan
   (the "sets that var in its own hooks.json env or session env" line names
   two channels; neither is confirmed to exist for a rulebook whose own
   hooks.json no longer registers the gate) rather than assumed working or
   silently dropped.
5. **`core/hooks/tests/stub-check.sh` vendored** into `tests/stub-check.sh`
   (verbatim copy from the local core checkout), wired into
   `README.md`'s "Run the checks" section in place of the now-deleted
   `tests/run-gate-tests.sh` (its only two test functions exercised the
   deleted `record-fields-gate.sh`/`trailer-gate.sh` copies directly and had
   nothing left to test once core stopped registering per-rulebook copies —
   this repo's own gate behavior is now core's coverage, per core's own
   `run-role-gates-tests.sh`).

## `stub-check.sh` passing — recorded per the issue's item 5

    $ /bin/bash tests/stub-check.sh reflect
    stub-check: ok — no vendored 'trailer-gate.sh' under reflect
    stub-check: ok — no vendored 'record-fields-gate.sh' under reflect
    stub-check: ok — no vendored 'handbook-trigger-gate.sh' under reflect
    stub-check: ok — no vendored 'parse-check.sh' under reflect
    stub-check: ok — reflect/hooks/directive.sh is a role-directive stub

Also re-ran the two surviving repo-level checks against the new tree:

    $ /bin/bash tests/parse-check.sh
    ok    directive.sh
    parse-check: 1 file(s) under /bin/bash

    $ /bin/bash tests/deny-only-check.sh
    deny-only-check: ok — no permissionDecision allow under <repo>
    deny-only-check: no gate scripts under <repo>/reflect/hooks — nothing to probe

`bash -n` on the new `directive.sh` also parses clean under bash 5. Not
run: a live Claude Code session actually loading the plugin and firing
`SessionStart` — the sandbox in this session denies executing
`reflect/hooks/directive.sh` directly (approval-required), so the stub's
runtime output was verified by static parse + the three checks above, not
by a live session render. Stated plainly rather than claimed as tested.

## Order constraint honored

Nothing beyond `directive.sh`/gates/`hooks.json` was touched — this repo's
own "rulebook maturation phase 2" issue, whatever it turns out to be, is
untouched.

## Open findings

1. **`RECORD_FIELDS_TERMINAL_STATES` propagation channel unconfirmed**
   (item 4 above) — carried forward as a gap to report against core issue
   #66, not resolved in this repo. Until confirmed, this rulebook's
   effective terminal state may silently fall back to core's default
   (`landed`) instead of `round-done`, which would make `round-done`
   records fail the "no next-steps section required" relaxation the old
   copy granted them. No resolution path exists inside this repo alone — it
   needs either a core-side answer or a live-session test neither role can
   run solo.
2. **Proposal's trap/pipefail premise was wrong against core's own enforced
   check** (item 3 above) — flagged so core's issue #66 prose record can be
   corrected to match its own `stub-check.sh` and golden fixture, since the
   next rulebook to read that record verbatim would hit the same
   contradiction.
