#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if python "$GITHUB_ACTION_PATH/main.py" "$INPUT_USER"; then
  merge=true
else
  merge=false
fi

if "$merge"; then
  gh pr merge "$INPUT_PR" --auto --squash
  gh pr edit "$INPUT_PR" --add-label "automerge: exact" || true
fi
