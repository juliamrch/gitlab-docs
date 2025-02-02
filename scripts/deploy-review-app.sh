#!/usr/bin/env bash

#
# Copied and adapted from https://gitlab.com/gitlab-com/www-gitlab-com/-/blob/10b95368133ea0a23326d293b7a80fc71317d011/scripts/deploy
#

# Exponential backoff, found from StackOverflow at https://stackoverflow.com/questions/8350942/how-to-re-run-the-curl-command-automatically-when-the-error-occurs/8351489#8351489
# Retries a command a with backoff.
#
# The retry count is given by ATTEMPTS (default 5), the
# initial backoff timeout is given by TIMEOUT in seconds
# (default 1.)
#
# Successive backoffs double the timeout.
#
# Beware of set -e killing your whole script!
function with_backoff {
  local max_attempts=${ATTEMPTS-5}
  local timeout=${TIMEOUT-1}
  local attempt=0
  local exitCode=0

  while [[ $attempt -lt $max_attempts ]]
  do
    "$@"
    exitCode=$?

    if [[ $exitCode == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep "$timeout"
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "You've failed me for the last time! ($*)" 1>&2
  fi

  return $exitCode
}

echo "Starting deploy for review app."

gcp_project=$GCP_PROJECT_REVIEW_APPS
gcp_bucket=$GCP_BUCKET_REVIEW_APPS
gcp_service_account_key=$GCP_SERVICE_ACCOUNT_KEY_REVIEW_APPS
cache_control_max_age='60'
src='public/'
dest="gs://$gcp_bucket/$CI_COMMIT_REF_SLUG$REVIEW_SLUG"

echo "$gcp_service_account_key" > key.json
gcloud auth activate-service-account --key-file key.json
gcloud config set project "$gcp_project"

if [ "$DEPLOY_DELETE_APP" = 'true' ]; then
  echo "Deleting review app from ${dest}..."
  echo "gsutil -m rm -r \"$dest\""
  gsutil -m rm -r "$dest"
else
  echo "Deploying review app to ${dest}..."
  echo "gsutil -h \"Cache-Control:public, max-age=$cache_control_max_age\" -m rsync -j css,html,js,txt -r -d \"$src\" \"$dest\""
  with_backoff gsutil -h "Cache-Control:public, max-age=$cache_control_max_age" -m rsync -j css,html,js,txt -r -d "$src" "$dest"
fi
