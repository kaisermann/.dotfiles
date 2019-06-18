# Make 'dot' the floating point separator
set -x LC_NUMERIC "en_US.UTF-8"

# Remove annoying fish greeting message
function fish_greeting
end

function til::git_prompt
    set -g __fish_git_prompt_char_upstream_ahead "↑"
    set -g __fish_git_prompt_char_upstream_behind "↓"
    set -g __fish_git_prompt_char_upstream_prefix ""
    set -g __fish_git_prompt_char_stagedstate "●"
    set -g __fish_git_prompt_char_dirtystate "~"
    set -g __fish_git_prompt_char_untrackedfiles "…"
    set -g __fish_git_prompt_char_conflictedstate "✖"
    set -g __fish_git_prompt_char_cleanstate "✔"
    set -g __fish_git_prompt_char_stateseparator '|'
    set -g __fish_git_prompt_show_informative_status 1
    set -g __fish_git_prompt_hide_untrackedfiles 1
    set -g __fish_git_prompt_showcolorhints 1
    set -g __fish_git_prompt_showstashstate 1
    set -g __fish_git_prompt_color $fish_color_normal
    set -g __fish_git_prompt_color_branch magenta
    set -g __fish_git_prompt_showupstream "informative"
    set -g __fish_git_prompt_color_dirtystate green
    set -g __fish_git_prompt_color_stagedstate yellow
    set -g __fish_git_prompt_color_invalidstate red
    set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
    set -g __fish_git_prompt_color_cleanstate green --bold

    echo -sn (__fish_vcs_prompt) " "
end

function til::time
    set -l exit_code $argv[1]
    if test "$CMD_DURATION" -gt 100
        set_color normal

        if test "$exit_code" -ne 0
            set_color red
        end

        printf "%.2fs" (math $CMD_DURATION / 1000 )
    else
        set_color green
        echo -sn (date "+%H:%M:%S")
    end
end

function til::whoami
    if test 0 -eq (id -u $USER) -o ! -z "$SSH_CLIENT"
        set_color -o white
        echo -sn (host_info "user@host")
        set_color normal
        echo -sn " | "
    end
end

function til::dir
    set -l exit_code $argv[1]
    set -l pwd_info (pwd_info "/")

    if pwd_is_home
        set_color -o yellow
        echo -sn "~/"
    end

    if test ! -z "$pwd_info[2]"
        set_color -o yellow
        echo -sn "$pwd_info[2]/"
    end

    if test ! -z "$pwd_info[1]"
        set_color -o white
        echo -sn "$pwd_info[1]"
    end

    if test ! -z "$pwd_info[3]"
        set_color -o yellow
        echo -sn "/$pwd_info[3]"
    end

    set_color normal
end

function til::exit_code
    set -l exit_code $argv[1]
    if test "$exit_code" -ne 0
        set status_color red
        echo -sn (set_color red) " $exit_code" (set_color normal)
    end
end

set vtex_json_path $HOME/.config/configstore/vtex.json
function vtex::prompt
    if not test -f $vtex_json_path
        return
    end

    function parse_vtex_json
        cat $vtex_json_path | grep $argv[1] | sed -n 's/.*\:.*\"\(.*\)\".*/\1/p'
    end

    function vtex::get_account
        parse_vtex_json account
    end

    function vtex::get_workspace
        parse_vtex_json workspace
    end

    if test (vtex::get_workspace 2> /dev/null)
        echo -sn '['
        set_color magenta
        echo -sn (vtex::get_account)/(vtex::get_workspace)
        set_color normal
        echo -sn ']'
    end
end

function fish_right_prompt
    set -l exit_code $status
    vtex::prompt
    til::git_prompt
    til::time $exit_code

    set_color normal
end

function fish_prompt
    set -l exit_code $status
    set -l status_color cyan

    if test "$exit_code" -ne 0
        set status_color red
    end

    til::whoami
    til::dir
    til::exit_code $exit_code

    set_color $status_color
    echo -en " \$ "

    set_color normal
end
