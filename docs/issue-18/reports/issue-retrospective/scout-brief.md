# Scout brief — issue #18

**Mode:** local-repo sweep, batched-sequential (not web — issue #18 names
its own reference implementations explicitly, so the "field" to survey is
this ecosystem's own hook-machine precedent, not external methodology).
4 angles read in 2 batched Read/Bash pairs this session: (1) pricing-
rulebook's `methodology-gate.sh` element-check pattern, (2)
implementation-rulebook's `coding-progress-gate.sh` + `state.sh` order-
constraint/state pattern, (3) implementation-rulebook's
`tests/run-gate-tests.sh` harness shape, (4) core canon's
`canon-scripts.md` reference-vs-copy norm + `record-fields-gate.sh`'s own
registration model. Angles chosen against the survey's gaps (survey §1-5):
prose-only methodology, no gate, no order enforcement, no gate tests, no
checklist.

## Judge point 1 — convergence

All four angles converge on one shape, already used twice in this same
ecosystem (pricing, implementation) rather than invented fresh:

1. **Additive, role-owned gate, never a core-canon fork.** Both
   `methodology-gate.sh` (pricing) and `coding-progress-gate.sh`
   (implementation) live in the *role's own* `hooks/` dir, run alongside
   (never instead of) the generic core gates, and open with a comment
   stating exactly that relationship. Neither is on `stub-check.sh`'s
   canon manifest.
2. **Narrow write-surface regex, named to this role's own paths.**
   `pricing/hooks/methodology-gate.sh:94-95` matches only
   `docs/issue-<n>/proposals/*pricing*.md` and
   `docs/issue-<n>/reports/pricing.md`; anything else exits 0 immediately
   — "not this gate's business."
3. **Resulting-content reconstruction, not raw diff.** Both gates read
   `tool_input` for `Write`/`Edit`/`MultiEdit`, reconstruct the *would-be*
   file content (applying old→new for Edit/MultiEdit against the file
   already on disk), and deny (fail-closed) if the tool shape makes that
   undeterminable — never guess from a partial diff.
4. **Keyword/phrase presence-check per required element, one deny message
   naming every missing element.** Pricing's six-element list
   (`methodology-gate.sh:163-218`) is the direct template for a
   retrospective four/five-element list (timeline / contributing-factors-
   not-root-cause / recurred-prediction-check / action-item shape).
5. **Order/state constraints route through what's already on disk, not a
   new persistent state file, when both sides live in the same git tree.**
   `coding-progress-gate.sh` reads a *second role's* record file directly
   at gate time — no separate state file — because the ordering fact
   (verify's `loop_state`) already lives in a file the gate can read.
   `implementation-rulebook/coding/hooks/state.sh` is the one place a
   *persistent* state file pattern appears in this ecosystem, but it is
   informational (`SessionStart`, prints resume context) and explicitly
   never blocks — the blocking order-constraint work is done by
   `coding-progress-gate.sh` reading files directly, not by `state.sh`.
6. **Fail-closed trap-at-top + explicit kill switch, on every gate.**
   `__fc` trap installed as the first executable line in all three gates
   read; `<ROLE>_METHODOLOGY_GATE_OFF`-shaped env var, defaulting to on.
7. **Tests as real subprocesses, not shell-logic unit tests.** `run-gate-
   tests.sh`'s `run()`/`report()` scaffold: `git init` a scratch repo per
   case, pipe a synthetic PreToolUse JSON payload on stdin into the actual
   script file, assert exit code (0=allow, 2=deny). No mocking of the
   gate's internals — the same binary the hook wiring would actually
   invoke.

One round was sufficient: all four angles are precedent already living in
this same ecosystem (not independent field lineages), so there was no
convergence-vs-divergence judgment to make across differing schools of
thought — the question was "what shape does this ecosystem already use
for exactly this problem," and all four reads answered with the same
shape. A second round (e.g. reading a fifth rulebook's gate) would spend
budget confirming a pattern already confirmed four times, not surfacing a
new build decision. Stopped at stage 1 (sweep only) — well inside the
5-stage/3-minute budget; elapsed wall-clock for the whole scout pass was
under 2 minutes (two batched tool-call rounds, no deepening round needed).

## Must-bes (binding candidates for adoption)

- Gate lives in `reflect/hooks/` (role-owned), never in core canon or as a
  vendored copy of a core-manifest file.
- Write-surface regex scoped to this role's own proposal/record paths only
  (`docs/issue-<n>/proposals/*issue-retrospective*.md` and
  `docs/issue-<n>/reports/issue-retrospective.md`) — anything else passes
  through untouched.
- Resulting-content reconstruction for Write/Edit/MultiEdit; fail-closed
  deny when undeterminable.
- One deny message naming every missing required element, not one deny
  per element.
- Fail-closed `__fc` trap + a `RETROSPECTIVE_METHODOLOGY_GATE_OFF`-shaped
  kill switch (role token is `issue-retrospective`; the env-var
  convention in this ecosystem uppercases and underscores the role name,
  matching `role-directive.sh`'s own `tr` transform).
- Gate tests as real subprocesses against the actual script file, table-
  driven, allow/deny pairs.

## Adopt / skip

- **Adopt**: pricing's element-presence-check gate shape wholesale for
  both this role's write surfaces (proposal AND record — pricing gates
  both too) — directly closes survey §1/§5's "prose promises, nothing
  checks" gap.
- **Adopt**: reading the *proposal file already on disk* to enforce the
  survey→scout→proposal *internal* ordering this role's own phase-1
  protocol requires (the scout directive this session ran under: "survey
  MUST run before scout"), the same way `coding-progress-gate.sh` reads
  a second record file directly — no new persistent state file needed,
  since the proposal write itself is the one place order matters and the
  survey/scout files it names are already on disk by the time the
  proposal write happens.
- **Skip**: `coding-progress-gate.sh`'s full cross-role blocking-finding-
  resolution machinery (verify→coding) — this role has no upstream role
  gating its own commits; adopting that shape here would build a
  mechanism for a coupling that does not exist in this role's contract
  (reflect is read-only over other roles' records, never blocked by
  them).
- **Skip**: a dedicated persistent `state.sh`-style `SessionStart` state
  file — the one ordering fact this role needs (has the proposal already
  been written, and does it name a survey + scout brief) is checkable by
  reading files already on disk at write time; a separate state file
  would duplicate information the git tree already holds, which is
  exactly the kind of unnecessary machinery `implementation-rulebook`
  itself reserves for a case (cross-session hunt-dispatch counting) this
  role does not have.

## Gap line

Current state (survey §1-2) has retrospective methodology fully stated as
`directive.sh` prose and a generic §20 field gate with zero retrospective-
specific concept. Missing, confirmed by this sweep: a role-owned
`PreToolUse` gate mirroring pricing's element-check shape scoped to this
role's own two write surfaces; an order check (proposal must name a
survey + scout-brief path, or an explicit scout-skip record, before its
own required elements are considered satisfied) implemented as a file-read
against what's already on disk, not a new state file; a gate-test file
under `tests/` (currently absent — only the three repo-wide harness
scripts exist); a decision on whether a checklist/agent is warranted for
the recurred-prediction-check + round-end-value-gate procedure (this
sweep found no exemplar of a *checklist file* in either pricing-rulebook
or implementation-rulebook — both encode their repeated procedure as gate
logic + directive prose only, no separate checklist artifact — noted as a
skip candidate for the proposal itself to weigh, not asserted here as a
must-be since no reference implementation in this ecosystem actually has
one).

Sources (local repo paths, this machine, read this session):
- /home/jwjung/tokenmaxxxer/rulebooks/pricing-rulebook/pricing/hooks/methodology-gate.sh
- /home/jwjung/tokenmaxxxer/rulebooks/implementation-rulebook/coding/hooks/coding-progress-gate.sh
- /home/jwjung/tokenmaxxxer/rulebooks/implementation-rulebook/coding/hooks/state.sh
- /home/jwjung/tokenmaxxxer/rulebooks/implementation-rulebook/coding/hooks/hunt-guard.sh
- /home/jwjung/tokenmaxxxer/rulebooks/implementation-rulebook/tests/run-gate-tests.sh
- /home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core/hooks/record-fields-gate.sh
- /home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core/hooks/lib/role-directive.sh
- /tmp/claude-1000/core-canon2/docs/handbooks/canon-scripts.md
- this repo: reflect/hooks/{directive.sh,hooks.json}, tests/{stub-check.sh,parse-check.sh,deny-only-check.sh}
