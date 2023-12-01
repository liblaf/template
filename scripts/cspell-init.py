import subprocess
import sys
from collections.abc import MutableMapping, MutableSequence, MutableSet, Sequence

import yaml

completed_process: subprocess.CompletedProcess = subprocess.run(
    [
        "cspell",
        "lint",
        "--words-only",
        "--unique",
        "--exclude=.git",
        "--no-exit-code",
        "--quiet",
        "--dot",
        "--gitignore",
        sys.argv[1] if len(sys.argv) > 1 else ".",
    ],
    stdin=subprocess.DEVNULL,
    stdout=subprocess.PIPE,
    stderr=sys.stderr,
    check=True,
    text=True,
)
stdout: str = completed_process.stdout
words: Sequence[str] = list(set(word.lower() for word in stdout.splitlines()))
completed_process: subprocess.CompletedProcess = subprocess.run(
    [
        "cspell",
        "trace",
        "--allow-compound-words",
        "--ignore-case",
        "--only-found",
        *words,
    ],
    stdin=subprocess.DEVNULL,
    stdout=subprocess.PIPE,
    stderr=sys.stderr,
    check=True,
    text=True,
)
stdout: str = completed_process.stdout
words_to_dictionaries: MutableMapping[str, MutableSequence[str]] = {}
i: int = -1
for line in stdout.splitlines():
    if line.split() == ["Word", "F", "Dictionary", "Dictionary", "Location"]:
        i += 1
        words_to_dictionaries[words[i]] = []
    else:
        words_to_dictionaries[words[i]].append(line.split()[2])
words: MutableSequence[str] = []
dictionaries: MutableSet[str] = set()
for word, dicts in words_to_dictionaries.items():
    if dicts:
        if any(dictionary.endswith("*") for dictionary in dicts):
            pass
        else:
            dictionaries.add(dicts[0])
    else:
        words.append(word)
yaml.safe_dump(
    {
        "words": sorted(words),
        "dictionaries": sorted(dictionaries),
        "allowCompoundWords": True,
    },
    stream=sys.stdout,
    sort_keys=False,
)
