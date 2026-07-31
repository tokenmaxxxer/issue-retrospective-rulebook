# Current-state survey — issue #18

Scope: this repo's `reflect` plugin as it stands after issue #12 (adopted
retrospective methodology) and issue #13 (core-canon reference switch),
read from `reflect/hooks/{directive.sh,hooks.json}`,
`reflect/.claude-plugin/plugin.json`, `tests/*.sh`, and core canon
(`/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core/hooks/{lib/role-directive.sh,record-fields-gate.sh}`).

## 1. What issue #12 already put in `directive.sh` (prose only)

`reflect/hooks/directive.sh` (post issue-12/issue-13) carries four
role-unique values via `core_role_directive`:

- `you_decide`: retrospective purpose statement (advisory, never
  re-litigates, never fixes).
- `use_when`: names blameless-postmortem as the exemplar methodology and
  the recurred-prediction check as the highest-value finding; requires a
  records-only survey.
- `produces`: phase-1 proposal must name its input records; phase-2
  record must contain, **in order**, Timeline → Contributing factors →
  What we learned (incl. recurred-prediction check) → Action items
  (optional, owner+date-shaped when present); round-end value gates
  (procedure-value, blind-onboarding) apply when the round concludes;
  findings are always `severity: advisory`.
- `hand_off`: record path and phase-gating reminder.

This is a **prose-only** commitment: nothing parses a proposal or record
write to confirm these sections actually exist, are in order, or that
"contributing factors" language wasn't quietly written as "root cause".
Issue #18 is exactly the gap this leaves — implementation-rulebook and
pricing-rulebook both close the equivalent gap with a `PreToolUse`
methodology gate; this repo has none.

## 2. What core canon already enforces mechanically (generic, not retrospective-specific)

`core/hooks/record-fields-gate.sh` (referenced, not vendored, since
issue-13) requires on any write to `docs/issue-<n>/reports/${CLAUDE_ROLE}.md`:
what-was-done, why, upstream-basis, `loop_state`, open-findings, and (when
`loop_state` is non-terminal) next-steps + resolution-path. It is
deliberately role-agnostic (core issue #66's design — identity via
`RECORD_FIELDS_TERMINAL_STATES` config, not per-role forks) and has zero
concept of "timeline," "contributing factors," "recurred-prediction," or
"action item shape." `trailer-gate.sh` / `handbook-trigger-gate.sh` are
likewise generic and out of scope here. `core/hooks/hooks.json` wires
these globally for every plugin install; this repo's own
`reflect/hooks/hooks.json` (2 lines) wires only `directive.sh`
(`SessionStart`) — no `PreToolUse` entry exists in this plugin at all
today.

## 3. Reference shape for a role-specific methodology gate (not to be copied, referenced for pattern only)

`pricing-rulebook`'s `pricing/hooks/methodology-gate.sh` is a `PreToolUse`
gate, additive to (never replacing) the generic record-fields gate, that:
targets a narrow, named write-surface regex (`docs/issue-<n>/proposals/*pricing*.md`
and `docs/issue-<n>/reports/pricing.md`); reconstructs the *resulting*
content for `Write`/`Edit`/`MultiEdit` (denying, fail-closed, if the tool
input doesn't let it determine the result); checks a fixed list of
required elements via keyword/phrase matching against the lower-cased
text; denies naming every missing element in one message; carries its own
kill switch (`PRICING_METHODOLOGY_GATE_OFF=1`); wraps the whole body in
the `__fc` fail-closed-on-any-nonzero/non-2-exit trap pattern used by
every gate in this ecosystem.

`implementation-rulebook`'s `coding/hooks/coding-progress-gate.sh` shows
the **order-constraint / state-tracking** half issue #18 asks about: it
gates a `Bash` `git commit` call (not a file write) by reading a *second*
role's record (`verify.md`) for unresolved blocking findings and refusing
the commit unless a resolution is recorded with a matching sha and the
finder's own `loop_state` reads `cleared`. That is heavier machinery than
this role needs (retrospective has no upstream role gating its commits),
but it establishes the pattern this proposal borrows for a lighter
same-role order constraint: reading the *proposal* file's content from
disk before allowing the *record* write, rather than a separate
persistent state file, since both live in the same git tree already.

`implementation-rulebook/tests/run-gate-tests.sh` is the exercised-as-
subprocess test harness shape: a small `run()`/`report()` scaffold that
`git init`s a scratch repo per case, pipes a synthetic PreToolUse JSON
payload on stdin into the gate script, and asserts the exit code
(`0`=allow, `2`=deny) against a table of named cases.

## 4. Canon-reference constraint (issue text's explicit constraint)

`docs/handbooks/canon-scripts.md` (core canon, referenced via the
`core-canon2` checkout used in issue-13's own survey): "Canon scripts are
referenced, never copied... If a script needs to run inside a rulebook's
own directory for a genuine technical reason... the transition directive
making that call states the reason explicitly." `tests/stub-check.sh`
(already vendored in this repo, verbatim, per its own header) mechanically
fails any rulebook tree that reintroduces a copy of
`trailer-gate.sh`/`record-fields-gate.sh`/`handbook-trigger-gate.sh`/
`parse-check.sh`. A new `methodology-gate.sh` is **not** on that manifest
(pricing-rulebook's own copy is role-owned, not core canon), so adding one
under `reflect/hooks/` does not trip `stub-check.sh` — but this proposal
must still state, explicitly, why the new gate lives in this repo's own
tree rather than being requested as a core-canon addition: because its
required-element list (timeline / contributing-factors / recurred-
prediction / action-item shape) is retrospective-specific in the same way
pricing's six elements are pricing-specific — not a generic §20 concept
core issue #66 already owns.

## 5. Gap this proposal must close

1. `directive.sh`'s phase-1/phase-2 prose is a single paragraph each
   (see §1) — issue #18 (a) asks for per-facet depth (steps, judgment
   criteria, prohibitions), not a longer one-liner.
2. No mechanical check exists that a proposal or record actually contains
   the sections `directive.sh` already promises in prose (§1 vs §2) —
   issue #18 (b) asks for a gate closing exactly this, referencing (not
   copying) pricing's pattern.
3. The methodology has an explicit order constraint already stated in
   prose (Timeline precedes any causal claim; "in order" per §1) that
   nothing currently enforces — issue #18 (b) names state tracking as the
   mechanism if an order constraint exists.
4. No gate test file exists for this plugin (`tests/` only has the three
   repo-wide harness scripts, no `run-gate-tests.sh` analogue) — issue #18
   (c).
5. No agents/checklist exists for the repeated recurred-prediction /
   round-end-value-gate procedure — issue #18 (d), conditional on whether
   the methodology's repeated procedure warrants one.
