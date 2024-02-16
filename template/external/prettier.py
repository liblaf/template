import subprocess
import sys


def pretter(text: str, parser: str) -> str:
    process: subprocess.CompletedProcess[str] = subprocess.run(
        ["prettier", "--write", "--parser", parser],
        stdout=subprocess.PIPE,
        stderr=sys.stderr,
        check=True,
        input=text,
        text=True,
    )
    return process.stdout
