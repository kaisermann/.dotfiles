# Main zsh configuration
# ZDOTDIR is set to ~/.config/zsh via ~/.zshenv

# ── Source config modules ───────────────────────────────────────────
source "$ZDOTDIR/env.zsh"
source "$ZDOTDIR/path.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/functions.zsh"

# ── Zsh options ─────────────────────────────────────────────────────
# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS  # Don't record duplicates
setopt HIST_SAVE_NO_DUPS     # Don't save duplicates
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks
setopt SHARE_HISTORY         # Share history between sessions
setopt APPEND_HISTORY        # Append, don't overwrite
setopt INC_APPEND_HISTORY    # Write immediately, not on exit
setopt HIST_VERIFY           # Show expanded history before executing
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming

# Directory navigation
setopt AUTO_CD               # cd by just typing the directory name
setopt AUTO_PUSHD            # Push dirs onto the stack automatically
setopt PUSHD_IGNORE_DUPS     # Don't push duplicates
setopt PUSHD_SILENT          # Don't print dir stack after pushd/popd

# Completion
setopt ALWAYS_TO_END         # Move cursor to end of word on completion
setopt AUTO_MENU             # Show completion menu on tab press
setopt COMPLETE_IN_WORD      # Complete from both ends of a word

# Misc
setopt INTERACTIVE_COMMENTS  # Allow comments in interactive shell
setopt NO_BEEP               # No beeping

# ── Completion system ───────────────────────────────────────────────
autoload -Uz compinit
# Only regenerate .zcompdump once per day for faster startup
if [[ -n "$ZDOTDIR/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive matching
zstyle ':completion:*' list-colors ''                       # Colorize completions
zstyle ':completion:*' menu select                          # Menu-style selection
zstyle ':completion:*' special-dirs true                    # Complete . and ..

# ── Key bindings ────────────────────────────────────────────────────
bindkey -e                          # Emacs-style keybindings
bindkey '^[[A' history-search-backward  # Up arrow: search history
bindkey '^[[B' history-search-forward   # Down arrow: search history
bindkey '^[[3~' delete-char             # Delete key
bindkey '^[[H' beginning-of-line        # Home key
bindkey '^[[F' end-of-line              # End key

# ── Sheldon (plugin manager) ───────────────────────────────────────
eval "$(sheldon source)"

# ── fzf (fuzzy finder) ────────────────────────────────────────────
source <(fzf --zsh)

# ── Zoxide (smart cd) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Starship (prompt) ──────────────────────────────────────────────
eval "$(starship init zsh)"
