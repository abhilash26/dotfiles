#!/usr/bin/env bash
set -o pipefail

if [[ ${1-} == --worker ]]; then
  shift
  exec yt-dlp -f 'bestaudio/best' -x --audio-format mp3 --audio-quality 0 \
    --embed-thumbnail --add-metadata \
    --external-downloader aria2c \
    --external-downloader-args 'aria2c:-x4 -s4 -k1M' \
    -o '%(title)s [%(id)s].%(ext)s' "$1"
fi

playlist_url=${1:?Usage: ./playlist-mp3.sh PLAYLIST_URL}
script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
script_path="$script_dir/$(basename -- "$0")"

yt-dlp --flat-playlist --print '%(webpage_url)s' "$playlist_url" |
  parallel -j 4 bash "$script_path" --worker

