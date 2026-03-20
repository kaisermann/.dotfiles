# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Zsh with [Sheldon](https://sheldon.cli.rs/), [Starship](https://starship.rs/), [zoxide](https://github.com/ajeetdsouza/zoxide), and [eza](https://eza.rocks/).

## Quick start

```sh
git clone git@github.com:kaisermann/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install
```

Installs Homebrew packages, Volta/Node, stows config symlinks, locks Sheldon plugins, applies macOS defaults, and sets zsh as the default shell. Idempotent — safe to re-run.

## Tasks

```sh
./install --brew      # Homebrew + Brewfile
./install --volta     # Volta + Node.js
./install --stow      # Symlink configs via Stow
./install --sheldon   # Lock Sheldon plugins
./install --macos     # macOS system defaults
./install --shell     # Set default shell to zsh
```

Combine flags: `./install --brew --stow`

## Structure

Each top-level directory is a [Stow](https://www.gnu.org/software/stow/) package — `stow <pkg>` symlinks its contents into `$HOME`.

| Path | Purpose |
|------|---------|
| [install](install) | Bootstrap script (idempotent, flag-based) |
| [Brewfile](Brewfile) | Homebrew formulae and casks |
| [macos.sh](macos.sh) | macOS `defaults write` preferences |
| [zsh/](zsh) | Zsh config (`ZDOTDIR=~/.config/zsh`) |
| [sheldon/](sheldon) | [Sheldon](https://sheldon.cli.rs/) plugin definitions |
| [starship/](starship) | [Starship](https://starship.rs/) prompt config |
| [git/](git) | Git config + global gitignore |
| [vim/](vim) | Vim config, color schemes, syntax files |
| [misc/](misc) | EditorConfig, ExifTool config |

## Adding a new package

1. `mkdir -p newpkg/.config/newpkg/`
2. Add config files mirroring target paths from `$HOME`
3. Add to the `packages` array in [install](install)
4. `./install --stow`
