#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

mapfile -t repos < <(
  gh repo list \
    --jq ".[].nameWithOwner" \
    --json "nameWithOwner" \
    --limit 1000 \
    --no-archived \
    --source \
    --visibility public
)

for repo in "${repos[@]}"; do
  case "$repo" in
    */template) ;;
    *)
      if gh workflow --repo "$repo" list --jq '.[] | select(.path == ".github/workflows/template.yaml")' --json "path" |
        grep ".github/workflows/template.yaml" > /dev/null; then
        if [[ -n ${GH_TOKEN-} ]]; then
          gh secret --repo "$repo" set GH_TOKEN --body "$GH_TOKEN"
        fi
        gh workflow --repo "$repo" run template.yaml
      fi
      ;;
  esac
done
