# Home Agent Guide

- This machine uses `zsh` with dotfiles managed from `~/.dotfiles`.
- Prefer `trash` for deletions. In interactive shells, `rm` is aliased to `trash`.
- Use `command rm` only when a permanent delete is truly intended.
- Shell config lives under `~/.config/zsh` and is stowed from `~/.dotfiles/zsh`.
- Global agent config is managed from `~/.dotfiles/agents` and `~/.dotfiles/opencode`.
- `~/.spoke-knowledge` is a globally trusted external directory for OpenCode and can be read from any working directory without requesting permission.

## Worktrees

When working on Spoke repositories located under `~/Projects/Spoke/`, always create git worktrees inside `~/Projects/Spoke/.worktrees/` rather than as sibling folders alongside the main repo clones.

For example:
```
git -C ~/Projects/Spoke/<repo> worktree add ../../../Projects/Spoke/.worktrees/<repo>-<branch-name> <branch>
```

This keeps the top-level `~/Projects/Spoke/` directory clean and worktrees organized in one place.

## Spoke Role

The user is a Spoke product web engineer working across Dispatch, Connect, and Route Planner.
Expect full-stack product work on web surfaces with close product and design collaboration.
Prioritize product behavior, practical tradeoffs, performance, and safe release flow.
Read `~/.spoke-knowledge/briefings/engineer.md` for behavioral adaptation guidance.
