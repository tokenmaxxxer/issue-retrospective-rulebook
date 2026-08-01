# Scout brief — issue #24

**Scout: skipped — no external web sweep warranted.** This role's
exemplars are records-based (blameless-postmortem practice, already
adopted per issue #12's scout sweep, and this repo's own prior
issue-retrospective records), not a product/market category needing
external field research. Issue #24 is a re-audit of this repo's own
plugin set (grade B), not a new methodology question — the relevant
"field" to sweep is this repo's own record history, per this role's
`use_when` clause (records-only survey; blameless postmortem's
"timeline before judgment; systems, not people"). Skip condition and
reasoning documented here per the scout directive, in place of a web
sweep.

## What earlier retrospective records exist

Three prior issue-retrospective records exist in this repo, all read in
full this session:
- `docs/issue-12/reports/issue-retrospective.md` — origin record,
  adopted the five-component blameless-postmortem shape as directive
  prose only. First-ever record; no earlier record to check for a
  recurred prediction.
- `docs/issue-18/reports/issue-retrospective.md` — built the six-plugin
  mechanical enforcement layer. Its own proposal
  (`docs/issue-18/proposals/issue-retrospective.md`, "Open questions for
  the approver") explicitly flagged the contributing-factors semantic
  check as an accepted, unresolved risk: "a record could still misuse
  'factors' in a way that isn't genuinely plural attribution."
- `docs/issue-21/reports/issue-retrospective.md` — remediated a B- audit
  (kill-switch fail-open bug, `replace_all` ignored, the exact
  "factors"-laundering risk issue #18 flagged, stale README). Its own
  "What we learned" section states the pattern explicitly: "an
  accepted-risk note written at proposal time is a leading indicator,
  not a closed matter — the next audit should specifically check items a
  prior proposal flagged as 'accepted' rather than treating 'the
  approver saw it' as resolution." It also recorded one explicit,
  named deferral (not a silent gap): Bash-tool-write coverage
  (`run-gate-lib-tests.sh` mandatory case 6) was out of scope for the
  six plugins and left "for a future issue if the approver wants it
  added."

## Did an earlier record predict a failure mode that recurred in issue #24?

**Yes — two candidate predictions, both worth checking against issue
#24's exact re-audit findings in phase 2:**

1. Issue-21's own "What we learned" is itself a *meta*-prediction about
   this exact situation: accepted risks/deferrals recorded at proposal
   time are leading indicators that need explicit re-checking at the
   next audit, not assumed resolved. Issue #24 is precisely that next
   audit, re-finding residual (grade-B) defects after a prior
   remediation — this is the predicted pattern recurring at the
   process level, independent of which specific defect it lands on.
2. Issue-21's proposal explicitly deferred Bash-tool-write coverage as
   an open, named gap (not fixed, not silently dropped). Issue #24
   names "hooks.json matcher와 코드의 도구 커버리지 완전 정합" and a
   "도달 불능 deny 분기" as required fixes — this session's scoping
   grep (recorded in the phase-1 proposal) found zero `Bash`-tool
   handling in any of the six plugins' matchers or code, consistent
   with the issue-21 deferral never having been picked up. Phase 2
   must confirm directly whether issue #24's specific dead-branch/
   coverage finding is this exact deferral resurfacing, or a distinct
   defect, and cite the finding precisely rather than assume.

## Pattern that should shape this proposal's record structure

Both issue-18 and issue-21's records already use, and issue #24's
phase-2 record should continue: timeline reconstructed only from
records/PR history before any causal claim; contributing factors as
plural structural conditions (never a single root cause, per issue
#18/#21's own gate norms); and the recurred-prediction check answered
explicitly, citing the exact source record and quote — not just "yes/no"
— since issue-21 demonstrated that a *named, quoted* accepted-risk
citation is what let this session confirm the recurrence exists at all.
