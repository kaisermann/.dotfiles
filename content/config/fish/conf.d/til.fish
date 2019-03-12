# Remove annoying fish greeting message
function fish_greeting
end

function fish_right_prompt
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
    set -g __fish_prompt_normal (set_color normal)

    set -l exit_code $status
    set -l status_color normal

    set_color normal
    printf "%s " (__fish_vcs_prompt)

    if test "$exit_code" -ne 0
        set status_color red
    end

    if test "$CMD_DURATION" -gt 100
        set -l duration (echo $CMD_DURATION | humanize_duration)
        echo -sn (set_color $status_color) "$duration"
    else
        echo -sn (set_color green) (date "+%H:%M:%S")
    end

    set_color normal
end

function fish_prompt
    set -l exit_code $status
    set -l status_color cyan
    set -l root_glyph "/"
    set -l pwd_info (pwd_info "/")

    if test 0 -eq (id -u $USER) -o ! -z "$SSH_CLIENT"
        echo -sn (set_color $status_color) "who(" (set_color normal)
        echo -sn (set_color -o white) (host_info "user@host") (set_color normal)
        echo -sn (set_color $status_color) ") " (set_color normal)
    end

    if pwd_is_home
        echo -sn (set_color -o yellow) "~/" (set_color normal)
    end

    if test ! -z "$pwd_info[2]"
        echo -sn (set_color -o yellow) "$pwd_info[2]/" (set_color normal)
    end

    if test ! -z "$pwd_info[1]"
        echo -sn (set_color -o white) "$pwd_info[1]" (set_color normal)
    end

    if test ! -z "$pwd_info[3]"
        echo -sn (set_color -o yellow) "/$pwd_info[3]" (set_color normal)
    end

    if test "$exit_code" -ne 0
        set status_color red
        echo -sn (set_color red) " $exit_code" (set_color normal)
    end

    set_color $status_color
    printf " \$ "
    set_color normal
end
