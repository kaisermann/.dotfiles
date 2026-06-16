# Home Agent Guide

- This machine uses `zsh` with dotfiles managed from `~/.dotfiles`.
- NEVER add `Co-Authored-By: Claude` (or any Claude/AI co-author or "Generated with" trailer) to git commits or PR bodies. No exceptions.
- Prefer `trash` for deletions. In interactive shells, `rm` is aliased to `trash`.
- Use `command rm` only when a permanent delete is truly intended.
- Shell config lives under `~/.config/zsh` and is stowed from `~/.dotfiles/zsh`.
- `ZDOTDIR` is set to `~/.config/zsh` in `~/.zshenv`, so `~/.zshrc` is **never sourced**. The real rc is `~/.config/zsh/.zshrc`. Installers that append to `~/.zshrc` will have no effect — move their PATH entries to `~/.config/zsh/path.zsh` (real file: `~/.dotfiles/zsh/.config/zsh/path.zsh`).
- Global agent config is managed from `~/.dotfiles/agents` and `~/.dotfiles/opencode`.
- `~/.spoke-knowledge` is a globally trusted external directory for OpenCode and can be read from any working directory without requesting permission.

## Problem Solving

Always use a holistic, systematic approach before acting. Ideate first: understand the goal, constraints, related systems, unknowns, loose pieces, and how those pieces compose into the larger behavior.

- Build a working model of the whole problem before choosing an implementation path.
- Trace cause and effect across boundaries instead of optimizing one isolated fragment.
- Identify loose facts, missing context, assumptions, and dependencies, then connect them into a coherent plan.
- Prefer solutions that compose cleanly with existing systems, conventions, and future maintenance.
- When the problem is ambiguous, pause to frame options and tradeoffs before editing.

## Debugging & getting unstuck

Problem Solving above is for *before* you act. This is for when you're *in* it — a bug that resists the obvious fix, or you're already several attempts deep. The failure to avoid: measuring or patching the *symptom* instead of isolating its *cause*. Measuring how far something is off never reveals what causes it. The full protocol lives in the `diagnose` skill; these are the always-on tripwires.

- **Isolate before you measure or patch.** Find *which* thing causes the bug by removing/toggling/disabling parts (or `git bisect`) until the symptom flips — *then* fix that. Move #1, not a last resort.
- **"It's a regression" → bisect, don't re-derive.** `git bisect`, or broad content history (`git log -S/-G --all`) which follows file moves/renames; per-file `git log` misses decomposed code.
- **A difference between two states with identical inputs is DYNAMIC.** "Measure ≠ settle", "lands then shifts", flaky, works-then-breaks → something changes/mounts/loads *between* the states. Find that thing. A static change can't fix a dynamic diff — it only shifts the baseline.
- **Trust your instrument before its readings.** If the measuring tool can lie (paused rAF, throttled/hidden tab, transformed coordinates, stale cache, contaminated env), verify or neutralize it first. Bad data manufactures wrong hypotheses.
- **Confirm the cause before writing the fix.** Toggle the suspected cause live and watch the symptom flip; only then edit. One falsifiable change at a time — never two speculative fixes on two unknowns (they mask each other).
- **Stop-loss.** After ~3 failed attempts on one symptom, repeated edits to a single file with no progress, or when a redirect lands ("running in circles", "this smells"): STOP. Revert to a clean state, write down the one contradiction you can't explain, and change *method* — isolate, bisect, or fan out subagents from different angles. Trying the same approach harder is the trap, and a forceful/repeated user redirect is a hard signal to switch methods, not to push harder.
- **Query learnings first.** Before debugging an unfamiliar or risky area, check stored learnings for known gotchas (`bd query … label=retro`, project memory files). The note that saves the hour usually already exists.
- **"Step back" is an action, not a sentence.** Don't narrate stepping back — invoke the skill: `step-back` for an ambiguous design/problem, `diagnose` for a resistant bug.

## Beads

A personal global Beads database lives at `~/.beads` (set via `BEADS_DIR`). It runs in embedded mode — no server, no git, no sync. Use it from any project directory.

- Run `bd prime` at session start for full workflow context, commands, and stored memories.
- Use `bd ready` to find available work, `bd create` to add tasks, `bd update <id> --claim` to start, `bd close <id>` to finish.
- Use `bd remember "insight"` for persistent cross-session memory. Search with `bd memories <keyword>`.
- Do not create MEMORY.md files or use markdown TODO lists for task tracking.

### Structure and hierarchy

Prefer organizing work as epics with child tasks. Avoid flat, disconnected issues for multi-step efforts. Small ad-hoc tasks (e.g. retro prevention actions) can stand alone with labels.

- Create an epic for any effort with more than one step: `bd create --title="Epic title" --type=epic`.
- Break epics into tasks with hierarchical IDs (e.g. `bd-a3f8.1`, `bd-a3f8.1.1`).
- Set priorities on everything (0=critical, 1=high, 2=medium, 3=low, 4=backlog).
- Use `bd dep add` to express blocking relationships between tasks.

