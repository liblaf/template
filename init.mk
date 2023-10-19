TARGET_DIR != git rev-parse --show-toplevel

ifeq ($(TARGET_DIR),)
$(error Fatal: not a git repository (or any of the parent directories): .git)
endif

SOURCE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

TARGETS += $(TARGET_DIR)/.github/dependabot.yaml
TARGETS += $(TARGET_DIR)/.github/sync-repo-settings.yaml
TARGETS += $(TARGET_DIR)/.github/workflows/license.yaml
TARGETS += $(TARGET_DIR)/.pre-commit-config.yaml

all: common

common: github pre-commit $(TARGETS)

include $(SOURCE_DIR)/make/*.mk

#####################
# Auxiliary Targets #
#####################

URL  != git config --get remote.origin.url
USER != echo $(URL) | sed --regexp-extended --expression='s/.*github.com\/(.+)\/(.+)\.git/\1/'
REPO != echo $(URL) | sed --regexp-extended --expression='s/.*github.com\/(.+)\/(.+)\.git/\2/'

$(TARGET_DIR)/%: $(SOURCE_DIR)/%
	@ install -D --mode="u=rw,go=r" --no-target-directory --verbose $< $@

github:
ifeq ($(and $(USER),$(REPO)),)
	$(warning Unable to determine USER and REPO from git remote origin url: $(URL))
else
# https://docs.github.com/en/rest/actions/permissions#set-default-workflow-permissions-for-a-repository
	GH_PAGER="" gh api repos/$(USER)/$(REPO)/actions/permissions/workflow \
	  --field="default_workflow_permissions=read" \
	  --field="can_approve_pull_request_reviews=true" \
	  --method=PUT
endif

pre-commit: $(TARGET_DIR)/.pre-commit-config.yaml
	pre-commit install --install-hooks --hook-type="commit-msg" --hook-type="pre-commit"
