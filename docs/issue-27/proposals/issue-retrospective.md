# Proposal — issue #27: A+ 인증 마감 (rename `reflect` → `issue-retrospective`)

Phase 1 only. No execution in this PR; phase 2 opens on Approve. This
document contains no timeline, no contributing factors, and no action
items — those are phase-2 content, written only after human Approve.

## Scout: skipped (recorded per scout directive)

This role's own `use_when` exemplars are records-based (blameless
postmortem practice + this repo's own prior issue-retrospective records
under `docs/issue-*/reports/issue-retrospective.md`), never a
product/market category — the same reasoning issue-24's proposal
recorded for the same skip
(`docs/issue-24/proposals/issue-retrospective.md`, "Scout: skipped").
Issue #27's own content (a rename of a role name across a fixed file
set) is not a design decision this role would scout a market for
either. Both stated skip conditions apply: no design decision is open
for this role's own deliverable, and this role's exemplar set is
records-only.

## Inputs read this session (named per contract v3 s19; phase 2 will re-read all of these)

- `docs/issue-27/reports/issue-retrospective/survey.md` (this session's
  own current-state survey, written first per the survey-first order).
- `gh issue view 27` (issue body, full text).
- `gh pr list --state all` (confirms no PR yet targets issue #27; only
  PR #1/#2, both unrelated and already merged).
- Prior same-role records in full: `docs/issue-12/reports/issue-retrospective.md` +
  its survey + its proposal; `docs/issue-18/reports/issue-retrospective.md` +
  its scout-brief + its survey + its proposal; `docs/issue-21/reports/issue-retrospective.md` +
  its survey + its proposal; `docs/issue-24/reports/issue-retrospective.md` +
  its scout-brief + its proposal.
- `docs/handbooks/round-end-value-gates.md` (exists; phase 2 will run
  both value gates against issue #27's record).
- `docs/specs/approvers.md` (exists; confirms single-account-mode
  approval convention already used by issue-21/issue-24).

## What the survey found (synthesis, not a re-paste)

Issue #27 asks for a mechanical, fully-enumerated rename (`reflect` →
`issue-retrospective`) across `marketplace.json`, plugin manifests, the
gates' default-role/deny text, `README.md`, and `tests/parse-check.sh` —
execution work, owned by whichever role does coding/implementation for
this repo, not by this role. This role's own contract forbids fixing
anything and requires its evidence be **the subject's other role
records only**. The survey found **zero** such records under
`docs/issue-27/` — no coding/implementation report, survey, or
proposal exists yet for this subject, and no PR targets issue-27 other
than this session's own branch. There is nothing yet on record for this
role to build a retrospective from.

This is a materially different starting state than issue-12/18/21/24,
each of which opened only after at least one prior execution round had
already landed and left a record this role could read. Issue #27 has
no such record. Per this role's own precedent (issue-18/issue-24: "a
record too thin to reflect on IS a finding"), the correct phase-1
posture here is to say so plainly rather than to open the running
plugin tree directly and reconstruct what issue #27's rename ought to
contain — that is precisely the prohibited move (this role's own
`use_when`: "never open a non-record source for the subject's own
behavior").

## Adopted norms + rationale

This proposal keeps the record/proposal shape issue-12/18/21/24 already
established (inputs read → synthesis → adopted norms → planned record
sections → open questions), per issue-12's own rationale for reusing a
proven in-repo shape (`docs/issue-12/proposals/issue-retrospective.md`,
"(a) Phase-1 proposal norms").

## What phase-2 will run

Per `docs/handbooks/round-end-value-gates.md`: **yes** — if/when phase
2 opens, it will run both round-end value gates (procedure-value,
blind-onboarding) against issue #27's own record, once that record has
actual execution records to draw on.

## Planned phase-2 record sections and the question each answers for issue #27

- **Timeline** — reconstructed only from whatever execution-role
  record(s) exist under `docs/issue-27/` by the time phase 2 runs, plus
  issue/PR history: when the `reflect`→`issue-retrospective` rename
  landed, across which files, and whether it landed in one pass or
  several.
- **Contributing factors** (plural, not root cause) — why the old role
  name `reflect` survived in marketplace.json/manifests/gate
  defaults/README/parse-check this long despite the role itself already
  having been renamed to `issue-retrospective` in this repo's own
  docs-path convention (`docs/issue-<n>/reports/issue-retrospective.md`)
  since at least issue #12 — a naming split between the plugin
  identity and the docs convention that this survey found still open.
- **What we learned** — will explicitly answer the recurred-prediction
  question with a citation. This proposal's own preliminary read: none
  of issue-12/18/21/24's records predicted a stale-plugin-identity
  failure mode specifically (issue-24's record predicted a stale
  *README/install-command* vocabulary residual, which is adjacent but
  not the same defect class as a plugin/manifest/gate-default identity
  string). Phase 2 must confirm this with a full re-read of all four
  prior records' "What we learned" sections rather than trusting this
  proposal's preliminary read.
- **Action items** (optional, owner+shape-gated when present) — if the
  record recommends anything, it will name an owner and a concrete,
  checkable change; this role remains advisory-only and does not itself
  perform the rename.

## Open questions for the approver

- No execution-role record exists yet for issue #27. Per this role's
  own contract, phase 2 cannot write a meaningful Timeline/Contributing
  factors section until at least one such record lands
  (e.g. a `docs/issue-27/reports/<execution-role>.md`) documenting the
  actual rename and its test-green evidence, as issue #27's own body
  requires ("record에 해소 확인... 기록"). The approver should confirm
  whether Approve on this PR is meant to open phase 2 immediately (in
  which case the phase-2 record will have to state plainly that no
  input existed yet, per issue-18/24's own "thin record IS a finding"
  precedent) or whether Approve is expected to wait until an execution
  role's record lands first.
- Issue #27 body item 2 ("sales만 해당: core #78... 착수") is scoped to
  a different role (`sales`) and does not apply to this
  `issue-retrospective` role's own work; this proposal does not address
  it and flags it only so the approver can confirm it is out of scope
  for this branch.
