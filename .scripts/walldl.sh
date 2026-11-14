#!/usr/bin/env bash

set -Eeuo pipefail

WALLHAVEN_API_KEY="l7EEQX0IYFm9eR74UL1MYvNi12sItzTy"
WALLHAVEN_API_BASE_URL="https://wallhaven.cc/api/v1/search"
DEFAULT_DIR="$HOME/pics/walls"
DEFAULT_RESOLUTION="1920x1080"
DEFAULT_RATIO="16x9"

# Usage: ./wallhaven.sh "search tags" [download-directory]

q=${1:?Usage: $0 'search tags' [download-directory]}
dir=${2:-"$DEFAULT_DIR"}

# Defaults
categories=111
purity=100
sorting=favorites
order=desc
topRange=1y
atleast="$DEFAULT_RESOLUTION"
resolutions="$DEFAULT_RESOLUTION"
ratios="$DEFAULT_RATIO"
page=1

for cmd in curl jq parallel magick jpegoptim notify-send; do
    command -v "$cmd" >/dev/null || {
        printf 'Missing dependency: %s\n' "$cmd" >&2
        exit 1
    }
done

mkdir -p -- "$dir"

api_args=(
    --get
    --data-urlencode "q=$q"
    --data-urlencode "categories=$categories"
    --data-urlencode "purity=$purity"
    --data-urlencode "sorting=$sorting"
    --data-urlencode "order=$order"
    --data-urlencode "atleast=$atleast"
    --data-urlencode "resolutions=$resolutions"
    --data-urlencode "ratios=$ratios"
    --data-urlencode "page=$page"
)

# topRange applies to toplist sorting; favorites sorting ignores it.
if [[ $sorting == toplist ]]; then
    api_args+=(--data-urlencode "topRange=$topRange")
fi

auth_args=()
if [[ -n ${WALLHAVEN_API_KEY:-} ]]; then
    auth_args+=(--header "X-API-Key: $WALLHAVEN_API_KEY")
fi

json=$(curl --fail --silent --show-error \
    "${auth_args[@]}" "${api_args[@]}" \
    "$WALLHAVEN_API_BASE_URL")

if ! jq -e '.data | type == "array"' >/dev/null <<<"$json"; then
    printf 'Wallhaven returned an unexpected response:\n' >&2
    jq -r '.errors[]? // .' <<<"$json" >&2
    exit 1
fi

count=$(jq '.data | length' <<<"$json")
if (( count == 0 )); then
    notify-send "Wallhaven" "No wallpapers found for: $q"
    exit 0
fi

download_one() {
    local id=$1 url=$2
    local tmp="$dir/.${1}.tmp.jpg" out="$dir/${1}.jpg"
    local raw="$dir/.${1}.source"

    if ! curl --fail --location --silent --show-error \
        --retry 3 --output "$raw" "$url"; then
        rm -f -- "$raw"
        return 1
    fi

    if ! magick "$raw" -auto-orient -quality 92 "$tmp"; then
        rm -f -- "$raw" "$tmp"
        return 1
    fi
    rm -f -- "$raw"

    if ! jpegoptim --strip-all --quiet "$tmp"; then
        rm -f -- "$tmp"
        return 1
    fi

    mv -- "$tmp" "$out"
    printf 'Saved %s\n' "$out"
}
export -f download_one
export dir

# Download the full-resolution image paths from the search results.
if ! jq -r '.data[] | [.id, .path] | @tsv' <<<"$json" |
    parallel --will-cite --jobs 4 --colsep '\t' \
        'bash -c '\''download_one "$@"'\'' _ {1} {2}'; then
    notify-send "Wallhaven" "Some downloads failed. Check the terminal output."
    exit 1
fi

notify-send "Wallhaven" "Downloaded and optimized $count wallpaper(s) to $dir"
