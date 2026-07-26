# reflect-cycle transition rules

Single source of truth for legal `reflect/state.md` (`stage` field)
transitions. Read by both `inject-transition-rules.sh` (UserPromptSubmit)
and `state-gate.sh` (PreToolUse). The state set mirrors the
`reflect-record`'s `loop_state` vocabulary fixed by
`docs/specs/role-handoff-contract.md` §2: `idle`, `reflecting`, `done`.

`actor` is `user` when the transition requires the user to have said
something in this conversation authorizing it; `agent` when the agent may
make the transition on its own recognizance (still recorded, never
user-gated).

| from | to | actor | precondition |
|---|---|---|---|
| (none) | idle | agent | reflect/state.md does not yet exist; the agent creates it with stage `idle` as the initial state |
| idle | reflecting | agent | reflect has woken per contract §3 (the subject's work has landed and verify and/or review have concluded) and begun reading the subject's other role records |
| reflecting | reflecting | agent | the retro draft is being revised; the `reflect-record`'s pointer to the other role records it read remains non-empty throughout (state-gate.sh's owned-path check enforces this on every write to the record itself, independently of this state file) |
| reflecting | done | user | user has reviewed the retro in this conversation and affirmed it is complete — a vague affirmation ("looks fine") is not sufficient; the model re-asks for what was specifically reviewed |
| done | reflecting | user | user sends the retro back for rework |

Two `actor: user` rows.

## Commit trailer (contract §13)

reflect-cycle's declared machine-checkable commit trailer is
`Subject: <subject>`, enforced by `trailer-gate.sh` whenever a reflect unit
is in progress (`reflect/state.md` exists with a non-terminal `stage`, i.e.
not `done`). A commit landing an in-progress reflect-record must carry this
trailer identifying the subject. This is stated here, in the rulebook's own
docs, rather than being discoverable only via the hook's rejection at commit
time.

No new `loop_state`/`stage` values are introduced by the §11/§20/§21/§13
procedure gates: they key only on the already-registered `idle`,
`reflecting`, `done` vocabulary above (`done` is the sole terminal state).
