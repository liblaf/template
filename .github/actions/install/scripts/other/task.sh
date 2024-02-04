#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if [[ ! ":$PATH:" =~ ~/.local/bin: ]]; then
  echo ~/.local/bin >> "$GITHUB_PATH"
fi
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
