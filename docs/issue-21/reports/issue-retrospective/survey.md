# Current-state survey — issue #21: gate A+ remediation

## Scope

This repo's six role-owned plugins (issue #18/#19/#20 plugin-set), each
`hooks/<name>.sh` + `hooks/<name>-tests.sh`:
`timeline-order-gate`, `contributing-factors-gate`,
`recurred-prediction-gate`, `action-item-shape-gate`,
`freelunch-completeness-gate`, `proposal-order-gate`. Plus `README.md`
and `reflect/hooks/directive.sh`.

## §1 — compliance-check.sh evidence (core issue #72's detector, run
against this repo's own gates)

```
$ bash core/hooks/tests/compliance-check.sh <this-repo>
FAIL timeline-order-gate.sh:      hand-rolled kill switch; .replace() reconstruction
FAIL action-item-shape-gate.sh:   hand-rolled kill switch; .replace() reconstruction
FAIL proposal-order-gate.sh:      hand-rolled kill switch
FAIL freelunch-completeness-gate.sh: hand-rolled kill switch; .replace() reconstruction
FAIL contributing-factors-gate.sh: hand-rolled kill switch; .replace() reconstruction
FAIL recurred-prediction-gate.sh: hand-rolled kill switch; .replace() reconstruction
```

All six plugins fail both checks (`proposal-order-gate.sh` only on the
kill-switch check — it never reconstructs Edit/MultiEdit content, it only
reads the subject's existing proposal file).

## §2 — kill-switch bug (matches audit's "킬스위치 비인식 값=활성")

Every plugin uses the same idiom, e.g. `contributing-factors-gate.sh`:

```sh
case "${ISSUE_RETROSPECTIVE_CONTRIBUTING_FACTORS_GATE_OFF:-}" in
  ""|0|false|no|off) ;;
  *) exit 0 ;;
esac
```

This is exactly the bug `gate-house-standard.md` §"two bugs" names: any
unrecognized value (a typo, a stray truthy-looking string) hits the `*`
branch and **disables** the gate — fail-open on garbage input. Confirmed
live in all six plugins, not isolated.

## §3 — `replace_all` ignored (matches audit's "Edit replace_all 무시")

Five of six plugins (all but `proposal-order-gate.sh`, which never
reconstructs writes) do resulting-content reconstruction like
`contributing-factors-gate.sh`:

```python
elif tool == "Edit":
    o, n = ti.get("old_string"), ti.get("new_string")
    if isinstance(o, str) and isinstance(n, str) and current is not None and o in current:
        new_text = current.replace(o, n, 1)
elif tool == "MultiEdit":
    ...
    text = text.replace(o, n, 1)
```

`count=1` is hardcoded; `tool_input.replace_all` (a real field on both
`Edit` and each `MultiEdit` edit) is never read. When a caller sets
`replace_all: true` on a multiply-occurring `old_string`, the actual tool
call replaces every occurrence but the gate judges content as if only the
first changed — the gate can allow content whose real post-edit form it
never evaluated (or deny content that would have been fine after a full
replace). This is the exact bug `gate-lib.py`'s
`gate_reconstruct_write` was built to fix (`gate-house-standard.md` §"two
bugs", item 2).

## §4 — semantic check is body-wide substring match, not
section/adjacency (matches audit's "risk factors 문서 전역 매치")

`contributing-factors-gate.sh`'s core check, after stripping heading
lines:

```python
low = body.lower()
has_factors = bool(re.search(r'\bcontributing factors?\b|\bfactors\b', low))
has_root_cause = "root cause" in low
if has_root_cause and not has_factors:
    deny(...)
if not has_factors:
    deny(...)
```

`has_factors` matches the bare word "factors" **anywhere in the entire
record body**, with no requirement that it appear in a Contributing
factors section or anywhere near the causal claim it's meant to qualify.
A record can state "root cause: X" in its Contributing factors section
and separately use the word "factors" in an unrelated sentence elsewhere
(e.g. "Timeline: three factors of the release schedule delayed this") and
the gate allows it — single-root-cause attribution laundered past the
check by an unrelated word match. This is the exact class of defect the
proposal that shipped this gate (`docs/issue-18/proposals/issue-retrospective.md`,
"Open questions for the approver") already flagged as accepted risk:
*"a record could still misuse 'factors' in a way that isn't genuinely
plural attribution."* Issue #21's audit confirms this materialized.

By contrast, `timeline-order-gate.sh` already does section/order-aware
matching correctly — it anchors on `^\s*#{1,6}\s*timeline\b` (structural
heading match) and checks causal language's *position* relative to that
heading (`before_timeline = new_text[: m.start()]`), not a body-wide
substring. `action-item-shape-gate.sh` similarly anchors on the Action
items heading and slices to the *next* heading before checking section
content. Both are the shape `contributing-factors-gate.sh` should have
used from the start; `recurred-prediction-gate.sh` and
`freelunch-completeness-gate.sh` also use unanchored `low = new_text.lower()`
+ body-wide `re.search`, i.e. the same class of substring-only check —
lower audit priority than contributing-factors (issue #21's audit names
"risk factors" specifically) but the same underlying pattern, so the
remediation should apply uniformly rather than patch one plugin only.

## §5 — already-sound, do not re-touch

- **fail-closed trap-at-top**: every plugin already installs `__fc`/trap
  as the very first statement before `set -uo pipefail` — matches
  `gate_trap_fail_closed`'s contract exactly, just hand-rolled instead of
  sourced.
- **malformed-JSON deny**: every plugin already denies on empty stdin,
  non-JSON payload, and non-object top level, before touching
  `tool_input`.
- **deny reason to stderr**: every plugin's `deny()` already writes to
  stderr (`echo ... >&2`) before `exit 2`. Root-level bash `deny()` and
  the Python payload's inner `deny()` both do this consistently.
- **absolute-path normalization**: `_under()` (bash) and each plugin's
  Python `resolve()` already run `os.path.realpath` + `posixpath.normpath`
  and accept both absolute and relative `file_path` values, checking
  containment via `root + "/"` prefix. No live bug found in manual review
  or `compliance-check.sh` (which has no absolute-path check of its own,
  but the pattern matches `gate_normalize_path`'s documented contract).
  Migrating to `gate_lib.gate_normalize_path` is still worth doing per the
  issue's "reference core canon, don't reimplement" instruction, but this
  is not a live defect the way §2/§3/§4 are.

## §6 — README staleness (matches audit's "README가 reflect 시절 기술")

`README.md` describes a `reflect` role (`reflect/hooks/directive.sh`,
plugin name `reflect@tokenmaxxxer-reflect`, kill switch `REFLECT_CYCLE_OFF`,
record vocabulary `loop_state`) and says *"Everything that used to live
here for coordination... is deleted"* as if this is the reflect-era
minimal stub repo. None of that matches the current tree: the role is
`issue-retrospective` (per `docs/specs/approvers.md` context and the
branch/record naming throughout `docs/issue-18`, `docs/issue-20`), there
is no `reflect/` plugin set installed as the enforcement layer — the six
plugins above (`*-gate/hooks/*.sh`) are the actual mechanism, each in its
own top-level directory, each with its own `ISSUE_RETROSPECTIVE_<NAME>_GATE_OFF`
kill switch. The README documents a prior architecture; a reader has no
accurate map of what ships today.

## §7 — precondition check (core issue #72)

`core/hooks/lib/gate-lib.sh` + `gate-lib.py` exist and are landed at
`/home/jwjung/tokenmaxxxer/tokenmaxxxer-core` (confirmed by direct file
read), exposing `gate_trap_fail_closed`, `gate_kill_switch_active`,
`gate_deny`/`gate_allow`, `gate_parse_json_or_deny`, `gate_normalize_path`,
`gate_reconstruct_write`, `gate_bash_write_targets`, plus
`core/hooks/tests/run-gate-lib-tests.sh` (six mandatory case groups) and
`core/hooks/tests/compliance-check.sh`. Issue #21's stated precondition
("core issue #72 랜딩된 뒤 그 라이브러리를 참조해 구현") is satisfied —
this proposal can reference-adopt rather than wait or reimplement.
