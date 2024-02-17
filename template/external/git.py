import subprocess
import sys


def auto(
    message: str,
    name: str = "github-actions[bot]",
    email: str = "41898282+github-actions[bot]@users.noreply.github.com",
) -> None:
    subprocess.run(
        ["git", "config", "user.name", name],
        stdin=subprocess.DEVNULL,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    subprocess.run(
        ["git", "config", "user.email", email],
        stdin=subprocess.DEVNULL,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    subprocess.run(
        ["git", "add", "--all"],
        stdin=subprocess.DEVNULL,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    diff: subprocess.CompletedProcess[bytes] = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        stdin=subprocess.DEVNULL,
        stdout=sys.stdout,
        stderr=sys.stderr,
    )
    match diff.returncode:
        case 0:
            return
        case 1:
            subprocess.run(
                ["git", "commit", f"--message={message}"],
                stdin=subprocess.DEVNULL,
                stdout=sys.stdout,
                stderr=sys.stderr,
                check=True,
            )
            subprocess.run(
                ["git", "push"],
                stdin=subprocess.DEVNULL,
                stdout=sys.stdout,
                stderr=sys.stderr,
                check=True,
            )
        case _:
            diff.check_returncode()
