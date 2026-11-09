#!/usr/bin/env bash
set -euo pipefail

sink=@DEFAULT_AUDIO_SINK@

case "$1" in
  up|down)
    op=+
    [[ $1 == down ]] && op=-
    wpctl set-volume -l 1.0 "$sink" "$2%$op"
    ;;
  mute)
    wpctl set-mute "$sink" toggle
    ;;
  *)
    echo "Usage: $0 {up|down} PERCENT | mute" >&2
    exit 1
    ;;
esac

read -r volume muted < <(
  wpctl get-volume "$sink" |
    awk '{printf "%d %s\n", $2 * 100, /MUTED/ ? "yes" : "no"}'
)

icon=audio-volume-high
(( volume < 50 )) && icon=audio-volume-low
(( volume < 10 )) && icon=audio-volume-muted
[[ $muted == yes ]] && icon=audio-volume-muted

notify-send -i "$icon" \
  -h "int:value:$volume" \
  -h string:x-canonical-private-synchronous:volume \
  "Volume: ${volume}%"
