#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function retry() {
  local attempts=0
  local max_attempts=5
  until "$@"; do
    local status_=$?
    if ((attempts < max_attempts)); then
      attempts=$((attempts + 1))
      echo "Retrying $* ... Attempt $attempts / $max_attempts"
      sleep 1
    else
      echo "Exited with status $status_"
      return $status_
    fi
  done
}

retry brew update
for pkg in "$@"; do
  retry brew install "$pkg"
  case $pkg in
    coreutils | make | gnu-*)
      echo "$(brew --prefix)/opt/$pkg/libexec/gnubin" >> "$GITHUB_PATH"
      ;;
  esac
done
