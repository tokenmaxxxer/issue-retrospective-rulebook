---
loop_state: in-progress
code_under_review: PENDING (will be filled with final commit sha)
---

## What was done

Renamed the stale "muster" prose mention on README.md:55 to
"on-the-record" ("muster installs it per role alongside the core
marketplace" -> "on-the-record installs it per role alongside the core
marketplace").

## Why

Issue #5: the orchestration stack was renamed upstream
(`tokenmaxxxer/muster` -> `tokenmaxxxer/on-the-record`, plugin `orchestrate`
-> `on-the-record`; see tokenmaxxxer/on-the-record#83). README.md:55 was
the one remaining stale prose mention of the old name. Historical docs are
left untouched per the issue body.

## Upstream basis

Based on: docs/issue-5/proposals/proposal.md (phase-1 proposal), approved
via issue comment "APPROVE issue-5/coding" on PR #6. Upstream rename
reference: tokenmaxxxer/on-the-record#83.

## Summary

Executing the approved phase-1 proposal: rename the 'muster' prose mention
in README.md line 55 to 'on-the-record'.

## closed_checks

- Post-edit grep check: `grep -n muster README.md` after the edit no longer
  matches the line-55 prose mention. Commit sha: PENDING.

## Open findings

none

## Next steps

- Commit README.md and this record.
- Update code_under_review to the final commit sha (resolution path: a
  follow-up commit updating this record once the sha is known).
- Push to origin issue-5/coding.
- Set loop_state to landed once pushed.

## What did not work

none
