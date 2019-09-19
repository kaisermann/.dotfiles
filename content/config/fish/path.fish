# Adds all relevant paths
set paths \
    /opt/bin /opt/local/bin \
    ~/.config/fish/bin \
    /usr/bin \
    /usr/local/bin \
    /usr/local/sbin \
    $HOME/.fnm \
    $HOME/.cargo/bin \
    /usr/local/opt/findutils/libexec/gnubin

for p in $paths
    if test -d $p
        and not string match -q $p $PATH
        set -x PATH $p $PATH
    end
end

# fnm bootstrap
fnm env --multi --use-on-cd | source

# Adds yarn's default global packages 'bin' path
command -v yarn >/dev/null
and set -x PATH (yarn global bin) $PATH
