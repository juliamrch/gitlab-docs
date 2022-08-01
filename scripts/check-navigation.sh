#!/usr/bin/env bash

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"

DUPLICATED_NAV_ENTRIES=$(sed -n -E "s/.*[section|category|doc|]_url: '(.*)'/\1/p" content/_data/navigation.yaml | sort | uniq -d)

printf "${COLOR_GREEN}INFO: Checking for identical duplicate global navigation entries...${COLOR_RESET}\n"

if [[ -n $DUPLICATED_NAV_ENTRIES ]]; then
  for DUPLICATED_NAV_ENTRY in $DUPLICATED_NAV_ENTRIES; do
    printf "${COLOR_RED}ERROR (identical duplicate entry):${COLOR_RESET} %s\n" "${DUPLICATED_NAV_ENTRY}"
  done
  exit 1
else
  printf "${COLOR_GREEN}INFO: No identical duplicate entries found!${COLOR_RESET}\n"
  exit 0
fi
