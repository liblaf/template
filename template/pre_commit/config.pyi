from collections.abc import Sequence
from typing import Literal

import pydantic

class CI(pydantic.BaseModel):
    """https://pre-commit.ci/#configuration"""

    autofix_commit_msg: str
    autofix_prs: bool
    autoupdate_commit_msg: str
    skip: Sequence[str]

class Hook(pydantic.BaseModel):
    """https://pre-commit.com/#pre-commit-configyaml---hooks"""

    id: str
    alias: str | None
    name: str | None
    language_version: str | None
    files: str | None
    exclude: str | None
    types: Sequence[str]
    types_or: Sequence[str]
    exclude_types: Sequence[str]
    args: Sequence[str]
    stages: Sequence[str]
    additional_dependencies: Sequence[str]
    always_run: bool
    verbose: bool
    log_file: str | None

class RepoRemote(pydantic.BaseModel):
    """https://pre-commit.com/#pre-commit-configyaml---repos"""

    repo: str
    rev: str
    hooks: Sequence[Hook]

class RepoLocal(pydantic.BaseModel):
    repo: Literal["local"]
    hooks: Sequence[Hook]

class Config(pydantic.BaseModel):
    """https://pre-commit.com/#pre-commit-configyaml---top-level"""

    ci: CI
    repos: Sequence[RepoRemote | RepoLocal]
