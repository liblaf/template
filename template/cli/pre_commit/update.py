import asyncio
import pathlib
import re
from typing import Annotated, Optional

import httpx
import semver
import typeguard
import typer
import yaml
from loguru import logger

from template.external import git as _git
from template.external import prettier as _prettier
from template.pre_commit import config as _config


@typeguard.typechecked()
def _filter_tag(tag: str, prerelease: bool = False) -> bool:
    try:
        version: semver.Version = semver.Version.parse(tag.removeprefix("v"))
        if not prerelease and version.prerelease is not None:
            return False
        return True
    except ValueError:
        return False


@typeguard.typechecked()
async def _get_latest_tag(repo: str, token: str | None) -> str | None:
    matches: re.Match[str] | None = re.fullmatch(
        r".*github.com/(?P<user>[^/]+)/(?P<repo>[^/]+)",
        repo.removesuffix(".git"),
    )
    assert matches
    owner: str = matches.group("user")
    repo = matches.group("repo")
    async with httpx.AsyncClient(
        headers={"Authorization": f"Bearer {token}"} if token else None,
        follow_redirects=True,
    ) as client:
        try:
            response: httpx.Response = await client.get(
                f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
            )
            response = response.raise_for_status()
            tag: str = response.json()["tag_name"]
            return tag
        except httpx.HTTPStatusError as e:
            if e.response.status_code != httpx.codes.NOT_FOUND:
                logger.error(e)
        except Exception as e:
            logger.error(e)
        try:
            response = await client.get(
                f"https://api.github.com/repos/{owner}/{repo}/tags"
            )
            response = response.raise_for_status()
            tags: list[str] = [tag["name"] for tag in response.json()]
            filtered: list[str] = [
                tag for tag in tags if _filter_tag(tag, prerelease=False)
            ]
            if not filtered:
                filtered = [tag for tag in tags if _filter_tag(tag, prerelease=True)]
            if not filtered:
                filtered = tags
            latest: str = max(
                filtered, key=lambda tag: semver.Version.parse(tag.removeprefix("v"))
            )
            return latest
        except Exception as e:
            logger.error(e)
    return None


@typeguard.typechecked()
async def _update_repo(
    repo: _config.RepoRemote | _config.RepoLocal, token: str | None = None
) -> _config.RepoRemote | _config.RepoLocal:
    if isinstance(repo, _config.RepoLocal):
        return repo
    if latest := await _get_latest_tag(repo.repo, token):
        logger.debug("[{}] latest tag: {}", repo.repo, latest)
        if repo.rev != latest:
            logger.success("[{}] updating {} -> {}", repo.repo, repo.rev, latest)
            repo.rev = latest
        else:
            logger.info("[{}] already up to date!", repo.repo)
    else:
        logger.error("[{}] failed to update!", repo.repo)
    return repo


@typeguard.typechecked()
async def _update_config(config: _config.Config, token: str | None) -> _config.Config:
    config.repos = await asyncio.gather(
        *[_update_repo(repo, token) for repo in config.repos]
    )
    return config


def main(
    config_file: Annotated[
        pathlib.Path, typer.Option("-c", "--config", exists=True, dir_okay=False)
    ] = pathlib.Path(".pre-commit-config.yaml"),
    token: Annotated[
        Optional[str], typer.Option(envvar=["GH_TOKEN", "GITHUB_TOKEN"])
    ] = None,
    commit: Annotated[bool, typer.Option("--commit")] = False,
) -> None:
    config: _config.Config = _config.Config(**yaml.safe_load(config_file.read_text()))
    config = asyncio.run(_update_config(config, token))
    config_file.write_text(
        _prettier.pretter(
            yaml.dump(config.model_dump(exclude_unset=True), sort_keys=False),
            parser="yaml",
        )
    )
    if commit:
        _git.auto(config.ci.autoupdate_commit_msg)
