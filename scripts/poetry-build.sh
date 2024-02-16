#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

version=$(poetry version --short)
poetry build
for file in dist/*; do
  dst="${file//"-$version"/}"
  if [[ $file != "$dst" ]]; then
    mv --no-target-directory --verbose "$file" "$dst"
  fi
done
