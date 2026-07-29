---
name: coding-proposal-issue-5
---

# Build proposal — issue #5

files: README.md

## Request (paraphrased)
Stale prose mention of the old name `muster` at README.md:55 must be
renamed to `on-the-record`, following the tool rename
(`tokenmaxxxer/muster` -> `tokenmaxxxer/on-the-record`).

## Constraints
- Historical docs untouched.
- Only the one prose mention at README.md:55 changes.

## What will be done
Replace `muster` with `on-the-record` in the sentence at README.md:55.

## Out of scope
Any other file or historical reference to the old name.

## Verification
`grep -n muster README.md` returns no matches after the change.
