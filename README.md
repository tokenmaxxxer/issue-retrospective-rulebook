# tokenmaxxxer / reflect-agent-rulebook

A Claude Code plugin marketplace for the `reflect` agent role, added as a
tenth role to the collaboration model specified in
`docs/specs/role-handoff-contract.md` (org-level `docs/` repository),
mirroring how `verify` and `ux-design` were each added as first-class
roles earlier in this model's history.

## What `reflect` decides

`reflect` owns the retrospective — looking back across a subject's whole
history once its work has landed and verify and/or review have concluded.

- **Given to start**: a subject whose work has landed and whose
  `verify-record` and/or `review-record` have reached a concluding
  `loop_state` (`cleared` / `reported`). Nothing more is required to open
  the role.
- **Produces**: a `reflect-record` — what went well, what failed, and what
  pattern should change next time — built from the subject's other role
  records, never from fresh re-investigation of the running system.
- **Prevents**: a subject's lessons disappearing once its work has landed,
  and — the sharper failure — the same failure mode recurring on the next
  subject because nothing on the board carried it forward.

This repository never reads another role's repository, and no other role's
repository reads this one. The user is the only channel between roles; see
`reflect-cycle/hooks/transition-rules.md` for the full state machine this
repository enforces.

## The state machine, briefly

States: `idle -> reflecting -> reflecting -> done`, carried in
`reflect/state.md`'s frontmatter (field `stage`), and separately in the
`reflect-record`'s `loop_state` field on the board
(`docs/reports/records/<subject>/reflect.md`).

The one gated transition, `reflecting -> done`, is refused unless the user
has affirmed in this conversation that the retro is complete — content
alone is never read as consent. `reflect-cycle/hooks/state-gate.sh` also
refuses any write landing on `docs/reports/records/<subject>/reflect.md`
that lacks a non-empty pointer to the other role records it read
(`records_read:` or `upstream_records:`), the mechanically checkable half
of contract §4's DEPENDS-ON bullet for reflect.

## Handoff protocol

The authoritative contract is the work repo's own
`docs/specs/role-handoff-contract.md` — the file inside the git root this
session is pointed at, not any file outside that repo. This section
describes only how the reflect role behaves against whatever contract the
work repo carries; it excerpts reflect's rows for convenience, but the
work repo's copy is what governs. `reflect-cycle/hooks/state-gate.sh`
refuses handoff-protocol actions when that repo has no
`docs/specs/role-handoff-contract.md` yet, rather than proceeding
silently.

### WAKES-ON

Per contract §3's reflect row: reflect wakes when a subject's work has
landed and verify and/or review have concluded (a `verify-record` reaching
`loop_state: cleared`, or a `review-record` reaching `loop_state:
reported`). WAKES-ON is a trigger condition, not an accept/refuse gate —
reading a kind and being woken by it are different questions (see the next
subsection).

### READ / DEPENDS-ON / NEVER-OVERWRITE

Per contract §4's three questions, at reflect's grain:

- **READ: broad, unconditional.** `reflect` may read any board record for
  context — `coding-record`, `qa-record`, `feasibility-record`,
  `ux-design-record`, `review-record`, `verify-record`, `ops-record` — none
  of these are refused reading.
- **DEPENDS-ON: narrow.** reflect depends on the subject's other role
  records and any `finding` blocks addressed to or from them — the
  retrospective material it reads to produce its retro — contract §4's own
  reflect bullet, verbatim.
- **NEVER-OVERWRITE.** reflect writes only
  `docs/reports/records/<subject>/reflect.md` (`kind: reflect-record`) —
  contract §11's reflect row, verbatim. Like ux-design and verify, reflect
  owns no slot under `docs/proposals/` and no standing doc; its entire
  write-owned surface is this one record path per subject.

### Where upstream lives

- The subject's other role records are read from
  `docs/reports/records/<subject>/<role>.md` in the target repo, per
  contract §2's kind table.

The user hands over only a pointer ("it's here"); this path is what lets
`reflect` resolve that pointer on its own, without asking.

### Blackboard record shapes

Per contract §2's table and §7, `reflect` owns one kind:

- **`reflect-record`** at `docs/reports/records/<subject>/reflect.md`.
  `loop_state` vocabulary: `idle,reflecting,done`. Required fields beyond
  the common header: a pointer to the subject's other role records read,
  plus what went well, what failed, and what pattern should change next
  time. This contract entry enforces structure only — that the record
  exists per subject and points at the records it read — not what the
  retro concludes; that stays reflect's own judgment (contract §4's
  reflect DEPENDS-ON bullet).

### Finding participation

Per contract §5: `reflect` may both produce and receive `finding` blocks.
A `finding` reflect emits carries `severity: advisory` — reflect's output
is advisory only; `severity: blocking` stays reserved to whichever roles'
own contract entries already define it. When `reflect` closes out a
`finding` addressed to it, `reflect.md` (the `reflect-record`) must carry
a `finding-response` entry with all three required parts: the finding
reference (record path + finding identifier), the action taken or decline
reason, and — when applicable — proof of the fix. An entry missing any of
the three parts does not close the finding.

