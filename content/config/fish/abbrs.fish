abbr mkdir mkdir -pv
abbr wget wget -c

# vtex related
if command -v exa >/dev/null
    abbr ls exa
else
    abbr ls ls -GFh
    abbr ll ls -lhAls
end

function zcode
    z $argv[1]
    code .
end
