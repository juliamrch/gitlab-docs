#!/usr/bin/env bash

unlinked_files=0

if [[ -z "$1" ]]; then
  echo "ERROR: No search path supplied."
  exit 1
fi

for FILE in $(git ls-files ./"$1"/**/*.png ./"$1"/**/*.gif ./"$1"/**/*.jpg); do
  if ! git grep "$(basename "$FILE")" > /dev/null; then echo "Unlinked file: $FILE"; unlinked_files+=1; fi
done

if [[ $unlinked_files -gt 0 ]]; then
  echo "ERROR: Unlinked files found."
  exit 1
else
  echo "INFO: No unlinked files found."
  exit 0
fi
