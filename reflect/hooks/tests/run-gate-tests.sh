#!/usr/bin/env bash
# The three surviving gates, exercised as real subprocesses.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
pass=0; fail=0
report() { if [ "$2" = "$1" ]; then pass=$((pass+1)); printf 'ok     %-32s %s\n' "$3" "$2"; else fail=$((fail+1)); printf 'FAIL   %-32s want=%s got=%s\n' "$3" "$1" "$2"; fi; }

REC=docs/issue-3/reports/reflect.md
GOOD='---
loop_state: round-done
records_read:
  - docs/issue-3/reports/coding.md
---
## What was done
Read all records.
## Why
Chose records-only basis; the alternative (re-running the system) was rejected per the role rule.
## What went well / failed / pattern change
...'
OPEN='---
loop_state: reflecting
records_read:
  - docs/issue-3/reports/coding.md
---
## What was done
Started reading.
## Why
Records-only basis; alternative rejected.
## Next steps
Read verify record.
## Open findings
None yet; resolution path: n/a.'

recgate() { # want name file content
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"; mkdir -p "$td/docs/issue-3/reports"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":%s},"cwd":"%s"}' \
    "$3" "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | env CLAUDE_PROJECT_DIR="$td" /bin/bash "$HERE/../record-fields-gate.sh" >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}
recgate allow record-complete-terminal "$REC" "$GOOD"
recgate allow record-complete-open     "$REC" "$OPEN"
recgate deny  record-missing-sections  "$REC" "just some text"
recgate deny  record-open-no-backlog   "$REC" '---
loop_state: reflecting
---
## What was done
x
## Why
alternative rejected
upstream: docs/issue-3/reports/coding.md'
recgate allow record-foreign-path      "docs/issue-3/reports/coding.md" "x"
recgate allow record-old-layout-path   "docs/reports/records/alpha/reflect.md" "x"

trailergate() { # want name stagepath commitcmd
  td="$(cd "$(mktemp -d)" && pwd -P)"; git init -q "$td"
  ( cd "$td" && git config user.email t@t && git config user.name t \
    && mkdir -p "$(dirname "$3")" && echo x > "$3" && git add "$3" )
  printf '{"tool_name":"Bash","tool_input":{"command":%s},"cwd":"%s"}' \
    "$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$4")" "$td" \
    | ( cd "$td" && env -u CLAUDE_PROJECT_DIR /bin/bash "$HERE/../trailer-gate.sh" ) >/dev/null 2>&1
  rc=$?; case "$rc" in 0) got=allow ;; 2) got=deny ;; *) got="exit-$rc" ;; esac
  rm -rf "$td"; report "$1" "$got" "$2"
}
trailergate deny  commit-no-trailer     "$REC" 'git commit -m "update record"'
trailergate deny  commit-wrong-issue    "$REC" 'git commit -m "update record

Subject: issue-9"'
trailergate allow commit-with-trailer   "$REC" 'git commit -m "update record

Subject: issue-3"'
trailergate deny  commit-editor-message "$REC" 'git commit'
trailergate allow commit-non-issue-work "src/app.py" 'git commit -m "code change"'

printf '\n== %d passed, %d failed ==\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
