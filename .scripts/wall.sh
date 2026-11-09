#!/usr/bin/env bash
set -euo pipefail

WALL_FOLDER="$HOME/Pictures/walls"
WALL_FILE="$HOME/Pictures/wall.jpg"

mapfile -d '' wallpapers < <(
  find "$WALL_FOLDER" -type f \( -iname '*.jpg' \) -print0
)

if ((${#wallpapers[@]} == 0)); then
  echo "No wallpaper images found in $WALL_FOLDER" >&2
  exit 1
fi

RAND_FILE="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
cp -- "$RAND_FILE" "$WALL_FILE"
swaybg -i "$WALL_FILE"
