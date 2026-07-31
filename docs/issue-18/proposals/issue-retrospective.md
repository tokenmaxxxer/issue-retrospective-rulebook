# Proposal — issue #18: methodology enforcement, hook-machine depth

Phase 1 only. No execution in this PR; Phase 2 opens on Approve.

**Revision note (per approver FEEDBACK on PR #19):** the prior revision of
this proposal expressed enforcement as one monolithic `methodology-gate.sh`
script. The approver required a **plugin-set** model instead: one adopted
methodology = one independent plugin (not one script with many checks
inside it); freelunch completeness (기획서·산출물의 "완성도") is itself one
of those plugins, not a property folded into the others; and the
기획서(proposal)/산출물(record) write-surface norms are each expressed as a
**combination of plugins**, not a single rule that owns every check. This
revision restructures (b) around that model and adds the required
**Plugin List** section (§ below) naming every plugin, the methodology it
owns, its components, and how it composes with the others. Section (a)
(directive deepening) and (d) (checklist) are unchanged in substance;
section (c) (tests) is re-scoped to per-plugin test files.

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

## (b) Methodology enforcement — a plugin set, not one gate

Per approver FEEDBACK: no single script owns every check. Each adopted
methodology becomes its **own independent plugin** — a small, separately
named `PreToolUse` gate script with its own kill switch, its own test
file, and its own single-fact responsibility. Freelunch completeness
(기획서·산출물의 완성도 — inputs-named, synthesis-present,
adopted-norms-with-rationale) is **one plugin among these**, not a
property smuggled into the others. The 기획서(proposal) and 산출물(record)
write surfaces are each governed by a **combination** of plugins wired
into `hooks.json`, not by one monolithic script that special-cases both
surfaces internally.

All plugins share one mechanical shape (adapted from
`pricing-rulebook/pricing/hooks/methodology-gate.sh`'s technique, scout
brief must-bes): resulting-content reconstruction for
`Write|Edit|MultiEdit`, fail-closed `__fc` trap-at-top, a per-plugin kill
switch (`ISSUE_RETROSPECTIVE_<PLUGIN>_GATE_OFF=1`, uppercased+underscored
per `role-directive.sh`'s `tr` convention), and one `hooks.json`
`PreToolUse` entry each — additive to (never replacing) core's generic
`record-fields-gate.sh`.

**New directory (phase 2 builds it): `reflect/hooks/plugins/`**, one file
per plugin (see Plugin List below for the exact file names). Each plugin
is independently deployable and independently disable-able: removing one
plugin's `hooks.json` entry does not affect any other plugin's checks —
this is the load-bearing difference from the prior single-script design,
where every check shared one kill switch and one file.

**Order constraint**, unchanged in substance from the prior draft but now
owned by its own plugin (`proposal-order-gate.sh`, see Plugin List): state
via direct file-read of the subject's own phase-1 proposal (adopted
pattern from `coding-progress-gate.sh`, scout brief must-be 5) — no new
persistent state file.

**Canon-reference statement (required by `canon-scripts.md`, survey
§4)**: every plugin in this set is role-owned by design, not a fork of
any core-canon file — none of the required-element lists (timeline /
contributing-factors / recurred-prediction / action-item shape /
freelunch completeness / phase ordering) is content core issue #66 does
or should own, the same way pricing's six-element list is
pricing-specific. None of the plugin files is on `stub-check.sh`'s canon
manifest and none needs to be; `stub-check.sh` itself stays copied
verbatim from core per its own header and is unaffected by adding a
`plugins/` subdirectory alongside it.

## Plugin List (required)

| # | Plugin (file, `reflect/hooks/plugins/`) | Methodology owned | Components checked | Composes into |
|---|---|---|---|---|
| 1 | `timeline-order-gate.sh` | Timeline-first ordering (issue #12 record norm) | Timeline section/keyword present; no causal-claim language precedes it | 산출물 combination |
| 2 | `contributing-factors-gate.sh` | Plural structural causation, no singular attribution | "contributing factor(s)"/"factors" present; "root cause" absent unless co-occurring with "factors" | 산출물 combination |
| 3 | `recurred-prediction-gate.sh` | Recurred-prediction question must be answered | "recurred"/"predicted" language, or an explicit "no earlier record" statement, present | 산출물 combination |
| 4 | `action-item-shape-gate.sh` | Action items, when claimed, are owned + checkable | If a non-"none" action-items section exists: owner token + checkable-change phrasing present | 산출물 combination |
| 5 | `freelunch-completeness-gate.sh` | Freelunch completeness (기획서·산출물 공통 "완성도" 방법론) | Inputs-read paths named; a synthesis section distinct from raw paste; adopted-norms-with-rationale section present | Both 기획서 and 산출물 combinations |
| 6 | `proposal-order-gate.sh` | Phase ordering (phase-1-before-phase-2, contract v3 s19) | Subject's own phase-1 proposal, read directly, names a survey path and a scout-brief path or explicit scout-skip | 기획서 combination (guards the phase-2 record write) |

**Write-surface combinations (how the plugins compose):**

- **기획서 (proposal) surface** —
  `docs/issue-<n>/proposals/.*issue-retrospective.*\.md`:
  plugin 5 (`freelunch-completeness-gate.sh`) alone. Ordering (plugin 6)
  does not apply here — it guards the *next* surface, not this one.
- **산출물 (record) surface** —
  `docs/issue-<n>/reports/issue-retrospective\.md`:
  plugins 1 + 2 + 3 + 4 + 5 + 6, all wired to the same write surface in
  `hooks.json`, each independently deny-capable. A write is denied if
  *any* plugin in the combination denies it; each plugin's deny message
  is scoped to only the facet it owns (no plugin references another
  plugin's facet in its message).

This replaces the prior draft's single `methodology-gate.sh` with six
independent files; no plugin's logic depends on another plugin's file
being present (each does its own resulting-content reconstruction), so
the write-surface combinations above are wiring in `hooks.json`, not
shared code.

## (c) Plugin tests

**New directory (phase 2 builds it): `tests/plugins/`**, one test file
per plugin, mirroring the plugin's own name (e.g.
`tests/plugins/timeline-order-gate-tests.sh`), run from the same harness
`stub-check.sh`/`parse-check.sh`/`deny-only-check.sh` already use
(repo-root `tests/`), using `implementation-rulebook/tests/run-gate-tests.sh`'s
exact scaffold (`run()`/`report()`, scratch `git init` per case, synthetic
PreToolUse JSON piped on stdin, assert exit 0/2 against the real plugin
file). One file per plugin keeps a plugin's tests independently runnable
and independently deletable if a plugin is later dropped from the set.

Planned cases by plugin (allow/deny pairs, phase 2 fills in exact fixture
text):
1. `timeline-order-gate.sh`: record with Timeline present and first →
   allow; Timeline missing → deny; a causal claim before Timeline → deny.
2. `contributing-factors-gate.sh`: "root cause" with no "factors" → deny;
   "contributing factor(s)"/"factors" present, no "root cause" → allow;
   neither present → deny.
3. `recurred-prediction-gate.sh`: no mention at all → deny; "no earlier
   record existed" (issue #12's own record, literal fixture) → allow.
4. `action-item-shape-gate.sh`: action item claimed with no owner → deny;
   "no action items" → allow, no further checks fire.
5. `freelunch-completeness-gate.sh`: proposal missing inputs-read section
   → deny; missing synthesis section → deny; all three elements present
   → allow — run once against the 기획서 fixture and once against the
   산출물 fixture, since this plugin guards both surfaces.
6. `proposal-order-gate.sh`: subject's own proposal (fixture, written
   into the scratch repo first) never names a survey path → deny; names
   survey + explicit scout-skip → allow.
7. Cross-plugin: write to a foreign role's record path (e.g.
   `docs/issue-7/reports/coding.md`) → every plugin allows it untouched
   (write-surface scoping, mirrors pricing's own `foreign-path` case).
8. Cross-plugin: each plugin's own
   `ISSUE_RETROSPECTIVE_<PLUGIN>_GATE_OFF=1` set → that plugin allows
   regardless of content, while the other five plugins in the same
   combination still enforce (proves independence — this is the case
   that could not exist under the prior single-script design, where one
   kill switch disabled every check at once).

`tests/stub-check.sh` is unaffected (no plugin file's name is on the canon
manifest); `tests/parse-check.sh` will parse every new plugin file
automatically (it already walks `reflect/hooks/**/*.sh` recursively) — no
change needed to either existing harness script.

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
- Per-plugin gate mechanics: adopted wholesale from
  `pricing-rulebook/methodology-gate.sh`'s technique (scout brief must-bes
  1-4, judge point 1) — the issue names this file explicitly as the bar
  to meet; the *decomposition into six files* is new in this revision,
  per approver FEEDBACK requiring one methodology = one independent
  plugin rather than one script owning every check.
