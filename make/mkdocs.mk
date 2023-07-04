MKDOCS_LIST += $(ROOT)/.github/workflows/mkdocs.yaml
MKDOCS_LIST += $(ROOT)/docs/requirements.txt
MKDOCS_LIST += $(ROOT)/mkdocs.yaml

mkdocs: all $(MKDOCS_LIST)

#####################
# Auxiliary Targets #
#####################

$(ROOT)/mkdocs.yaml: $(TEMPLATE)/mkdocs.yaml
ifneq ($(REPO), )
	sed --expression="s/template/$(REPO)/g" $< > $@
else
  $(error REPO is not defined)
endif
