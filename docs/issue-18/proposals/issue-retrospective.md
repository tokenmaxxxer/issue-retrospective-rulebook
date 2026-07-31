# Proposal — issue #18: methodology enforcement, hook-machine depth

Phase 1 only. No execution in this PR; Phase 2 opens on Approve.

## Inputs read

- This repo: `reflect/hooks/{directive.sh,hooks.json}`,
  `reflect/.claude-plugin/plugin.json`, `tests/{stub-check.sh,parse-check.sh,
  deny-only-check.sh}`.
- Core canon (referenced, not copied):
  `core/hooks/{lib/role-directive.sh,record-fields-gate.sh}`,
  `docs/handbooks/canon-scripts.md`.
- Reference pattern only, per issue text's constraint (not vendored):
  `pricing-rulebook/pricing/hooks/methodology-gate.sh`,
  `implementation-rulebook/coding/hooks/{coding-progress-gate.sh,state.sh,
  hunt-guard.sh}`, `implementation-rulebook/tests/run-gate-tests.sh`.
- This issue's own adopted-norms source: `docs/issue-12/proposals/issue-retrospective.md`
  and `docs/issue-12/reports/issue-retrospective.md` (the record norms this
  proposal is now enforcing mechanically).
- Details: `docs/issue-18/reports/issue-retrospective/survey.md`,
  `docs/issue-18/reports/issue-retrospective/scout-brief.md`.

## What the survey + scout found

Issue #12 adopted a five-component retrospective methodology and wrote it
into `directive.sh` as prose only (survey §1). Nothing mechanically checks
that a proposal or record actually contains those components, in order,
or that "contributing factors" wasn't quietly written as "root cause"
(survey §1 vs §2). The generic core-canon `record-fields-gate.sh` is
role-agnostic by design and cannot carry this (survey §2). Two sibling
rulebooks already solved the identical problem for their own domains:
pricing-rulebook's `methodology-gate.sh` (element-presence-check,
role-owned, additive PreToolUse gate) and implementation-rulebook's
`coding-progress-gate.sh` (order-constraint via reading a second record
file directly, no separate state file) — both converge with
implementation-rulebook's test harness shape on one pattern this proposal
adopts rather than invents (scout brief, judge point 1). The canon
reference-not-copy rule (`canon-scripts.md`) is satisfied because a
retrospective-specific methodology gate is not on `stub-check.sh`'s
canon manifest — it is role-owned, the same way pricing's copy is.

## (a) Directive deepening — per-facet, phase-gated

`directive.sh`'s current prose (survey §1) states the methodology once,
compressed into four single-value strings. This proposal keeps the
`core_role_directive` four-slot shape (no fork of `role-directive.sh`) but
expands the `use_when`/`produces` slot content into explicit,
per-phase, per-facet structure — steps, judgment criteria, and
prohibitions named separately, not folded into one sentence each:

**Phase 1 (research → survey → proposal), stepwise:**
1. *Scout* (steps): read this role's own `use_when` exemplar clause;
   run the scout protocol (already governed by the platform-level scout
   directive, not restated here) against the gaps a current-state survey
   finds — never against the issue text alone.
2. *Current-state survey* (steps, must precede scout): read every subject
   record + PR/issue history only. Judgment criterion: a record too thin
   to reflect on IS a finding (contract §20 failed), never a reason to
   re-investigate the running system. Prohibition: never open non-record
   sources for the subject's own behavior (this role's contract already
   states "records-only"; the deepening states what counts as a
   violation — opening a source file, log, or running a command against
   the subject system to verify a record's claim).
3. *Proposal* (steps): name every input record path read (not paraphrase
   it); synthesize what survey+scout found (not re-paste the survey/scout
   files verbatim — they stay separate, linkable evidence, per issue #12's
   own precedent); state the adopted methodology subset with rationale
   tracing to a named source. Judgment criterion: an unsourced "best
   practice" assertion is not acceptable in this role's own proposal
   (mirrors the scout directive's "no source, no claim," applied to the
   proposal body). Prohibition: no phase-2 execution content in a
   phase-1 PR (existing contract v3 s19 constraint, restated here because
   this role's own `produces` slot had never named it explicitly before).

**Phase 2 (record), stepwise:**
1. Write the record as the *first* act of phase 2 (already stated in
   `hand_off`; kept).
2. Body order, judgment criterion for each: **Timeline** — chronological,
   records-only, must precede any causal claim (a record that states a
   contributing factor before establishing the timeline it rests on
   fails this facet, even if both sections are present); **Contributing
   factors** — plural, structural; prohibition: the phrase "root cause"
   (singular attribution) is a methodology violation, not a style
   nit — this is the facet the mechanical gate in (b) checks for
   directly; **What we learned** — must explicitly answer the
   recurred-prediction question (did any earlier record predict a failure
   mode that recurred here), even when the answer is "no earlier record
   existed" (issue #12's own record did this; that is now the required
   shape, not an option); **Action items** — optional; judgment
   criterion when present: owner named (a person/role, not "the team")
   and phrased as a concrete, checkable change; prohibition: never
   mandatory — making it required would silently expand this
   advisory-only role's scope (issue #12's own adopted rationale, restated
   as an explicit prohibition here rather than left as a rationale
   paragraph only).
