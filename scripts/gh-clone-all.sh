#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

prefix=${1:-$HOME/github}

repos=($(
  gh repo list \
    --jq=".[].nameWithOwner" \
    --json="nameWithOwner" \
    --limit=1000 \
    --no-archived \
    --source
))

for repo in "${repos[@]}"; do
  case $repo in
    */dotfiles) target=$HOME/.local/share/chezmoi ;;
    *) target=$prefix/$repo ;;
  esac
  if [[ -d "$target/.git" ]]; then
    run git -C "$target" pull
  else
    run gh repo clone "$repo" "$target"
  fi
  case $repo in
    */template) ;;
    *)
      visibility=$(gh repo view "$repo" --jq=".visibility" --json="visibility")
      case $visibility in
        PUBLIC) run make --always-make --directory="$target" --file="$PWD/init.mk" ;;
      esac
      ;;
  esac
done
