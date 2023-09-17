TOP_LEVEL != git rev-parse --show-toplevel

ifeq ($(TOP_LEVEL),)
$(error Fatal: not a git repository (or any of the parent directories): .git)
endif

TEMPLATE := $(TOP_LEVEL)/template

TARGETS += $(TOP_LEVEL)/.github/dependabot.yaml
TARGETS += $(TOP_LEVEL)/.github/sync-repo-settings.yaml
TARGETS += $(TOP_LEVEL)/.github/workflows/license.yaml
TARGETS += $(TOP_LEVEL)/.pre-commit-config.yaml

URL  != git config --get remote.origin.url
USER != echo $(URL) | sed --regexp-extended --expression='s/.*github.com\/(.+)\/(.+)\.git/\1/'
REPO != echo $(URL) | sed --regexp-extended --expression='s/.*github.com\/(.+)\/(.+)\.git/\2/'

all: common

common: github pre-commit $(TARGETS)

include $(TEMPLATE)/make/*.mk

#####################
# Auxiliary Targets #
#####################

github:
ifneq ($(and $(USER), $(REPO)), )
# https://docs.github.com/en/rest/actions/permissions#set-default-workflow-permissions-for-a-repository
	gh api repos/$(USER)/$(REPO)/actions/permissions/workflow \
	  --field default_workflow_permissions=read \
	  --field can_approve_pull_request_reviews=true \
	  --method=PUT
else
	$(warning Unable to determine USER and REPO from git remote origin url: $(URL))
endif

pre-commit: $(TOP_LEVEL)/.pre-commit-config.yaml
	pre-commit install --install-hooks

$(TEMPLATE):
	git submodule add https://github.com/liblaf/template.git $@

$(TOP_LEVEL)/%: $(TEMPLATE)/%
	@ install -D --mode="u=rw,go=r" --no-target-directory --verbose $< $@

$(TEMPLATE)/%: | $(TEMPLATE)
