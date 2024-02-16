import pathlib
import sys

import yaml

file = pathlib.Path(".github/auto-merge.yaml")
allow: list[str]
deny: list[str]
if file.exists():
    config: dict[str, list[str]] = yaml.safe_load(file.read_text())
    allow = config.get("allow", [])
    deny = config.get("deny", [])
else:
    allow = ["dependabot[bot]", "pre-commit-ci[bot]"]
    deny = []
user: str = sys.argv[1]
if user in deny:
    sys.exit(1)
if user in allow:
    sys.exit(0)
sys.exit(1)
