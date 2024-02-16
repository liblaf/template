import pathlib
from collections.abc import Sequence
from typing import Annotated

import typer
import yaml

from template.external import prettier as _prettier
from template.pre_commit import hook as _hook


def main(
    file: Annotated[
        pathlib.Path, typer.Argument(exists=True, dir_okay=False, writable=True)
    ] = pathlib.Path(".pre-commit-hooks.yaml"),
) -> None:
    hooks: Sequence[_hook.Hook] = [
        _hook.Hook(**hook) for hook in yaml.safe_load(file.read_text())
    ]
    hooks = sorted(hooks, key=lambda hook: hook.id)
    output: str = _prettier.pretter(
        yaml.dump(
            [hook.model_dump(exclude_unset=True) for hook in hooks], sort_keys=False
        ),
        parser="yaml",
    )
    file.write_text(output)
