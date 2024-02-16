import pathlib
from typing import Annotated

import typer
import yaml

from template.external import prettier as _prettier
from template.pre_commit import config as _config


def str_presenter(dumper: yaml.SafeDumper, data: str) -> yaml.ScalarNode:
    """configures yaml for dumping multiline strings

    Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data"""
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")  # type: ignore
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)  # type: ignore


def main(
    file: Annotated[
        pathlib.Path, typer.Argument(exists=True, dir_okay=False, writable=True)
    ] = pathlib.Path(".pre-commit-config.yaml"),
) -> None:
    config = _config.Config(**yaml.safe_load(file.read_text()))
    config.ci.skip = sorted(config.ci.skip)
    for repo in config.repos:
        repo.hooks = sorted(repo.hooks, key=lambda hook: hook.id)
    config.repos = sorted(config.repos, key=lambda repo: repo.repo)
    yaml.SafeDumper.add_representer(str, str_presenter)
    output: str = _prettier.pretter(
        yaml.safe_dump(config.model_dump(exclude_unset=True), sort_keys=False),
        parser="yaml",
    )
    file.write_text(output)
