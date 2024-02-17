NAME := template

default: fmt mypy ruff stub

build: scripts/poetry-build.sh
	bash "$<"

fmt: fmt-pre-commit-config.yaml fmt-pre-commit-hooks.yaml fmt-pyproject.toml

mypy:
	mypy --strict --package "$(NAME)"

ruff:
	ruff format
	ruff check --fix --unsafe-fixes

setup:
	micromamba create --yes --name "$(NAME)" python poetry
	micromamba run --name "$(NAME)" poetry install
	micromamba run --name "$(NAME)" mypy --install-types --non-interactive

stub:
	stubgen --include-docstrings --output "." --package "$(NAME)"
	$(MAKE) ruff
	stubtest "$(NAME)"

update:
	template pre-commit update

###############
# Auxiliaries #
###############

fmt-pre-commit-config.yaml: .pre-commit-config.yaml
	template sort pre-commit-config "$<"

fmt-pre-commit-hooks.yaml: .pre-commit-hooks.yaml
	template sort pre-commit-hooks "$<"

fmt-pyproject.toml: pyproject.toml
	toml-sort --in-place --all "$<"
	taplo format --option reorder_keys=true reorder_arrays=true "$<"
