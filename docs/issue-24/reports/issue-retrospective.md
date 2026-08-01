loop_state: round-done

## Inputs read

`docs/issue-24/proposals/issue-retrospective.md` (approved phase-1
proposal), `docs/issue-24/reports/issue-retrospective/scout-brief.md`
(scout-skip record), `docs/issue-12/reports/issue-retrospective.md`,
`docs/issue-18/reports/issue-retrospective.md`,
`docs/issue-21/reports/issue-retrospective.md` (all three prior same-role
records, read in full), `docs/handbooks/round-end-value-gates.md`,
`docs/specs/approvers.md`. Plus this session's own direct grep/`git log`/
`git show` against the current tree (not a separate survey file — the
approved proposal folded survey into itself since issue #24 is a re-audit
of already-surveyed territory): `README.md`, all seven `*/hooks/hooks.json`
matchers, all `*/hooks/*.sh` gate scripts (main, not just tests) for
`tool_name`/`Bash` handling, `git log -- README.md`, `git show 4d9d085 --
README.md` (issue-21's own README-rewrite commit, in full).

## Why

This record exists because the approved phase-1 proposal
(`docs/issue-24/proposals/issue-retrospective.md`) named exactly this
question open: whether issue #24's residual defects are new failures or
the recurrence of something a prior same-role record already predicted.
Writing the record required resolving that question with file:line/commit
evidence rather than repeating the proposal's open questions unanswered —
in particular, confirming whether issue-21's README rewrite regressed or
was always incomplete, and whether the Bash-tool-write gap issue-21
deferred is the same gap issue #24 now names.

## Timeline

- Issue #18/#19/#20: the six-plugin `issue-retrospective` gate set landed
  (independent hand-rolled kill-switch/trap/reconstruction machinery per
  plugin; `contributing-factors-gate.sh`'s semantic check flagged at
  proposal time, in its own "Open questions for the approver" section, as
  body-wide substring matching — an accepted, named risk, not an unnoticed
  defect).
- Issue #21: a B- audit found the accepted risk had materialized
  ("risk factors" 문서 전역 매치 laundering path), plus a fail-open kill
  switch and an `Edit`/`MultiEdit` `replace_all`-ignoring bug reproduced
  identically across all five reconstructing plugins. Remediation (commit
  `4d9d085`, PR #23, approved via issue-level `APPROVE
  issue-21/issue-retrospective`) migrated all six plugins to
  `core/hooks/lib/gate-lib.sh`/`gate-lib.py` (core issue #72), upgraded
  three plugins' semantic checks to heading-anchored/section-scoped
  matching, added 91 test cases across six suites, ran
  `compliance-check.sh` before/after (six FAIL → six `ok`), and rewrote
  `README.md`. Issue #21's own approved proposal explicitly deferred one
  item out of scope: Bash-tool-write coverage
  (`run-gate-lib-tests.sh` case 6) — recorded as a named deferral, not a
  closed gap.
- Issue #24 (this issue, filed 2026-08-01): a second re-audit of the same
  six-plugin tree, grading B, naming: stale README vocabulary/install
  form, a residual `"risk factors"` occurrence, an unreachable deny
  branch, and hooks.json-matcher/code coverage drift — plus two external
  landing preconditions (core #75, on-the-record #182) this repo does not
  yet vendor.
- This session (phase 2): confirmed by direct grep/`git show`, not by
  re-paraphrasing issue #24's text, which of the four named residuals are
  actually present in this tree today (see "Contributing factors" below).

## Contributing factors

Three structural conditions combined to let a second B-grade set of
defects surface past issue #21's own-stated A+ closure — none of them a
single root explanation:

1. **Issue #21's README rewrite was scoped to architecture prose, not the
   Install/Record-vocabulary sections, and this was never itself
   verified against exact lines.** `git log -- README.md` shows exactly
   one commit since issue #21 (`4d9d085` itself — no later regression).
   `git show 4d9d085 -- README.md` shows the rewrite replaced the
   architecture description (single-`reflect`-plugin → six-plugin) but
   left two things untouched in the same commit: the `## Install` section
   still ends with `claude plugin install
   reflect@tokenmaxxxer-reflect` (the pre-plugin-set single-role install
   line, now stale alongside the six new lines it added above it), and
   the `## Record vocabulary` section's `loop_state` value list
   (`idle, reflecting, candidate-round-done, round-done`) was never
   touched at all. Issue #21's own record (`docs/issue-21/reports/issue-
   retrospective.md`, "What was done") states "`README.md` rewritten to
   describe the actual shipped tree" as a completed, unqualified claim —
   true for the sections it covered, but the claim was never checked
   against the *entire* file, so a genuinely-incomplete rewrite was
   recorded as a closed item. This is not a regression after issue #21;
   it is issue #21's own rewrite never having reached those lines.
2. **The Bash-tool-write deferral was carried as a proposal-level
   "accepted risk" note, not converted into either a landed decision or a
   tracked follow-up issue.** Issue #21's approved proposal named it
   explicitly out of scope ("left for a future issue if the approver
   wants it added"); its record repeated the same deferral under "Open
   findings." No new issue was ever filed naming that scope. This session
   confirmed by grep that all six gate scripts' main bodies (not test
   files) still contain zero `tool_name == "Bash"`/`"Bash"`-branch
   handling — the exact same gap, unresolved, now resurfacing as part of
   issue #24's "hooks.json matcher와 코드의 도구 커버리지 완전 정합"
   finding.
3. **Issue #24's own audit left no citable record this role can read.**
   This role's contract restricts phase-1 survey to prior *records*
   (docs/issue-\*/reports/\*.md, issue/PR history), never fresh
   re-investigation. This session's own grep — done only to source-check
   issue #24's specific claims against the tree, not as a substitute
   audit — found no `"risk factors"` string anywhere in this repo
   (README.md, docs/handbooks/\*.md, or any `*-gate.sh`/`*-gate-tests.sh`
   file), and found `tool_name` handling gated correctly behind
   `if tool in ("Write", "Edit", "MultiEdit")` in every plugin — a branch
   that is redundant with (but not unreachable relative to) the
   `Write|Edit|MultiEdit` matcher, not an obviously "도달 불능" deny path.
   Because issue #24's text is the *only* record of that audit's findings
   — no linked report, no file:line citations — this role cannot
   determine whether those two items are (a) already resolved by issue
   #21's semantic-check upgrade and issue #24's text is itself stale, or
   (b) present somewhere this session's grep scope did not reach (e.g.
   inside core or on-the-record, which this repo does not vendor). That
   gap is itself a contributing factor: an audit finding with no citable
   evidence trail is not verifiable by the next role in the chain.

## What we learned

Yes — this is a recurred-prediction case, and this session's own evidence
extends what issue #21 already predicted. Issue #21's "What we learned"
section stated, in its own words: "an accepted-risk note written at
proposal time is a leading indicator, not a closed matter — the next
audit should specifically check items a prior proposal flagged as
'accepted' rather than treating 'the approver saw it' as resolution."
Issue #24's re-audit is exactly that recurrence for the Bash-tool-write
deferral (contributing factor 2, above): the deferral was never converted
into either a landed fix or a tracked issue, and it resurfaced as a fresh
audit finding rather than being recognized as the same named gap.

This session's own investigation surfaces a second instance of the same
underlying pattern that issue #21's prediction did not name explicitly:
a **"done" claim recorded without being checked against the artifact's
exact remaining lines** is also a leading indicator, not a closed matter.
Issue #21's record said "README.md rewritten to describe the actual
shipped tree" — true of the sections it touched, but the record made no
distinction between "rewrote the parts I changed" and "verified the whole
file no longer contains stale content," and the next audit (issue #24)
caught the gap the earlier claim's phrasing had papered over. The pattern
worth carrying forward, alongside issue #21's own: **a completion claim
about a whole-file property (README accuracy, matcher/code coverage) is
only as trustworthy as the line-level grep that backs it — a record
should say what it checked, not just what it changed.**

## Adopted norms + rationale

This record adopts, unchanged, the record shape issue #12/#18/#21 already
established for this role (inputs read → why → timeline → contributing
factors → what we learned → action items → round-end value gates → open
findings), per issue-12's own rationale for reusing a proven in-repo
shape rather than inventing a new one each issue
(`docs/issue-12/proposals/issue-retrospective.md`, "(a) Phase-1 proposal
norms"), and per this issue's own approved proposal
(`docs/issue-24/proposals/issue-retrospective.md`, "Planned phase-2
record sections") which committed to that same section list in advance.
It also adopts issue-21's own named lesson — that an accepted-risk/
deferral note recorded at one proposal's time must be checked explicitly
at the next audit rather than assumed resolved — as the organizing frame
for "Contributing factors" and "What we learned" above, rather than
treating issue #24's four named residuals as unrelated fresh findings.

## Action items

- Owner: whichever role executes issue #24's remediation (not this role
  — issue-retrospective remains advisory-only and does not itself fix
  other roles' processes). Concrete, checkable change: when a phase-2
  record claims a whole-file rewrite or coverage fix is complete, the
  record must state the specific grep/check command run to verify the
  *entire* file/tree, not just the sections edited (directly answers
  contributing factor 1 and the second "What we learned" pattern above).
- Owner: whichever role executes issue #24's remediation. Concrete,
  checkable change: any item deferred as an "accepted risk" or "future
  issue" in an approved proposal must either be closed in the same
  remediation or have a real tracked issue filed naming it by the time
  that remediation's record is written — a proposal-level deferral note
  alone is not sufficient closure, per issue #21's own predicted-and-now-
  twice-observed pattern (Bash-tool-write coverage).
- Owner: whichever role files or re-files issue #24-class audit findings.
  Concrete, checkable change: an audit issue naming residual defects
  (e.g. `"risk factors"` occurrence, "unreachable deny branch") should
  cite file:line evidence or link the audit's own report, so the next
  role in the chain (this one, or the remediating role) can verify rather
  than re-derive or guess the finding's location.

## Round-end value gates

**A. Procedure-value** — not `ritual`. Citable evidence: issue #21's own
"What we learned" section is the direct predictor of a pattern issue #24
independently confirmed recurred (Bash-tool-write deferral, contributing
factor 2) — a same-role record changed what this session looked for and
found, which is the mechanism this role exists to provide.

**B. Blind-onboarding** — partially fails, and that failure is itself the
finding to report, not a gap this record routes around: a zero-context
reader can reconstruct the plugin set's build/remediation history in full
from `docs/issue-18` and `docs/issue-21`'s records, and can reconstruct
*two* of issue #24's four named residuals (stale README, Bash-tool
coverage) from this record plus a direct grep. They cannot reconstruct
the other two (`"risk factors"` residual, "unreachable deny 분기") from
records alone, because issue #24's issue body is the only source for
those claims and this session's grep did not corroborate either one in
this repo's own tree — see contributing factor 3.

## Open findings

The `"risk factors"` residual and the "도달 불능 deny 분기" issue #24
names are not corroborated by this session's grep of this repo's own
tree (README.md, docs/handbooks/\*.md, all seven `*-gate.sh`/
`*-gate-tests.sh` files). Advisory only, not this role's to resolve: the
remediating role should confirm with file:line evidence whether these two
items are already closed (issue #21's semantic-check upgrade may have
already removed the `"risk factors"` pattern, making issue #24's text
stale) or located outside this repo's own tree (core, on-the-record) —
either way, citing the evidence trail this issue's own text does not
provide, per the "What we learned" pattern above.

Upstream basis: proposal `466ddd4` (this role's phase-1 survey + proposal,
PR #25, merged), approved by the issue-level comment `APPROVE
issue-24/issue-retrospective`.

Next steps: this record satisfies issue #24's retrospective scope in
full. Remediation of the four named residual defects, and confirmation of
the two external preconditions (core #75, on-the-record #182), is out of
this role's scope — see "Action items" above for who inherits it.

Resolution path for the open findings above: the role executing issue
#24's remediation should, before writing its own record, re-grep this
repo's tree (README.md, docs/handbooks/, all `*-gate.sh`/
`*-gate-tests.sh` files) plus the core and on-the-record checkouts for
`"risk factors"` and any `Write|Edit|MultiEdit`-matcher-relative dead
branch, and either close them with file:line evidence or, if genuinely
absent from this repo, note in its own record that issue #24's text was
stale on those two items — closing this open finding does not require a
new issue, only that the next record cite what it checked.
