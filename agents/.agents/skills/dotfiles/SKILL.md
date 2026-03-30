---
name: dotfiles
description: Use when editing, adding, or reorganizing anything in the ~/.dotfiles repository. Covers the GNU Stow package structure, how to place new config files, how to re-stow, and what to commit. Load whenever a task touches dotfiles directly or creates new config that should be tracked there.
---

# Dotfiles Workflow

The dotfiles live at `~/.dotfiles` and are managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory inside `~/.dotfiles` is a **Stow package**. Running `stow <pkg>` from `~/.dotfiles` symlinks the package's contents into `$HOME`, mirroring the directory structure.

## Package Structure

| Package | Symlinks into |
|---|---|
| `zsh/` | `~/.config/zsh/`, `~/.zshenv` |
| `opencode/` | `~/.config/opencode/` |
| `agents/` | `~/.agents/` (direct symlink, not stow-managed — see below) |
| `git/` | `~/.gitconfig`, `~/.gitignore.global` |
| `misc/` | `~/.editorconfig`, `~/.exiftool_config` |
| `sheldon/` | `~/.config/sheldon/` |
| `starship/` | `~/.config/starship.toml` |
| `vim/` | `~/.vim/`, `~/.vimrc` |

## Adding or Editing Config

### Editing an existing tracked file
Just edit the file inside `~/.dotfiles/<pkg>/...`. The symlink means the change is live immediately. No re-stow needed.

### Adding a new config file to an existing package
1. Place the file inside `~/.dotfiles/<pkg>/` mirroring its `$HOME` path.
   - Example: to track `~/.config/opencode/AGENTS.md` → create `~/.dotfiles/opencode/.config/opencode/AGENTS.md`
2. Remove the real file at its `$HOME` location if it already exists (stow won't overwrite non-symlinks).
3. Re-stow: `cd ~/.dotfiles && stow --restow <pkg>`

### Adding a brand-new package
1. `mkdir -p ~/.dotfiles/<newpkg>/<mirror-of-home-path>/`
2. Add files under it.
3. Add the package name to the `packages` array in `~/.dotfiles/install`.
4. `cd ~/.dotfiles && stow <newpkg>`

### Adding a new agent skill
Skills live in `~/.dotfiles/agents/.agents/skills/<skill-name>/SKILL.md`.

`~/.agents` is a **direct symlink** to `~/.dotfiles/agents/.agents/` — it is not managed by stow. This means any CLI that installs a skill into `~/.agents/skills/` writes directly into dotfiles. No restow needed.

1. `mkdir -p ~/.dotfiles/agents/.agents/skills/<skill-name>/`
2. Create `SKILL.md` with required YAML frontmatter (`name`, `description`).

The skill is immediately live at `~/.agents/skills/<skill-name>/SKILL.md`.

## Re-stowing

Applies to all packages **except `agents`** (which is a direct symlink).

```bash
cd ~/.dotfiles
stow --restow <pkg>             # re-stow a single package
stow --restow opencode zsh      # re-stow multiple
```

If stow reports a conflict (`cannot stow ... over existing target`), the target file is a real file (not a symlink). Either:
- Move the real file into dotfiles first, then remove the original, then re-stow.
- Or use `--adopt` to absorb it: `stow --adopt <pkg>` (then review `git diff` — adopt overwrites the dotfiles version with the live file).

## Committing Changes

After making changes, commit from `~/.dotfiles`:

```bash
git -C ~/.dotfiles add -A
git -C ~/.dotfiles commit -m "chore: <describe what changed>"
```

There is no CI or pre-commit hook — commits go straight to `main`.
