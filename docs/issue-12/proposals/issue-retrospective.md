# Proposal — issue #12: issue-retrospective 도메인 규범 수립

Phase 1 only. No execution in this PR; Phase 2 opens on Approve.

## Inputs read (survey + scout, named per contract v3 s19)

- This repo: `reflect/hooks/{directive.sh,record-fields-gate.sh,hooks.json}`,
  `reflect/.claude-plugin/plugin.json`, full-repo grep for `warrant` and for
  `reflect.md` records.
- Core canon (local checkout,
  `/home/jwjung/tokenmaxxxer/tokenmaxxxer-core`): `core/hooks/{lib/role-directive.sh,
  record-fields-gate.sh}` — for the generic §20 field set this role's gate
  inherits and cannot fork without reintroducing per-role copy drift.
- Prior same-repo phase-1 proposal for structural reference:
  `docs/issue-13/proposals/implementation.md`.
- Web sweep (4 parallel angles: SRE blameless postmortem, agile
  retrospective, military AAR, RCA methodology) — details and sources in
  `docs/issue-12/reports/issue-retrospective/scout-brief.md`.
- Details: `docs/issue-12/reports/issue-retrospective/survey.md`.

## What the survey + scout found

The directive already *states* a methodology commitment (blameless
postmortem: "timeline before judgment; systems, not people") but nothing
mechanically checks a record honors it — `record-fields-gate.sh`'s
required fields (what/why/upstream-basis/loop_state/open-findings) are
generic across all rulebook roles by design (core issue #66) and contain
no retrospective-specific concept. No `reflect.md` record has ever been
written in this repo, so there is no existing exemplar to imitate or
diverge from — issue #12's adoption is the first one. The scout sweep
found four independent lineages (SRE engineering, agile process, military
training, RCA methodology) converging on the same four elements: timeline
before judgment, contributing factors (plural, not one root cause),
owned+dated action items when any are claimed, and blame-free naming. Full
reasoning and adopt/skip calls are in the scout brief; this proposal
converts the adopted subset into rulebook norms.

## (a) Phase-1 proposal norms — this document's own required shape

Methodology: **named-input, evidence-cited proposal** — already partially
required by `directive.sh`'s `produces` clause ("promise the reflect-record
and name your inputs"); this proposal formalizes it as the required
section shape for every future issue-retrospective phase-1 proposal:

1. **Inputs read** — every record/file/URL consulted, named, not just
   described in prose (this section, above, is itself the worked example).
2. **What the survey + scout found** — a synthesis, not a re-paste of the
   survey/scout files; those stay as separate, linkable evidence.
3. **Adopted norms + rationale** — each adopted element traces to a named
   source in the scout brief or survey; no unsourced "best practice"
   assertions (mirrors the scout directive's own "no source, no claim"
   rule, extended to the proposal body itself).
4. **Plugin reflection plan** — concrete diffs to `directive.sh` /
   `record-fields-gate.sh` behavior / gate additions, not just prose intent.
5. **Open questions for the approver**, if any remain.

Rationale: this shape is not invented here — it is the structure
`docs/issue-13/proposals/implementation.md` already used successfully in
this same repo (inputs → findings → plan → order-constraints → open
question), generalized slightly. Reusing a proven in-repo shape rather than
inventing a new one is itself consistent with this role's own value
(carrying forward what worked, not re-litigating format every issue).

## (b) Phase-2 record norms — methodology + required components

Methodology: **blameless-postmortem's five-question frame**, adopted over
AAR's live-discussion format and agile retro's meeting mechanics because
this role runs solo and async on records already written — a discussion
format built for a live meeting has no facilitator, no room, no other
participants to convene here (scout brief, "adopt/skip"). The written,
citable, five-question SRE shape is the only one of the four surveyed
lineages built for exactly this role's actual operating mode.

Required components (on top of §20's generic what/why/upstream/loop_state/
open-findings, which stay as-is — core-owned, not forked):

1. **Timeline** — a chronological reconstruction of the subject issue's
   events, built only from other roles' records/PR history (per
   `directive.sh`'s existing "records-only survey" instruction) — precedes
   any causal claim in the record's body.
2. **Contributing factors** (plural, explicitly not "root cause" singular)
   — closes the gap the generic gate leaves open; wording in the gate
   message should say "factors," never "the cause," to structurally
   discourage single-cause attribution (RCA angle, Cook 1998 caution).
3. **Recurred-prediction check** — already named in `use_when` ("did any
   earlier reflect record predict a failure mode that recurred") but not
   yet a required record section; promoted to a named component so it is
   checked every time, not only when the writer happens to remember.
4. **Action items, optional but shape-constrained when present** — if the
   record recommends a change, it must name an owner and be phrased as a
   concrete, checkable change (SRE standard) — never mandatory, since this
   role is advisory-only and does not own delivering fixes (contract:
   "never fixes anything").
5. **Round-end value gates** (already named in `produces`: procedure-value,
   blind-onboarding) stay as-is — unaffected by this proposal, already
   well-specified.

## (c) Rationale for each adoption, in one place

- Timeline-first: unanimous across all 4 surveyed lineages; already named
  in this role's own `use_when` prose — promoting it to a required record
  *section*, not just an investigative instruction, closes the
  prose-vs-enforcement gap the survey found (survey §1-§2).
- Contributing factors over root cause: directly serves this role's stated
  purpose ("what this issue's history teaches," plural lessons, not a
  verdict) and structurally prevents this role from overstepping into
  re-litigating another role's verdict by pinning blame on one record.
- Recurred-prediction as a named section: already the directive's stated
  *highest-value finding* type ("A recurred prediction is your highest-
  value finding") — a value this important should be a required section,
  not left to memory.
- Action items optional/shape-constrained: matches the existing
  advisory-only, never-fixes-anything contract exactly; making it
  mandatory would silently expand this role's scope past what contract v3
  grants it.
- Reused proposal shape: avoids inventing a new document convention this
  repo does not already have reason to prefer (issue #13's shape already
  worked and was reviewed).

## (d) Plugin reflection plan

1. **`reflect/hooks/directive.sh`** — extend the `produces` heredoc with
   one clause naming the five required record sections explicitly (What
   happened / Timeline / Contributing factors / What we learned incl.
   recurred-prediction check / What changes, if any, with owner). Fix the
   stale `hand_off` literal `docs/issue-<n>/reports/reflect.md` to the
   dynamic form the closing `core_role_directive` line already uses
   (`docs/issue-<n>/reports/${role}.md`) — a pure correctness fix, not a
   new norm, surfaced here because phase 2 will touch this file anyway.
2. **Record-fields gate**: `record-fields-gate.sh` is core-owned and
   generic by design (core issue #66) — this repo does not fork it.
   Instead, phase 2 adds this role's five required sections as prose
   instruction inside `directive.sh`'s `produces`/`hand_off` (per item 1)
   the same way the existing what/why/loop_state fields are currently
   enforced only by the generic gate plus this role's own prose
   discipline. If, during phase 2, this proves insufficiently enforced
   (writer skips a section and nothing blocks the write), that itself
   becomes a finding for a future core-canon issue (parallel to how core
   issue #66 already treats per-role field needs as a config/extension
   point, not a fork) — not something this repo routes around by forking
   the gate.
3. **No change to `hooks.json`, `RECORD_FIELDS_TERMINAL_STATES`, or the
   warrant/hunt mechanism** — orthogonal to this issue (survey §4).
4. **First real exemplar**: this issue's own phase-2 record
   (`docs/issue-12/reports/issue-retrospective.md`, once Approved) becomes
   the first record ever written under these norms, and the first
   exemplar future `use_when` prose can actually point to (closing survey
   §3's "empty exemplar set" finding).

## Open questions for the approver

None blocking — the one soft judgment call (making action items optional
rather than mandatory, §b.4) is stated with its rationale above; flag here
if the approver disagrees before Phase 2 starts.
