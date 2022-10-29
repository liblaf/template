#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function prepare() {
  if [[ ! -f "docs/index.md" ]]; then
    cp "README.md" "docs/index.md"
  fi
}

cmd="${1}"
shift 1
case "${cmd}" in
*)
  prepare "${@}"
  ;;
esac
