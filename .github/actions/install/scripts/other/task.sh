#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if [[ ! ":$PATH:" =~ ~/.local/bin: ]]; then
  if [[ $RUNNER_OS == "Windows" ]]; then
    cygpath --windows ~/.local/bin >> "$GITHUB_PATH"
  else
    echo ~/.local/bin >> "$GITHUB_PATH"
  fi
fi
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
