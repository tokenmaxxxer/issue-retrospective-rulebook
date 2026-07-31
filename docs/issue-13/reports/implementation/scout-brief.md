# Scout brief — issue #13

**Mode:** direct primary-source read, not a web sweep. This task has no
product category to compare against (no competing tools do "canon reference
switch for an agent rulebook") — the strongest available exemplar is the
authoring system itself: `tokenmaxxxer-core`'s own canon files and its own
record of how issue #66 planned this exact per-rulebook follow-up. A local
checkout exists at `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core`, read
directly in place of search angles. Stage count: 1 (single targeted read
pass over core's `hooks/`, `hooks/lib/`, `hooks/tests/`, and
`docs/issue-63/`, `docs/issue-66/` — no fan-out needed, each file answered
one item 1:1).

## Must-bes (from core canon, binding — not optional style choices)
- Gate files removed, not edited: core fires them globally via
  `core/hooks/hooks.json`'s `.*`-matcher `PreToolUse` block; a rulebook
  keeping its own copy is the drift class `stub-check.sh` exists to catch.
- `directive.sh` must be *structurally* a stub: source
  `core/hooks/lib/role-directive.sh`, one `core_role_directive` call, plain
  var assignments only — `stub-check.sh` fails on any other line
  (case/guard/echo/cat = regrown boilerplate).
- Kill-switch pair (`trap ...; set -uo pipefail`) stays in the rulebook's own
  `directive.sh` — core's own record notes this is the one piece that could
  not be factored into the shared lib (a trap inside a sourced function
  doesn't catch the sourcing script's own abnormal exit).

## Adopt / skip
- **Adopt**: core's own transition-path list (issue #66 record, "Per-rulebook
  follow-up" section) as the checklist shape for this proposal's Phase 2 plan
  — it is the author's own intended execution order, not a reconstruction.
- **Skip**: guessing the `RECORD_FIELDS_TERMINAL_STATES` injection channel.
  Core's record names the *what* (a rulebook "sets that var") but not a
  confirmed *how* for a rulebook whose `hooks.json` no longer registers the
  gate itself. Guessing here risks building a config surface core doesn't
  actually read — left as an explicit open question for the approver.

## Gap line
This repo already meets the "no vendored `parse-check.sh`" and "no vendored
warrant-hunter copy" must-bes (neither ever existed here) — item 1 is
genuinely N/A. It is missing all of: the gate deletions (item 2), the
directive stub shape (item 3), and the terminal-state config (item 4) —
those three are real, confirmed-present drift, not assumptions.

Sources: `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core/hooks/hooks.json`,
`core/hooks/lib/role-directive.sh`, `core/hooks/tests/stub-check.sh`,
`core/hooks/{trailer,record-fields,handbook-trigger}-gate.sh`,
`docs/issue-66/reports/implementation.md`, `docs/issue-63/` (existence check
of `warrant/` plugin layout) — all local paths, read directly, no web access
used or needed.