3. Round-end value gates (already named): stated here as a two-question
   checklist, not a single clause — see (d) for the checklist artifact.

## (b) Methodology gate — mechanical verification, role-owned

**New file (phase 2 builds it): `reflect/hooks/methodology-gate.sh`.**
`PreToolUse` gate for `Write|Edit|MultiEdit`, additive to (never replacing)
core's generic `record-fields-gate.sh` — mirrors
`pricing-rulebook/pricing/hooks/methodology-gate.sh`'s structure exactly
(scout brief, must-bes), adapted to this role's own elements:

- **Write surfaces** (regex-scoped, everything else passes through
  untouched): `docs/issue-<n>/proposals/.*issue-retrospective.*\.md` and
  `docs/issue-<n>/reports/issue-retrospective\.md`.
- **Resulting-content reconstruction** for Write/Edit/MultiEdit
  (pricing's exact technique); fail-closed deny when the tool shape makes
  the result undeterminable.
- **Required elements checked on the record surface** (keyword/phrase
  presence, one deny message naming every missing element):
  1. `timeline` (a Timeline section heading or the word, case-insensitive).
  2. Contributing-factors language present AND the phrase "root cause"
     (singular, not "factors") absent — this is the one check pricing's
     pattern has no analogue for (pricing has no "never say X" negative
     check); implemented as: deny if `"root cause"` appears without
     `"factors"` appearing in the same section, OR if neither
     "contributing factor(s)" nor "factors" appears at all.
  3. Recurred-prediction language present ("recurred", "predicted", or an
     explicit "no earlier record" statement) — a record that never
     mentions the recurred-prediction question at all is denied; one that
     mentions it and answers "none" (issue #12's own record did exactly
     this) passes.
  4. If an action item is claimed (heuristic: an "action items" /
     "what changes" section with non-empty, non-"none" content), an owner
     token and a checkable-change phrasing must be present; a section
     that explicitly states "none" / "no action items" passes without
     further checks (mirrors pricing's `exited_early` early-exit pattern).
- **Required elements checked on the proposal surface**: input records
  named (a `docs/issue-` path or a record filename token present); a
  synthesis section distinct from a raw paste (heuristic: presence of a
  "found"/"synthesis" heading, not just a record's own section headers
  reproduced verbatim); adopted-norms-with-rationale section present.
- **Order constraint** (state via file-read, not a new persistent state
  file — scout brief's adopted pattern from `coding-progress-gate.sh`):
  before the phase-2 record write is allowed to pass the required-elements
  check, the gate additionally requires that this subject's own phase-1
  proposal (`docs/issue-<n>/proposals/*issue-retrospective*.md`, already
  on disk by the time phase 2 starts, per contract v3 s19's Approve gate)
  names both a survey path and either a scout-brief path or an explicit
  scout-skip statement — reading that file directly at gate time, the
  same way `coding-progress-gate.sh` reads `verify.md` directly, rather
  than introducing a separate state file this repo would then have to
  keep in sync.
- **Fail-closed `__fc` trap-at-top**, on every code path, matching every
  other gate in this ecosystem.
- **Kill switch**: `ISSUE_RETROSPECTIVE_METHODOLOGY_GATE_OFF=1` (role
  token `issue-retrospective`, uppercased+underscored per
  `role-directive.sh`'s own `tr` convention).
- **`hooks.json` addition**: one `PreToolUse` entry pointing at the new
  file, alongside the existing `SessionStart` entry for `directive.sh`.
- **Canon-reference statement (required by `canon-scripts.md`, survey
  §4)**: this gate is role-owned by design, not a fork of any core-canon
  file — its required-element list (timeline / contributing-factors /
  recurred-prediction / action-item shape) is retrospective-methodology
  content core issue #66 does not and should not own, the same way
  pricing's six-element list is pricing-specific. It is not on
  `stub-check.sh`'s canon manifest and does not need to be; `stub-check.sh`
  itself is copied verbatim from core per its own header and is
  unaffected.

## (c) Gate tests

**New file (phase 2 builds it): `tests/methodology-gate-tests.sh`**, run
from the same harness `stub-check.sh`/`parse-check.sh`/`deny-only-check.sh`
already use (repo-root `tests/`), using
`implementation-rulebook/tests/run-gate-tests.sh`'s exact scaffold
(`run()`/`report()`, scratch `git init` per case, synthetic PreToolUse
JSON piped on stdin, assert exit 0/2 against the real script file):

Planned cases (allow/deny pairs, phase 2 fills in exact fixture text):
1. Record with all five components in order → allow.
2. Record missing Timeline → deny, message names `timeline`.
3. Record with "root cause" and no "factors" language → deny, message
   names the contributing-factors facet.
4. Record with contributing-factors language present and no "root cause"
   phrase → allow (negative check does not false-positive on a compliant
   record).
5. Record with no recurred-prediction mention at all → deny.
6. Record stating "no recurred prediction — no earlier record existed" →
   allow (issue #12's own record, used as the literal fixture text).
7. Record claiming an action item with no owner named → deny.
8. Record stating "no action items" → allow, no further action-item
   checks fire.
9. Record whose own proposal (fixture, written into the scratch repo
   first) never names a survey path → deny (order constraint).
10. Proposal write missing an inputs-read section → deny.
11. Write to a foreign role's record path (e.g. `docs/issue-7/reports/coding.md`)
    → allow untouched (write surface scoping, mirrors pricing's own
    `foreign-path` case in `run-gate-tests.sh`).
12. `ISSUE_RETROSPECTIVE_METHODOLOGY_GATE_OFF=1` set → allow regardless of
    content (kill switch).

`tests/stub-check.sh` is unaffected (new file's name is not on the canon
manifest); `tests/parse-check.sh` will parse the new file automatically
(it already walks `reflect/hooks/*.sh` recursively) — no change needed to
either existing harness script.

## (d) Agents/checklist

**Adopt a checklist, not an agent.** The scout brief found no exemplar of
a separate checklist *file* in either sibling rulebook (scout brief, gap
line) — both encode their repeated procedure as gate logic + directive
prose only. This role's one repeated procedure that is not fully covered
by (a)+(b) is the **round-end value gate pair** (procedure-value,
blind-onboarding) — a two-question judgment call the mechanical gate in
(b) cannot verify (whether a role "cited evidence it changed the issue's
outcome," or whether "a zero-context reader could reconstruct" the issue,
are not keyword-checkable). Phase 2 adds a short checklist file,
`docs/handbooks/round-end-value-gates.md`, listing the two questions and
the fail condition for each (`ritual` / "stuck point"), for a phase-2
session to walk through explicitly at record-writing time — informational,
not gated, the same non-blocking role `state.sh` plays in
implementation-rulebook (scout brief: `state.sh` is `SessionStart`,
informational, never blocks). No new agent: this role is a single async
solo agent (contract v3), and neither sibling rulebook uses a dedicated
sub-agent for its methodology enforcement either.

## Rationale summary (traced to source, per proposal norm from issue #12)

- Directive deepening structure (steps/criteria/prohibitions, kept inside
  the existing four-slot `core_role_directive` call): the issue's own
  wording ("facet별 실행 가능한 수준," "한 줄 요약 금지"); no fork of
  `role-directive.sh` needed since the deepening lives inside the existing
  slot strings, not a new call signature.
- Gate shape: adopted wholesale from `pricing-rulebook/methodology-gate.sh`
  (scout brief must-bes 1-4, judge point 1) — the issue names this file
  explicitly as the bar to meet.
- Order constraint via direct file-read, no new state file: adopted from
  `coding-progress-gate.sh`'s pattern (scout brief must-be 5, adopt/skip);
  a dedicated persistent state file was considered and explicitly skipped
  (scout brief adopt/skip) since the one ordering fact needed is already
  on disk.
- Test harness shape: adopted from `run-gate-tests.sh` verbatim structure
  (scout brief must-be 6).
- Checklist over agent for round-end value gates: no reference
  implementation in this ecosystem uses a dedicated checklist file or
  sub-agent for methodology enforcement (scout brief gap line); the one
  gap not covered by the mechanical gate is a judgment pair, which a
  checklist prompts for and a gate cannot verify.

## Open questions for the approver

None blocking. One soft judgment call: the contributing-factors negative
check (deny on "root cause" without "factors" in the same record) is a
heuristic on prose, not a semantic check — a record could still misuse
"factors" in a way that isn't genuinely plural attribution. This is
accepted as the same class of limitation pricing's own gate already
lives with (all six of its checks are keyword/phrase heuristics, not
semantic parses); flag here if the approver wants a stricter phase-2
design before Approve.
