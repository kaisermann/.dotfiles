export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
export PATH="/usr/local/sbin:$PATH"

alias ls='ls -GFh'
alias db-replace='~/.tmp/db-replace.sh'
alias tmp='cd ~/.tmp'
alias rmdsstore='find . -type f -name '.DS_Store' -delete'
alias mysql='/Applications/MAMP/Library/bin/mysql --host=localhost -uroot -proot'
