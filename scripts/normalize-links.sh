#!/usr/bin/env bash

TARGET="$1" # The directory that has all the HTML files including versions.
            # Usually public/ locally and /site in the Docker image.

VER="$2"    # The docs version which is a directory holding all the respective
            # versioned site, for example 13.0/

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
echo "Replace relative URLs in $TARGET/$VER for /ee/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/ee/#="/'"$VER"'/ee/#g'

echo "Replace relative URLs in $TARGET/$VER for /runner/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/runner/#="/'"$VER"'/runner/#g'

echo "Replace relative URLs in $TARGET/$VER for /omnibus/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/omnibus/#="/'"$VER"'/omnibus/#g'

echo "Replace relative URLs in $TARGET/$VER for /charts/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/charts/#="/'"$VER"'/charts/#g'

echo "Replace relative URLs in $TARGET/$VER for /operator/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/operator/#="/'"$VER"'/operator/#g'

echo "Replace relative URLs in $TARGET/$VER for /assets/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/assets/#="/'"$VER"'/assets/#g'
find "${TARGET}/$VER" -type f -name '*.css' -print0 | xargs -0 sed -i 's#/assets/#/'"$VER"'/assets/#g'
find "${TARGET}/$VER" -type f -name '*.js' -print0 | xargs -0 sed -i 's#/assets/#/'"$VER"'/assets/#g'

echo "Replace relative URLs in $TARGET/$VER for /frontend/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/frontend/#="/'"$VER"'/frontend/#g'

echo "Replace relative URLs in $TARGET/$VER for /search/"
find "${TARGET}/$VER" -type f -name '*.js' -print0 | xargs -0 sed -i 's#/search/#/'"$VER"'/search/#g'

echo "Replace relative URLs in $TARGET/$VER for /"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#<a href="/">#<a href="/'"$VER"'/">#g'

echo "Replace relative URLs in $TARGET/$VER for opensearch.xml"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="/opensearch.xml#="/'"$VER"'/opensearch.xml#g'

##
## Full URLs
##
echo "Replace full URLs in $TARGET/$VER for /ee/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="https://docs.gitlab.com/ee/#="/'"$VER"'/ee/#g'

echo "Replace full URLs in $TARGET/$VER for /runner/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="https://docs.gitlab.com/runner/#="/'"$VER"'/runner/#g'

echo "Replace full URLs in $TARGET/$VER for /omnibus/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="https://docs.gitlab.com/omnibus/#="/'"$VER"'/omnibus/#g'

echo "Replace full URLs in $TARGET/$VER for /charts/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="https://docs.gitlab.com/charts/#="/'"$VER"'/charts/#g'

echo "Replace full URLs in $TARGET/$VER for /operator/"
find "${TARGET}/$VER" -type f -name '*.html' -print0 | xargs -0 sed -i 's#="https://docs.gitlab.com/operator/#="/'"$VER"'/operator/#g'

echo "Fix URLs inside the sitemap"
find "${TARGET}/$VER" -type f -name 'sitemap.xml' -print0 | xargs -0 sed -i 's#docs.gitlab.com/#docs.gitlab.com/'"$VER"'/#g'

##
## Don't deploy the CE docs since they are identical to the EE ones.
## https://gitlab.com/gitlab-org/gitlab-docs/issues/418
##
echo "Remove CE dir and symlink EE to CE"
if [ -d "${TARGET}/${VER}/ce/" ]; then cd "${TARGET}/${VER}" && rm -r ce && ln -s ee ce; fi
