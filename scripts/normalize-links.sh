#!/usr/bin/env bash

COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[39m"

TARGET="$1" # The directory that has all the HTML files including versions.
            # Usually public/ locally and /site in the Docker image.

VER="$2"    # The docs version which is a directory holding all the respective
            # versioned site, for example 13.0/

## Check which OS the script runs from since sed behaves differently
## on macOS and Linux. For macOS, check if you're using the built-in sed.
## gnu-sed is preferred https://medium.com/@bramblexu/install-gnu-sed-on-mac-os-and-set-it-as-default-7c17ef1b8f64.
## For more information about their differences, see
## https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed
if [ "$(uname)" == "Darwin" ]; then
  if hash gsed 2>/dev/null; then
    SED="gsed"
  else
    # shellcheck disable=2059
    printf "${COLOR_RED}ERROR: The built-in sed in macOS is not supported. Run 'make setup'.${COLOR_RESET}\n" >&2
    exit 1
  fi
else
  SED="sed"
fi

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target> <version>"
  echo "Example: $0 public 13.0"
  # shellcheck disable=2059
  printf "${COLOR_RED}ERROR: No target provided.${COLOR_RESET}\n"
  exit 1
fi

if [ -z "$VER" ]; then
  echo "Usage: $0 <target> <version>"
  echo "Example: $0 public 13.0"
  # shellcheck disable=2059
  printf "${COLOR_RED}ERROR: No version provided.${COLOR_RESET}\n"
  exit 1
fi

if ! [ -d "$TARGET/$VER" ]; then
  # shellcheck disable=2059
  printf "${COLOR_RED}ERROR: Target directory $TARGET/$VER does not exist.${COLOR_RESET}\n"
  exit 1
fi

##
## In order for the version to be correct, we need to replace any occurrences
## of relative or full URLs with the respective version. Basically, prefix
## all top level directories (except archives/) under public/ with the version.
##
##
## Relative URLs
##

# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Replacing relative URLs in $TARGET/$VER for HTML files...${COLOR_RESET}\n"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 "$SED" -i -e 's|href="/ee/|href="/'"$VER"'/ee/|g' \
                                                                          -e 's|href="/runner/|href="/'"$VER"'/runner/|g' \
                                                                          -e 's|href="/omnibus/|href="/'"$VER"'/omnibus/|g' \
                                                                          -e 's|href="/charts/|href="/'"$VER"'/charts/|g' \
                                                                          -e 's|href="/operator/|href="/'"$VER"'/operator/|g' \
                                                                          -e 's|="/assets/|="/'"$VER"'/assets/|g' \
                                                                          -e 's|="/frontend/|="/'"$VER"'/frontend/|g' \
                                                                          -e 's|<a href="/">|<a href="/'"$VER"'/">|g' \
                                                                          -e 's|="/opensearch.xml|="/'"$VER"'/opensearch.xml|g'

# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Replacing relative URLs in $TARGET/$VER for CSS files...${COLOR_RESET}\n"
find "${TARGET}/$VER" -type f -name '*.css' -print0 | xargs -0 "$SED" -i 's|/assets/|/'"$VER"'/assets/|g'

# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Replacing relative URLs in $TARGET/$VER for JavaScript files...${COLOR_RESET}\n"
find "${TARGET}/$VER" -type f -name '*.js' -print0 | xargs -0 "$SED" -i -e 's|/search/|/'"$VER"'/search/|g' \
                                                                        -e 's|/assets/|/'"$VER"'/assets/|g'
#
# Full URLs
#
# We exclude the following occurrences from sed that are used to determine the
# canonical URL:
# - rel="canonical"
# - property="og:url"
# See https://gitlab.com/gitlab-org/gitlab-docs/-/issues/1568
#
# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Replacing full URLs in $TARGET/$VER for HTML files...${COLOR_RESET}\n"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 "$SED" -i -e '/\(rel="canonical"\|property="og:url"\)/! s|href="https://docs.gitlab.com/ee/|href="/'"$VER"'/ee/|g' \
                                                                          -e '/\(rel="canonical"\|property="og:url"\)/! s|href="https://docs.gitlab.com/runner/|href="/'"$VER"'/runner/|g' \
                                                                          -e '/\(rel="canonical"\|property="og:url"\)/! s|href="https://docs.gitlab.com/omnibus/|href="/'"$VER"'/omnibus/|g' \
                                                                          -e '/\(rel="canonical"\|property="og:url"\)/! s|href="https://docs.gitlab.com/charts/|href="/'"$VER"'/charts/|g' \
                                                                          -e '/\(rel="canonical"\|property="og:url"\)/! s|href="https://docs.gitlab.com/operator/|href="/'"$VER"'/operator/|g'

# shellcheck disable=2059
printf "${COLOR_GREEN}INFO: Fixing URLs inside the sitemap...${COLOR_RESET}\n"
find "${TARGET}/$VER" -type f -name 'sitemap.xml' -print0 | xargs -0 "$SED" -i 's|docs.gitlab.com/|docs.gitlab.com/'"$VER"'/|g'
