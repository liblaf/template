all:

update: update-git update-pre-commit

update-git:
	git pull

update-pre-commit:
	pre-commit autoupdate --jobs $(shell nproc)
