#!/usr/bin/env bash

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"
RETURN_CODE=0


DUPLICATED_NAV_ENTRIES=$(sed -n -E "s/.*[section|category|doc|]_url: '(.*)'/\1/p" content/_data/navigation.yaml | sort | uniq -d)

# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Checking for identical duplicate global navigation entries...${COLOR_RESET}\n"

if [[ -n $DUPLICATED_NAV_ENTRIES ]]; then
  for DUPLICATED_NAV_ENTRY in $DUPLICATED_NAV_ENTRIES; do
    printf "${COLOR_RED}ERROR (identical duplicate entry):${COLOR_RESET} %s\n" "${DUPLICATED_NAV_ENTRY}"
  done
  RETURN_CODE=1
else
  # shellcheck disable=2059
  printf "${COLOR_GREEN}INFO: No identical duplicate entries found!${COLOR_RESET}\n"
fi

NAV_ENTRIES_WITH_INDEX=$(sed -n -E "s/.*[section|category|doc|]_url: '(.*)'/\1/p" content/_data/navigation.yaml | grep -e "index.html" | grep -v "index.html.")

# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Checking for global navigation entries with index.html...${COLOR_RESET}\n"

if [[ -n $NAV_ENTRIES_WITH_INDEX ]]; then
  for NAV_ENTRY_WITH_INDEX in $NAV_ENTRIES_WITH_INDEX; do
    printf "${COLOR_RED}ERROR (entry with index.html):${COLOR_RESET} %s\n" "${NAV_ENTRY_WITH_INDEX}"
  done
  RETURN_CODE=1
else
  # shellcheck disable=2059
  printf "${COLOR_GREEN}INFO: No entries with index.html found!${COLOR_RESET}\n"
fi

if [[ $RETURN_CODE == 1 ]]; then exit 1; else exit 0; fi
