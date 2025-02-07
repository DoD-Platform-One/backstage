#! /usr/bin/env bash

# Exit on error
set -e

# Get dirs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/get_dirs.sh"

cp .single-stage.dockerignore .dockerignore
{
  yarn build-image
} || {
  rm .dockerignore
  exit 1
}

rm .dockerignore
