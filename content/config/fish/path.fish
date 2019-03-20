# Adds all relevant paths
for p in /opt/bin /opt/local/bin ~/.config/fish/bin /usr/bin /usr/local/bin
    if test -d $p
        set -x PATH $p $PATH
    end
end

# fnm
set PATH $HOME/.fnm $PATH
fnm env --multi --use-on-cd | source

# Rust
test -d $HOME/.cargo/bin; and set -x PATH $HOME/.cargo/bin $PATH

# Adds yarn's default global packages 'bin' path
command -v yarn >/dev/null
and set -x PATH (yarn global bin) $PATH
