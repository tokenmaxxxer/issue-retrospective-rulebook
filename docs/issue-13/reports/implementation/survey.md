# Current-state survey — issue #13

Scope: this repo (`reflect-agent-rulebook`), against core canon read directly
from a local checkout of `tokenmaxxxer-core` (`/home/jwjung/tokenmaxxxer/
tokenmaxxxer-core`), state as landed by core issue #63 (warrant-hunt canon)
and #66 (role-agnostic gate canon).

## Per work item

1. **warrant-hunter copy removal — N/A here.** `grep -ril warrant .` finds
   only `docs/README.md`'s metaphor ("this repository's own `warrant`-style
   units of work") — no `agents/warrant-hunter.md`, no hunt-cadence hook, no
   reference to `warrant/hooks/*` anywhere in this repo. `install.sh` installs
   only this repo's own `reflect` plugin; the `warrant` plugin is installed
   by the session harness separately (per README's plugin-set description),
   never vendored here. There is nothing to remove for this item.

2. **Gate copies — real, byte-diverged duplicates.** `reflect/hooks/{trailer-gate.sh,
   record-fields-gate.sh,handbook-trigger-gate.sh}` exist and are registered
   in `reflect/hooks/hooks.json`'s `PreToolUse` block. Diffed against core's
   canon copies (`core/hooks/{trailer-gate.sh,record-fields-gate.sh,
   handbook-trigger-gate.sh}`): same judge logic, but core's now reads role
   identity from `CLAUDE_ROLE` at runtime and derives kill-switch var and
   message prefix from it, while this repo's copies hardcode `REFLECT_CYCLE_OFF`
   / `reflect-cycle` literals. Core's `hooks/hooks.json` already registers
   all three with matcher `.*`, firing for every plugin install — confirmed
   by reading it directly. This repo's copies + registrations are exactly
   the drift class core issue #66's rollout plan targets for deletion.

3. **`directive.sh` — not yet a stub.** Current file (`reflect/hooks/directive.sh`,
   62 lines) hand-writes the trap/kill-switch/`CLAUDE_ROLE`-guard boilerplate
   that core issue #66 factored into `core/hooks/lib/role-directive.sh`'s
   `core_role_directive(you_decide, use_when, produces, hand_off)` (4
   positional args, each a block of text). Role-unique content in this repo's
   directive is organized as 5 named sections (RESEARCH / CURRENT-STATE
   SURVEY / PROPOSAL / EXECUTION JUDGMENT / RECORD REQUIREMENTS), not core's
   4-slot shape (YOU DECIDE / USE WHEN / PRODUCES / HAND-OFF) — mapping one
   onto the other is a real content decision, not mechanical, and is a phase-2
   question (see proposal's open question).

4. **`RECORD_FIELDS_TERMINAL_STATES` — genuinely needed.** Core's
   `record-fields-gate.sh` (line 86) defaults terminal states to `landed`.
   This repo's copy (`reflect/hooks/record-fields-gate.sh:197`) hardcodes
   `TERMINAL = {"round-done"}` — confirmed non-default, matching exactly the
   per-role divergence core issue #66's implementation record flagged as
   real (not stale copy-paste) and left as a config knob for exactly this
   reason. **Open question, not resolved in this survey**: core's gate is
   registered from `core/hooks/hooks.json`, a file this repo cannot edit: the
   mechanism by which a rulebook's chosen `RECORD_FIELDS_TERMINAL_STATES`
   value reaches that hook's process environment at `PreToolUse` time is not
   established from reading core alone (a `directive.sh` `export` does not
   propagate — hooks run in one-shot subprocesses; SessionStart output is
   context, not env). Core's issue #66 record says only "sets that var in its
   own `hooks.json` env or session env," without confirming a per-rulebook
   `hooks.json` file that no longer registers any hooks itself still gets
   consulted for an `env` block, or naming any other channel. Flagged for the
   approver rather than guessed.

5. **`core/hooks/tests/stub-check.sh` — read, understood, not yet run against
   this repo (no local copy vendored, nothing to run it against pre-migration).**
   Its checks map 1:1 onto items 2–3: absence-based for the three gates
   (`find -maxdepth 3 -name <gate>`), structural for `directive.sh` (must
   source `role-directive.sh`, call `core_role_directive`, and contain no
   other non-blank/non-comment line). Distributed the same way
   `parse-check.sh` already is — copied verbatim into a rulebook's own test
   harness (`tests/`) and run from there.

## Existing local pattern for a phase-1-only PR

`docs/issue-9/proposals/coding.md` + `docs/issue-9/reports/coding/survey.md`
is this repo's own prior single-batch, phase-1-only submission (issue #9,
"strip wake/board routing vocabulary") — same shape as this issue: a
mechanical de-restatement against an upstream canon change, survey-then-propose,
no execution. Followed here for section shape.
