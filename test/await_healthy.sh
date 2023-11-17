#!/usr/bin/env bash

CONTAINER_ENGINE="${CONTAINER_ENGINE:-docker}"
GITLAB_BASE_URL="${GITLAB_BASE_URL:-http://127.0.0.1:8080}"

set -e

if [ "$CONTAINER_ENGINE" != "docker" ]; then
  echo "Using container engine $CONTAINER_ENGINE"
fi

printf 'Waiting for GitLab container to become healthy'

until test -n "$($CONTAINER_ENGINE ps --quiet --filter label=gitlab-pipeline-action/owned --filter health=healthy)"; do
  printf '.'
  sleep 5
done

echo
echo "GitLab is healthy at $GITLAB_BASE_URL"

# Print the version, since it is useful debugging information.
curl --silent --show-error --header "Private-Token: TEST1234567890123456" "$GITLAB_BASE_URL/api/v4/version"

echo
