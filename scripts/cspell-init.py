import json
import re
import subprocess
import sys
from collections.abc import MutableMapping, MutableSequence, MutableSet, Set

completed_process: subprocess.CompletedProcess = subprocess.run(
    [
        "cspell",
        "lint",
        "--words-only",
        "--unique",
        "--exclude=.git",
        "--exclude=*-lock.*",
        "--exclude=*.lock",
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
words: Set[str] = set(word.lower() for word in stdout.splitlines())
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
PATTERN: re.Pattern = re.compile(r"(?P<word>.*): (?P<not>Not )?Found")
words_to_dictionaries: MutableMapping[str, MutableSequence[str]] = {
    word: [] for word in words
}
for line in stdout.splitlines():
    if not line:
        pass
    if PATTERN.fullmatch(line):
        continue
    if line.split() == ["Word", "F", "Dictionary", "Dictionary", "Location"]:
        continue
    if len(line.split()) == 4:
        word: str = line.split()[0].replace("+", "")
        dictionary: str = line.split()[2]
        words_to_dictionaries[word].append(dictionary)
words_not_found: MutableSequence[str] = []
dictionaries: MutableSet[str] = set()
for word, dicts in words_to_dictionaries.items():
    if word not in words:
        continue
    if dicts:
        if any(dictionary.endswith("*") for dictionary in dicts):
            pass
        else:
            dictionaries.add(dicts[0])
    else:
        words_not_found.append(word)
config: str = json.dumps(
    {
        "words": sorted(words_not_found),
        "ignorePaths": ["*-lock.*", "*.lock", "cspell.json"],
        "dictionaries": sorted(dictionaries),
        "allowCompoundWords": True,
    },
    sort_keys=False,
)
completed_process: subprocess.CompletedProcess = subprocess.run(
    ["prettier", "--parser=json"],
    stdout=subprocess.PIPE,
    stderr=sys.stderr,
    check=True,
    input=config,
    text=True,
)
config: str = completed_process.stdout
print(config, end="")
