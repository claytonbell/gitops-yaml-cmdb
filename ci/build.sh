#!/bin/bash
set -e

cd "$(dirname "$0")/.."

IMAGE=${IMAGE:-gitops-yaml-cmdb}

(
  cat Dockerfile
  echo
  echo "COPY . /app"
) | docker build --rm --tag "${IMAGE}" -f- .
