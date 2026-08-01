#!/usr/bin/env bash
# reflect's proposal-order-gate.sh, exercised as a real subprocess. Unlike
# the other plugins, this gate reads the subject's own phase-1 proposal
# directly off disk (state via file-read, no persistent state file), so the
# fixture proposal must be written into the scratch repo before the record
# write is simulated.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE"
GATE="proposal-order-gate.sh"
# Test-only override: this dev checkout is not laid out as a sibling of
# core (the runtime install layout the gate's own fallback assumes), so
# point CLAUDE_PLUGIN_ROOT_CORE at core directly rather than relying on
# the ../../core fallback.
export CLAUDE_PLUGIN_ROOT_CORE="${CLAUDE_PLUGIN_ROOT_CORE:-/home/jwjung/tokenmaxxxer/tokenmaxxxer-core/core}"
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-34s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-34s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

runcase() { # want name record_file record_content proposal_content(''=no proposal) extra_env...
  want="$1"; name="$2"; recfile="$3"; reccontent="$4"; propcontent="$5"; shift 5
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  mkdir -p "$td/$(dirname "$recfile")"
  if [ -n "$propcontent" ]; then
    mkdir -p "$td/docs/issue-7/proposals"
    printf '%s' "$propcontent" > "$td/docs/issue-7/proposals/issue-retrospective.md"
  fi
  payload="$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$recfile" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$reccontent")" "$td")"
  printf '%s' "$payload" | env "$@" CLAUDE_PROJECT_DIR="$td" /bin/bash "$HOOKS/$GATE" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$want" "$got" "$name"
}

# rawcase: build a temp repo with an optional pre-existing phase-1 proposal,
# run the gate against an arbitrary raw stdin payload built by a python
# helper (so JSON escaping is exact), for the malformed-JSON / absolute-path
# mandatory cases. build_json_py receives $REC_ABS on argv[1].
rawcase() { # want name proposal_content use_absolute_path(0|1) build_json_py raw_override
  want="$1"; name="$2"; propcontent="$3"; use_abs="$4"; build_py="$5"; raw_override="${6:-}"
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  rec="$td/docs/issue-7/reports/issue-retrospective.md"
  mkdir -p "$(dirname "$rec")"
  if [ -n "$propcontent" ]; then
    mkdir -p "$td/docs/issue-7/proposals"
    printf '%s' "$propcontent" > "$td/docs/issue-7/proposals/issue-retrospective.md"
  fi
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
NO_SURVEY='## Inputs read
Nothing survey-shaped here.'
SURVEY_AND_SKIP='## Inputs read
docs/issue-7/reports/issue-retrospective/survey.md was the current-state survey.
Scouting was skipped: pure bugfix, no design decision open.'
SURVEY_AND_SCOUT='## Inputs read
docs/issue-7/reports/issue-retrospective/survey.md and
docs/issue-7/reports/issue-retrospective/scout-brief.md.'

runcase deny  no-proposal-on-disk     "$REC" "content" ""
runcase deny  proposal-no-survey-name "$REC" "content" "$NO_SURVEY"
runcase allow survey-plus-scout-skip  "$REC" "content" "$SURVEY_AND_SKIP"
runcase allow survey-plus-scout-brief "$REC" "content" "$SURVEY_AND_SCOUT"
runcase allow foreign-path "docs/issue-7/reports/coding.md" "content" ""
runcase allow kill-switch-off "$REC" "content" "" ISSUE_RETROSPECTIVE_PROPOSAL_ORDER_GATE_OFF=1

# --- mandatory case: kill switch, unrecognized value stays ACTIVE ---------
# No phase-1 proposal on disk -> gate stays active and denies, exactly like
# the no-switch fixture above.
runcase deny kill-switch-garbage-stays-active "$REC" "content" "" ISSUE_RETROSPECTIVE_PROPOSAL_ORDER_GATE_OFF=banana

# Edit/MultiEdit replace_all groups intentionally omitted: this gate never
# reconstructs its own write's content (issue #21 remediation,
# proposal-order-gate note) -- it only reads the SUBJECT's existing
# phase-1 proposal file off disk and checks its text, so there is no
# hand-rolled content-reconstruction path to exercise here.

# --- mandatory case: malformed JSON denies, fail-closed --------------------
rawcase deny malformed-json-truncated "" 0 "" '{"tool_name":"Write"'
rawcase deny malformed-json-non-object "" 0 "" '"just a string"'
rawcase deny malformed-json-empty-payload "" 0 "" ''

# --- mandatory case: absolute path and ./-prefixed path resolve the same
# scope a plain relative-path fixture already matches -----------------------
rawcase deny absolute-path-no-proposal \
  "" 1 '
import json, sys
fp = sys.argv[1]
print(json.dumps({"tool_name": "Write", "tool_input": {
  "file_path": fp, "content": "content"}}))
'
rawcase deny dot-prefixed-relative-path-no-proposal \
  "" 0 '
import json, sys
fp = "./" + sys.argv[1]
print(json.dumps({"tool_name": "Write", "tool_input": {
  "file_path": fp, "content": "content"}}))
'

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
