# Round-end value gates (issue-retrospective, phase 2 checklist)

Informational, not gated (no plugin enforces this file — it is a
non-blocking prompt, the same role `state.sh` plays in
implementation-rulebook). Walk both questions explicitly at record-writing
time, when a round is concluding (`loop_state: round-done`). Neither
question is keyword-checkable, which is why this lives as a checklist
instead of a `reflect/hooks/plugins/*-gate.sh` file (issue #18 proposal
(d)).

## A. Procedure-value

Question: can this role or mechanism cite evidence it changed this issue's
outcome?

Fail condition: no citable evidence → mark `ritual`. Persistent `ritual`
across issues is a defect the next contract revision must remove, not a
one-off note to drop.

## B. Blind-onboarding

Question: could a zero-context reader reconstruct what was asked, built,
decided, and what is next, from the records alone?

Fail condition: any point where such a reader would get stuck → that stuck
point is a **records defect** to report in this role's findings (always
`severity: advisory`), never a gap to route around by explaining it
out-of-band.