### Loop termination

Per contract §6: a wake is consumed only by writing the resulting record
entry — a `loop_state` change, a new `finding`, a `finding-response`, or
equivalent. An unchanged board wakes no one.

### Minting `subject` (contract §9)

Any role may open a chain, not only `reflect` — but in practice reflect is
never the chain-opener, since its WAKES-ON trigger requires a subject
already carrying a `verify-record` or `review-record`. Before writing,
`reflect` adopts the subject's existing identifier verbatim rather than
minting a new one.

### Stops

- **Upstream stale at role entry — contract §12.** Before acting on any
  handed-over role record, `reflect` compares the recorded `sha` in its
  `upstream` entry against the current commit that touched that path. On
  first read of an `upstream` entry, this always prompts the user once. On
  a later re-entry, if the current sha matches the recorded
  `acknowledged_sha`, it does not re-prompt. A sha matching neither `sha`
  nor `acknowledged_sha` re-fires the full prompt — the gate does not
  decide "proceed" or "re-confirm" itself, it asks.
- **A record already exists at a path `reflect` does not own.** If
  `reflect`, in the course of its work, finds an existing record already
  present under `docs/reports/records/` or at a `docs/proposals/`
  filename it does not own, it refuses to write there and reports the
  conflict — the path, and whose territory it falls in — to the user. It
  never overwrites or merges into it silently.

## Install

```
curl -fsSL https://raw.githubusercontent.com/tokenmaxxxer/reflect-agent-rulebook/main/install.sh | bash
```

This registers the `tokenmaxxxer-reflect` marketplace and installs the
`reflect-agent-env` bundle plus `reflect-cycle` at **user scope**. It
applies to your account on every machine-local session; it does not travel
with a repo and does not reach Claude Code on the web or Slack cloud
sessions. It names only this repository and its own marketplace — nothing
else in the `tokenmaxxxer` org is touched or referenced.

The script prefers a real `claude` CLI (standalone, or the binary bundled
inside the VSCode extension) if it finds one, and runs `plugin install
<name>@tokenmaxxxer-reflect --scope user` for `reflect-cycle` and the
bundle, then updates each to the marketplace's latest. If no `claude`
binary is found — or `TOKENMAXXXER_SETTINGS_ONLY=1` is set to force it —
the script falls back to writing `~/.claude/settings.json` directly: it
resolves and prefix-checks the settings path against your home directory
before writing, aborts untouched on a parse failure of an existing file,
backs up before writing, and follows a symlink rather than replacing it.

Or, from any Claude Code session, the equivalent by hand:

```
/plugin marketplace add tokenmaxxxer/reflect-agent-rulebook
/plugin install reflect-agent-env@tokenmaxxxer-reflect
```

`install.sh --help` prints usage. The only other input it reads is the
`TOKENMAXXXER_SETTINGS_ONLY=1` environment variable described above.

## Writing the settings by hand

```json
{
  "extraKnownMarketplaces": {
    "tokenmaxxxer-reflect": {
      "source": { "source": "github", "repo": "tokenmaxxxer/reflect-agent-rulebook" }
    }
  },
  "enabledPlugins": {
    "reflect-agent-env@tokenmaxxxer-reflect": true
  }
}
```

## Repo layout

- `install.sh` — the one-shot installer described above.
- `.claude-plugin/marketplace.json` — the marketplace manifest (name
  `tokenmaxxxer-reflect`), listing `reflect-cycle` and `reflect-agent-env`,
  both `./`-relative to this repository.
- `reflect-cycle/` — the role plugin: `.claude-plugin/plugin.json`, two
  hooks (`hooks/hooks.json`, `hooks/inject-transition-rules.sh`,
  `hooks/state-gate.sh`), and `skills/`.
- `reflect-agent-env/` — the bundle plugin: `.claude-plugin/plugin.json`
  only, no code of its own, listing `reflect-cycle` as its dependency.
- `docs/` — six lifetime buckets (`decisions/`, `handbooks/`, `reports/`,
  `specs/`, `proposals/`, `_assets/`), each with a placeholder if empty.
  `docs/specs/role-handoff-contract.md` is the byte-identical tenth copy of
  the shared handoff contract.

## Self-contained by design

This repository is independently installable into its own sandbox: no
shared code, no cross-repository dependency, no shared file, index, or
ledger with `coding-agent-rulebook`, `qa-agent-rulebook`, or any sibling
role repository (`feasibility-agent-rulebook`, `review-agent-rulebook`,
`ops-agent-rulebook`, `product-agent-rulebook`, `verify-agent-rulebook`,
`ux-design-rulebook`). Nothing in this repository names or reads another
repository at runtime.
