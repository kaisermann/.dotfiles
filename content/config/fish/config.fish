# Shell configuration
set -x fish_greeting ''
set -x EDITOR vim
set -x BROWSER open
set -gx CLICOLOR 1
set -gx TERM xterm-256color
set -x LC_NUMERIC "en_US.UTF-8"

# Colored man pages
set -x LESS_TERMCAP_mb (printf "\033[01;31m")
set -x LESS_TERMCAP_md (printf "\033[01;31m")
set -x LESS_TERMCAP_me (printf "\033[0m")
set -x LESS_TERMCAP_se (printf "\033[0m")
set -x LESS_TERMCAP_so (printf "\033[01;44;33m")
set -x LESS_TERMCAP_ue (printf "\033[0m")
set -x LESS_TERMCAP_us (printf "\033[01;32m")

# Some alias
alias ls 'ls -GFh --color=auto'
alias grep 'grep --color=always'

# Dircolors (fish's ls already does it)
# eval (dircolors -c ~/.dircolors | sed 's/>&\/dev\/null$//')

set DIR (readlink -f (dirname (status -f)); and pwd)

source $DIR/path.fish

# Spacefish configuration
set SPACEFISH_PROMPT_ORDER time user dir host git package node docker ruby golang php rust haskell julia aws conda pyenv kubecontext exec_time battery jobs line_sep exit_code char
set SPACEFISH_PROMPT_ADD_NEWLINE true
set SPACEFISH_PROMPT_SEPARATE_LINE true
set SPACEFISH_EXIT_CODE_SHOW true
set SPACEFISH_PACKAGE_SYMBOL '📦'
set SPACEFISH_GIT_BRANCH_COLOR 'yellow'
set SPACEFISH_GIT_STATUS_COLOR 'cyan'
