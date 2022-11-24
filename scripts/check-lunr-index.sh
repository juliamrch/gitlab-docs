#!/usr/bin/env bash

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"

#
# The following checks are performed:
#
# - index_check: checks if the lunr.js index is built. There's two files when the
#   index is built: 'lunr-index.json' and 'lunr-map.json'.
# - dev_check: when ALGOLIA_SEARCH is set to 'false' the div we're looking for
#   is set to 'js-lunr-form'. Otherwise, it's set to 'docsearch' by default.
#   This is defined in
#   https://gitlab.com/gitlab-org/gitlab-docs/-/blob/83ebc0de813c6e916b522a9203a6182d7425dd20/content/index.erb#L20-24.
#

if [ "$CI" = "true" ];
then
  div_check=$(docker run --rm "$IMAGE_NAME" grep -o js-lunr-form "/usr/share/nginx/html/$GITLAB_VERSION/index.html")
  index_check=$(docker run --rm "$IMAGE_NAME" find "/usr/share/nginx/html/$GITLAB_VERSION/assets/javascripts/lunr-index.json" | wc -l)
else
  div_check=$(grep -o js-lunr-form public/index.html)
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
  if [ "$div_check" != "js-lunr-form" ];
  then
    # shellcheck disable=2059
    printf "${COLOR_RED}ERROR: lunr.js index is found, but not enabled!\n"
    printf "       Did you forget to build the site with ALGOLIA_SEARCH='false'?\n"
    # shellcheck disable=2059
    printf "       For more information, see https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/docsearch.md#lunrjs-search${COLOR_RESET}\n"
    exit 1;
  else
    # shellcheck disable=2059
    printf "${COLOR_GREEN}INFO: lunr.js is found and enabled!${COLOR_RESET}\n"
  fi
fi
