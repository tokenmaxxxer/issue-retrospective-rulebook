# Current-state survey — issue #12

Scope: this repo's own `reflect` plugin (installed under role token
`issue-retrospective`, confirmed by `board-gate.sh` refusing writes to
another issue's tree from this branch) — what phase-1 proposal norms and
phase-2 record norms it enforces today, read directly from
`reflect/hooks/directive.sh`, `reflect/hooks/record-fields-gate.sh`, and
core canon (`/home/jwjung/tokenmaxxxer/tokenmaxxxer-core`).

## 1. What the directive already asks for (`reflect/hooks/directive.sh:19-22`)

Four core-canon slots, already populated:
- `you_decide`: "what this issue's history teaches — what went well, what
  failed, what pattern should change next time," explicitly never
  re-litigating other roles' verdicts and never fixing anything.
- `use_when`: names blameless-postmortem practice ("timeline before
  judgment; systems, not people") and this repo's own earlier
  `docs/issue-*/reports/reflect.md` records as exemplars; directs a
  records-only survey (never re-investigate the running system).
- `produces`: requires the proposal to name input record paths; requires
  phase-2 conclusions to cite the record path (and sha where it matters);
  names two round-end value gates (procedure-value / blind-onboarding);
  states findings are always `severity: advisory`.
- `hand_off`: record lives at `docs/issue-<n>/reports/${role}.md` (the
  hardcoded prose says `reflect.md`, but the actual role token this branch
  runs under is `issue-retrospective` — `core_role_directive`'s closing
  line already derives the path from `${role}` dynamically, so the gate
  itself is correct; only the prose literal in `hand_off` is stale, a
  phase-2-scope fix, not phase-1's concern here).

So this role's methodology commitment (blameless postmortem: timeline
first, systems not people) is already stated as *use_when* prose. What is
**not yet enforced mechanically** is the point of this issue: no gate
checks that a record actually contains a timeline, contributing factors
distinct from blame, or owned action items — `record-fields-gate.sh`'s
required-field set is generic across all rulebook roles (see §2), not
retrospective-methodology-specific.

## 2. What `record-fields-gate.sh` currently enforces (generic, core canon)

Per `core/hooks/record-fields-gate.sh` (comment block, lines 6-11) the
gate requires, on any write to `docs/issue-<n>/reports/${CLAUDE_ROLE}.md`:
a "what was done" section, a "why" section, the upstream basis, the
record's own `loop_state`, and an open-findings section; non-terminal
`loop_state` additionally requires next-steps + an open-finding resolution
path. `RECORD_FIELDS_TERMINAL_STATES` is set to `round-done` in this
repo's `directive.sh:17` (the retrospective role's own terminal state,
distinct from core's default `landed`).

This field set is intentionally role-agnostic (core issue #66's design:
identity via config, not per-role copies). It has no notion of "timeline,"
"contributing factor," "blameless," or "action item with owner+date" —
those are retrospective-methodology concepts this role would need to
require *within* its own "what/why" prose, since the gate itself cannot be
edited per-role without reintroducing the copy drift core issue #66 just
removed.

## 3. Existing reflect records in this repo — what a real one looks like

`grep -rl "docs/issue-.*/reports/reflect.md"` and directory listing show
**no `reflect.md` record has ever been written in this repo's history**
(`docs/issue-{5,7,9,13}` all use other roles' report folders —
`coding`/`implementation` — never `reflect`). This role's own `use_when`
exemplar clause ("this repository's own earlier reflect records... show
what a useful lesson looked like") currently has **no instance to point
to** — the exemplar set it names is empty. This is itself a finding: the
directive's phase-1 research instruction assumes a corpus that does not
exist yet; issue #12's adopted norms will produce the first one.

## 4. Constraint check — warrant-hunter (issue text's constraint)

`grep -ril warrant .` in this repo finds only `docs/README.md`'s metaphor
usage — no vendored `warrant-hunter.md`, no hunt-cadence hook. Matches
issue #13's survey finding for the same repo: nothing to reference or
remove here; core issue #63 (warrant-hunt canon promotion) is the
authoritative source for hunt-cadence semantics if this proposal's plugin
plan ever needs to describe interaction with hunt — it does not, since
retrospective methodology and warrant-hunt cadence are orthogonal
concerns. Noted as satisfied, not touched.

## 5. Gap this proposal must close

Phase 1's job (per issue #12) is to pick, on researched grounds, (a) the
proposal-document methodology/sections/evidence format, (b) the
phase-2 record's methodology/required components, (c) the reasoning tying
each to this role's stated value ("what this issue's history teaches"),
and (d) exactly which `directive.sh` prose and which gate behavior encode
that. Sections 1-3 above are the "current state" the proposal must
improve on: prose-only methodology commitment, generic field gate, zero
existing exemplar corpus.
