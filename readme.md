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
./install --volta     # Install Volta, Node.js LTS, diff-so-fancy
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
│       ├── colors/      # Color schemes (onedark, molokai, desert256)
│       └── syntax/      # Syntax files (json, ghmarkdown)
└── misc/                # Stow package: standalone configs
    ├── .editorconfig
    └── .exiftool_config
```

Each top-level directory is a Stow package. Running `stow <package>` from the repo root symlinks its contents into `$HOME`. The `install` script handles this automatically.

## How it works

**Stow** mirrors directory structure as symlinks. For example, `zsh/.config/zsh/.zshrc` becomes `~/.config/zsh/.zshrc`. The `~/.zshenv` file sets `ZDOTDIR=$HOME/.config/zsh` so zsh reads config from there instead of `$HOME`, keeping `$HOME` clean.

**Shell startup order**: `~/.zshenv` → `$ZDOTDIR/.zshrc` → sources `env.zsh`, `path.zsh`, `aliases.zsh`, `functions.zsh` → initializes Sheldon → fzf → zoxide → Starship.

---

## Stow packages

### `zsh/` — Shell configuration

Full Zsh setup with XDG-clean config location (`~/.config/zsh` instead of `$HOME`).

#### Environment variables (`env.zsh`)

| Variable | Value | Purpose |
|----------|-------|---------|
| `EDITOR` | `vim` | Default editor |
| `BROWSER` | `open` | Default browser (macOS) |
| `CLICOLOR` | `1` | Colored CLI output |
| `LC_ALL` / `LANG` | `en_US.UTF-8` | Locale |
| `LESS_TERMCAP_*` | ANSI codes | Colored man pages |
| `VOLTA_HOME` | `~/.volta` | Volta Node.js manager |
| `BUN_INSTALL` | `~/.bun` | Bun runtime |

#### PATH priority (`path.zsh`)

1. `$BUN_INSTALL/bin`
2. `/opt/homebrew/opt/openjdk@11/bin`
3. `/opt/homebrew/bin`
4. `$VOLTA_HOME/bin`
5. System `$PATH`

Deduplicated via `typeset -U path`.

#### Shell options (`.zshrc`)

**History** — 50,000 entries, no duplicates, shared across sessions, written immediately, expanded before executing.

**Navigation** — `AUTO_CD` (type a directory name to cd), silent `AUTO_PUSHD` with dedup.

**Completion** — Case-insensitive matching, menu-style selection, colored completions, `.`/`..` completion. `.zcompdump` regenerated at most once per 24 hours for fast startup.

**Misc** — `INTERACTIVE_COMMENTS`, `NO_BEEP`.

#### Key bindings

| Binding | Action |
|---------|--------|
| Emacs mode | Base keymap |
| `Up` / `Down` | History substring search |
| `Delete` | Delete character |
| `Home` / `End` | Beginning / end of line |

#### Aliases (`aliases.zsh`)

| Alias | Expands to | Purpose |
|-------|-----------|---------|
| `mkdir` | `mkdir -pv` | Create parents, verbose |
| `wget` | `wget -c` | Resume downloads |
| `ls` | `eza` | Modern ls replacement |
| `ll` | `eza -la --icons --group-directories-first` | Long list with icons |
| `la` | `eza -a --icons --group-directories-first` | All files with icons |
| `lt` | `eza -la --icons --tree --level=2` | Tree view (2 levels) |
| `zsh-bench` | `time zsh -i -c exit` | Benchmark shell startup |

#### Custom functions (`functions.zsh`)

| Function | Usage | Purpose |
|----------|-------|---------|
| `reset-dns` | `reset-dns` | Flushes macOS DNS cache |
| `killport` | `killport 3000` | Kill process on a TCP port |
| `zcode` | `zcode myproject` | Zoxide jump + open in VS Code |
| `ssh` | `ssh host` | Wraps ssh to downgrade `$TERM` for remote compatibility |

#### Tool initialization (`.zshrc`)

| Tool | Init | Purpose |
|------|------|---------|
| Sheldon | `eval "$(sheldon source)"` | Load zsh plugins |
| fzf | `source <(fzf --zsh)` | Fuzzy finder keybindings + completion |
| zoxide | `eval "$(zoxide init zsh)"` | Smart `z` directory jumper |
| Starship | `eval "$(starship init zsh)"` | Prompt |

---

### `sheldon/` — Zsh plugin manager

[Sheldon](https://sheldon.cli.rs/) manages 4 Zsh plugins. Plugin cache lives at `~/.local/share/sheldon/` (not tracked).

| Plugin | Source | Purpose |
|--------|--------|---------|
| `zsh-autosuggestions` | zsh-users/zsh-autosuggestions | Fish-like inline history suggestions |
| `zsh-completions` | zsh-users/zsh-completions | Extra completion definitions for many tools |
| `zsh-history-substring-search` | zsh-users/zsh-history-substring-search | Type a substring, arrow keys search matching history |
| `fast-syntax-highlighting` | zdharma-continuum/fast-syntax-highlighting | Real-time command syntax highlighting |

---

### `starship/` — Prompt

Minimal single-line [Starship](https://starship.rs/) prompt inspired by Tide's lean mode.

**Prompt layout:**

```
directory git_branch git_status nodejs rust python docker_context kubernetes cmd_duration
❯
```

| Module | Symbol | Style | Details |
|--------|--------|-------|---------|
| directory | — | bold cyan | Truncated to 3 segments, `…/` prefix |
| git_branch | ` ` | bold purple | Current branch |
| git_status | — | bold red | `[$all_status$ahead_behind]` |
| nodejs | ` ` | default | Detected via `package.json` only |
| rust | ` ` | default | Detected automatically |
| python | ` ` | default | Detected automatically |
| docker_context | ` ` | default | Current Docker context |
| kubernetes | `⎈ ` | default | Shown only in k8s directories |
| cmd_duration | — | bold yellow | Commands taking 2s+ |
| character | `❯` | green/red | Success/error indicator |

`add_newline = false` — no blank line between prompts.

**Kubernetes context aliases** — the `[kubernetes]` module only appears in directories containing k8s-related files (`Chart.yaml`, `helmfile.yaml`, `kustomization.yaml`, `Dockerfile`) or folders (`charts/`, `k8s/`, `kubernetes/`, `helm/`). Long GKE context names are aliased:

| Context | Alias |
|---------|-------|
| `gke_circuit-api-284012_asia-east1-c_circuit-ae1c` | `circuit-ae1c` |
| `gke_circuit-api-284012_asia-southeast1-a_circuit-ase1a` | `circuit-ase1a` |
| `gke_circuit-api-284012_australia-southeast1-a_circuit-ause1a` | `circuit-ause1a` |
| `gke_circuit-api-284012_europe-west1-b_circuit-euw1b` | `circuit-euw1b` |
| `gke_circuit-api-284012_europe-west4-b_circuit-euw4b` | `circuit-euw4b` |
| `gke_circuit-api-284012_southamerica-east1-c_circuit-sae1c` | `circuit-sae1c` |
| `gke_circuit-api-284012_southamerica-west1-a_circuit-saw1a` | `circuit-saw1a` |
| `gke_circuit-api-284012_us-central1-a_circuit-usc1a` | `circuit-usc1a` |
| `gke_circuit-api-284012_us-central1-b_control-usc1b` | `control-usc1b` |
| `gke_circuit-api-284012_us-west1-b_circuit-usw1b` | `circuit-usw1b` |

---

### `git/` — Git configuration

#### Basics

- **Editor**: VS Code (`code --wait`)
- **Default branch**: `main`
- **Line endings**: `autocrlf = input` (normalize to LF on commit)
- **Pager**: [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) for diffs and show

#### Behavior

| Setting | Value | Effect |
|---------|-------|--------|
| `push.default` | `current` | Push to same-name remote branch |
| `push.followTags` | `true` | Push tags automatically |
| `push.autoSetupRemote` | `true` | Auto-set upstream on first push |
| `pull.rebase` | `true` | Rebase instead of merge on pull |
| `fetch.prune` | `true` | Auto-delete stale remote tracking branches |
| `diff.renames` | `copies` | Detect copies as renames |
| `help.autocorrect` | `1` | Auto-run corrected command after 0.1s |

#### Aliases

**Everyday shortcuts:**

| Alias | Command | Purpose |
|-------|---------|---------|
| `co` | `checkout` | Checkout |
| `ci` | `commit` | Commit |
| `cm` | `commit -m` | Quick commit with message |
| `cmnv` | `commit -m --no-verify` | Commit skipping hooks |
| `amend` | `commit --amend -C HEAD` | Amend last commit, reuse message |
| `st` | `status` | Status |
| `sts` | `status -sb` | Short status |
| `br` | `branch` | Branch |

**Diff and log:**

| Alias | Command | Purpose |
|-------|---------|---------|
| `df` | `diff` | Diff |
| `dfs` | `diff --stat` | Diff stat |
| `dfc` | `diff --cached` | Staged diff |
| `dfcs` | `diff --cached --stat` | Staged diff stat |
| `l` | Colored graph log | Pretty log (hash, refs, message, date, author) |
| `ls` | `log --oneline --graph --stat` | Log with file stats |
| `changelog` | `log --oneline --no-merges` | Clean changelog output |

**Undo and reset:**

| Alias | Command | Purpose |
|-------|---------|---------|
| `uncommit` | `reset --soft HEAD~` | Undo last commit, keep staged |
| `unstage` | `reset HEAD --` | Unstage files |
| `rsh N` | `reset --soft HEAD~N` | Soft-reset N commits |
| `rhh N` | `reset --hard HEAD~N` | Hard-reset N commits |
| `foda-se` | `reset --hard HEAD` | Discard all local changes |

**Rebase:**

| Alias | Command | Purpose |
|-------|---------|---------|
| `rbi N` | `rebase -i HEAD~N` | Interactive rebase last N commits |
| `rbc` | `rebase --continue` | Continue rebase |
| `rbs` | `rebase --skip` | Skip rebase step |
| `rba` | `rebase --abort` | Abort rebase |

**Cherry-pick:**

| Alias | Command | Purpose |
|-------|---------|---------|
| `cp` | `cherry-pick` | Cherry-pick |
| `cpc` | `cherry-pick --continue` | Continue |
| `cpa` | `cherry-pick --abort` | Abort |

**Remote and collaboration:**

| Alias | Command | Purpose |
|-------|---------|---------|
| `cr` | `clone --recursive` | Clone with submodules |
| `polite-force-push` | `push --force-with-lease` | Safe force push |
| `pushnv` | `push --no-verify` | Push skipping hooks |
| `fml` | `fetch origin && reset --hard origin/<branch>` | Force-sync to remote |
| `sync` | Delete all tags + `fetch -t` | Re-sync tags from remote |
| `bora` / `pei` | `gh pr create --web` | Open PR creation in browser |
| `contrib` | `shortlog --summary --numbered` | Contributor stats |
| `recent` | `branch --sort=-committerdate` | Branches by recency |
| `show-ignored` | `clean -ndX` | List ignored files |
| `g` | `grep --break --heading -n` | Grep with nice output |

#### URL shortcut

`kaisermann:` rewrites to `git@github.com:kaisermann/` — e.g. `git clone kaisermann:dotfiles`.

#### Special diff driver

`.lockb` files (Bun lockfiles) use `bun` as textconv for readable diffs.

#### Global gitignore (`~/.gitignore.global`)

Ignores macOS junk (`.DS_Store`, `._*`, Spotlight/Trash dirs), Windows junk (`Thumbs.db`, `Desktop.ini`), editor files (`.idea/`, `*.swp`, `*~`), and local env files (`.env.local`, `.env.*.local`).

---

### `vim/` — Vim configuration

One Dark theme with sensible defaults.

**General:**
- 2-space soft tabs (spaces, not tabs)
- `smartindent`, no line wrap
- Line numbers (width 6), cursor line highlight
- 81-column border (red highlight)
- Incremental search, case-insensitive
- Visual bell, no persistent search highlight

**Filetype handling:**

| Pattern | Behavior |
|---------|----------|
| Makefile | Hard tabs (no expandtab) |
| Ruby / Vagrantfile | 2-space indentation |
| JSON | Custom syntax (`~/.vim/syntax/json.vim`) |
| `.md` / `.markdown` | GitHub-flavored Markdown syntax |

**Custom commands:**

| Command | Purpose |
|---------|---------|
| `:PrettyJSON` | Format buffer as JSON via `python -m json.tool` |

**Color schemes** (in `~/.vim/colors/`):

| Scheme | Status | Description |
|--------|--------|-------------|
| `onedark` | Active | Atom-inspired dark theme with language-specific highlighting |
| `molokai` | Available | Classic dark theme |
| `desert256` | Available | 256-color desert variant |

**Syntax files** (in `~/.vim/syntax/`):

| File | Purpose |
|------|---------|
| `json.vim` | Enhanced JSON highlighting |
| `ghmarkdown.vim` | GitHub-flavored Markdown highlighting |

---

### `misc/` — Standalone configs

#### EditorConfig (`~/.editorconfig`)

Universal code style enforced across all editors that support [EditorConfig](https://editorconfig.org/):

- 2-space indentation (spaces)
- UTF-8 charset
- LF line endings
- Auto trim trailing whitespace
- Auto insert final newline

#### ExifTool (`~/.exiftool_config`)

Custom tag shortcuts for batch metadata operations on photos and videos:

| Shortcut | Purpose |
|----------|---------|
| `PhotoDates` | Read/write all date fields in photos (`DateTimeOriginal`, `CreateDate`, `ModifyDate`, `FileCreateDate`, `FileModifyDate`, EXIF dates) |
| `VideoDates` | Same as PhotoDates plus all video-specific dates (`MediaCreateDate`, `MediaModifyDate`, Track1/Track2 dates across containers) |

---

## Brewfile — All packages

### Taps

| Tap | Purpose |
|-----|---------|
| `homebrew/bundle` | Brewfile support |

### CLI tools

| Package | Purpose |
|---------|---------|
| `coreutils` | GNU core utilities |
| `git` | Version control |
| `gh` | GitHub CLI |
| `vim` | Terminal editor |
| `jq` | JSON processor |
| `ripgrep` | Fast recursive grep (`rg`) |
| `tree` | Directory tree viewer |
| `wget` | File downloader |
| `rsync` | File sync/transfer |
| `rename` | Batch file renaming |
| `trash` | Safe rm (moves to Trash) |
| `ncdu` | Interactive disk usage analyzer |
| `hyperfine` | Command benchmarking |
| `exiftool` | Image/video metadata reader/writer |
| `imagemagick` | Image manipulation |
| `ffmpeg` | Audio/video processing |
| `stow` | Symlink manager for dotfiles |

### Shell and prompt

| Package | Purpose |
|---------|---------|
| `fzf` | Fuzzy finder (Ctrl-R history, Ctrl-T file picker, Alt-C cd) |
| `sheldon` | Zsh plugin manager |
| `starship` | Cross-shell prompt |
| `zoxide` | Smart directory jumper (`z`) |
| `eza` | Modern `ls` replacement with icons and git integration |

### Development

| Package | Purpose |
|---------|---------|
| `volta` | Node.js version manager (fast, Rust-based) |
| `deno` | Deno JavaScript/TypeScript runtime |
| `rust` | Rust language toolchain |
| `python@3.14` | Python 3.14 |
| `openjdk@11` | Java 11 |
| `cmake` | Build system generator |

### DevOps

| Package | Purpose |
|---------|---------|
| `helm` | Kubernetes package manager |
| `argocd` | ArgoCD GitOps CLI |
| `act` | Run GitHub Actions locally |

### AI

| Package | Purpose |
|---------|---------|
| `ollama` | Run LLMs locally |

### Misc CLI

| Package | Purpose |
|---------|---------|
| `blueutil` | Bluetooth control from the terminal |
| `scrcpy` | Android screen mirroring/control |
| `yt-dlp` | Video downloader (YouTube, etc.) |
| `nmap` | Network scanner |

### GUI apps (casks)

| Cask | Category | Description |
|------|----------|-------------|
| `appcleaner` | System | App uninstaller |
| `chatgpt` | AI | ChatGPT desktop app |
| `cleanshot` | Productivity | Screenshot and screen recording |
| `deepl` | Productivity | Translation |
| `firefox` | Browser | Firefox |
| `gcloud-cli` | DevOps | Google Cloud SDK |
| `google-chrome` | Browser | Chrome |
| `handbrake-app` | Media | Video transcoder |
| `istat-menus` | System | System monitor (CPU, memory, network, etc.) |
| `maccy` | Productivity | Clipboard manager |
| `mullvad-vpn` | Privacy | VPN |
| `numi` | Productivity | Calculator with natural language input |
| `obsidian` | Productivity | Notes and knowledge management |
| `raycast` | Productivity | Launcher and productivity tool (Spotlight replacement) |
| `rectangle` | Productivity | Window manager (keyboard shortcuts for window tiling) |
| `spotify` | Media | Music streaming |
| `tailscale-app` | Networking | Mesh VPN / private network |
| `telegram-desktop` | Communication | Messaging |
| `the-unarchiver` | System | Archive extractor |
| `tuple` | Development | Pair programming |
| `twist` | Communication | Team async communication |
| `visual-studio-code` | Development | Code editor |
| `vlc` | Media | Media player |
| `warp` | Development | AI-powered terminal |
| `whatsapp` | Communication | Messaging |

Apps installed outside Homebrew (Zoom, LM Studio, etc.) are intentionally excluded.

### Volta global packages

Installed by the `--volta` task, not the Brewfile:

- `node` (LTS)
- `diff-so-fancy` — required by gitconfig for pretty diffs

---

## macOS defaults (`macos.sh`)

System preferences applied via `defaults write`:

| Setting | Value | Effect |
|---------|-------|--------|
| `AppleShowAllFiles` | `YES` | Finder shows hidden files |
| `NSDocumentSaveNewDocumentsToCloud` | `false` | Save to disk by default, not iCloud |
| `NewWindowTarget` | `PfLo` | Finder opens to home directory |
| `FXDefaultSearchScope` | `SCcf` | Finder searches current folder by default |
| `ShowPathbar` | `true` | Show path bar in Finder |
| `ShowStatusBar` | `true` | Show status bar in Finder |
| `show-process-indicators` | `true` | Dock shows dots under running apps |
| `DSDontWriteNetworkStores` | `true` | No `.DS_Store` on network volumes |
| `DSDontWriteUSBStores` | `true` | No `.DS_Store` on USB drives |
| `ApplePressAndHoldEnabled` | `false` | Key repeat instead of accent character picker |

Restarts Finder and Dock after applying.

---

## Adding a new config

1. Create a new directory: `mkdir -p newpkg/.config/newpkg/`
2. Add config files inside it, mirroring the target path from `$HOME`
3. Add the package name to the `packages` array in `install`
4. Run `./install --stow`
