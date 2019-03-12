# Shell configuration
set -x fish_greeting ''
set -x EDITOR 'vim'
set -x BROWSER open
set -gx CLICOLOR 1

# Some alias
alias ls 'ls -GFh --color=auto'

# Dircolors
eval (dircolors -c ~/.dircolors | sed 's/>&\/dev\/null$//')

set DIR (readlink -f (dirname (status -f)); and pwd)

source $DIR/path.fish

# Spacefish configuration
# set SPACEFISH_PROMPT_ORDER time user dir host git package node docker ruby golang php rust haskell julia aws conda pyenv kubecontext exec_time battery jobs line_sep exit_code char
# set SPACEFISH_PROMPT_ADD_NEWLINE true
# set SPACEFISH_PROMPT_SEPARATE_LINE true
# set SPACEFISH_EXIT_CODE_SHOW true
# set SPACEFISH_PACKAGE_SYMBOL ''
# set SPACEFISH_GIT_BRANCH_COLOR 'yellow'
# set SPACEFISH_GIT_STATUS_COLOR 'cyan'
