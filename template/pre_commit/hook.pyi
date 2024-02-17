from collections.abc import Sequence

import pydantic

class Hook(pydantic.BaseModel):
    """https://pre-commit.com/#creating-new-hooks"""

    id: str
    name: str
    entry: str
    language: str
    files: str
    exclude: str
    types: Sequence[str]
    types_or: Sequence[str]
    exclude_types: Sequence[str]
    always_run: bool
    fail_fast: bool
    verbose: bool
    pass_filenames: bool
    require_serial: bool
    description: str
    language_version: str
    minimum_pre_commit_version: str
    args: Sequence[str]
    stages: Sequence[str]
    additional_dependencies: Sequence[str]
