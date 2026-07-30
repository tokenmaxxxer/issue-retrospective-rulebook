# Build proposal — issue-9

files:
- reflect/hooks/directive.sh
- README.md

## Request (paraphrased intent, secrets stripped)

Strip routing-side vocabulary (wake, board-as-routing-device, WAKES-ON,
downstream roles, pointers to wake-routing.md) from this rulebook,
restating record obligations purely as record-format requirements: path,
kind, loop_state vocabulary, required fields, write record first in
phase 2, update loop_state every transition, commit on branch.
Historical docs untouched. Phase 1 only — no self-approval.

## Constraints

- Only the two hit sites found in the survey (directive.sh, README.md)
  are in scope; docs/issue-7/** and other historical docs stay untouched.
- References to "core's board-gate" as an actual external gate mechanism
  (not this role's routing framing) are not vocabulary to strip.
- Repo's own tests (parse-check, run-gate-tests, deny-only-check) must
  keep passing.

## What will be done

- `reflect/hooks/directive.sh`: replace the "YOUR RECORD IS THE BOARD"
  section with a "RECORD REQUIREMENTS" section stating the record path,
  loop_state vocabulary, required fields, first-act-of-phase-2 timing,
  update-on-every-transition, and commit-on-branch — no wake/board/
  downstream-role language.
- `README.md`: drop the "when this role wakes ... routing table" sentence
  since routing decisions are not this rulebook's concern.

## Out of scope

Any change to docs/issue-7/**, to core's actual gate scripts (external
plugin), or to test files (they contain no such vocabulary to strip).

## How you'll know it worked

`grep -rn "WAKES-ON\|wake-routing\|board-as-routing\|downstream role" reflect/ README.md`
returns nothing, and `bash tests/parse-check.sh && bash tests/deny-only-check.sh`
still pass.
