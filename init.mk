GIT_ROOT     != git rev-parse --show-toplevel
OWNER        != git remote get-url origin | sed --regexp-extended 's|\.git$$||;s|.*github.com/([^/]+)/([^/]+)|\1|'
REPO         != git remote get-url origin | sed --regexp-extended 's|\.git$$||;s|.*github.com/([^/]+)/([^/]+)|\2|'
TEMPLATE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifndef GIT_ROOT
$(error GIT_ROOT not set)
endif

default: common github pre-commit

common:

github: $(TEMPLATE_DIR)/scripts/gh-init.sh
	bash "$<" "$(OWNER)" "$(REPO)"

pre-commit: $(GIT_ROOT)/.pre-commit-config.yaml
	pre-commit install --install-hooks

###############
# Auxiliaries #
###############

define sync
common: $(GIT_ROOT)/$(1)

$(GIT_ROOT)/$(1): $(TEMPLATE_DIR)/$(1)
	@ install -D --mode="u=rw,go=r" --no-target-directory --verbose "$$<" "$$@"
endef

$(eval $(call sync,.github/auto-label.yaml))
$(eval $(call sync,.github/blunderbuss.yml))
$(eval $(call sync,.github/dependabot.yaml))
$(eval $(call sync,.github/workflows/merge.yaml))
$(eval $(call sync,.github/workflows/pre-commit.yaml))
$(eval $(call sync,.github/workflows/template.yaml))
$(eval $(call sync,.pre-commit-config.yaml))
