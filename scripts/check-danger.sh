#!/usr/bin/env bash

EXIT_CODE=0

output=$(DANGER_LOCAL_BASE="origin/main" bundle exec rake danger_local)

echo "${output}"

[[ "${output}" =~ "The commit subject must" ]] && EXIT_CODE=1

exit "${EXIT_CODE}"
