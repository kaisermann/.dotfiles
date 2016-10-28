set -x AUTOJUMP_SOURCED 1
set -x AUTOJUMP_ERROR_PATH ~/Library/autojump/errors.log

# set the user installation path
if test -d ~/.autojump
  set -gx PATH ~/.autojump/bin $PATH
end

# Set ostype, if not set
if not set -q OSTYPE
    set -gx OSTYPE (echo $OSTYPE)
end

# set error file location
if test (uname) != "Darwin"
    if test -d "$XDG_DATA_HOME"
        set -x AUTOJUMP_ERROR_PATH $XDG_DATA_HOME/autojump/errors.log
    else
        set -x AUTOJUMP_ERROR_PATH ~/.local/share/autojump/errors.log
    end
end

if test ! -d (dirname $AUTOJUMP_ERROR_PATH)
    mkdir -p (dirname $AUTOJUMP_ERROR_PATH)
end

if command -s autojump > /dev/null
    function __aj_add --on-variable PWD
        if status --is-command-substitution
            return
        end

        autojump --add $PWD >/dev/null ^ "$AUTOJUMP_ERROR_PATH" &
    end
else
    function autojump -d "https://github.com/wting/autojump"
        echo "Install <github.com/wting/autojump> to use this plugin." > /dev/stderr
        return 1
    end
end
