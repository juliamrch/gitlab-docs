#!/usr/bin/env bash

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
    echo "✖ ERROR: The built-in sed in macOS is not supported.
         Install gnu-sed instead: 'brew install gnu-sed'." >&2
    exit 1
  fi
else
  SED="sed"
fi

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target> <version>"
  echo "Example: $0 public 13.0"
  echo "No target provided. Exiting."
  exit 1
fi

if [ -z "$VER" ]; then
  echo "Usage: $0 <target> <version>"
  echo "Example: $0 public 13.0"
  echo "No version provided. Exiting."
  exit 1
fi

if ! [ -d "$TARGET/$VER" ]; then
  echo "Target directory $TARGET/$VER does not exist. Exiting."
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
echo "=> Replace relative URLs in $TARGET/$VER for HTML files"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 "$SED" -i -e 's|href="/ee/|href="/'"$VER"'/ee/|g' \
                                                                          -e 's|href="/runner/|href="/'"$VER"'/runner/|g' \
                                                                          -e 's|href="/omnibus/|href="/'"$VER"'/omnibus/|g' \
                                                                          -e 's|href="/charts/|href="/'"$VER"'/charts/|g' \
                                                                          -e 's|href="/operator/|href="/'"$VER"'/operator/|g' \
                                                                          -e 's|href="/assets/|href="/'"$VER"'/assets/|g' \
                                                                          -e 's|href="/frontend/|href="/'"$VER"'/frontend/|g' \
                                                                          -e 's|<a href="/">|<a href="/'"$VER"'/">|g' \
                                                                          -e 's|href="/opensearch.xml|href="/'"$VER"'/opensearch.xml|g'

echo "=> Replace relative URLs in $TARGET/$VER for CSS files"
find "${TARGET}/$VER" -type f -name '*.css' -print0 | xargs -0 "$SED" -i 's|/assets/|/'"$VER"'/assets/|g'

echo "=> Replace relative URLs in $TARGET/$VER for JavaScript files"
find "${TARGET}/$VER" -type f -name '*.js' -print0 | xargs -0 "$SED" -i -e 's|/search/|/'"$VER"'/search/|g' \
                                                                        -e 's|/assets/|/'"$VER"'/assets/|g'
##
## Full URLs
##
echo "=> Replace full URLs in $TARGET/$VER for HTML files"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 "$SED" -i -e 's|href="https://docs.gitlab.com/ee/|href="/'"$VER"'/ee/|g' \
                                                                          -e 's|href="https://docs.gitlab.com/runner/|href="/'"$VER"'/runner/|g' \
                                                                          -e 's|href="https://docs.gitlab.com/omnibus/|href="/'"$VER"'/omnibus/|g' \
                                                                          -e 's|href="https://docs.gitlab.com/charts/|href="/'"$VER"'/charts/|g' \
                                                                          -e 's|href="https://docs.gitlab.com/operator/|href="/'"$VER"'/operator/|g'

echo "=> Fix URLs inside the sitemap"
find "${TARGET}/$VER" -type f -name 'sitemap.xml' -print0 | xargs -0 "$SED" -i 's|docs.gitlab.com/|docs.gitlab.com/'"$VER"'/|g'
