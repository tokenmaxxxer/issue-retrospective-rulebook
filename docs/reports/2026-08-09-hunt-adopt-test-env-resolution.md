---
proposal: docs/proposals/2026-08-09-adopt-test-env-resolution.md
---

# Hunt record — adopt-test-env-resolution

## after-proposal — stance 4: assume the write set cannot carry this work — find the path the build will need that the proposal does not list.

Verdict: NO FINDING
Seed: docs/issue-34/proposals/2026-08-09-adopt-test-env-resolution.md (write set: the six hooks/<gate>-tests.sh scripts)
cap_seconds: 120
tier: default
diff_stat_lines: ~350 (docs-only proposal, no code changed yet)
started_at: 2026-08-09T00:00:00Z
ended_at: 2026-08-09T00:02:00Z

Checked candidates for a path the build would need beyond the six
listed scripts:
- `install.sh` — no reference to CLAUDE_PLUGIN_ROOT_CORE or gate-lib.sh
  (`grep -n "CLAUDE_PLUGIN_ROOT_CORE\|gate-lib" install.sh` empty); not
  a consumer of the resolution block.
- `tests/deny-only-check.sh`, `tests/parse-check.sh`,
  `tests/stub-check.sh` — `grep -n "CLAUDE_PLUGIN_ROOT_CORE\|gate-lib"
  tests/*.sh` returns nothing; deny-only-check.sh invokes the gate
  scripts directly via `/bin/bash "$g"` (which have their own
  independent runtime fallback, out of scope per the proposal), never
  the `-tests.sh` wrappers, so it does not need the new resolution
  block either.
- A shared helper/lib file the six scripts might source in common —
  none exists (`find . -iname "*lib*"` under repo root turns up
  nothing outside the gates' own `hooks/lib/gate-lib.sh` inside the
  on-the-record core checkout, which this repo does not vendor); each
  `-tests.sh` is fully self-contained/copy-pasted already (confirmed
  by identical `runcase`/`rawcase` bodies across all six), consistent
  with the proposal's "implement inline, no shared file" plan — there
  is no missing shared file to also update.
- `docs/specs/test-env-resolution.md` — confirmed absent from this
  repo (`ls docs/specs` shows only `approvers.md`); the proposal's
  plan is to reference it only in a comment string (satisfying `grep
  -l test-env-resolution`), not to resolve/vendor it, so its absence
  is not a build dependency.
- `README.md`'s "Run the checks" section lists the six `bash
  <gate>-tests.sh` invocations verbatim but does not document exit
  codes or SKIP semantics anywhere (`grep -n "exit 75\|exit
  code\|SKIP" README.md docs/handbooks/hooks.md` empty), so there is
  no stale exit-code claim in tracked docs that this change would
  invalidate.

No path the build actually needs was found missing from the write
set; the six `*-tests.sh` scripts do appear sufficient for the change
as scoped.
