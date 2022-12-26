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

function success() {
  if exists rich; then
    rich --style "bold bright_green" --print "${*}"
  else
    echo -e -n "\x1b[1;92m"
    echo -n "${*}"
    echo -e "\x1b[0m"
  fi
}

function call() {
  info "+ ${*}"
  "${@}"
}

function copy() {
  mkdir --parents "$(realpath --canonicalize-missing "${2}/..")"
  cp --force --recursive "${1}" "${2}"
  success "Copy: ${1} -> ${2}"
}

if [[ -n ${1-} ]]; then
  workspace="${1}"
else
  workspace="$(git rev-parse --show-toplevel || pwd)"
fi

cd "${workspace}"
call bash "scripts/build.sh"
mkdir --parents "${HOME}/.local/bin"
files=("dist"/*)
for file in "${files[@]}"; do
  if [[ -x ${file} ]]; then
    copy "${file}" "${HOME}/.local/bin"
  fi
done
