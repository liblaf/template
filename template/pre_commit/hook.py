from collections.abc import Sequence

import pydantic


class Hook(pydantic.BaseModel):
    """https://pre-commit.com/#creating-new-hooks"""

    id: str
    name: str
    entry: str
    language: str
    files: str = ""
    exclude: str = r"^$"
    types: Sequence[str] = pydantic.Field(default_factory=list)
    types_or: Sequence[str] = pydantic.Field(default_factory=list)
    exclude_types: Sequence[str] = pydantic.Field(default_factory=list)
    always_run: bool = False
    fail_fast: bool = False
    verbose: bool = False
    pass_filenames: bool = True
    require_serial: bool = False
    description: str = ""
    language_version: str = "default"
    minimum_pre_commit_version: str = "0"
    args: Sequence[str] = pydantic.Field(default_factory=list)
    stages: Sequence[str] = pydantic.Field(default_factory=list)
