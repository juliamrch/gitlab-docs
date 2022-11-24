#!/usr/bin/env bash

TARGET="$1"
VER="$2"
PNGQUANT=$(which pngquant)
PNG="$PNGQUANT -f --skip-if-larger --ext .png --speed 1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target> <version>"
  echo "No target provided. Exiting."
  exit 1
fi

if [ -z "$VER" ]; then
  echo "Usage: $0 <target> <version>"
  echo "No version provided. Exiting."
  exit 1
fi

if ! [ -d "$TARGET/$VER" ]; then
  echo "Target directory $TARGET/$VER does not exist. Exiting."
  exit 1
fi

# Compress images
# shellcheck disable=SC2044
for image in $(find "${TARGET}/${VER}/" -name "*.png")
  do echo "Compressing $image"
  $PNG "$image"
done
