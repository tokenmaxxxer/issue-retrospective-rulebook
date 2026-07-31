#!/usr/bin/env bash
# reflect's recurred-prediction-gate.sh, exercised as a real subprocess.
# Scaffold adapted from implementation-rulebook/tests/run-gate-tests.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE"
GATE="recurred-prediction-gate.sh"
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

REC=docs/issue-7/reports/issue-retrospective.md
NO_MENTION='## What we learned
Everything went fine.'
NO_EARLIER='## What we learned
No earlier record existed, so there is no recurred prediction to report.'
PREDICTED='## What we learned
An earlier record predicted this failure mode and it recurred here.'

runcase deny  no-mention-at-all "$REC" "$NO_MENTION"
runcase allow no-earlier-record "$REC" "$NO_EARLIER"
runcase allow predicted-recurred "$REC" "$PREDICTED"
runcase allow foreign-path "docs/issue-7/reports/coding.md" "$NO_MENTION"
runcase allow kill-switch-off "$REC" "$NO_MENTION" ISSUE_RETROSPECTIVE_RECURRED_PREDICTION_GATE_OFF=1

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
