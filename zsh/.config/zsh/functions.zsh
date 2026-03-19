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

# Mirror Android screen via scrcpy
# Usage: mirror-android         (USB)
#        mirror-android wifi    (wireless via TCP/IP)
mirror-android() {
  local base_args=(--video-codec=h265 -m1920 --max-fps=60 --no-audio -K)
  if [[ $# -gt 0 ]]; then
    scrcpy "${base_args[@]}" --tcpip=192.168.1.247:5555
  else
    scrcpy "${base_args[@]}"
  fi
}

# Auto-create aliases for kiwi-* scripts in ~/scripts
for script in ~/scripts/kiwi-*.sh(N); do
  if [[ -x "$script" ]]; then
    alias "${script:t:r}"="$script"
  fi
done

# SSH wrapper: downgrade TERM for compatibility with remote servers
ssh() {
  case "$TERM" in
    screen-256color) TERM=screen command ssh "$@" ;;
    xterm-256color)  TERM=xterm command ssh "$@" ;;
    *)               command ssh "$@" ;;
  esac
}
