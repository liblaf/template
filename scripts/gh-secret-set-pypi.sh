#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

gh secret set PYPI_USERNAME --body $(bw get username PyPI)
gh secret set PYPI_PASSWORD --body $(bw get password PyPI)
