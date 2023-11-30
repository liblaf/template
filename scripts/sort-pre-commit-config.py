from pathlib import Path
from typing import Any

import yaml
from yaml import CLoader as Loader

config_path: Path = Path(".pre-commit-config.yaml")
data: dict[str, Any] = yaml.load(stream=config_path.read_text(), Loader=Loader)
data["repos"].sort(key=lambda x: x["repo"].lower())
config_path.write_text(yaml.dump(data, sort_keys=False))
