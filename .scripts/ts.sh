#!/usr/bin/env bash
set -euo pipefail

directories=("$HOME/.config" "$HOME/dev")

choose_directory() {
  local -a existing=()
  local dir

  for dir in "${directories[@]}"; do
    [[ -d $dir ]] && existing+=("$dir")
  done
  ((${#existing[@]})) || return 1

  find "${existing[@]}" -mindepth 1 -maxdepth 1 \
    \( -type d -o -type l \) -print |
    while IFS= read -r dir; do
      [[ -d $dir ]] && printf '%s\n' "$dir"
    done |
    fzf --scheme=path --height=20 --border-label='projects'
}

if (($#)); then
  case $1 in
    .)  folder_path=$PWD ;;
    ..) folder_path=$(dirname -- "$PWD") ;;
    *)  folder_path=$1 ;;
  esac
else
  folder_path=$(choose_directory) || exit 0
fi

[[ -n $folder_path ]] || exit 0
[[ -d $folder_path ]] || {
  printf 'Not a directory: %s\n' "$folder_path" >&2
  exit 1
}
command -v tmux >/dev/null 2>&1 || {
  printf 'tmux is not installed.\n' >&2
  exit 1
}

folder_path=$(cd -- "$folder_path" && pwd -P)

folder_name=$(basename -- "$folder_path" | tr -cs '[:alnum:]_-' '_')
folder_name=${folder_name##_}
folder_name=${folder_name%%_}
[[ -n $folder_name ]] || folder_name=project

path_hash=$(printf '%s' "$folder_path" | cksum | awk '{print $1}')
session_name="$folder_name-$path_hash"

if ! tmux has-session -t "=$session_name" 2>/dev/null; then
  tmux new-session -d \
    -s "$session_name" \
    -c "$folder_path" \
    -n "$folder_name" ||
    tmux has-session -t "=$session_name" 2>/dev/null ||
    exit 1
fi

if [[ -n ${TMUX_CLIENT:-} ]]; then
  tmux switch-client -c "$TMUX_CLIENT" -t "=$session_name"
elif [[ -n ${TMUX:-} ]]; then
  tmux switch-client -t "=$session_name"
else
  tmux attach-session -t "=$session_name"
fi
