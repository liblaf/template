from collections.abc import Sequence
from typing import Literal

import pydantic


class CI(pydantic.BaseModel):
    """https://pre-commit.ci/#configuration"""

    autofix_commit_msg: str = """\
[pre-commit.ci] auto fixes from pre-commit.com hooks

for more information, see https://pre-commit.ci"""
    autofix_prs: bool = True
    autoupdate_commit_msg: str = "[pre-commit.ci] pre-commit autoupdate"
    skip: Sequence[str] = pydantic.Field(default_factory=lambda: list)


class Hook(pydantic.BaseModel):
    """https://pre-commit.com/#pre-commit-configyaml---hooks"""

    id: str
    alias: str | None = None
    name: str | None = None
    language_version: str | None = None
    files: str | None = None
    exclude: str | None = None
    types: Sequence[str] = pydantic.Field(default_factory=list)
    types_or: Sequence[str] = pydantic.Field(default_factory=list)
    exclude_types: Sequence[str] = pydantic.Field(default_factory=list)
    args: Sequence[str] = pydantic.Field(default_factory=list)
    stages: Sequence[str] = pydantic.Field(default_factory=list)
    additional_dependencies: Sequence[str] = pydantic.Field(default_factory=list)

    always_run: bool = False
    verbose: bool = False
    log_file: str | None = None


class RepoRemote(pydantic.BaseModel):
    """https://pre-commit.com/#pre-commit-configyaml---repos"""

    repo: str
    rev: str
    hooks: Sequence[Hook]


class RepoLocal(pydantic.BaseModel):
    repo: Literal["local"] = "local"
    hooks: Sequence[Hook]


class Config(pydantic.BaseModel):
    """https://pre-commit.com/#pre-commit-configyaml---top-level"""

    ci: CI = pydantic.Field(default_factory=CI)
    repos: Sequence[RepoRemote | RepoLocal]
