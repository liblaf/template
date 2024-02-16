import typer

from template.cli.sort.pre_commit import config as _config
from template.cli.sort.pre_commit import hooks as _hooks

app = typer.Typer(name="sort")
app.command(name="pre-commit-config")(_config.main)
app.command(name="pre-commit-hooks")(_hooks.main)
