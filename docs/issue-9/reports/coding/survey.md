# Current-state survey — issue-9

Scout skip: this is a pure vocabulary-strip edit with no design decision
open (spec names exact phrases to remove and the record-format facts to
keep) — scout protocol skip condition 2 applies.

## Write set

Grepped the whole repo for `WAKES-ON|wake-routing|board-as-routing|downstream role|wake\b|WAKES|board` outside historical docs (docs/issue-*, docs/proposals, docs/reports are untouched per issue scope):

- `reflect/hooks/directive.sh:53-60` — "YOUR RECORD IS THE BOARD (do not
  skip this): WAKES-ON reads ... wake no one ... the board never saw
  your work and no downstream role can ever be woken by it." Routing
  vocabulary throughout.
- `README.md:18-19` — "When this role wakes is decided by on-the-record's
  routing table (`docs/specs/wake-routing.md`), not by this rulebook."
  Pointer to routing canon.
- `reflect/hooks/record-fields-gate.sh:8` and `tests/deny-only-check.sh:45`
  reference "core's board-gate" — this names an actual core plugin gate
  script (a real mechanism this rulebook composes with), not
  routing-device framing of this role's own record. Left as-is; no
  wake/routing vocabulary to strip there.
- `docs/issue-7/**` — historical, untouched per issue scope.

No other files under `reflect/`, `tests/`, or top-level docs matched.

## What will be done

Restate the two hit sites as pure record-format requirements: path
(`docs/issue-<n>/reports/reflect.md`), loop_state vocabulary, required
fields, "write first act of phase 2," "update loop_state every
transition," "commit on branch." Remove all mention of wake, waking,
board-as-routing, WAKES-ON, downstream roles, and the wake-routing.md
pointer.

## Out of scope

Historical docs (docs/issue-7/**), core's actual board-gate/approval-gate
scripts (external plugin, not this repo), and anything beyond the two
identified hit sites.
