#!/usr/bin/env bash
# issue-retrospective's contributing-factors-gate.sh, exercised as a real subprocess.
# Scaffold adapted from implementation-rulebook/tests/run-gate-tests.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE"
GATE="contributing-factors-gate.sh"
# Test-only override: this dev checkout is not laid out as a sibling of
# core (the runtime install layout the gate's own fallback assumes), so
# point CLAUDE_PLUGIN_ROOT_CORE at core directly rather than relying on
# the ../../core fallback.
export CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core}"
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-60s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-60s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

runcase() { # want name file content extra_env...
  want="$1"; name="$2"; file="$3"; content="$4"; shift 4
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/$(dirname "$file")"
  payload="$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$file" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$content")" "$td")"
  printf '%s' "$payload" | env "$@" CLAUDE_PROJECT_DIR="$td" /bin/bash "$HOOKS/$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

# rawcase: build a temp repo with an optional pre-existing record file, run
# the gate against an arbitrary raw stdin payload built by a python
# helper (so JSON escaping is exact), for the Edit/MultiEdit/malformed-JSON/
# absolute-path mandatory cases. build_json_py receives $REC_ABS on argv[1].
rawcase() { # want name existing_content use_absolute_path(0|1) build_json_py raw_override
  want="$1"; name="$2"; existing="$3"; use_abs="$4"; build_py="$5"; raw_override="${6:-}"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  rec="$td/docs/issue-7/reports/issue-retrospective.md"
  mkdir -p "$(dirname "$rec")"
  if [ -n "$existing" ]; then printf '%s' "$existing" > "$rec"; fi
  fp="$rec"
  [ "$use_abs" = "0" ] && fp="docs/issue-7/reports/issue-retrospective.md"
  if [ -n "$raw_override" ]; then
    raw="$raw_override"
  else
    raw="$(python3 -c "$build_py" "$fp")"
  fi
  printf '%s' "$raw" | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$HOOKS/$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

REC=docs/issue-7/reports/issue-retrospective.md
ROOT_ONLY='## Contributing factors
The root cause was a single misconfigured flag.'
FACTORS_ONLY='## Contributing factors
Several structural factors combined: A and B.'
NEITHER='## Contributing factors
Nothing to say here.'

runcase deny  root-cause-no-factors "$REC" "$ROOT_ONLY"
runcase allow factors-no-root-cause "$REC" "$FACTORS_ONLY"
runcase deny  neither-present       "$REC" "$NEITHER"
runcase allow foreign-path "docs/issue-7/reports/coding.md" "$ROOT_ONLY"
runcase allow kill-switch-off "$REC" "$ROOT_ONLY" ISSUE_RETROSPECTIVE_CONTRIBUTING_FACTORS_GATE_OFF=1

# --- mandatory case: kill switch, unrecognized value stays ACTIVE ---------
runcase deny kill-switch-garbage-stays-active "$REC" "$NEITHER" ISSUE_RETROSPECTIVE_CONTRIBUTING_FACTORS_GATE_OFF=banana

# --- mandatory case: Edit with replace_all against multiply-occurring text
rawcase allow edit-replace_all-true-passes \
  '## Contributing factors
placeholder placeholder placeholder' 0 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Edit", "tool_input": {
  "file_path": fp, "old_string": "placeholder",
  "new_string": "structural factors", "replace_all": True}}))
'

rawcase deny edit-replace_all-false-leaves-root-cause \
  '## Contributing factors
placeholder' 0 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Edit", "tool_input": {
  "file_path": fp, "old_string": "placeholder",
  "new_string": "the root cause"}}))
'

# --- mandatory case: MultiEdit with mixed replace_all across edits --------
rawcase allow multiedit-mixed-replace_all \
  '## Contributing factors
x x x root' 0 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "MultiEdit", "tool_input": {"file_path": fp, "edits": [
  {"old_string": "x", "new_string": "factors", "replace_all": True},
  {"old_string": "root", "new_string": "root cause", "replace_all": False}]}}))
'
# every "x" -> "factors" (replace_all:true); "root" -> "root cause" once
# (replace_all:false) -> body "factors factors factors cause" -> factors
# present alongside root-cause language -> allow

# --- mandatory case: malformed JSON denies, fail-closed --------------------
rawcase deny malformed-json-truncated "" 0 "" '{"tool_name":"Write"'
rawcase deny malformed-json-non-object "" 0 "" '"just a string"'
rawcase deny malformed-json-empty-payload "" 0 "" ''

# --- mandatory case: absolute path and ./-prefixed path resolve the same
# scope a plain relative-path fixture already matches -----------------------
rawcase deny absolute-path-root-cause-no-factors \
  "$ROOT_ONLY" 1 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Write", "tool_input": {
  "file_path": fp, "content": "## Contributing factors\nThe root cause was a single misconfigured flag."}}))
'
rawcase deny dot-prefixed-relative-path-root-cause-no-factors \
  "$ROOT_ONLY" 0 '
import json, sys
fp = "./" + sys.argv[1]
print(json.dumps({"tool_name": "Write", "tool_input": {
  "file_path": fp, "content": "## Contributing factors\nThe root cause was a single misconfigured flag."}}))
'

# --- section-scoping regression (issue #21's named laundering defect) -----
LAUNDERED='## Contributing factors
root cause: a misconfigured flag

## Notes
Timeline: three factors of the release schedule delayed this, unrelated to
the section above.'
runcase deny laundered-factors-outside-section "$REC" "$LAUNDERED"

GENUINE_NO_ROOT='## Contributing factors
Several structural factors combined to cause this: A, B, and C.'
runcase allow genuine-factors-no-root-cause-happy-path "$REC" "$GENUINE_NO_ROOT"

# --- mandatory case: missing core (core #75 source guard) fails closed ----
runcase deny missing-core-source-guard "$REC" "$FACTORS_ONLY" CLAUDE_PLUGIN_ROOT_CORE=/nonexistent/core

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
