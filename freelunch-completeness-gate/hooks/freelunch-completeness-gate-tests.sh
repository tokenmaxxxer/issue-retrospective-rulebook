#!/usr/bin/env bash
# reflect's freelunch-completeness-gate.sh, exercised as a real subprocess.
# Runs against BOTH write surfaces it guards (기획서 proposal + 산출물
# record), per issue #18 proposal (b)/(c) item 5.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE"
GATE="freelunch-completeness-gate.sh"
# Test-only override: this dev checkout is not laid out as a sibling of
# core (the runtime install layout the gate's own fallback assumes), so
# point CLAUDE_PLUGIN_ROOT_CORE at core directly rather than relying on
# the ../../core fallback.
export CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core}"
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-34s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-34s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

runcase() { # want name file content extra_env...
  want="$1"; name="$2"; file="$3"; content="$4"; shift 4
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/$(dirname "$file")"
  payload="$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$file" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$content")" "$td")"
  printf '%s' "$payload" | env "$@" CLAUDE_PROJECT_DIR="$td" /bin/bash "$HOOKS/$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

# rawcase: build a temp repo with an optional pre-existing file, run the
# gate against an arbitrary raw stdin payload built by a python helper (so
# JSON escaping is exact), for the Edit/MultiEdit/malformed-JSON/absolute-
# path mandatory cases. build_json_py receives $fp on argv[1].
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

PROP=docs/issue-7/proposals/issue-retrospective.md
REC=docs/issue-7/reports/issue-retrospective.md

COMPLETE='## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis of what those records show.
## Adopted norms
Adopted per issue-12 rationale, tracing to a named source.'

NO_INPUTS='## What the survey found
Synthesis text.
## Adopted norms
Adopted per issue-12 rationale.'

NO_SYNTHESIS='## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## Adopted norms
Adopted per issue-12 rationale.'

NO_RATIONALE='## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis text, no adopted-norms language here.'

runcase allow proposal-complete   "$PROP" "$COMPLETE"
runcase deny  proposal-no-inputs  "$PROP" "$NO_INPUTS"
runcase allow record-complete     "$REC" "$COMPLETE"
runcase deny  record-no-synthesis "$REC" "$NO_SYNTHESIS"
runcase deny  record-no-rationale "$REC" "$NO_RATIONALE"
runcase allow foreign-path "docs/issue-7/reports/coding.md" "$NO_INPUTS"
runcase allow kill-switch-off "$REC" "$NO_INPUTS" ISSUE_RETROSPECTIVE_FREELUNCH_COMPLETENESS_GATE_OFF=1

# --- mandatory case: kill switch, unrecognized value stays ACTIVE ---------
runcase deny kill-switch-garbage-stays-active "$REC" "$NO_INPUTS" ISSUE_RETROSPECTIVE_FREELUNCH_COMPLETENESS_GATE_OFF=banana

# --- adjacency regression (issue #21 item 2): "adopted" far apart from a
# rationale marker must no longer satisfy the check ------------------------
FAR_APART='## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis text.
## Adopted norms
We adopted several norms in this cycle.

Unrelated commentary follows, several paragraphs of filler text about
process, timelines, and other topics entirely unrelated to that.

More filler. More filler. More filler. More filler. More filler.

More filler. More filler. More filler. More filler. More filler.

More filler. More filler. More filler. More filler. More filler.

Finally, somewhere down here, because reasons, things happened.'
runcase deny adopted-rationale-far-apart-denies "$REC" "$FAR_APART"

ADJACENT='## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis text.
## Adopted norms
We adopted the plural-causation norm per issue #12s rationale.'
runcase allow adopted-rationale-adjacent-allows "$REC" "$ADJACENT"

# --- mandatory case: Edit with replace_all against multiply-occurring text
rawcase allow edit-replace_all-true-passes \
  '## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis text.
## Adopted norms
placeholder placeholder placeholder' 0 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Edit", "tool_input": {
  "file_path": fp, "old_string": "placeholder",
  "new_string": "adopted this per issue #7 rationale", "replace_all": True}}))
'

rawcase deny edit-replace_all-false-leaves-incomplete \
  '## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis text.
## Adopted norms
placeholder' 0 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Edit", "tool_input": {
  "file_path": fp, "old_string": "placeholder",
  "new_string": "adopted", "replace_all": False}}))
'

# --- mandatory case: MultiEdit with mixed replace_all across edits --------
rawcase allow multiedit-mixed-replace_all \
  '## Inputs read
docs/issue-7/reports/coding.md and docs/issue-7/reports/verify.md.
## What the survey found
Synthesis text.
## Adopted norms
x x x root' 0 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "MultiEdit", "tool_input": {"file_path": fp, "edits": [
  {"old_string": "x", "new_string": "y", "replace_all": True},
  {"old_string": "root", "new_string": "adopted per issue #7 rationale", "replace_all": False}]}}))
'

# --- mandatory case: malformed JSON denies, fail-closed --------------------
rawcase deny malformed-json-truncated "" 0 "" '{"tool_name":"Write"'
rawcase deny malformed-json-non-object "" 0 "" '"just a string"'
rawcase deny malformed-json-empty-payload "" 0 "" ''

# --- mandatory case: absolute path and ./-prefixed path resolve the same
# scope a plain relative-path fixture already matches -----------------------
rawcase deny absolute-path-incomplete-denies \
  "$NO_INPUTS" 1 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Write", "tool_input": {
  "file_path": fp, "content": "## What the survey found\nSynthesis text.\n## Adopted norms\nAdopted per issue-12 rationale."}}))
'
rawcase deny dot-prefixed-relative-path-incomplete-denies \
  "$NO_INPUTS" 0 '
import json, sys
fp = "./" + sys.argv[1]
print(json.dumps({"tool_name": "Write", "tool_input": {
  "file_path": fp, "content": "## What the survey found\nSynthesis text.\n## Adopted norms\nAdopted per issue-12 rationale."}}))
'

# --- mandatory case: missing core (core #75 source guard) fails closed ----
runcase deny missing-core-source-guard "$REC" "$COMPLETE" CLAUDE_PLUGIN_ROOT_CORE=/nonexistent/core

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
