# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Zsh shell with [Sheldon](https://sheldon.cli.rs/) (plugin manager), [Starship](https://starship.rs/) (prompt), [zoxide](https://github.com/ajeetdsouza/zoxide) (smart cd), and [eza](https://eza.rocks/) (ls replacement).

## Quick start

```sh
git clone git@github.com:kaisermann/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install
```

This runs all tasks: installs Homebrew + Brewfile packages, sets up Volta/Node, stows config symlinks, locks Sheldon plugins, applies macOS defaults, and sets zsh as default shell. The script is idempotent — safe to re-run at any time.

## Individual tasks

Run specific tasks with flags:

```sh
./install --brew      # Install Homebrew and Brewfile packages
./install --volta     # Install Volta, Node.js, diff-so-fancy
./install --stow      # Create config symlinks via GNU Stow
./install --sheldon   # Lock Sheldon shell plugins
./install --macos     # Apply macOS system defaults (Finder, Dock, etc.)
./install --shell     # Set default shell to zsh
```

Combine flags as needed: `./install --brew --stow`

## Structure

```
~/.dotfiles/
├── install              # Bootstrap script (idempotent, flag-based)
├── macos.sh             # macOS system defaults
├── Brewfile             # Homebrew packages and casks
├── zsh/                 # Stow package: zsh config
│   ├── .zshenv          # → ~/.zshenv (sets ZDOTDIR)
│   └── .config/zsh/
│       ├── .zshrc       # Main config (options, completions, keybinds)
│       ├── env.zsh      # Environment variables
│       ├── path.zsh     # PATH entries
│       ├── aliases.zsh  # Shell aliases
│       └── functions.zsh # Custom functions
├── sheldon/             # Stow package: Sheldon plugin manager
│   └── .config/sheldon/
│       └── plugins.toml # Plugin definitions
├── starship/            # Stow package: Starship prompt
│   └── .config/
│       └── starship.toml
├── git/                 # Stow package: git config
│   ├── .gitconfig
│   └── .gitignore.global
├── vim/                 # Stow package: vim config
│   ├── .vimrc
│   └── .vim/
│       ├── colors/      # Color schemes
│       └── syntax/      # Syntax files
└── misc/                # Stow package: standalone configs
    ├── .editorconfig
    └── .exiftool_config
```

Each top-level directory is a Stow package. Running `stow <package>` from the repo root symlinks its contents into `$HOME`. The `install` script handles this automatically.

## How it works

**Stow** mirrors directory structure as symlinks. For example, `zsh/.config/zsh/.zshrc` becomes `~/.config/zsh/.zshrc`. The `~/.zshenv` file sets `ZDOTDIR=$HOME/.config/zsh` so zsh reads config from there instead of `$HOME`.

**Shell startup order**: `~/.zshenv` → `$ZDOTDIR/.zshrc` → sources `env.zsh`, `path.zsh`, `aliases.zsh`, `functions.zsh` → initializes Sheldon, zoxide, Starship.

## Dependencies

Managed via Brewfile. Key tools:

| Tool | Purpose |
|------|---------|
| `sheldon` | Zsh plugin manager |
| `starship` | Cross-shell prompt |
| `zoxide` | Smart directory jumper (`z`) |
| `eza` | Modern `ls` replacement |
| `volta` | Node.js version manager |
| `diff-so-fancy` | Better git diffs (installed via Volta) |
| `stow` | Symlink manager for dotfiles |

## Adding a new config

1. Create a new directory: `mkdir -p newpkg/.config/newpkg/`
2. Add config files inside it, mirroring the target path from `$HOME`
3. Add the package name to the `packages` array in `install`
4. Run `./install --stow`

## Notes

- Volta global packages (diff-so-fancy, etc.) are installed by the `--volta` task, not the Brewfile
- `macos.sh` restarts Finder and Dock after applying defaults
- The Brewfile intentionally excludes apps installed outside Homebrew (e.g. Zoom, LM Studio)
- Sheldon plugin cache lives in `~/.local/share/sheldon/` (not tracked in this repo)
