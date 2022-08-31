#!/bin/bash

PROJECT_PATH="$(dirname "$0")/../.."
OUTPUT_FILE="$PROJECT_PATH/build/prod-config.tar.xz"

mkdir -p "$(dirname "$OUTPUT_FILE")"

tar \
  cvJf "$OUTPUT_FILE" \
  --transform 's/\.env-prod/.env/' \
  --transform 's/docker-compose-prod\.yml/docker-compose.override.yml/' \
  .env-prod \
  docker-compose.yml \
  docker-compose-prod.yml \
    > /dev/null