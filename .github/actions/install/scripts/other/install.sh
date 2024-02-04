#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
for pkg in "$@"; do
  bash "${pkg}.sh"
done
