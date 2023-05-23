ROOT != git rev-parse --show-toplevel

ifeq ($(ROOT), )
$(error fatal: not a git repository (or any of the parent directories): .git)
endif

TEMPLATE := $(ROOT)/template

TARGETS += $(ROOT)/.github/dependabot.yaml
TARGETS += $(ROOT)/.github/sync-repo-settings.yaml
TARGETS += $(ROOT)/.github/workflows/license.yaml
TARGETS += $(ROOT)/.pre-commit-config.yaml

URL  != git config --get remote.origin.url
USER != echo $(URL) | sed --regexp-extended --expression='s/.*github.com\/(.+)\/(.+)\.git/\1/'
REPO != echo $(URL) | sed --regexp-extended --expression='s/.*github.com\/(.+)\/(.+)\.git/\2/'

all: github pre-commit $(TARGETS)

include $(TEMPLATE)/make/*.mk

github:
ifneq ($(and $(USER), $(REPO)), )
	# https://docs.github.com/en/rest/actions/permissions#set-default-workflow-permissions-for-a-repository
	gh api repos/$(USER)/$(REPO)/actions/permissions/workflow --field default_workflow_permissions=read --field can_approve_pull_request_reviews=true --method PUT
else
$(warning Unable to determine USER and REPO from git remote origin url: $(URL))
endif

pre-commit:
	pre-commit install --install-hooks

$(TEMPLATE):
	git submodule add https://github.com/liblaf/template.git $@

$(ROOT)/%: $(TEMPLATE)/%
	install -D --mode="u=rw,go=r" --no-target-directory --verbose $< $@

$(TEMPLATE)/%: | $(TEMPLATE)
