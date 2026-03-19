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

# SSH wrapper: downgrade TERM for compatibility with remote servers
ssh() {
  case "$TERM" in
    screen-256color) TERM=screen command ssh "$@" ;;
    xterm-256color)  TERM=xterm command ssh "$@" ;;
    *)               command ssh "$@" ;;
  esac
}
