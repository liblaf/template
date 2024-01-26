#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function checks() {
  (gh pr checks "$INPUT_PULL_REQUEST" || true) |
    grep --invert-match "$GITHUB_RUN_ID"
}

function count() {
  checks |
    cut --fields=2 |
    (grep --count "$@" || true)
}

while true; do
  sleep 60
  pending=$(count pending)
  if ((pending == 0)); then
    break
  fi
  echo "Waiting for $pending checks to complete..."
done

fail=$(count fail)
if ((fail > 0)); then
  echo "$fail checks failed"
  exit 1
else
  echo "All checks passed"
  exit 0
fi
