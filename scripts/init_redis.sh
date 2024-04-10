#!/usr/bin/env bash

set -x
set -eo pipefail

RUNNING_CONTAINER=$(docker ps --filter 'name=redis' --format '{{.ID}}')

if [[ -n $RUNNING_CONTAINER ]]; then
    echo >&2 "there is a redis container already running, kill it with"
    echo >&2 "    docker kill ${RUNNING_CONTAINER}"
fi

docker run \
  -p "6379:6379" \
  -d \
  --name "redis_$(date '+%s')" \
  redis:7

echo >&2 "Redis is ready to go!"