# https://fishshell.com/docs/current/cmds/set.html

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

################
# PATH related #
################

# https://fishshell.com/docs/current/cmds/fish_add_path.html
# sets brew path
fish_add_path -g /opt/homebrew/bin/

# sets volta path
set -gx VOLTA_HOME "$HOME/.volta"
fish_add_path -g $VOLTA_HOME/bin/

# Java runtime
fish_add_path -g /opt/homebrew/opt/openjdk@11/bin

# Remove the given path from the PATH environment variable.
# Affects current session only
function remove_from_path
    if set -l index (contains -i $argv[1] $PATH)
        set --erase -g fish_user_paths[$index]
    end
end


function find_node_bin --on-variable PWD
    set -l current_dir $PWD

    # Remove previous paths from PATH
    if set -q LOCAL_NODE_BIN_DIR
        # https://fishshell.com/docs/current/cmds/for.html
        for path in $LOCAL_NODE_BIN_DIR
            remove_from_path $path
        end
    end

    set -g --erase LOCAL_NODE_BIN_DIR

    # Look for closest node_modules/.bin until hitting /
    # And collect them on a list
    while not test (realpath $current_dir) = /
        set bin_dir $current_dir/node_modules/.bin

        if test -d "$bin_dir"
            set -gx --append LOCAL_NODE_BIN_DIR $bin_dir
        end

        set current_dir $current_dir/..
    end

    # If list is set, add those paths to $PATH
    if set -q LOCAL_NODE_BIN_DIR
        fish_add_path -g $LOCAL_NODE_BIN_DIR
    end
end

# Run it when a session starts
find_node_bin
