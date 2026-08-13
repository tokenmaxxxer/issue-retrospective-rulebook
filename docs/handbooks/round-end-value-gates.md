# Round-end value gates (issue-retrospective, phase 2 checklist)

Informational, not gated (no plugin enforces this file — it is a
non-blocking prompt, the same role `state.sh` plays in
implementation-rulebook). Walk both questions explicitly at record-writing
time, when a round is concluding (`loop_state: round-done`). Neither
question is keyword-checkable, which is why this lives as a checklist
instead of a `issue-retrospective/hooks/plugins/*-gate.sh` file (issue #18 proposal
(d)).

`impact_summary` and `retro_id` (issue #31) are directive-level record
fields (`issue-retrospective/hooks/directive.sh`'s `produces`), not new
round-end value-gate questions — this file's two questions (A, B) are
unchanged by that mapping.

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

## C. Timeline sourcing preference (issue-1199 fold-in)

When two records disagree on when something happened, or a record only
summarizes an event after the fact, prefer the record entry closest to
the event's own timestamp over a later narrative recounting of it —
build the timeline forward from that earliest entry, not backward from
whichever record was read last. This is a sourcing preference, not a new
gate: it resolves ties the mechanical gates cannot see, the same way
questions A and B do.
