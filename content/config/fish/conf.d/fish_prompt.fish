
function fish_prompt

    set -l status_copy $status
    set -l prompt_glyph " \$ "
    set -l status_color cyan
    set -l root_glyph "/"
    set -l pwd_info (pwd_info "/")
  	set -l prefix
    set color_cwd $fish_color_cwd

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

    if test "$status_copy" -ne 0
				set status_color red
        echo -sn (set_color red) " $status_copy" (set_color normal)
    end

    set_color $status_color
    printf "$prompt_glyph"
    set_color normal
end
