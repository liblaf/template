all: update

update: update-git update-pre-commit

#####################
# Auxiliary Targets #
#####################

update-git:
	git checkout main
	git pull

update-pre-commit:
	pre-commit autoupdate --jobs=8
