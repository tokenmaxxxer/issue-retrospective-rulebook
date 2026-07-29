# Coding record — issue-7

subject: issue-7
code_under_review: README.md@HEAD (post-edit, see commit sha in git log)

## Approval (upstream basis)

PR #8 comment `APPROVE issue-7/coding` by JiwonJung94 (approvers.md,
single-account mode), 2026-07-29T22:45:51Z. Executed the proposal at
`docs/issue-7/proposals/coding.md` exactly.

## What was done

Reworded `README.md:18` to drop the named-role wake triggers (`verify`,
`review`) and repoint routing ownership to on-the-record's
`docs/specs/wake-routing.md`. No other file changed (frozen write set:
`README.md` only, per docs/issue-7/reports/coding/survey.md).

## Why

Issue #7: wake-routing ownership moved to on-the-record
(`docs/specs/wake-routing.md`); this rulebook must no longer restate which
role a record state summons. `reflect/hooks/directive.sh`'s own-record
WAKES-ON line is this role's own board statement (which file is the board),
not inter-role routing, so it stays out of scope per the approved survey.

## closed_checks

- check: post-edit `grep -rniE "wake" README.md` shows no other-role name
  tied to a wake condition; `reflect/hooks/directive.sh` unchanged.
  Result: confirmed — README.md:18-19 now names no role; directive.sh has
  no diff. code_sha: set at commit below.

## What did not work

(none)

## Open findings

None outstanding; no blocking finding was addressed to this record.

## Open-finding resolution path

Not applicable — no open findings.

## Next steps

None for coding; issue is complete pending human PR merge/close decision.

loop_state: phase-2-done
