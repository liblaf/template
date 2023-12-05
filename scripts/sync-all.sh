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
    *)
      if gh workflow --repo="$repo" list --jq='.[] | select(.name == "Template Repository")' --json="name" |
        grep "Template Repository"; then
        if [[ -n ${CI-} ]]; then
          gh secret --repo="$repo" set GH_TOKEN --body="$GH_TOKEN"
        else
          gh secret --repo="$repo" set GH_TOKEN --body="$(bw get notes GH_TOKEN)"
        fi
        gh workflow --repo="$repo" run template.yaml
      fi
      ;;
  esac
done
