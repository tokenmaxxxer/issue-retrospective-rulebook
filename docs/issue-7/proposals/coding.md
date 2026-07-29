# Build proposal — issue-7

files: `README.md`

## Request (paraphrased intent)

Wake-routing ownership moved to on-the-record (`docs/specs/wake-routing.md`
in that repo); this rulebook must no longer state which role a record state
summons. Keep this role's own record states/format as-is.

## Constraints

- Two-phase discipline (contract v3 s19): this proposal is phase 1 only. No
  target file is edited in this PR. No APPROVE is posted by any role (s19).
- Only strip/repoint statements that name which role wakes on which state;
  a role's own record-format/state-vocabulary content stays.

## What will be done (phase 2, after human Approve)

In `README.md`, replace line 18:

> Wakes once the subject's work has landed and verify and/or review have
> concluded.

with a line that states reflect's own trigger condition without naming the
other roles, and repoints ownership of the actual routing table to
on-the-record's `docs/specs/wake-routing.md`, e.g.:

> When this role wakes is decided by on-the-record's routing table
> (`docs/specs/wake-routing.md`), not by this rulebook.

## Out of scope

- `reflect/hooks/directive.sh` — its "WAKES-ON reads
  docs/issue-<n>/reports/reflect.md ONLY" block is this role's own
  record-board statement (which file is the board), not a statement of
  which role a state summons. Left unchanged.
- No other files matched the audit (see survey.md).

## How it will be known to work

- Post-change, `grep -rniE "wake" README.md` shows no mention of another
  role name (`verify`, `review`, or any role) tied to a wake condition.
- `reflect/hooks/directive.sh` unchanged; its own-record WAKES-ON line
  still present (confirms scope was not over-applied).
