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

## before-landing — stance 3: assume the rule as written cannot hold: find the state nothing maintains

Verdict: FINDING — the new sibling-candidate resolution omits the one path that actually exists in this dev checkout, so in this environment every one of the six *-tests.sh scripts now unconditionally SKIPs (exit 75, zero tests run) instead of exercising the gate, whereas the old hardcoded fallback ran all tests (rc 0) here.
Kind: design-error
Seed: c1065dd9 "adopt test-env resolution convention in six gate-test scripts" — all six `*-gate-tests.sh` scripts
cap_seconds: 120
tier: default
diff_stat_lines: ~184 insertions across 7 files
started_at: 2026-08-09T00:00:00+09:00
ended_at: 2026-08-09T00:20:00+09:00

### Reproduce
```
cd /home/jwjung/.tokenmaxxxer/work/issue-retrospective-rulebook-issue-34-implementation
env -u CLAUDE_PLUGIN_ROOT_CORE bash proposal-order-gate/hooks/proposal-order-gate-tests.sh
echo "current (post-change) rc=$?"

# compare against the pre-change version of the same script (parent commit 4ebd1a0,
# the commit immediately before c1065dd which introduced this resolution block),
# run in place so $HERE still resolves correctly:
git show 4ebd1a0:proposal-order-gate/hooks/proposal-order-gate-tests.sh > proposal-order-gate/hooks/proposal-order-gate-tests.sh.bak_old
cp proposal-order-gate/hooks/proposal-order-gate-tests.sh /tmp/new2.sh
cp proposal-order-gate/hooks/proposal-order-gate-tests.sh.bak_old proposal-order-gate/hooks/proposal-order-gate-tests.sh
env -u CLAUDE_PLUGIN_ROOT_CORE bash proposal-order-gate/hooks/proposal-order-gate-tests.sh
echo "pre-change rc=$?"
cp /tmp/new2.sh proposal-order-gate/hooks/proposal-order-gate-tests.sh
rm proposal-order-gate/hooks/proposal-order-gate-tests.sh.bak_old
```

### Observed
Post-change: `SKIP: core plugin unreachable — unverifiable outside spawn env`, exit 75, 0 tests run.
Pre-change (same checkout, same missing env var): 13 tests run, `== 13 passed, 0 failed ==`, exit 0 — because the old script's hardcoded fallback `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core` is a real, populated directory on this machine (`hooks/lib/gate-lib.sh` present and non-empty), while neither of the new script's two sibling candidates (`$HERE/../../core`, `$HERE/../../../tokenmaxxxer-core/core`) exist here — this checkout's actual sibling layout is `.../work/tokenmaxxxer-core-issue-<N>-*/core` (issue-suffixed), not a bare `tokenmaxxxer-core/core` sibling of the rulebook repo.

### Expected
The resolution convention should either find the core checkout that is actually present in a dev environment like this one, or the change's commit message claiming "convention...replaces hardcoded fallback" should not silently convert a previously-green, fully-exercised test suite into a universally-skipped one in the very checkout the change was authored in. As written, the convention assumes a sibling-repo layout (`<parent>/tokenmaxxxer-core/core`) that nothing in this repo or environment maintains or guarantees, so its second-tier fallback is dead code here and the SKIP path becomes the only reachable outcome without a manually exported env var — an untested/false "still works" state.
