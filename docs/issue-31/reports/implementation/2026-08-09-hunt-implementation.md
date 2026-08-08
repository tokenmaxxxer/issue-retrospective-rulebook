---
proposal: docs/issue-31/proposals/implementation.md
---

# Hunt record — implementation

## after-proposal — stance 3: assume the write set cannot carry this work — find the path the build will need that the proposal does not list.

Verdict: FINDING — `docs/handbooks/hooks.md` hard-codes the exact old terminal-state value (`RECORD_FIELDS_TERMINAL_STATES=round-done`) that this proposal's write set changes to `landed`, but `docs/handbooks/hooks.md` is not in the frozen write set (only `issue-retrospective/hooks/directive.sh`, `README.md`, `docs/handbooks/round-end-value-gates.md`), so landing the proposal as scoped leaves a handbook asserting a value that no longer exists in the code it documents.
Kind: design-error
Seed: docs/issue-31/proposals/implementation.md (frozen write set: issue-retrospective/hooks/directive.sh, README.md, docs/handbooks/round-end-value-gates.md)
cap_seconds: 120
tier: size:docs-only-ish
diff_stat_lines: 0 (untracked docs only: survey.md, scout-brief.md, proposal.md)
started_at: 2026-08-09T00:00:00Z
ended_at: 2026-08-09T00:04:00Z

### Reproduce
```
grep -n "RECORD_FIELDS_TERMINAL_STATES" docs/handbooks/hooks.md issue-retrospective/hooks/directive.sh
```

### Observed
`docs/handbooks/hooks.md:10-11` currently reads:
```
`issue-retrospective`'s non-default terminal `loop_state` (`round-done`, vs core's
default `landed`) is set via `RECORD_FIELDS_TERMINAL_STATES=round-done` in
`issue-retrospective/hooks/directive.sh`
```
After the proposed edit, `issue-retrospective/hooks/directive.sh` will contain
`RECORD_FIELDS_TERMINAL_STATES=landed`, but `docs/handbooks/hooks.md` — not in
the frozen write set — still asserts the old `round-done` value and describes
it as "non-default" vs core's `landed` default, which becomes false (the repo
now matches core's default, `round-done` no longer appears anywhere in the
directive).

### Expected
`docs/handbooks/hooks.md` needs the same rename touch as `directive.sh`
(or the write set needs to include it), otherwise the proposal's own
"How you'll know it worked" check — `round-done` no longer appears
anywhere — is falsified by a file it never planned to touch, and the
handbook stays permanently wrong about the mechanism it exists to explain.
