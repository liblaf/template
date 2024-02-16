import collections
import json
import re
import subprocess
import sys
from collections.abc import MutableMapping, MutableSequence, MutableSet, Set

process: subprocess.CompletedProcess[str] = subprocess.run(
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
stdout: str = process.stdout
words: Set[str] = set(word.lower() for word in stdout.splitlines())
process = subprocess.run(
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
stdout: str = process.stdout
PATTERN: re.Pattern[str] = re.compile(r"(?P<word>.*): (?P<not>Not )?Found")
words_to_dictionaries: MutableMapping[
    str, MutableSequence[str]
] = collections.defaultdict(list)
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
dictionaries: MutableSet[str] = set()
for word, dicts in words_to_dictionaries.items():
    if word not in words:
        continue
    if any(dictionary.endswith("*") for dictionary in dicts):
        pass
    else:
        dictionaries.add(dicts[0])
words_not_found: Set[str] = words - words_to_dictionaries.keys()
config: str = json.dumps(
    {
        "words": sorted(words_not_found),
        "ignorePaths": ["*-lock.*", "*.lock", "cspell.json"],
        "dictionaries": sorted(dictionaries),
        "allowCompoundWords": True,
    },
    ensure_ascii=False,
    sort_keys=False,
)
process = subprocess.run(
    ["prettier", "--parser=json"],
    stdout=subprocess.PIPE,
    stderr=sys.stderr,
    check=True,
    input=config,
    text=True,
)
config: str = process.stdout
print(config, end="")
