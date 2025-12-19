PY                                  := uv run python
MATLAB                              := matlab -batch
SRC_DIR                             := src
DATA_DIR                            := data
DATA_RAW_DIR                        := data/raw
DATA_PROCESSED_DIR                  := data/processed
OUTPUT_DIR                          := output
FIGS_DIR                            := output/figures
TABLES_DIR                          := output/tables
SCRIPTS_DIR                         := scripts

LATEX_TEMPLATE_REPOSITORY_URL       := https://github.com/utkucm/latex_templates
BRANCH     						    := main
LATEX_ASSIGNMENT_REPO_DIR 	        := assignments
LATEX_DOCS_ASSIGNMENTS_DIR   		:= docs/assignments
TMP_ZIP   		    				:= repo.zip
TMP_DIR   					        := repo-tmp

.PHONY: help sync set-name set-description fetch-assignments

help:
	@echo "Targets: sync | data | estimate | figs | paper | all | clean"

sync:
	uv sync

set-name:
	perl -0777 -i -pe 's/^(\[project\][\s\S]*?^name\s*=\s*)".*?"/$$1"$(NEW_NAME)"/m' pyproject.toml

set-description:
	perl -0777 -i -pe 's/^(\[project\][\s\S]*?^description\s*=\s*)".*?"/$$1"$(NEW_DESCRIPTION)"/m' pyproject.toml

fetch-assignments:
	mkdir -p docs
	rm -rf $(DEST_DIR)
	curl -L $(LATEX_TEMPLATE_REPOSITORY_URL)/archive/refs/heads/$(BRANCH).zip -o $(TMP_ZIP)
	unzip -q $(TMP_ZIP) -d $(TMP_DIR)
	mv $(TMP_DIR)/*/$(LATEX_TEMPLATE_ASSIGNMENT_DIR) $(DEST_DIR)
	rm -rf $(TMP_DIR) $(TMP_ZIP)