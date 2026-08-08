# Scout brief — issue-31

Mode: single-pass, no external web search (angles are internal to the
repo/marketplace ecosystem already named as this role's own exemplars in
`issue-retrospective/hooks/directive.sh`'s `use_when` clause — its
sweep-target is prior `issue-retrospective` records and the blameless
postmortem source standard, not external product exemplars). One stage.

Angles checked concurrently:
1. Spec file itself (`roles/specs/issue-retrospective.spec.json`) —
   ground truth for required fields/loop_state (read in survey.md).
2. Prior records in this repo (`docs/issue-12,18,21,24,27/reports/issue-retrospective.md`)
   — how blameless-postmortem structure is already realized here.
3. `blameless-postmortem` skill description (available in this session's
   skill list) — cross-check against the spec's cited `source_standard`.

## Must-bes (from the spec + blameless-postmortem lineage)

- A retro must be traceable to a unique record identity (`retro_id`) —
  every prior record here already has this implicitly via its issue
  number/file path, just not a named field.
- A retro must state impact before or alongside timeline
  (`impact_summary`) — blameless-postmortem's own required sections
  include "quantify impact" per that skill's own description; this
  rulebook's current record order has no impact section at all — a real
  gap, not just missing metadata.
- Action items must exist and be traceable (spec: `required: true` +
  reference-resolution to real tracked issues) — this rulebook currently
  treats them as optional, which undershoots the spec.

## Adopt

- Name `retro_id` explicitly as `issue-<n>` (the value already flowing
  through file path + commit trailer) rather than inventing a new
  identifier scheme — reuses an existing, already-enforced invariant.
- Add `Impact summary` as a new required record section, placed
  immediately after `Timeline` (impact follows from what happened,
  before contributing factors are analyzed) — consistent with blameless
  lineage ("quantify impact" ranks alongside the timeline, ahead of root-
  cause-style analysis).
- Rename terminal loop_state `round-done` → `landed` to match the spec
  exactly (no reason to diverge — nothing in this repo's own content
  depends on the string `round-done` beyond the directive's own env var).
- Add the missing progress (`gathering`, `writing`) and refusal/error
  (`blame-language-detected`, `timeline-unreachable`) states explicitly
  to directive text, since none exist today.

## Skip

- Do not invent a new `retro_id` numbering scheme independent of
  `issue-<n>` — the reference-resolution and issue-tracking invariants
  already used elsewhere in this repo (Subject: issue-<n> trailer) make
  a second identifier redundant and risks drift between the two.
- Do not fold `blame-language-detected` into `contributing-factors-gate`
  as a side-effect of its existing singular-attribution check — the two
  are different concepts (person-directed blame vs. singular causation);
  conflating them risks the gate silently missing person-directed blame
  that isn't phrased as "root cause".

## Gap line

Already met: `timeline` (fully gated), `write_scope`
(`docs/issue-<n>/reports/issue-retrospective.md` matches exactly),
plural-causation framing (partial overlap with blame refusal, not a full
match).
Missing entirely: `retro_id` as a named field, `impact_summary` as a
section, `action_items` required-not-optional, full loop_state
vocabulary, person-directed blame-language refusal.

Sources: `roles/specs/issue-retrospective.spec.json` (local marketplace
copy); `docs/issue-27/reports/issue-retrospective.md`,
`docs/issue-24/reports/issue-retrospective.md` (this repo's own prior
records); `blameless-postmortem` skill description (session skill
listing, citing Google SRE lineage retrospective format — same lineage
the spec's own `source_standard` cites).
