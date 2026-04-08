# Custom functions

# Flush DNS cache
reset-dns() {
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  echo "DNS cache flushed"
}

# Kill process on a given port
killport() {
  if [[ $# -lt 1 ]]; then
    echo "Please specify a port"
    return 1
  fi

  local process_info pid command_name user_name
  process_info=$(lsof -i tcp:"$1" | grep LISTEN)
  pid=$(echo "$process_info" | awk '{print $2}')

  if [[ -n "$pid" ]]; then
    command_name=$(echo "$process_info" | awk '{print $1}')
    echo "Killing process '$command_name' (PID: $pid) running on port $1"
    kill -9 "$pid"
  else
    echo "No process running on port $1"
  fi
}

# z + code: jump to dir and open in VS Code
zcode() {
  z "$1" && code .
}

# Resolve a git worktree path by branch name
git-worktree-path() {
  local repo_root branch target_path line worktree_path worktree_branch

  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf 'Not inside a git repository\n' >&2
    return 1
  }

  if [[ -n "$1" ]]; then
    branch="$1"
  else
    branch=$(git branch --show-current 2>/dev/null)
    if [[ -z "$branch" ]]; then
      printf 'Current branch is detached. Pass a branch name.\n' >&2
      return 1
    fi
  fi

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        worktree_path="${line#worktree }"
        ;;
      branch\ refs/heads/*)
        worktree_branch="${line#branch refs/heads/}"
        if [[ "$worktree_branch" == "$branch" ]]; then
          target_path="$worktree_path"
          break
        fi
        ;;
      '')
        worktree_path=''
        worktree_branch=''
        ;;
    esac
  done < <(git -C "$repo_root" worktree list --porcelain)

  if [[ -z "$target_path" ]]; then
    printf 'No worktree found for branch %s\n' "$branch" >&2
    return 1
  fi

  printf '%s\n' "$target_path"
}

# Change directory into a git worktree
cdwt() {
  local target_path

  target_path=$(git-worktree-path "$1") || return 1
  cd "$target_path" || return 1
}

# SSH wrapper: downgrade TERM for compatibility with remote servers
ssh() {
  case "$TERM" in
    screen-256color) TERM=screen command ssh "$@" ;;
    xterm-256color)  TERM=xterm command ssh "$@" ;;
    *)               command ssh "$@" ;;
  esac
}
