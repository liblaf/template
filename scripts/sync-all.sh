#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

mapfile -t repos < <(
  gh repo list \
    --jq=".[].nameWithOwner" \
    --json="nameWithOwner" \
    --limit=1000 \
    --no-archived \
    --source \
    --visibility="public"
)

for repo in "${repos[@]}"; do
  case "$repo" in
    */template) ;;
    *) run gh workflow --repo="$repo" run template.yaml || continue ;;
  esac
done
