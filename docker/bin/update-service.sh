#!/bin/bash

set -e

SERVICE_NAME="$1"
HOME=/opt/cas

if [[ -z "$SERVICE_NAME" ]]; then
  echo "Usage: $(basename "$0") <service-name>"
  exit 1
fi

(cd "$HOME" && \
  docker-compose pull "$SERVICE_NAME" &&
  docker-compose up --build --no-deps -d "$SERVICE_NAME")