### Learnings

Knowledge has three tiers of durability. Use the right tier for the insight.

**Tier 1 — Always in context (`bd remember`).** Atomic, universal facts that every session needs. Conventions, preferences, one-liners. These appear in every `bd prime`. Keep tier-1 under ~20 memories. Prefer tier 2 for structured knowledge.

```
bd remember "web-apps uses pnpm, not yarn"
bd remember --key <key> "corrected fact"   # update in place
bd forget <key>                            # remove stale ones
```

**Tier 2 — Evergreen learnings (pinned decision issues).** Structured insights that should never decay but don't need to be in every prime. Architecture decisions, hard-won debugging knowledge, stable conventions.

```
bd create --title="Suspense boundaries belong at route level, not per-component" \
  --type=decision --priority=3 \
  --description="Per-component Suspense causes layout thrash and waterfall fetches. Route-level boundaries batch loading states."
bd tag <id> learning
bd tag <id> react
bd update <id> --status=pinned
```

**Tier 3 — Decayable learnings (open decision issues).** Context-specific insights that may become stale. Gotchas, workarounds, version-specific behavior. These naturally decay via `bd gc` after 90 days unless reinforced.

```
bd create --title="pnpm v9 hoisted deps need --filter" \
  --type=decision --priority=3 \
  --description="Phantom resolution in monorepos without --filter."
bd tag <id> learning
bd tag <id> pnpm
```

Reinforce a learning by appending a note (advances the updated timestamp, prevents decay):
```
bd note <id> "confirmed again — still true as of 2026-05"
```

Retire a learning: `bd close <id> --reason="fixed in pnpm v10"`.
Evolve a learning: `bd supersede <id> --with=<new-id>`.

**Domain labels.** Tag every learning with its domain: `react`, `web-apps`, `infra`, `pnpm`, `testing`, `typescript`, etc. Use multiple labels when an insight spans domains. Use lowercase, singular, short labels. Check `bd label list-all` before inventing new ones.

**Session start.** After `bd prime`, query for learnings relevant to the current work:
```
bd query "type=decision AND label=learning AND label=<domain>" --all
```

**Session end.** Before closing:
1. Close completed work issues.
2. Distill any reusable insight into the appropriate tier.
3. If a tier-2 or tier-3 insight is universal enough, also distill it into a `bd remember` (tier 1).

Search before storing: `bd memories <keyword>` and `bd query "type=decision AND label=learning AND title=<keyword>" --all`.

**Retro learnings.** When something goes wrong — a bug, a wasted hour, a wrong assumption — run `/retro` to do a structured post-mortem. Retro insights are tagged `retro` + domain labels and flow into the same tier system. At session start, retro learnings for the current domain surface alongside regular learnings via the query above. Check for `label=retro` specifically when a task feels risky or unfamiliar:
```
bd query "type=decision AND label=retro AND label=<domain>" --all
```

## Worktrunk

Worktrunk (`wt`) is installed for git worktree management. Use `wt` commands instead of raw `git worktree`.

- `wt switch --create <branch>` — create a worktree + branch and switch to it
- `wt switch <branch>` — switch to an existing worktree
- `wt switch -` — switch back to the previous worktree
- `wt switch --create <branch> --base=@` — branch from current HEAD instead of the default branch
- `wt list` — show all worktrees with status, changes, and CI/PR state
- `wt remove` — remove the current worktree (deletes branch if merged)
- `wt merge` — squash, rebase, merge, and clean up in one step

**Spawning a parallel agent in a background worktree:**
```bash
tmux new-session -d -s <name> "wt switch --create <branch> -x claude -- '<task instruction>'"
```

Run `wt <command> --help` for full options on any subcommand.

## Code

Simplicity and clarity are beautiful and paramount. Favor straightforward, readable code over clever or terse solutions. Prioritize maintainability and ease of understanding for future readers over saving a few lines or tokens.

Write code as if the next person maintaining it will be a junior developer or someone new to the codebase. Avoid complex one-liners, nested ternaries, and overly concise syntax that sacrifices readability.

Prefer derivation over effects and synchronization. Compute from canonical state when possible instead of adding bookkeeping, mirrors, or repair loops to keep multiple representations aligned.

In TypeScript, prefer `type` aliases over `interface` declarations unless an interface is specifically required.

Avoid blind type casts and unsafe conversions. They are trapdoors painted to look like types. Reach for narrowing, validation, schema parsing, or better data modeling over forcing a type at system boundaries. Parse external data; don't just assert its shape. If a cast seems unavoidable, stop and prove why the compiler cannot be taught the truth another way.

Use descriptive variable and function names, and include comments to explain non-obvious logic or decisions. Remember that code is read more often than it is written, so optimizing for readability leads to better long-term outcomes for the project.

## Tests

Tests should protect the user experience by verifying actual behavior and observable outcomes, not implementation details. Name tests after the case or scenario they cover so failures explain the broken behavior clearly.
