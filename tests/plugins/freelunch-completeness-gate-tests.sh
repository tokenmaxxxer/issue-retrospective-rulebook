#!/usr/bin/env bash
# reflect's freelunch-completeness-gate.sh, exercised as a real subprocess.
# Runs against BOTH write surfaces it guards (기획서 proposal + 산출물
# record), per issue #18 proposal (b)/(c) item 5.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOOKS="$HERE/../../reflect/hooks/plugins"
GATE="freelunch-completeness-gate.sh"
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

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
