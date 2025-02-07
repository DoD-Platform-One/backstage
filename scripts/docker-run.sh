#! /usr/bin/env bash

# Exit on error
set -e

# Get dirs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/get_dirs.sh"

docker run -p 3000:3000 -p 7007:7007 $PACKAGE_NAME
