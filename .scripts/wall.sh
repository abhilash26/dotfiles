#!/usr/bin/env bash
set -euo pipefail

<<<<<<< HEAD
WALL_FOLDER="$HOME/Pictures/walls"
WALL_FILE="$HOME/Pictures/wall.jpg"
=======
WALL_FOLDER="$HOME/pics/walls"
WALL_FILE="$HOME/pics/wall.jpg"
>>>>>>> a34560c (CHORE: initial commit)

mapfile -d '' wallpapers < <(
  find "$WALL_FOLDER" -type f \( -iname '*.jpg' \) -print0
)

if ((${#wallpapers[@]} == 0)); then
  echo "No wallpaper images found in $WALL_FOLDER" >&2
  exit 1
fi

RAND_FILE="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
cp -- "$RAND_FILE" "$WALL_FILE"
<<<<<<< HEAD
swaybg -i "$WALL_FILE"
=======
pkill swaybg || true
swaybg -i "$WALL_FILE" &

>>>>>>> a34560c (CHORE: initial commit)
