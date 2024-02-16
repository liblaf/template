import pathlib
import subprocess
import sys
import tempfile
from typing import Annotated

import typer
import yaml

from template.pre_commit import config as _config


def main(
    config_file: Annotated[pathlib.Path, typer.Argument()] = pathlib.Path(
        ".pre-commit-config.yaml"
    ),
    autofix: Annotated[bool, typer.Option(envvar="AUTOFIX")] = False,
) -> None:
    config = _config.Config(**yaml.safe_load(config_file.read_text()))
    for repo in config.repos:
        repo.hooks = [hook for hook in repo.hooks if hook.id not in config.ci.skip]
    with tempfile.NamedTemporaryFile(mode="w") as tmpfile:
        tmpfile.write(yaml.dump(config.model_dump(exclude_unset=True), sort_keys=False))
        tmpfile.flush()
        subprocess.run(
            ["pre-commit", "run", "--config", tmpfile.name, "--all-files"],
            stdin=subprocess.DEVNULL,
            stdout=sys.stdout,
            stderr=sys.stderr,
            check=not autofix,
        )
    if autofix:
        subprocess.run(
            ["git", "add", "--all"],
            stdin=subprocess.DEVNULL,
            stdout=sys.stdout,
            stderr=sys.stderr,
            check=True,
        )
        subprocess.run(
            ["git", "commit", "-m", config.ci.autofix_commit_msg],
            stdin=subprocess.DEVNULL,
            stdout=sys.stdout,
            stderr=sys.stderr,
            check=True,
        )
