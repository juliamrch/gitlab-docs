#!/usr/bin/env bash

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"

#
# The following checks are performed:
#
# - index_check: checks if the lunr.js index is built. There's two files when the
#   index is built: 'lunr-index.json' and 'lunr-map.json'.
# - dev_check: when SEARCH_BACKEND is set to 'lunr' the string we're looking for
#   is 'lunr.min.js'. Otherwise, it's set to 'docsearch' by default.
#   This is defined in
#   https://gitlab.com/gitlab-org/gitlab-docs/-/blob/83ebc0de813c6e916b522a9203a6182d7425dd20/content/index.erb#L20-24.
#

if [ "$CI" = "true" ];
then
  lunr_check=$(docker run --rm "$IMAGE_NAME" grep -o lunr.min.js "/usr/share/nginx/html/$GITLAB_VERSION/search/index.html")
  index_check=$(docker run --rm "$IMAGE_NAME" find "/usr/share/nginx/html/$GITLAB_VERSION/assets/javascripts/lunr-index.json" | wc -l)
else
  lunr_check=$(grep -o lunr.min.js public/search/index.html)
  index_check=$(find public/assets/javascripts/lunr-index.json | wc -l)
fi

if [ "$index_check" != 1 ];
then
  # shellcheck disable=2059
  printf "${COLOR_RED}ERROR: lunr.js index is not built!\n"
  printf "       Did you forget to run 'make build-lunr-index'?\n"
  # shellcheck disable=2059
  printf "       For more information, see https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/docsearch.md#lunrjs-search${COLOR_RESET}\n"
  exit 1;
else
  if [ "$lunr_check" != "lunr.min.js" ];
  then
    # shellcheck disable=2059
    printf "${COLOR_RED}ERROR: lunr.js index is found, but not enabled!\n"
    printf "       Did you forget to build the site with SEARCH_BACKEND='lunr'?\n"
    # shellcheck disable=2059
    printf "       For more information, see https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/docsearch.md#lunrjs-search${COLOR_RESET}\n"
    exit 1;
  else
    # shellcheck disable=2059
    printf "${COLOR_GREEN}INFO: lunr.js is found and enabled!${COLOR_RESET}\n"
  fi
fi
