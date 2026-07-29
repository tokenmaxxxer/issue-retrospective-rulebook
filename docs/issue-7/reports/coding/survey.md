# Current-state survey — issue-7

## Method

`grep -rliE "wakes|wake-on|wakes-on"` over all `*.md` and `*.sh` files in
the repo, excluding `docs/issue-*` (per-issue trees are not rulebook).

## Findings

- `README.md:18` — "Wakes once the subject's work has landed and verify
  and/or review have concluded." Names `verify` and `review` by role as the
  triggers for this role waking. This is a WAKES-ON routing restatement and
  is in scope to strip/repoint.
- `reflect/hooks/directive.sh:53-60` — "YOUR RECORD IS THE BOARD ... WAKES-ON
  reads docs/issue-<n>/reports/reflect.md ONLY ... no downstream role can
  ever be woken by it." This block states which file is this role's own
  board-visible record (own record format/mechanics) and does NOT name which
  role summons on which state. It matches the pattern the current coding
  session's own SessionStart directive uses verbatim for the coding role, so
  it reads as standard boilerplate about record placement, not inter-role
  routing. Out of scope: keep as-is.
- No other files (hooks, tests, other docs) matched.

## Write set (frozen)

- `README.md` — reword line 18 to drop the named triggers, repoint to
  `docs/specs/wake-routing.md` for actual routing.

No other files change.
