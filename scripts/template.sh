#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function info() {
  rich --print "[bold bright_blue]${*}"
}

function call() {
  info "+ ${@}"
  "${@}"
}

REPO_NAME="$(basename "$(realpath .)")"
files=(
  "mkdocs.yaml"
  "pyproject.toml"
  "README.md"
)
for file in "${files[@]}"; do
  call sed --in-place "s/template/${REPO_NAME}/g" "${file}"
done

files=(.github/workflows/**.yaml)
for file in "${files[@]}"; do
  call sed --in-place "s/branches-ignore/branches/g" "${file}"
done

call gh repo edit --homepage "https://liblaf.github.io/${REPO_NAME}/"
