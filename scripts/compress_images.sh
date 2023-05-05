#!/usr/bin/env bash

INPUT="$1"
PNGQUANT=$(which pngquant)
PNG="$PNGQUANT -f --skip-if-larger --ext .png --speed 1"

if [ -z "$INPUT" ]; then
  echo "Usage: $0 <INPUT>"
  echo "No target provided. Exiting."
  exit 1
fi

# Compress images
# shellcheck disable=SC2044
for image in $(find "${INPUT}/" -name "*.png")
  do echo "Compressing $image"
  $PNG "$image"
done
