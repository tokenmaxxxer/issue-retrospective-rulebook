# Proposal — issue #24: gate A+ final closeout retrospective (re-audit grade B)

Phase 1 only. No execution in this PR; Phase 2 opens on Approve. This
document contains no timeline, no contributing factors, and no action
items — those are phase-2 content, written only after human Approve.

## Scout: skipped (recorded per scout directive)

See `docs/issue-24/reports/issue-retrospective/scout-brief.md` for the
full skip reasoning: this role's exemplars are records-based
(blameless-postmortem practice + this repo's own prior
issue-retrospective records), not a product/market category, so no
external web sweep is warranted for a re-audit of this repo's own
plugin set.

## Inputs read this session (named per contract v3 s19; phase 2 will re-read all of these plus the items named below)

Prior same-role records, read in full:
- `docs/issue-12/reports/issue-retrospective.md`
- `docs/issue-12/reports/issue-retrospective/scout-brief.md`
- `docs/issue-12/reports/issue-retrospective/survey.md`
- `docs/issue-12/proposals/issue-retrospective.md`
- `docs/issue-18/reports/issue-retrospective.md`
- `docs/issue-18/reports/issue-retrospective/scout-brief.md`
- `docs/issue-18/reports/issue-retrospective/survey.md`
- `docs/issue-18/proposals/issue-retrospective.md`
- `docs/issue-21/reports/issue-retrospective.md`
- `docs/issue-21/reports/issue-retrospective/survey.md`
- `docs/issue-21/proposals/issue-retrospective.md`

Handbooks/specs checked:
- `docs/handbooks/round-end-value-gates.md` (exists; phase 2 will run
  both value gates against issue #24's record, per its own precedent in
  issue #18/#21's records).
- `docs/specs/approvers.md` (exists; confirms this repo's approver
  convention — single-account mode, `JiwonJung94`).

This repo's current tree, scoped by grep this session:
- `README.md` — still names the old repo/plugin-marketplace form
  (`claude plugin install <gate>@tokenmaxxxer-reflect`, README.md:106-112)
  and the old vocabulary (`loop_state: idle, reflecting,
  candidate-round-done, round-done`, README.md:98) — issue #24's "옛
  레포명·설치 명령·loop_state 어휘" residual, confirmed present at these
  exact lines. No `"risk factors"` literal string found in README.md or
  `docs/handbooks/*.md` by this session's grep — phase 2 must locate
  the exact "'risk factors' 잔여" issue #24 names (likely inside a gate
  script's deny message or a `*-tests.sh` fixture, not README prose;
  phase 2's own grep must widen past README/handbooks to the six
  `*-gate/hooks/*.sh` and `*-tests.sh` files, and any marketplace
  description text, to find it).
