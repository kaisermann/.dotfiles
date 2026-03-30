# Home Agent Guide

- This machine uses `zsh` with dotfiles managed from `~/.dotfiles`.
- Prefer `trash` for deletions. In interactive shells, `rm` is aliased to `trash`.
- Use `command rm` only when a permanent delete is truly intended.
- Shell config lives under `~/.config/zsh` and is stowed from `~/.dotfiles/zsh`.
- Global agent config is managed from `~/.dotfiles/agents` and `~/.dotfiles/opencode`.

## Worktrees

When working on Spoke repositories located under `~/Projects/Spoke/`, always create git worktrees inside `~/Projects/Spoke/.worktrees/` rather than as sibling folders alongside the main repo clones.

For example:
```
git -C ~/Projects/Spoke/<repo> worktree add ../../../Projects/Spoke/.worktrees/<repo>-<branch-name> <branch>
```

This keeps the top-level `~/Projects/Spoke/` directory clean and worktrees organized in one place.
