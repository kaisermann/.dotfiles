function fish_right_prompt
  if not set -q __fish_git_prompt_show_informative_status
    set -g __fish_git_prompt_show_informative_status 1
  end
  if not set -q __fish_git_prompt_hide_untrackedfiles
    set -g __fish_git_prompt_hide_untrackedfiles 1
  end
  if not set -q __fish_git_prompt_showstashstate
    set -g __fish_git_prompt_showstashstate 1
  end
  if not set -q __fish_git_prompt_color_branch
    set -g __fish_git_prompt_color_branch magenta
  end
  if not set -q __fish_git_prompt_showupstream
    set -g __fish_git_prompt_showupstream "informative"
  end
  if not set -q __fish_git_prompt_char_upstream_ahead
    set -g __fish_git_prompt_char_upstream_ahead "↑"
  end
  if not set -q __fish_git_prompt_char_upstream_behind
    set -g __fish_git_prompt_char_upstream_behind "↓"
  end
  if not set -q __fish_git_prompt_char_upstream_prefix
    set -g __fish_git_prompt_char_upstream_prefix ""
  end
  if not set -q __fish_git_prompt_char_stagedstate
    set -g __fish_git_prompt_char_stagedstate "●"
  end
  if not set -q __fish_git_prompt_char_dirtystate
    set -g __fish_git_prompt_char_dirtystate "~"
  end
  if not set -q __fish_git_prompt_char_untrackedfiles
    set -g __fish_git_prompt_char_untrackedfiles "…"
  end
  if not set -q __fish_git_prompt_char_conflictedstate
    set -g __fish_git_prompt_char_conflictedstate "✖"
  end
  if not set -q __fish_git_prompt_char_cleanstate
    set -g __fish_git_prompt_char_cleanstate "✔"
  end

  if not set -q __fish_git_prompt_color_dirtystate
    set -g __fish_git_prompt_color_dirtystate green
  end
  if not set -q __fish_git_prompt_color_stagedstate
    set -g __fish_git_prompt_color_stagedstate yellow
  end
  if not set -q __fish_git_prompt_color_invalidstate
    set -g __fish_git_prompt_color_invalidstate red
  end
  if not set -q __fish_git_prompt_color_untrackedfiles
    set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
  end
  if not set -q __fish_git_prompt_color_cleanstate
    set -g __fish_git_prompt_color_cleanstate green --bold
  end
	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end
  set -l status_copy $status
  set -l status_color white

  set_color normal
  printf "%s " (__fish_vcs_prompt)

  if test "$status_copy" -ne 0
      set status_color red
  end

  if test "$CMD_DURATION" -gt 100
      set -l duration_copy $CMD_DURATION
      set -l duration (echo $CMD_DURATION | humanize_duration)

      echo -sn (set_color $status_color) "$duration"
  else
      echo -sn (set_color green) (date "+%H:%M:%S")
  end
  set_color normal
end

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
