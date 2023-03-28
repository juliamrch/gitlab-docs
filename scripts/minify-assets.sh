#!/usr/bin/env bash
# shellcheck disable=SC2059

TARGET="$1"
VER="$2"
MINIFY_FLAGS=("--html-keep-document-tags" "--html-keep-whitespace" "--recursive")

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"

if [ -z "$TARGET" ] || [ -z "$VER" ]; then
  echo "Usage: $0 <target> <ver>"
    printf "${COLOR_RED}ERROR: Either <target> or <ver> is missing.${COLOR_RESET}\n"
  exit 1
fi

if ! [ -d "$TARGET" ]; then
    printf "${COLOR_RED}ERROR: Target directory $TARGET does not exist.${COLOR_RESET}\n"
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
        printf "${COLOR_RED}ERROR: minify not found in PATH. Run 'make setup'.${COLOR_RESET}\n"
    exit 1
  fi
fi

# Minify assets
printf "${COLOR_GREEN}INFO: Minifying HTML...${COLOR_RESET}\n"
if $MINIFY_BIN "${MINIFY_FLAGS[@]}" --type=html --match="\.html$" -o "${TARGET}/${VER}/" "${TARGET}/${VER}"; then
    printf "${COLOR_GREEN}INFO: HTML minified!${COLOR_RESET}\n"
else
    printf "${COLOR_RED}ERROR: Couldn't minify HTML${COLOR_RESET}\n"
  exit 1
fi

printf "${COLOR_GREEN}INFO: Minifying CSS...${COLOR_RESET}\n"
if $MINIFY_BIN "${MINIFY_FLAGS[@]}" --type=css  --match="\.css$"  -o "${TARGET}/${VER}/" "${TARGET}/${VER}"; then
    printf "${COLOR_GREEN}INFO: CSS minified!${COLOR_RESET}\n"
else
    printf "${COLOR_RED}ERROR: Couldn't minify CSS${COLOR_RESET}\n"
  exit 1
fi


printf "${COLOR_GREEN}INFO: Minifying JSON...${COLOR_RESET}\n"
if $MINIFY_BIN "${MINIFY_FLAGS[@]}" --type=json --match="\.json$" -o "${TARGET}/${VER}/" "${TARGET}/${VER}"; then
    printf "${COLOR_GREEN}INFO: JSON minified!${COLOR_RESET}\n"
else
    printf "${COLOR_RED}ERROR: Couldn't minify JSON${COLOR_RESET}\n"
  exit 1
fi

printf "${COLOR_GREEN}INFO: Minifying SVGs...${COLOR_RESET}\n"
if $MINIFY_BIN "${MINIFY_FLAGS[@]}" --type=svg  --match="\.svg$"  -o "${TARGET}/${VER}/" "${TARGET}/${VER}"; then
    printf "${COLOR_GREEN}INFO: SVGs minified!${COLOR_RESET}\n"
else
    printf "${COLOR_RED}ERROR: Couldn't minify SVGs${COLOR_RESET}\n"
  exit 1
fi
