#!/usr/bin/env bash
set -euo pipefail

case "$1" in
  up)   brightnessctl set "+$2%" ;;
  down) brightnessctl set "$2%-" ;;
  *)
    echo "Usage: $0 {up|down} PERCENT" >&2
    exit 1
    ;;
esac

brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

notify-send -i display-brightness \
  -h "int:value:$brightness" \
  -h string:x-canonical-private-synchronous:brightness \
  "Brightness: ${brightness}%"
