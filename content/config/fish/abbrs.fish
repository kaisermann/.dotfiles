abbr mkdir mkdir -pv
abbr wget wget -c

# vtex related
abbr prod vtex config set env prod
abbr staging vtex config set env staging
abbr s vtex switch
abbr l vtex link --unsafe
abbr r vtex workspace reset
abbr u vtex use

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