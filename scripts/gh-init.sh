#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

user=$1
repo=$2

# https://docs.github.com/en/rest/repos/repos#update-a-repository
gh api "repos/$user/$repo" \
  --field "allow_merge_commit=false" \
  --field "allow_auto_merge=true" \
  --field "delete_branch_on_merge=true" \
  --method PATCH

# https://docs.github.com/en/rest/actions/permissions#set-default-workflow-permissions-for-a-repository
gh api "repos/$user/$repo/actions/permissions/workflow" \
  --field "default_workflow_permissions=read" \
  --field "can_approve_pull_request_reviews=true" \
  --method PUT

# https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection
gh api "repos/$user/$repo/branches/main/protection" \
  --input "-" \
  --method PUT \
  <<- EOF
{
  "required_status_checks": {
    "strict": false,
    "checks": [
      { "context": "Check", "app_id": 15368 },
      { "context": "conventionalcommits.org", "app_id": 37172 },
      { "context": "GitGuardian Security Checks", "app_id": 46505 }
    ]
  },
  "enforce_admins": null,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": true
}
EOF

if [[ -n ${GH_TOKEN-} ]]; then
  gh secret --repo "$user/$repo" set GH_TOKEN --body "$GH_TOKEN"
fi
