#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
