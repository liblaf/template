#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function call() {
  rich --print "[bold bright_blue]+ ${*}"
  "${@}"
}

function prepare() {
  if [[ ! -f "docs/index.md" ]]; then
    call cp "README.md" "docs/index.md"
  fi
}

function build() {
  call poetry run mkdocs build
}

function deploy() {
  call poetry run mkdocs gh-deploy
}

cmd="${1}"
shift 1
case "${cmd}" in
*)
  "${cmd}" "${@}"
  ;;
esac
