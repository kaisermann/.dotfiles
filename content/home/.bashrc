export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
export PATH="/usr/local/sbin:$PATH"

alias ls='ls -GFh'

# For nvm
source $(brew --prefix nvm)/nvm.sh

# For z
source /usr/local/etc/profile.d/z.sh
export PATH=$PATH:/home/kaisermann/.postools
alias possh="ssh -oStrictHostKeyChecking=no MAINAPP@127.0.0.1 -p 51000"
