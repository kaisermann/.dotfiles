# Shell configuration
set -x fish_greeting ''
set -x EDITOR vim
set -x BROWSER open

set -gx CLICOLOR 1
# set -gx LS_COLORS "di=38;5;27:fi=38;5;7:ln=38;5;51:pi=40;38;5;11:so=38;5;13:or=38;5;197:mi=38;5;161:ex=38;5;9:"
set -gx TERM xterm-256color
set -gx fish_color_normal white
set -gx fish_color_command white

set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
set -gx LC_NUMERIC en_US.UTF-8

# Colored man pages
set -x LESS_TERMCAP_mb (printf "\033[01;31m")
set -x LESS_TERMCAP_md (printf "\033[01;31m")
set -x LESS_TERMCAP_me (printf "\033[0m")
set -x LESS_TERMCAP_se (printf "\033[0m")
set -x LESS_TERMCAP_so (printf "\033[01;44;33m")
set -x LESS_TERMCAP_ue (printf "\033[0m")
set -x LESS_TERMCAP_us (printf "\033[01;32m")

# Some alias
alias ls 'ls -GFh'
alias grep 'grep --color=always'

# Dircolors (fish's ls already does it)
# eval (dircolors -c ~/.dircolors | sed 's/>&\/dev\/null$//')

set DIR (realpath (dirname (status -f)); and pwd)

source $DIR/path.fish

# Spacefish configuration
set SPACEFISH_PROMPT_ORDER time user dir host git package node docker ruby golang php rust haskell julia aws conda pyenv kubecontext exec_time battery jobs line_sep exit_code char

set SPACEFISH_PROMPT_ADD_NEWLINE true
set SPACEFISH_PROMPT_SEPARATE_LINE true

set SPACEFISH_EXIT_CODE_SHOW true

set SPACEFISH_DIR_TRUNC_REPO false
set SPACEFISH_DIR_TRUNC 3

set SPACEFISH_GIT_STATUS_COLOR 'cyan'
set SPACEFISH_GIT_BRANCH_COLOR 'yellow'

set SPACEFISH_PACKAGE_SYMBOL '📦 '
