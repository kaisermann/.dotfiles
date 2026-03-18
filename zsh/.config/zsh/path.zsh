# PATH configuration
# Order matters: first entry has highest priority

# Homebrew
path=(/opt/homebrew/bin $path)

# Volta (Node.js version manager)
path=($VOLTA_HOME/bin $path)

# Java runtime
path=(/opt/homebrew/opt/openjdk@11/bin $path)

# Bun
path=($BUN_INSTALL/bin $path)

# LM Studio CLI
path=($HOME/.lmstudio/bin $path)

# Deduplicate PATH
typeset -U path
