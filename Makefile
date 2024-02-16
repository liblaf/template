default: fmt

build: scripts/poetry-build.sh
	bash "$<"

fmt: fmt-pre-commit-config.yaml fmt-pre-commit-hooks.yaml fmt-pyproject.toml

setup:
	micromamba create --yes --name "template" python poetry
	micromamba run --name "template" poetry install

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
