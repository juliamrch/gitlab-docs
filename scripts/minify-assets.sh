#!/usr/bin/env bash

TARGET="$1"
VER="$2"
MINIFY_FLAGS="--html-keep-document-tags --html-keep-whitespace --recursive"

if [ -z "$TARGET" ] || [ -z "$VER" ]; then
  echo "Usage: $0 <target> <ver>"
  echo "Either <target> or <ver> is missing. Exiting."
  exit 1
fi

if ! [ -d "$TARGET" ]; then
  echo "Target directory $TARGET does not exist. Exiting."
  exit 1
fi

# Check if minify is in the PATH
if which minify > /dev/null 2>&1
then
  MINIFY_BIN=$(which minify)
else
  # Backwards compatibility
  if [ -f /scripts/minify ]
  then
    MINIFY_BIN=/scripts/minify
  else
    echo "minify binary not found in PATH. Exiting."
    exit 1
  fi
fi

# Minify assets
printf "Optimizing assets..."

printf "HTML..."; $MINIFY_BIN "$MINIFY_FLAGS" --type=html --match="\.html$" -o "${TARGET}/${VER}/" "${TARGET}/${VER}" || true
printf "CSS..." ; $MINIFY_BIN "$MINIFY_FLAGS" --type=css  --match="\.css$"  -o "${TARGET}/${VER}/" "${TARGET}/${VER}" || true
printf "JSON..."; $MINIFY_BIN "$MINIFY_FLAGS" --type=json --match="\.json$" -o "${TARGET}/${VER}/" "${TARGET}/${VER}" || true
printf "SVG..." ; $MINIFY_BIN "$MINIFY_FLAGS" --type=svg  --match="\.svg$"  -o "${TARGET}/${VER}/" "${TARGET}/${VER}" || true

echo "Done"
