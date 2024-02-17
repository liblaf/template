import typer

from template.cli.pre_commit import ci as _ci
from template.cli.pre_commit import update as _update

app: typer.Typer = typer.Typer(name="pre-commit")
app.command(name="ci")(_ci.main)
app.command(name="update")(_update.main)
