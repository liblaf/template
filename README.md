# Template

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
```
