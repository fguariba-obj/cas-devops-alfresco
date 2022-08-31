#!/bin/bash

set -e

DOCKER_COMPOSE_ENV_FILE=.env-build

if docker-compose --env-file "$DOCKER_COMPOSE_ENV_FILE" &> /dev/null; then
  DOCKER_COMPOSE_PARAMS="--env-file $DOCKER_COMPOSE_ENV_FILE $DOCKER_COMPOSE_PARAMS"
else
  # Rename the environment file since docker-compose does not support the CLI argument --env-file.
  mv "$DOCKER_COMPOSE_ENV_FILE" .env
fi

[[ -n "$QUAY_IO_USERNAME" ]] || throw 'Missing QUAY_IO_USERNAME'
[[ -n "$QUAY_IO_PASSWORD" ]] || throw 'Missing QUAY_IO_PASSWORD'

# Log into quay.io (required for Alfresco Enterprise docker images):
docker login quay.io -u "$QUAY_IO_USERNAME" -p "$QUAY_IO_PASSWORD"

# Build and push images:
docker compose $DOCKER_COMPOSE_PARAMS build
docker compose $DOCKER_COMPOSE_PARAMS push