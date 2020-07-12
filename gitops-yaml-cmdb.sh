#!/bin/bash

cd "$(dirname "$0")"

IMAGE=${IMAGE:-gitops-yaml-cmdb}

ci/build.sh

docker run -ti --rm "${IMAGE}" bin/gitops-cmdb.rb "${@}"
