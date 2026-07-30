# coding record — issue-9

code_under_review: 7c7c91dcec0c1273a38fab99e7908623658e22e0
loop_state: round-done

## why

PR #10 (phase 1) merged only the survey and proposal — no code change
landed. Phase 2 approval (issue-level APPROVE) opens execution of that
approved proposal now, upstream: docs/issue-9/proposals/coding.md at
1e9c341.

## what was done

Implemented the approved proposal (docs/issue-9/proposals/coding.md):
- `reflect/hooks/directive.sh`: replaced the "YOUR RECORD IS THE BOARD"
  section with a "RECORD REQUIREMENTS" section — record path, first-act-
  of-phase-2 timing, update-on-every-transition, commit-on-branch. All
  WAKES-ON/board/downstream-role language removed.
- `README.md`: dropped the "when this role wakes ... routing table"
  sentence and its pointer to `docs/specs/wake-routing.md`.

Verified: `grep -rn "WAKES-ON\|wake-routing\|board-as-routing\|downstream
role" reflect/ README.md` returns nothing; `bash tests/parse-check.sh`,
`bash tests/deny-only-check.sh`, and `bash tests/run-gate-tests.sh` all
pass (11/11 on the gate test suite).

## closed_checks

- check: grep-sweep-for-routing-vocabulary, code_sha: 7c7c91dcec0c1273a38fab99e7908623658e22e0, result: clean
- check: parse-check + deny-only-check + run-gate-tests, code_sha: 7c7c91dcec0c1273a38fab99e7908623658e22e0, result: pass (11/11)

## open finding

None. Resolution path: n/a — no open findings from this pass.

## next steps

None — proposal scope fully implemented, tests green, record terminal.

## What did not work

(none — both edits applied cleanly on first attempt)
