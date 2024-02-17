import pathlib
from typing import Annotated

def main(
    config_file: Annotated[pathlib.Path, None] = ...,
    token: Annotated[str | None, None] = None,
    commit: Annotated[bool, None] = False,
) -> None: ...
