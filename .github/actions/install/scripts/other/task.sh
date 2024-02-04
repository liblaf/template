#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