- `.claude-plugin/marketplace.json` — lists `reflect` plus the six
  `*-gate` plugins by name; each plugin's `source`/`description` will
  need cross-check in phase 2 against the actual six-directory tree for
  stale-name/ghost-file drift (issue #24 requirement 4).
- Each `<gate>/hooks/hooks.json` (six files) — all six matchers read
  this session are `"Write|Edit|MultiEdit"`; grep for `Bash`/`tool_name
  ==` branches in each `<gate>/hooks/<name>.sh` this session found zero
  Bash-tool handling in any of the six plugins — consistent with
  issue-21's proposal's own named deferral (Bash-tool-write coverage,
  `run-gate-lib-tests.sh` case 6) never having been picked up. Phase 2
  must confirm directly whether issue #24's "도달 불능 deny 분기" and
  "hooks.json matcher와 코드의 도구 커버리지 완전 정합" findings are
  this exact resurfaced gap or a distinct dead-branch inside the
  existing Write/Edit/MultiEdit handling (e.g. a tool-type branch that
  can never be reached given the matcher, independent of Bash).
- `gate-lib` presence: `gate-lib`/`gate_reconstruct_write`-style calls
  are present in all six plugins' `.sh` files (adopted per issue #21,
  confirmed by this session's grep) — core issue #75's precondition
  ("gate-lib source 가드 의무화 + compliance-check 검출 + missing-core
  의무 테스트 + `gate_bash_write_targets` py 이식") is a *further*
  hardening of the same library issue #21 already adopted, not a fresh
  adoption; this session's grep found no `gate_bash_write_targets`,
  `spawn.py`, or `CLAUDE_PLUGIN_ROOT_CORE` string anywhere in this
  repo — **core #75's and on-the-record #182's confirmed guard/injection
  shape is not vendored in this repo and was not guessed at**. Phase 2
  must pull the landed, confirmed form of both directly from wherever
  core and on-the-record actually live (the same core checkout path
  issue #18/#21 already used,
  `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core`, plus wherever
  `on-the-record` lives) before writing any remediation content — not
  reimplement from issue #24's one-line paraphrase of what those issues
  landed.
- `compliance-check.sh` — present at
  `core/hooks/tests/compliance-check.sh` per issue #21's own prior
  record; phase 2 will re-run it directly against this repo the same
  way issue #21 did (before/after evidence), and must additionally
  confirm it now exercises core #75's missing-core test case once that
  precondition's landed shape is pulled fresh.

## What the survey found (synthesis, not a re-paste of the records above)

This session's own current-state grep (not a separate survey file —
folded into this proposal since issue #24 is a re-audit of an already
surveyed tree, not new territory) found: three prior same-role records
exist, each building on the last (issue #12 adopted the methodology as
prose; issue #18 built six independent enforcement plugins; issue #21
remediated a B- audit of those plugins to its own stated bar). Issue
#24 is a *second* re-audit, now grading B, on the same six-plugin tree.
The residual defects issue #24 names split into two classes: (1) items
this session confirmed still present by direct grep — stale
`tokenmaxxxer-reflect`-era install commands and `loop_state` vocabulary
in README.md at the exact lines cited above, and zero Bash-tool
coverage in any of the six plugins' matchers/code, matching issue-21's
own named-and-deferred gap; and (2) items this session could not yet
locate by grep — the exact `"risk factors"` occurrence and the exact
unreachable deny branch — which phase 2 must find with file:line
evidence rather than this proposal guessing their location. The two
named preconditions (core #75, on-the-record #182) are confirmed absent
from this repo's own tree by grep (no `gate_bash_write_targets`,
`spawn.py`, or `CLAUDE_PLUGIN_ROOT_CORE` string found anywhere), so
phase 2's remediation content depends on landings this repo does not
yet vendor and must be pulled fresh rather than paraphrased from issue
#24's issue-body description of them.

## Adopted norms + rationale

This proposal adopts, unchanged, the record/proposal shape issue
#12/#18/#21 already established in this repo (inputs read → synthesis →
adopted norms → plan/open-questions), per issue-12's own rationale for
reusing a proven in-repo shape rather than inventing a new one each
issue (`docs/issue-12/proposals/issue-retrospective.md`, "(a) Phase-1
proposal norms"). It also adopts issue-21's explicit lesson — named in
its own "What we learned" section — that an accepted-risk/deferral note
recorded at one proposal's time must be checked explicitly at the next
audit rather than assumed resolved; this proposal's "Open questions for
the approver" section below is written specifically against that
lesson (checking issue-21's own named deferral, not just issue #24's
literal text).

## What phase-2 will run

Per `docs/handbooks/round-end-value-gates.md`: **yes**, phase 2 will run
both round-end value gates (procedure-value, blind-onboarding) against
issue #24's own record, the same way issue #18 and issue #21's records
did.

## Planned phase-2 record sections and the question each answers for issue #24

- **Timeline** — reconstructed only from the records above plus
  issue/PR history (records-only survey, per this role's `use_when`):
  what sequence of landings (issue #18's plugin set, issue #21's B-
  remediation, core #75's landing, on-the-record #182's landing, this
  re-audit) produced a grade-B residual-defect finding despite issue
  #21 already having closed a prior audit to its own stated bar.
- **Contributing factors** (plural, not root cause) — what structural
  conditions let a B-grade set of defects (stale README vocabulary,
  unreachable deny branches, matcher/code coverage drift) survive past
  issue #21's remediation into this second audit — distinct from, but
  possibly related to, issue-21's own named deferral and the two
  preconditions (core #75, on-the-record #182) issue #24 requires be
  landed first.
- **What we learned** — will explicitly answer the recurred-prediction
  question with a citation, not a bare yes/no. This proposal's own
  finding (see below) is that the answer is **yes**: issue-21's "What
  we learned" section predicted, in its own words, that "an
  accepted-risk note written at proposal time is a leading indicator,
  not a closed matter — the next audit should specifically check items
  a prior proposal flagged as 'accepted'" — and issue-21's proposal
  itself left one item explicitly flagged-and-deferred (Bash-tool-write
  coverage) that this session's grep found still unaddressed. Phase 2
  must confirm, with file:line evidence, whether that specific deferral
  is what issue #24's coverage/dead-branch findings actually are, and
  must also check whether the stale-README/`loop_state`-vocabulary
  finding was itself foreseeable from issue-21's own scope note (issue
  #21's remediation *did* rewrite the README, per its own record — so
  this proposal flags an open question below on whether the README
  regressed again after issue #21, or whether issue #21's rewrite was
  itself incomplete).
- **Action items** (optional, owner+date-shaped when present, per this
  role's own gate) — if the record recommends anything, it will name an
  owner and a concrete checkable change; this role remains advisory-only
  and does not itself fix other roles' processes.

## Open questions for the approver

- README.md:98/106-112 currently show the stale vocabulary/install-form
  issue #24 names, but issue-21's record claims a full README rewrite
  already landed (`docs/issue-21/reports/issue-retrospective.md`,
  "README rewrite" section) describing the *current* six-plugin
  architecture correctly. This proposal's own grep this session found
  the stale text still present at those lines. Phase 2 must resolve
  this discrepancy with file:line evidence (did the README regress
  after issue #21 via some later untracked edit, or did issue #21's
  rewrite never actually remove the stale install-command block) before
  writing any contributing-factors content that assumes one story or
  the other.
- This session found no `"risk factors"` string anywhere in
  README.md/docs/handbooks. Phase 2 must widen the search (gate scripts,
  test fixtures, marketplace descriptions) to locate the exact
  occurrence issue #24 names, since this proposal does not want to
  guess its location.
