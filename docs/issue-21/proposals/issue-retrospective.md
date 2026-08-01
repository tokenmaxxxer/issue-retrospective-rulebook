# Proposal — issue #21: gate A+ remediation (B- → A+)

Phase 1 only. No execution in this PR; Phase 2 opens on Approve.

## Scout: skipped (recorded per scout directive)

Skip condition: the spec leaves no design decision open. Issue #21 names
the fix mechanism explicitly (adopt `core/hooks/lib/gate-lib.sh`, landed
by core issue #72 — "그 라이브러리를 참조해 구현(자체 재구현 금지)"), and
this repo already contains the target pattern for the semantic-check
upgrade internally: `timeline-order-gate.sh`'s existing heading-anchor +
positional check (survey §4) is the bar the other five plugins must be
brought up to. This is internal gate-library adoption inside one repo,
not product-shaped or exemplar-shaped work — there is no external field
to sweep.

## Inputs read

- This repo: all six `*-gate/hooks/*.sh` + `*-tests.sh` files, `README.md`,
  `docs/issue-18/proposals/issue-retrospective.md` (this plugin set's own
  origin proposal, including its accepted-risk "Open questions" section
  that issue #21's audit confirms materialized), `docs/specs/approvers.md`.
- Core canon (referenced, not copied): `core/hooks/lib/gate-lib.sh`,
  `core/hooks/lib/gate-lib.py`, `core/hooks/tests/run-gate-lib-tests.sh`,
  `core/hooks/tests/compliance-check.sh`,
  `docs/handbooks/gate-house-standard.md` (issue #72's canon).
- Evidence: `compliance-check.sh` run directly against this repo's gates
  (survey §1) — six FAIL results, all naming the exact two defect classes
  gate-lib.sh exists to fix.
- Details: `docs/issue-21/reports/issue-retrospective/survey.md`.

## What the survey found

Running core issue #72's own compliance detector against this repo's six
plugins returns six FAILs (survey §1): every plugin hand-rolls a
kill-switch case statement with the confirmed fail-open bug (unrecognized
value disables instead of staying active, survey §2), and five of six
hand-roll Edit/MultiEdit reconstruction via `.replace(o, n, 1)` that
ignores `replace_all` (survey §3) — both are exactly the defect classes
`gate-lib.sh`/`gate-lib.py` were built to fix, landed and referenceable
per the issue's precondition (survey §7). Separately,
`contributing-factors-gate.sh`'s semantic check matches the bare word
"factors" anywhere in the record body, with no requirement that it sit in
a Contributing factors section or near the causal claim it qualifies
(survey §4) — this is the exact residual risk this plugin's own origin
proposal (`docs/issue-18/proposals/issue-retrospective.md`, "Open
questions for the approver") flagged as accepted and issue #21's audit
now confirms materialized. The same substring-only shape (unanchored
`.lower()` + body-wide `re.search`) also exists in
`recurred-prediction-gate.sh` and `freelunch-completeness-gate.sh`, at
lower audit priority but the same underlying defect (survey §4).
`timeline-order-gate.sh` and `action-item-shape-gate.sh` already do
heading-anchored, position-aware matching — the pattern this proposal
generalizes to the rest. Fail-closed trap-at-top, malformed-JSON deny,
deny-to-stderr, and absolute-path normalization are all already sound
across every plugin (survey §5) and are migrated to the library call for
canon-reference compliance, not because a live bug was found in them.
README staleness is confirmed: it documents a prior `reflect`-role
single-plugin architecture that no longer matches the six-plugin,
`issue-retrospective`-role tree that actually ships (survey §6).

## (1) Full defect remediation

**Library adoption, every plugin** — replace hand-rolled machinery with
`gate-lib.sh`/`gate-lib.py` calls, per `gate-house-standard.md`'s
per-repo migration checklist:

- Kill switch: `gate_kill_switch_active "${ISSUE_RETROSPECTIVE_<NAME>_GATE_OFF:-}" || { trap - EXIT; exit 0; }`
  replaces every `case ... esac` block. Fixes survey §2 in all six
  plugins in one mechanical swap; each plugin keeps its own distinct env
  var name (independence property from issue #18/#19's plugin-set design
  is preserved — the library call is per-plugin, not a shared kill
  switch).
- Fail-closed trap: `gate_trap_fail_closed` (bash) replaces the
  hand-rolled `__fc`/`trap __fc EXIT` pair — same contract, sourced
  instead of reimplemented, in all six plugins.
- Reconstruction: the Python payload loads `gate_lib.py` via the
  `GATE_LIB_PY` env var (per `gate-lib.sh`'s usage comment) and calls
  `gate_lib.gate_reconstruct_write(tool, tool_input, current_content)`
  instead of the hand-rolled `.replace(o, n, 1)` branch, in the five
  plugins that reconstruct writes (all but `proposal-order-gate.sh`,
  which only reads the subject's existing proposal file and does no
  Write/Edit/MultiEdit reconstruction of its own). Fixes survey §3 —
  `replace_all` is now honored per-edit for `MultiEdit`, matching the
  real tool call's actual resulting content.
- Path normalization: `gate_normalize_path(root, path)` replaces each
  plugin's hand-rolled `resolve()` — not fixing a live bug (survey §5
  found the existing logic already sound) but removing the
  reimplementation the issue's precondition instructs against, and
  giving all six plugins one behavior for `./`-prefixed and absolute
  paths instead of six independently-maintained copies.
- Malformed-JSON deny and deny-to-stderr already match
  `gate_parse_json_or_deny`/`gate_deny`'s contract; migrated to the
  library calls verbatim for the same canon-reference reason, no
  behavior change.

**Canon-reference compliance**: per `canon-scripts.md`'s reference-not-copy
rule (already this repo's practice per issue #18's proposal), no plugin
vendors a copy of `gate-lib.sh`/`gate-lib.py` — each sources/imports it
from `core`'s installed location the same way `gate-lib.sh`'s own usage
comment specifies. `stub-check.sh`'s canon manifest already lists these
two files (`gate-house-standard.md` §"Compliance detector"), so a future
accidental vendored copy is caught automatically; no change needed to
`stub-check.sh` itself.

## (2) Semantic-check upgrade: substring → section/adjacency

Applies the shape `timeline-order-gate.sh`/`action-item-shape-gate.sh`
already use (heading-anchor, then scope the check to that section or to
positional relationship, never a body-wide substring) to the three
plugins currently doing unanchored body-wide matching:

- **`contributing-factors-gate.sh`** (issue's named example — "risk
  factors" 문서 전역 매치): anchor on
  `^\s*#{1,6}\s*contributing factors?\b`. If the heading is absent, deny
  (same shape as `timeline-order-gate.sh`'s missing-Timeline-heading
  deny) — a record cannot satisfy this plugin by using the word "factors"
  anywhere else in the document. Slice to the next heading (or EOF) to
  get the section body, exactly as `action-item-shape-gate.sh` already
  does for its own section. Within that section body: `has_factors` check
  runs only against the section text (never the full document), and the
  existing "root cause without factors" deny additionally checks for
  "root cause" **outside** the section with no in-section factors
  language nearby — i.e. a causal claim made anywhere in the document
  that never gets addressed by the structural section is still caught,
  not just a causal claim inside the section itself. This directly closes
  the laundering path survey §4 confirmed (a stray unrelated use of
  "factors" elsewhere no longer satisfies the check).
- **`recurred-prediction-gate.sh`**: anchor on the "What we learned"
  heading (per issue #18's directive-deepening body-order — this is the
  section the recurred-prediction question belongs to), scope
  "recurred"/"predicted"/"no earlier record" matching to that section
  body plus a document-wide fallback only for the explicit "no earlier
  record existed" phrase (which by its nature may legitimately sit
  outside a heading in a short record) — narrower than today's
  unrestricted document-wide match, without breaking the one accepted
  document-wide fixture from issue #18's own test plan.
- **`freelunch-completeness-gate.sh`**: its three checked elements
  (inputs-read, synthesis, adopted-norms-with-rationale) are themselves
  section-shaped already (`inputs_named` already anchors on a heading);
  extend the same anchor-then-scope treatment to the `synthesis_present`
  and `adopted_with_rationale` checks so all three elements are verified
  as actual sections/paragraphs the write introduces, not any occurrence
  of their trigger words anywhere in the document.

No change to `action-item-shape-gate.sh` or `timeline-order-gate.sh` — 
survey §4/§5 found these already structurally sound; touching them would
be scope beyond what the audit named.

## (3) Mandatory test cases (phase 2 fills exact fixtures; case list is
the phase-1 commitment)

New shared six-case group, run against **every** plugin (adapted from
`gate-house-standard.md`'s `run-gate-lib-tests.sh` mandatory list — this
proposal adopts it as this repo's own bar, not a separate invention):

1. `Edit` with `replace_all: true` against a multiply-occurring
   `old_string` → gate judges the fully-replaced resulting content, not a
   single-occurrence simulation.
2. `MultiEdit` with a mix of `replace_all: true`/`false` edits in one
   call → each edit's own flag honored independently.
3. Malformed JSON (truncated, non-object, empty stdin) → deny, fail
   closed.
4. Kill switch set to an unrecognized/garbage value (e.g. `maybe`) →
   gate stays **active** (this is the regression test for survey §2's
   bug — a case that could not even be written correctly under the old
   hand-rolled logic, since the old logic actively disabled on this
   input).
5. Absolute `file_path` targeting the plugin's own write surface, plus a
   `./`-prefixed relative variant → both resolve to the same scope a
   plain relative-path fixture already matches.
6. A `Bash`-tool file write reaching the same target a `Write`-tool call
   would hit → out of scope to require for these six plugins (none
   currently checks Bash-originated writes and the issue does not name
   this gap) — recorded here as an explicit deferral, not silently
   dropped from the mandatory list.

Plus, **per-plugin, the section-scoping regression case** (issue's
"semantic 검사... 상향" requirement, tested directly rather than only
implemented):

7. `contributing-factors-gate.sh`: a record containing "root cause: X" in
   its Contributing factors section, plus an unrelated sentence elsewhere
   in the document containing the bare word "factors" (survey §4's exact
   laundering shape) → **deny**. This is the regression test that fails
   under the current substring-only implementation and must pass after
   remediation — the single most direct evidence this proposal's fix
   actually closes the gap the issue's audit named.
8. Same plugin: "root cause" absent, "Contributing factors" section
   present with genuine plural-factor language inside it → allow
   (unchanged happy path).
9. `recurred-prediction-gate.sh` / `freelunch-completeness-gate.sh`: an
   analogous case — trigger word present only outside the relevant
   section/heading, no legitimate content in-section → deny (proves the
   scoping actually narrowed the match, not just for
   contributing-factors).

All new and existing per-plugin cases must be green in the same delivery
that lands the fixes — per the issue's requirement ("배송 상태에서 전
스위트 green"), phase 2 does not land partial passes.

## (4) README rewrite

Replace the current `reflect`-role description with the actual shipped
architecture (survey §6): role is `issue-retrospective`, no single
`reflect/` plugin — six independent top-level plugin directories
(`timeline-order-gate/`, `contributing-factors-gate/`,
`recurred-prediction-gate/`, `action-item-shape-gate/`,
`freelunch-completeness-gate/`, `proposal-order-gate/`), each
`hooks/<name>.sh` + `hooks/<name>-tests.sh`, each with its own
`ISSUE_RETROSPECTIVE_<NAME>_GATE_OFF` kill switch (not the stale
`REFLECT_CYCLE_OFF`), each additive to core's generic
`record-fields-gate.sh` per issue #18's plugin-set model. No ghost files:
`reflect/hooks/directive.sh` is real (survey confirms it exists) and
stays documented as the `SessionStart` role-directive stub it actually
is; the removed "Everything that used to live here... is deleted"
narrative section is dropped since it describes a prior architecture, not
this one.

## Rationale summary (traced to source)

- Library adoption over reimplementation: issue #21's own precondition
  clause ("자체 재구현 금지"), confirmed satisfiable by direct read of
  the landed `gate-lib.sh`/`gate-lib.py` (survey §7) and by running
  `compliance-check.sh` directly against this repo (survey §1) rather
  than assuming which plugins need it.
- Section/adjacency shape for the semantic-check upgrade: not invented —
  copied from this repo's own already-correct plugins
  (`timeline-order-gate.sh`, `action-item-shape-gate.sh`, survey §4/§5),
  the same "adopt what already works next door" instruction issue #18's
  proposal followed for its gate mechanics.
- Test list: `gate-house-standard.md`'s own mandatory six-case group,
  adopted as this repo's bar rather than deriving a separate list, plus
  section-scoping regression cases scoped directly from the audit's named
  defect (survey §4) and its own gate's origin proposal's flagged risk
  (`docs/issue-18/proposals/issue-retrospective.md`, "Open questions").
- README scope: rewritten only to match the tree survey §6 confirmed by
  direct listing — no aspirational content, no re-introduction of the
  deleted coordination-machinery narrative.

## Open questions for the approver

None blocking. One scope note: the Bash-tool-write coverage case
(`run-gate-lib-tests.sh` case 6) is deferred (§3, item 6) since none of
these six plugins currently gates Bash-originated writes and issue #21's
audit does not name this gap — flag here if the approver wants it added
to this remediation's scope rather than left for a future issue.
