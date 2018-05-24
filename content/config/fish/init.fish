# Shell configuration
set -x fish_greeting ''
set -x EDITOR 'vim'
set -x BROWSER open
set -gx CLICOLOR 1

# Some alias
alias ls 'ls -GFh --color=auto'

# Dircolors
eval (dircolors -c ~/.dircolors | sed 's/>&\/dev\/null$//')

# Adds all relevant paths
for p in /opt/bin /opt/local/bin ~/.config/fish/bin /usr/bin /usr/local/bin
	if test -d $p
		set -x PATH $p $PATH
	end
end

# Adds yarn's default global packages 'bin' path
command -v yarn > /dev/null; and set -x PATH (yarn global bin) $PATH
