import typer

from template.cli import pre_commit_ci as _pre_commit_ci
from template.cli import sort as _sort

app = typer.Typer(name="template")
app.add_typer(_sort.app, name="sort")
app.command(name="pre-commit-ci")(_pre_commit_ci.main)
