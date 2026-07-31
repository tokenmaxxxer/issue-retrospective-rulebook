#!/usr/bin/env bash
# reflect's action-item-shape-gate.sh, exercised as a real subprocess.
# Scaffold adapted from implementation-rulebook/tests/run-gate-tests.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE/../../reflect/hooks/plugins"
GATE="action-item-shape-gate.sh"
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
NO_OWNER='## Action items
Fix the flaky test.'
NONE='## Action items
None.'
OWNED='## Action items
Owner: coding role -- add a regression test for the flaky parser.'
NO_SECTION='## What we learned
Nothing else here.'

runcase deny  claimed-no-owner "$REC" "$NO_OWNER"
runcase allow explicit-none    "$REC" "$NONE"
runcase allow owner-named      "$REC" "$OWNED"
runcase allow no-section-at-all "$REC" "$NO_SECTION"
runcase allow foreign-path "docs/issue-7/reports/coding.md" "$NO_OWNER"
runcase allow kill-switch-off "$REC" "$NO_OWNER" ISSUE_RETROSPECTIVE_ACTION_ITEM_SHAPE_GATE_OFF=1

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
