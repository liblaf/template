#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if [[ -n $INPUT_TAG && -n $INPUT_FILES ]]; then
  tmpfile=$(mktemp)
  trap 'rm --verbose $tmpfile' EXIT
  wget --output-document="$tmpfile" "https://github.com/${INPUT_REPO}/releases/download/${INPUT_TAG}/sha256sums.txt" || true
  # shellcheck disable=SC2086
  sha256sum $INPUT_FILES > sha256sums.txt
  sed --regexp-extended --expression="s|([[:xdigit:]]+)([[:blank:]])+.*/([^/]+)|\1\2\3|" --in-place "sha256sums.txt"
  if diff "$tmpfile" "sha256sums.txt" > /dev/null; then
    echo "created=false" >> "$GITHUB_OUTPUT"
    exit 0
  fi
fi

if [[ -n $INPUT_TAG ]]; then
  gh release --repo="$INPUT_REPO" delete "$INPUT_TAG" --cleanup-tag || true
fi

args=(gh release)
if [[ -n $INPUT_REPO ]]; then
  args+=(--repo "$INPUT_REPO")
fi
args+=(create)
if [[ -n $INPUT_TAG ]]; then
  args+=("$INPUT_TAG")
fi
# shellcheck disable=SC2206
args+=($INPUT_FILES)
if [[ -f "sha256sums.txt" && ! " ${args[*]} " =~ \ sha256sums.txt\  ]]; then
  args+=("sha256sums.txt")
fi
if [[ "$INPUT_GENERATE_NOTES" ]]; then
  args+=(--generate-notes)
fi
if [[ "$INPUT_LATEST" ]]; then
  args+=(--latest)
fi
if [[ "$INPUT_PRERELEASE" ]]; then
  args+=(--prerelease)
fi
if [[ -n $INPUT_TITLE ]]; then
  args+=(--title "$INPUT_TITLE")
elif [[ -n $INPUT_TAG ]]; then
  args+=(--title "$INPUT_TAG")
fi
echo "${args[@]}"
"${args[@]}"
echo "created=true" >> "$GITHUB_OUTPUT"
