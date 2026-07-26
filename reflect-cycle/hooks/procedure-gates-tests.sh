#!/usr/bin/env bash
# Test harness for the reflect-cycle procedure gates (§11/§20/§21/§13):
#   record-fields-gate.sh, path-ownership-gate.sh, doc-bucket-gate.sh,
#   handbook-trigger-gate.sh, trailer-gate.sh
# Each gate gets one REFUSE case (crafted violation) and one PASS case
# (compliant). exit 0 = allow, non-zero = deny.
set -uo pipefail

hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd -P)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fail_count=0; pass_count=0
pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1"; fail_count=$((fail_count + 1)); }

# run_gate <gate> <root> <payload>  (runs with cwd = root)
run_gate() {
  local gate="$1" root="$2" payload="$3"
  GATE_OUT="$(cd "$root" && printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$root" "$hook_dir/$gate" 2>&1)"
  return $?
}

mkroot() { local d="$1"; rm -rf "$d"; mkdir -p "$d"; ( cd "$d" && git init -q && git config user.email t@t && git config user.name t ); echo "$d"; }

json_write() { # <file_path> <content>
  python3 -c 'import json,sys;print(json.dumps({"tool_name":"Write","tool_input":{"file_path":sys.argv[1],"content":sys.argv[2]}}))' "$1" "$2"
}
json_bash() { python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$1"; }

expect_deny() { local name="$1" code="$2"; if [ "$code" -ne 0 ]; then pass "$name (denied, exit $code)"; else fail "$name was ALLOWED (exit 0): $GATE_OUT"; fi; }
expect_allow() { local name="$1" code="$2"; if [ "$code" -eq 0 ]; then pass "$name (allowed)"; else fail "$name was DENIED (exit $code): $GATE_OUT"; fi; }

########## 1. record-fields-gate ##########
r="$(mkroot "$work/rf")"
bad_rec="---
stage: reflecting
---
just a stub, no required sections."
run_gate record-fields-gate.sh "$r" "$(json_write "docs/reports/records/subj/reflect.md" "$bad_rec")"
expect_deny "record-fields §20 refuses record missing sections" $?

good_rec="---
loop_state: done
records_read: docs/reports/records/subj/coding.md, docs/reports/records/subj/verify.md
---
## What was done
Wrote the retro for subj.
## Why
Chose a per-round retro over a per-commit one; the alternative (per-commit)
was rejected as too noisy.
## Basis
upstream: docs/reports/records/subj/coding.md at 1a2b3c4d.
loop_state is done."
run_gate record-fields-gate.sh "$r" "$(json_write "docs/reports/records/subj/reflect.md" "$good_rec")"
expect_allow "record-fields §20 passes a complete terminal record" $?

########## 2. path-ownership-gate ##########
r="$(mkroot "$work/po")"
run_gate path-ownership-gate.sh "$r" "$(json_write "docs/reports/records/subj/coding.md" "x")"
expect_deny "path-ownership §11 refuses write to another role's record" $?
run_gate path-ownership-gate.sh "$r" "$(json_write "docs/reports/records/subj/reflect.md" "x")"
expect_allow "path-ownership §11 passes write to reflect's own record" $?

########## 3. doc-bucket-gate ##########
r="$(mkroot "$work/db")"
run_gate doc-bucket-gate.sh "$r" "$(json_write "docs/scratch/notes.md" "x")"
expect_deny "doc-bucket §21 refuses doc outside the six buckets" $?
run_gate doc-bucket-gate.sh "$r" "$(json_write "docs/reports/2026-07-26-retro.md" "x")"
expect_allow "doc-bucket §21 passes doc inside reports/ bucket" $?

########## 4. handbook-trigger-gate ##########
r="$(mkroot "$work/hb")"
mkdir -p "$r"; printf '{"name":"x"}\n' > "$r/package.json"; ( cd "$r" && git add package.json )
run_gate handbook-trigger-gate.sh "$r" "$(json_bash 'git commit -m "change deps"')"
expect_deny "handbook §21 refuses surface change with no handbook update" $?
mkdir -p "$r/docs/handbooks"; printf '# x\n' > "$r/docs/handbooks/x.md"; ( cd "$r" && git add docs/handbooks/x.md )
run_gate handbook-trigger-gate.sh "$r" "$(json_bash 'git commit -m "change deps + handbook"')"
expect_allow "handbook §21 passes surface change with handbook update" $?

########## 5. trailer-gate ##########
r="$(mkroot "$work/tr")"
mkdir -p "$r/reflect"; printf -- '---\nstage: reflecting\n---\n' > "$r/reflect/state.md"
run_gate trailer-gate.sh "$r" "$(json_bash 'git commit -m "land retro, no trailer"')"
expect_deny "trailer §13 refuses in-progress commit missing Subject: trailer" $?
run_gate trailer-gate.sh "$r" "$(json_bash 'git commit -m "land retro

Subject: subj"')"
expect_allow "trailer §13 passes in-progress commit with Subject: trailer" $?

########## 6. fail-closed on internal error (all gates) ##########
# Each gate must map an internal crash to exit 2 (DENY), never a non-2
# non-zero that PreToolUse treats as NON-blocking (fail-open).
expect_deny2() { local name="$1" code="$2"; if [ "$code" -eq 2 ]; then pass "$name (fail-closed DENY, exit 2)"; else fail "$name did NOT fail closed to exit 2 (got exit $code): $GATE_OUT"; fi; }

# null byte in file_path -> os.path.realpath raises ValueError -> must be 2.
json_write_nullpath() { # <content>
  python3 -c 'import json,sys;print(json.dumps({"tool_name":"Write","tool_input":{"file_path":"docs/reports/records/subj/"+chr(0)+"reflect.md","content":sys.argv[1]}}))' "$1"
}
r="$(mkroot "$work/fc")"
for g in record-fields-gate.sh path-ownership-gate.sh doc-bucket-gate.sh; do
  run_gate "$g" "$r" "$(json_write_nullpath "x")"
  expect_deny2 "$g null-byte file_path" $?
done

# Bash-only gates (handbook/trailer): a malformed JSON payload must exit 2.
r="$(mkroot "$work/fcb")"
mkdir -p "$r/reflect"; printf -- '---\nstage: reflecting\n---\n' > "$r/reflect/state.md"
for g in handbook-trigger-gate.sh trailer-gate.sh; do
  run_gate "$g" "$r" '{ this is not valid json'
  expect_deny2 "$g malformed JSON" $?
done

echo "-----"
echo "procedure-gates: $pass_count passed, $fail_count failed"
[ "$fail_count" -eq 0 ]
