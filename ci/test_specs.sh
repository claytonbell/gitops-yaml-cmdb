#!/bin/bash

cd "$(dirname "$0")"/.. &&
  ci/docker-run bundle exec rspec --format documentation "${@}"
