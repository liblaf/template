#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function _exec() {
  echo -e -n "\033[1;94m"
  echo -n "${@}"
  echo -e "\033[0m"
  "${@}"
}

REPO_NAME="$(basename "$(realpath .)")"
files=(
  "mkdocs.yaml"
  "pyproject.toml"
  "README.md"
)
for file in "${files[@]}"; do
  _exec sed --in-place "s/template/${REPO_NAME}/g" "${file}"
done

files=(.github/workflows/**.yaml)
for file in "${files[@]}"; do
  _exec sed --in-place "s/branches-ignore/branches/g" "${file}"
done

gh repo edit --homepage "https://liblaf.github.io/${REPO_NAME}/"
