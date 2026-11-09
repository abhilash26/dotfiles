#!/usr/bin/env bash
set -euo pipefail

for f in *.png; do
  [ -e "$f" ] || continue
  magick "$f" -background white -alpha remove -alpha off "${f%.*}.jpg" || exit 1
done

jpegoptim --strip-all *.jpg
rm -- *.png
