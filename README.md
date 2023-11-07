# Template

[![GitHub release (with filter)](https://img.shields.io/github/v/release/liblaf/template)](https://github.com/liblaf/template/releases/latest)
[![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/liblaf/template/ci.yaml)](https://github.com/liblaf/template/actions/workflows/ci.yaml)

## Usage Example

```yaml
jobs:
  template:
    name: Template
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Sync Repository
        uses: liblaf/template@main
      - name: Git Commit
        run: |-
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add --all
          git commit --message="ci: sync with template repository" || true
```
