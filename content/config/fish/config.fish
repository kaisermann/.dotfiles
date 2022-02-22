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

set DIR (realpath (dirname (status -f)); and pwd)

source $DIR/abbrs.fish
source $DIR/functions/node_bin_path.fish

set -gx VOLTA_HOME "$HOME/.volta"

# sets brew and volta bin paths
set -gx PATH \
    $PATH \
    /opt/homebrew/bin/ \
    "$VOLTA_HOME/bin"