# Home Agent Guide

- This machine uses `zsh` with dotfiles managed from `~/.dotfiles`.
- Prefer `trash` for deletions. In interactive shells, `rm` is aliased to `trash`.
- Use `command rm` only when a permanent delete is truly intended.
- Shell config lives under `~/.config/zsh` and is stowed from `~/.dotfiles/zsh`.
- Global agent config is managed from `~/.dotfiles/agents` and `~/.dotfiles/opencode`.
- `~/.spoke-knowledge` is a globally trusted external directory for OpenCode and can be read from any working directory without requesting permission.

## Code

Simplicity and clarity are beautiful and paramount. Favor straightforward, readable code over clever or terse solutions. Prioritize maintainability and ease of understanding for future readers over saving a few lines or tokens.

Write code as if the next person maintaining it will be a junior developer or someone new to the codebase. Avoid complex one-liners, nested ternaries, and overly concise syntax that sacrifices readability.

Use descriptive variable and function names, and include comments to explain non-obvious logic or decisions. Remember that code is read more often than it is written, so optimizing for readability leads to better long-term outcomes for the project.

## Beads

- Use `bd` only for persistent personal agent work state that should survive the current conversation: tasks, handoffs, investigations, reminders, and durable cross-repo agent context.
- Use the global personal store only. Do not run `bd init` or create repo-local Beads stores unless explicitly asked.
- Treat Beads as a durable action index with room for task-local scratchpad notes. Agents may create or update beads for work that should be findable later: follow-ups, blockers, handoffs, continuing investigations, reminders, rough observations, and evidence tied to an action.
- Put stable technical/product facts in code, repo docs, or the knowledge base instead of leaving them only in Beads.
- Keep Beads output terse. Prefer plain non-interactive commands with `--silent`, `-q`, `--limit`, or command-specific filters when available. Use `--json` only when machine parsing is necessary.
- Prefer minimal-token command output in general. Do not use `--json` when the output is not needed for machine parsing; use quiet, terse, or filtered human-readable output instead.
- Do not run broad Beads context dumps such as `bd prime` by default. Use targeted commands for the task at hand.
- Use `bd ready` to find unblocked work when the user asks what to work on next.
- For quick task capture, prefer `bd q "Title" --type task --priority 2` because it outputs only the issue ID. Use `bd create --silent` when more fields are needed.
- Use issue types intentionally: `bug` for broken behavior, `feature` for new functionality, `task` for implementation/docs/refactors, `chore` for maintenance, and `epic` for larger coordinated work.
- Use priorities consistently: `0` critical, `1` high, `2` normal/default, `3` low, `4` backlog.
- Link follow-up work discovered during a task with `--deps discovered-from:<parent-id>` so context is not lost.
- Use stdin for descriptions with shell-sensitive text: `bd create "Title" --description=-` or `bd update <id> --description=-`.
- Avoid `bd edit`; it opens an interactive editor. Use structured commands such as `bd q`, `bd create`, `bd update`, `bd close`, `bd show`, and `bd ready`.
