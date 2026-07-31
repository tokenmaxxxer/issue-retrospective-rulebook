# Proposal — issue #13: core canon reference switch

Phase 1 only. No execution in this PR; Phase 2 opens on Approve.

## Inputs read (survey + scout, named per contract v3 s19)
- This repo: `reflect/hooks/{directive.sh,trailer-gate.sh,record-fields-gate.sh,
  handbook-trigger-gate.sh,hooks.json}`, `install.sh`, `README.md`,
  `docs/README.md`, full-repo grep for `warrant`.
- Core canon (local checkout, `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core`):
  `core/hooks/{hooks.json,lib/role-directive.sh,tests/stub-check.sh,
  trailer-gate.sh,record-fields-gate.sh,handbook-trigger-gate.sh}`,
  `docs/issue-66/reports/implementation.md`, `warrant/` plugin layout.
- Details: `docs/issue-13/reports/implementation/survey.md`,
  `docs/issue-13/reports/implementation/scout-brief.md`.

## What the survey found
Of the issue's 5 items, item 1 (warrant-hunter copy) is **N/A** — this repo
never vendored one. Items 2, 3, 4 are real, confirmed drift. Item 5 is a
mechanical add once 2–4 land.

## Plan for Phase 2

1. **Delete gate copies + their registrations.** Remove
   `reflect/hooks/{trailer-gate.sh,record-fields-gate.sh,handbook-trigger-gate.sh}`
   and drop their three entries from `reflect/hooks/hooks.json`'s
   `PreToolUse` block (core's own `hooks.json` already fires all three
   role-agnostically — confirmed, not assumed).
2. **Rewrite `directive.sh` as a stub.** Keep the existing
   `trap 'rc=$?; ...' EXIT` / `set -uo pipefail` pair at the top (per core's
   own record, this is the one part that cannot move into the shared lib).
   Replace everything else with: source
   `core/hooks/lib/role-directive.sh` (resolved via
   `${CLAUDE_PLUGIN_ROOT_CORE:-...}`, the pattern the lib's own header
   documents) and one `core_role_directive` call. Content mapping: fold the
   current 5 sections (RESEARCH / CURRENT-STATE SURVEY / PROPOSAL /
   EXECUTION JUDGMENT / RECORD REQUIREMENTS) into core's 4 slots — `YOU
   DECIDE` from the opening decision statement, `USE WHEN` from
   RESEARCH+SURVEY (when/how this role investigates), `PRODUCES` from
   PROPOSAL+EXECUTION JUDGMENT (what the phase-1/phase-2 outputs are and
   their quality bar), `HAND-OFF` from RECORD REQUIREMENTS. Every sentence
   of role-unique content carries over losslessly — the reorganization is
   structural (which of 4 buckets), not a content cut.
3. **Preserve the terminal-state difference explicitly.** Set
   `RECORD_FIELDS_TERMINAL_STATES=round-done` (this repo's actual value,
   confirmed non-default at `record-fields-gate.sh:197` pre-deletion) via
   whatever channel the approver confirms reaches the core-fired gate's
   process environment — **open question, not resolved in Phase 1**: core's
   own transition-path record says a rulebook "sets that var in its own
   `hooks.json` env or session env" but does not confirm either channel
   works once the rulebook's `hooks.json` no longer registers the gate
   itself. Phase 2 starts by confirming this mechanism (asking core's
   maintainers or testing against a live session) before relying on it —
   if no working channel exists, that itself is a finding to report back
   through core issue #66's tracked follow-up, not something to route
   around silently.
4. **Vendor `core/hooks/tests/stub-check.sh`** into this repo's own
   `tests/`, alongside the existing `parse-check.sh`/`deny-only-check.sh`
   copies, and wire it into whatever runs those (README's "Run the checks"
   section, `install.sh` if it invokes tests).
5. **Record `stub-check.sh` passing** in the Phase 2 implementation record
   (`docs/issue-13/reports/implementation.md`), per the issue's item 5.

## Order constraint honored
This PR does not touch anything this repo's own "rulebook maturation phase
2" issue would touch beyond `directive.sh`/gates/`hooks.json` — consistent
with core issue #66's stated sequencing (canon-switch stubs land before any
maturation phase 2 that would otherwise duplicate this work).

## Open question for the approver
Confirm the `RECORD_FIELDS_TERMINAL_STATES` injection channel (item 3 above)
before Phase 2 work starts — this is the one item this repo cannot verify
by reading core alone (core's own gate file is deleted from this repo in
the same phase that needs to set the var, so the mechanism must be
external to `reflect/hooks/`).
