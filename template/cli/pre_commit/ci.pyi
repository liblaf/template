import pathlib
from typing import Annotated

def main(
    config_file: Annotated[pathlib.Path, None] = ...,
    autofix: Annotated[bool, None] = False,
) -> None: ...
