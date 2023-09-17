MKDOCS_LIST += $(TOP_LEVEL)/.github/workflows/mkdocs.yaml
MKDOCS_LIST += $(TOP_LEVEL)/docs/requirements.txt
MKDOCS_LIST += $(TOP_LEVEL)/mkdocs.yaml

mkdocs: common $(MKDOCS_LIST)

#####################
# Auxiliary Targets #
#####################

$(TOP_LEVEL)/mkdocs.yaml: $(TEMPLATE)/mkdocs.yaml
ifneq ($(REPO), )
	sed --expression="s/template/$(REPO)/g" $< > $@
else
	$(error REPO is not defined)
endif
