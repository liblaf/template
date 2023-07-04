all:

update: update-git update-pre-commit

#####################
# Auxiliary Targets #
#####################

update-git:
	git pull

update-pre-commit:
	pre-commit autoupdate --jobs=$(shell nproc)
