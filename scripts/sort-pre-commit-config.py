from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import Any

import yaml

config_path: Path = Path(".pre-commit-config.yaml")
data: Mapping[str, Any] = yaml.safe_load(stream=config_path.read_text())
repos: Sequence[Mapping[str, Any]] = data["repos"]
data["repos"] = sorted(repos, key=lambda repo: repo["repo"])
config_path.write_text(yaml.dump(data, sort_keys=False))
