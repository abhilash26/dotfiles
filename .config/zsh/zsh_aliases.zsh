# Aliases - Safety
alias rm="rm -I --preserve-root"
alias mv="mv -i"
alias cp="cp -i"

# Aliases - Replacements
alias yay="paru"
alias ls="eza -alh --group-directories-first"

# Aliases - Shortening
alias v="nvim"
alias pkg="sudo pacman"
alias sys="sudo systemctl"
alias zed="zeditor"

# Aliases - Sane defaults
alias grep="grep --color=auto"
alias mkdir="mkdir -pv"
alias df="df -h --total"
alias du="du -h --total"
alias free="free -h"
alias ps="ps aux"
alias ping="ping -c 5"
alias journalctl="sudo journalctl -p 3 -xb"

# Aliases - New
alias ..="cd .."


# Functions
mirrors() {
  sudo reflector --latest 10 --sort rate --threads 8 -p https \
    --save /etc/pacman.d/mirrorlist >/dev/null &&
    notify-send 'Mirrors updated.' 2>/dev/null ||
    { notify-send 'Mirror update failed.' 2>/dev/null; return 1; }
}

pkg-refresh() {
  sudo pacman-key --refresh-keys &&
    notify-send 'Package keys refreshed.' 2>/dev/null ||
    { notify-send 'Package key refresh failed.' 2>/dev/null; return 1; }
}

pkg-clean() {
  local o
  local -a p
  o=$(pacman -Qtdq 2>/dev/null) || return 1
  [[ -n $o ]] || { echo 'No orphan packages found.'; return 0; }
  printf '%s\n' "$o"
  mapfile -t p <<< "$o"
  sudo pacman -Rns -- "${p[@]}"
}

hgrep() {
  [[ $# == 1 ]] || { echo 'Usage: hgrep PATTERN' >&2; return 2; }
  history | grep -- "$1"
}

mkcd() {
  [[ $# == 1 ]] || { echo 'Usage: mkcd DIRECTORY' >&2; return 2; }
  mkdir -p -- "$1" && cd -P -- "$1"
}

mkscript() {
  [[ $# == 1 ]] || { echo 'Usage: mkscript FILE' >&2; return 2; }
  [[ ! -e $1 ]] || { echo "File exists: $1" >&2; return 1; }
  printf '#!/usr/bin/env bash\n' > "$1" &&
    chmod u+x -- "$1" &&
    "${EDITOR:-vi}" "$1"
}

cheat() {
  [[ $# == 1 ]] || { echo 'Usage: cheat TOPIC' >&2; return 2; }
  curl -fsSL -- "https://cheat.sh/$1"
}

restart_app() {
  [[ $# -ge 1 ]] || { echo 'Usage: restart_app COMMAND [ARGS...]' >&2; return 2; }
  local c=$1; shift
  pkill -x -- "$c" 2>/dev/null || true
  sleep 1
  command "$c" "$@" &
}
