# Aliases

# Core utils
alias mkdir='mkdir -pv'
alias wget='wget -c'

# Safer deletes
if command -v trash &> /dev/null; then
  alias rm='trash'
  alias del='trash'
fi

# eza (modern ls replacement)
if command -v eza &> /dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza --group-directories-first -l'
  alias la='eza --group-directories-first -la'
  alias lt='eza --group-directories-first --tree --level=2'
  alias lta='eza --group-directories-first --tree --level=2 -a'
  alias lg='eza --group-directories-first -l --git'
  alias lga='eza --group-directories-first -la --git'
fi

# bat - syntax-highlighted cat with git integration
if command -v bat &> /dev/null; then
  alias cat='bat --style=plain --paging=never'
  alias catt='bat --style=full'
  alias bathelp='bat --plain --language=help'

  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
  export BAT_THEME="Catppuccin Mocha"

  help() {
    "$@" --help 2>&1 | bathelp
  }
fi

# Benchmarking
alias zsh-bench='time zsh -i -c exit'
