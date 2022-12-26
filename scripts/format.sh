#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function exists() {
  command -v "${@}" > /dev/null 2>&1
}

function info() {
  if exists rich; then
    rich --style "bold bright_blue" --print "${*}"
  else
    echo -e -n "\x1b[1;94m"
    echo -n "${*}"
    echo -e "\x1b[0m"
  fi
}

function call() {
  info "+ ${*}"
  "${@}"
}

if [[ -n ${1-} ]]; then
  workspace="${1}"
else
  workspace="$(git rev-parse --show-toplevel || pwd)"
fi

call isort --profile black "${workspace}"
call black "${workspace}"
