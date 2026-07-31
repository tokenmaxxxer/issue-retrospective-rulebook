#!/usr/bin/env bash
# reflect's proposal-order-gate.sh, exercised as a real subprocess. Unlike
# the other plugins, this gate reads the subject's own phase-1 proposal
# directly off disk (state via file-read, no persistent state file), so the
# fixture proposal must be written into the scratch repo before the record
# write is simulated.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE/../../reflect/hooks/plugins"
GATE="proposal-order-gate.sh"
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

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
