# PATH configuration
# Order matters: first entry has highest priority

# Volta (Node.js version manager)
path=($VOLTA_HOME/bin $path)

# Homebrew
path=(/opt/homebrew/bin $path)

# Java runtime
path=(/opt/homebrew/opt/openjdk@11/bin $path)

# Bun
path=($BUN_INSTALL/bin $path)

# Deduplicate PATH
typeset -U path
