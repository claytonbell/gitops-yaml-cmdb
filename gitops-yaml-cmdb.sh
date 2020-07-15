#!/bin/bash
set -e

pushd "$(dirname "$0")"

IMAGE=${IMAGE:-gitops-yaml-cmdb}

ci/build.sh

popd

docker run \
  -ti \
  --rm \
  --volume "$(pwd):/data" \
  --workdir /data \
  "${IMAGE}" \
    /app/bin/gitops-cmdb.rb "${@}"