- Freelunch completeness as its own plugin, not a folded-in property: per
  approver FEEDBACK explicitly — 완성도 (inputs-named, synthesis-present,
  adopted-norms-with-rationale) is `freelunch-completeness-gate.sh`, wired
  into both the 기획서 and 산출물 combinations rather than duplicated as
  ad-hoc checks inside each surface's own logic.
- 기획서/산출물 norms as plugin combinations, not one rule: per approver
  FEEDBACK — the Plugin List's "Composes into" column and the
  write-surface combinations subsection are the explicit mapping from
  surface to plugin set, replacing the prior draft's single script that
  branched internally on which surface it was called against.
- Order constraint via direct file-read, no new state file, now its own
  plugin (`proposal-order-gate.sh`): adopted from `coding-progress-gate.sh`'s
  pattern (scout brief must-be 5, adopt/skip); a dedicated persistent
  state file was considered and explicitly skipped (scout brief
  adopt/skip) since the one ordering fact needed is already on disk.
- Test harness shape: adopted from `run-gate-tests.sh` verbatim structure
  (scout brief must-be 6), now one test file per plugin so a plugin's
  tests travel with it if the plugin is later added to or dropped from
  the set.
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

One added judgment call from this revision: six independent plugin files
means six kill switches and six small scripts instead of one — more
files to keep in sync with `hooks.json`, traded for the independence
(disable/replace one methodology's check without touching the others)
the approver's FEEDBACK specifically asked for. Flag here if the
approver would rather cap the plugin count (e.g. merge 1-4 into one
"record-shape" plugin while keeping 5-6 separate) before Approve.
