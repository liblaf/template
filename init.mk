SOURCE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
TARGET_DIR != git rev-parse --show-toplevel

ifndef TARGET_DIR
$(error fatal: not a git repository (or any of the parent directories): .git)
endif

TARGET_LIST += $(TARGET_DIR)/.github/dependabot.yaml
TARGET_LIST += $(TARGET_DIR)/.github/workflows/check.yaml
TARGET_LIST += $(TARGET_DIR)/.github/workflows/merge.yaml
TARGET_LIST += $(TARGET_DIR)/.github/workflows/template.yaml
TARGET_LIST += $(TARGET_DIR)/.pre-commit-config.yaml

all: common

common: $(TARGET_LIST) github pre-commit

###############
# Auxiliaries #
###############

REPO != gh repo view --jq=".name" --json=name
USER != gh repo view --jq=".owner.login" --json=owner

$(TARGET_DIR)/%: $(SOURCE_DIR)/%
	@- install -D --mode="u=rw,go=r" --no-target-directory --verbose $< $@

github:
ifeq ($(and $(USER),$(REPO)), )
	$(error fatal: not a github repository (or any of the parent directories))
else
	- bash $(SOURCE_DIR)/scripts/gh-init.sh $(USER) $(REPO)
endif

pre-commit: $(TARGET_DIR)/.pre-commit-config.yaml
	- pre-commit install --install-hooks --hook-type=commit-msg --hook-type=pre-commit
