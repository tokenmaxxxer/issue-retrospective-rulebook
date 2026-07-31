# Scout brief — issue #12

**Mode:** parallel web sweep, single round, 4 angles in one batch
(WebSearch x4 in one turn) — genuine concurrent fan-out, not serialized.
Angles chosen against the survey's gaps: the survey found the directive's
methodology commitment (blameless postmortem) already named but
mechanically unenforced, and zero existing record exemplar in this repo —
so the sweep rounds out the *field's* consensus on retrospective
methodology (not just the one exemplar already named) to judge whether
blameless-postmortem-only is the right adoption or too narrow. Angles: (1)
Google SRE / industry blameless postmortem template, (2) agile sprint
retrospective methodology (Kolb/Start-Stop-Continue/Five-Whys), (3)
military After-Action Review (AAR) structure, (4) root-cause-analysis
evidence/citation standards (5 Whys, fishbone, and their known limits).

## Judge point 1 — convergence across angles

All four angles converge on the same shape despite different lineages:
1. **Timeline/chronology before judgment** — SRE's "objective, time-ordered
   narrative"; AAR's "what was planned vs. what actually happened"; both
   precede any causal or evaluative claim.
2. **Systems/contributing-factors framing, not single blame** — SRE
   blameless principle ("why our systems allowed this," names only for
   timeline context); AAR's explicit non-punitive climate; RCA's own
   internal caution (Cook 1998, cited directly in the RCA search result:
   "post-accident attribution to a 'root cause' is fundamentally wrong" —
   practice has shifted to *contributing factors*, plural, not one root
   cause).
3. **Action items are owned and dated, not vague** — SRE: "owner named (a
   person, not a team), due date set... change described (a PR, a config,
   a runbook, a monitor)." AAR: "what will be done to improve next time,"
   explicitly forward-looking, not just diagnostic.
4. **Facilitation/independence matters** — agile retro angle: a neutral
   facilitator improves candor; this role's own contract position
   (advisory-only, never re-litigating other roles' verdicts) already
   satisfies the "neutral, not the actor being reviewed" requirement
   structurally.

One round was decision-relevant and sufficient: the four independent
lineages (SRE engineering, agile process, military training, RCA
methodology) converged on the same four elements rather than diverging,
which is itself the saturation signal — a second round would spend budget
re-confirming agreement already found, not surfacing a new build decision.
Stopped at stage 1 (sweep only, no deepening needed) — well inside the
5-stage/3-minute budget.

## Must-bes (binding candidates for adoption)

- Chronological timeline reconstructed before any causal or evaluative
  claim is made (all 4 angles).
- Contributing factors, plural, explicitly not a single "root cause" —
  directly relevant since this role already reads *other roles'* records
  only (survey §1) and could otherwise be tempted to pin one record as
  "the cause."
- Action items (if the retrospective produces any — see skip below) carry
  an owner and a date, never left as vague prose.
- Names appear only for timeline/evidence attribution, never for blame.

## Adopt / skip

- **Adopt**: blameless-postmortem's five-question frame (what happened /
  why / how did we respond / what did we learn / what will change) as the
  record's required section shape — it is the only one of the four
  lineages built for a *written, citable* artifact (AAR is a live
  facilitated discussion; agile retro is a live meeting) — this role's own
  contract already requires the record to be a citing document
  (`use_when`: "cite the record path... where it matters"), not a
  transcript of a discussion that never happened here.
- **Adopt**: RCA's "contributing factors, not one root cause" caution as
  an explicit required-field rename — directly closes survey §5's gap
  (generic gate has no causal-framing requirement at all).
- **Skip**: AAR's live "guided discussion" format and agile retro's
  meeting-facilitation mechanics (Start-Stop-Continue prompts, a live
  facilitator role) — this role is a solo async agent reading records
  after the fact, not convening a meeting; adopting meeting mechanics
  would mismatch how this role actually operates (contract v3: one agent,
  async, phase-gated).
- **Skip**: making action items mandatory in every record — this role's
  own `produces` clause already states findings are advisory-only and this
  role "never fixes anything"; an action item here is a recommendation to
  a *future* issue, not a committed change this role owns delivering. The
  field is adopted as *optional but must be owner+date-shaped when
  present*, not mandatory-every-time.

## Gap line

Current state (survey §1-§2) already has the blameless framing as prose
and a generic what/why/upstream/loop_state/open-findings gate. Missing,
confirmed by this sweep, and worth encoding as required record components:
an explicit timeline section, a "contributing factors" (not singular root
cause) section, and an owner+date shape for any action item claimed. Not
missing: facilitation/live-meeting mechanics — correctly out of scope for
an async solo role, not a gap to fill.

Sources:
- https://sre.google/sre-book/postmortem-culture/
- https://sre.google/workbook/postmortem-culture/
- https://incident.io/blog/sre-incident-postmortem-best-practices
- https://www.easyagile.com/blog/agile-retrospective
- https://www.freecodecamp.org/news/how-to-run-a-sprint-retrospective-start-stop-continue-method
- https://en.wikipedia.org/wiki/After-action_review
- https://apps.dtic.mil/sti/tr/pdf/ADA368651.pdf
- https://pinnacle-leaders.com/wp-content/uploads/2018/02/Leaders_Guide_to_AAR.pdf
- https://clickhouse.com/resources/engineering/root-cause-analysis
- https://www.modernanalyst.com/Resources/Articles/tabid/115/ID/5914/Root-Cause-Analysis-Using-a-Fishbone-Diagram-and-the-Five-Whys.aspx
