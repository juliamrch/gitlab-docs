#!/usr/bin/env bash

# Note this uses linux-specific (GNU) find syntax, it does not work with MacOS (BSD) find syntax because of the usage of the 'regextype' flag (and possibly other reasons)
find public/ -type f -regextype egrep -iregex ".*\.(html|css|json|xml|txt)" -exec sed --in-place "s#https\?://docs.gitlab.com#https://$CI_COMMIT_REF_SLUG$REVIEW_SLUG.docs.gitlab-review.app#g" "{}" +;
