from pathlib import Path

import yaml
from yaml import CLoader as Loader

config_path: Path = Path(".pre-commit-config.yaml")
data = yaml.load(stream=config_path.read_text(), Loader=Loader)
data["repos"].sort(key=lambda x: x["repo"].lower())
for repo in data["repos"]:
    repo["hooks"].sort(key=lambda x: x["id"].lower())
config_path.write_text(yaml.dump(data, sort_keys=False))
