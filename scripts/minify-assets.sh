#!/usr/bin/env bash
# shellcheck disable=SC2059

DEST="$1"
SOURCE="$2"
MINIFY_FLAGS=("--html-keep-document-tags" "--html-keep-whitespace" "--recursive" "--sync")

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"

if [ -z "$DEST" ] || [ -z "$SOURCE" ]; then
  echo "Usage: $0 <target> <ver>"
  printf "${COLOR_RED}ERROR: Either <DEST> or <SOURCE> is missing.${COLOR_RESET}\n"
  exit 1
fi

if ! [ -d "$DEST" ]; then
  printf "${COLOR_RED}ERROR: Output directory $DEST does not exist.${COLOR_RESET}\n"
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
printf "${COLOR_GREEN}INFO: Minifying all assets...${COLOR_RESET}\n"
if $MINIFY_BIN "${MINIFY_FLAGS[@]}" --match="\.html$|\.css$|\.json|\.svg$" -o "${DEST}" "${SOURCE}"; then
  printf "${COLOR_GREEN}INFO: Assets minified!${COLOR_RESET}\n"
  # Calculate sizes before and after minifying/gzipping the static files (HTML, CSS, JS)
  SIZE_BEFORE_MINIFY=$(du -sh "$SOURCE" | awk '{print $1}')
  SIZE_AFTER_MINIFY=$(du -sh "$DEST" | awk '{print $1}')
  # Print size results
  printf "${COLOR_GREEN}INFO: Size before minifying: $SIZE_BEFORE_MINIFY ${COLOR_RESET}\n"
  printf "${COLOR_GREEN}INFO: Size after minifying: $SIZE_AFTER_MINIFY ${COLOR_RESET}\n"

  #
  # Test that minification worked by comparing the number of the source and
  # destination files.
  #
  SOURCE_FILES_COUNT=$(find "$SOURCE" -type f | wc -l)
  DEST_FILES_COUNT=$(find "$DEST" -type f | wc -l)
  SOURCE_DIR_COUNT=$(find "$SOURCE" -type d | wc -l)
  # Destination is always one directory deeper (more) than source, so we subtract one
  DEST_DIR_COUNT=$(($(find "$DEST" -type d | wc -l) - 1))
  printf "${COLOR_GREEN}INFO: Checking that the number of source and destination files is the same...${COLOR_RESET}\n"
  if [[ $SOURCE_FILES_COUNT -eq $DEST_FILES_COUNT ]]; then
    printf "${COLOR_GREEN}SUCCESS: File count in $SOURCE and $DEST: $SOURCE_FILES_COUNT/$DEST_FILES_COUNT ${COLOR_RESET}\n"
  else
    printf "${COLOR_RED}ERROR: File count in $SOURCE and $DEST do not match: $SOURCE_FILES_COUNT/$DEST_FILES_COUNT ${COLOR_RESET}"
    exit 1
  fi
  printf "${COLOR_GREEN}INFO: Checking that the number of source and destination directories is the same...${COLOR_RESET}\n"
  if [[ $SOURCE_DIR_COUNT -eq $DEST_DIR_COUNT ]]; then
    printf "${COLOR_GREEN}SUCCESS: Directory count in $SOURCE and $DEST: $SOURCE_DIR_COUNT/$DEST_DIR_COUNT ${COLOR_RESET}\n"
  else
    printf "${COLOR_RED}ERROR: Directory count in $SOURCE and $DEST do not match: $SOURCE_DIR_COUNT/$DEST_DIR_COUNT ${COLOR_RESET}"
    exit 1
  fi
else
  printf "${COLOR_RED}ERROR: Couldn't minify assets${COLOR_RESET}\n"
  exit 1
fi
