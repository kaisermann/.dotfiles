for p in /opt/bin /opt/local/bin ~/.config/fish/bin /usr/bin /usr/local/bin
	if test -d $p
		set -x PATH $p $PATH
	end
end
# Adds yarn's default global packages 'bin' path
command -v yarn > /dev/null; and set -x PATH (yarn global bin) $PATH

# Adds MAMP path
[ -d /Applications/MAMP/Library/bin ]; and set -x PATH /Applications/MAMP/Library/bin $PATH

# Adds coreutils path
[ -d /usr/local/opt/coreutils/libexec/gnubin ]; and set -x PATH /usr/local/opt/coreutils/libexec/gnubin $PATH

# Adds NVM path
if test -d "/usr/local/opt/nvm"
  function nvm
    set -q NVM_DIR; or set -gx NVM_DIR ~/.nvm
    bass source (brew --prefix nvm)/nvm.sh --no-use ';' nvm $argv
  end
end

# Shell configuration
set -x fish_greeting ''
set -x EDITOR "vim"
set -x BROWSER open
set -x PS1 "\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
set -gx CLICOLOR 1
set -gx TERM xterm-256color
set -gx LSCOLORS gxfxcxdxbxegedabagacad

# Some alias
alias ls "ls -GFh"
alias showFiles 'defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles 'defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
command -v rmtrash > /dev/null; and alias rmt "rmtrash"
