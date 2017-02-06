function fish_right_prompt
  if not set -q __fish_git_prompt_show_informative_status
    set -g __fish_git_prompt_show_informative_status true
  end
  
  if not set -q __fish_git_prompt_showuntrackedfiles
    set -g __fish_git_prompt_showuntrackedfiles true
  end
  
  if not set -q __fish_git_prompt_showstashstate
    set -g __fish_git_prompt_showstashstate true
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
  
  if not set -q __fish_git_prompt_showdirtystate
    set -g __fish_git_prompt_showdirtystate true
  end
  
  if not set -q __fish_git_prompt_char_stateseparator
    set -g __fish_git_prompt_char_stateseparator '|'
  end

  if not set -q __fish_git_prompt_color_branch
    set -g __fish_git_prompt_color_branch magenta
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

  if not set -q __fish_git_prompt_color
    set -g __fish_git_prompt_color white
  end

  if not set -q __fish_git_prompt_color_flags
    set -g __fish_git_prompt_color_flags red
  end

  if not set -q __fish_git_prompt_color_prefix
    set -g __fish_git_prompt_color_prefix cyan
  end

  if not set -q __fish_git_prompt_color_suffix
    set -g __fish_git_prompt_color_suffix cyan
  end

	if not set -q __fish_prompt_normal
		set -g __fish_prompt_normal (set_color normal)
	end
  printf "%s " (__fish_vcs_prompt)
  
  set -l white (set_color white)
  set -l green (set_color green)

  echo -sn $white
  if test "$CMD_DURATION" -gt 100
      echo -sn (echo $CMD_DURATION | humanize_duration)
  else
      echo -sn $green (date "+%H:%M:%S")
  end
  
  set_color normal
end

function fish_prompt
  # Cache exit status
  set -l last_status $status
  
  if not set -q __fish_prompt_char
    switch (id -u)
      case 0
	      set -g __fish_prompt_char '#'
      case '*'
	      set -g __fish_prompt_char '$'
    end
  end

  # Setup colors
  set -l normal (set_color normal)
  set -l red (set_color red)
  set -l cyan (set_color cyan)
  set -l white (set_color white)
  set -l whiteBold (set_color -o white)
  set -l yellow (set_color -o yellow)
  set -l red (set_color red)
  set -l pwd_info (pwd_info "/")
  set -l pwd_root ""
  
  if pwd_is_home
    set pwd_root "~"
  end
  echo -sn $yellow "$pwd_root/"
  
  # first part of path
  if test ! -z "$pwd_info[2]"
      echo -sn $yellow "$pwd_info[2]/"
  end

  # git repository dir
  if test ! -z "$pwd_info[1]"
      echo -sn $whiteBold "$pwd_info[1]"
  end

  # rest of path
  if test ! -z "$pwd_info[3]"
      echo -sn $yellow "/$pwd_info[3]"
  end

  # error code
  if test "$last_status" -ne 0
      echo -n $red "[$last_status]"
  end
  
  # prompt gryph
  echo -n "" $cyan$__fish_prompt_char$white ""
  set_color normal
end
