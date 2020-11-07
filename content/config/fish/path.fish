# Adds all relevant paths
set paths \
    /opt/bin /opt/local/bin \
    ~/.config/fish/bin \
    /usr/bin \
    /usr/local/bin \
    /usr/local/sbin \
    $HOME/.cargo/bin \
    /usr/local/opt/findutils/libexec/gnubin

for p in $paths
    if test -d $p
        and not string match -q $p $PATH
        set -x PATH $p $PATH
    end
end

# fnm bootstrap
command -v fnm >/dev/null
and fnm env --multi --use-on-cd | source
