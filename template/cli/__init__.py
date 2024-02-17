import typer

from template.cli import pre_commit as _pre_commit
from template.cli import sort as _sort

app: typer.Typer = typer.Typer(name="template")
app.add_typer(_pre_commit.app, name="pre-commit")
app.add_typer(_sort.app, name="sort")
