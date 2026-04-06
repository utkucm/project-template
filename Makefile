PY                            := uv run python
SRC_DIR                       := src
DATA_DIR                      := data
DATA_RAW_DIR                  := data/raw
DATA_PROCESSED_DIR            := data/processed
OUTPUT_DIR                    := output
FIGS_DIR                      := output/figures
TABLES_DIR                    := output/tables
SCRIPTS_DIR                   := scripts

LATEX_TEMPLATE_REPOSITORY_URL := https://github.com/utkucm/latex_templates
BRANCH                        := main
LATEX_ASSIGNMENT_REPO_DIR     := assignments
LATEX_LECTURE_NOTES_REPO_DIR  := lecture_notes
LATEX_DOCS_ASSIGNMENTS_DIR    := docs/assignments
LATEX_DOCS_LECTURE_NOTES_DIR  := docs/
TMP_ZIP                       := repo.zip
TMP_DIR                       := repo-tmp

.PHONY: help sync lint format typecheck run fetch-assignments pre-commit-install clean

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  sync              Install dependencies"
	@echo "  lint              Run ruff linter"
	@echo "  format            Run ruff formatter"
	@echo "  typecheck         Run ty type checker"
	@echo "  run               Run src/main.py"
	@echo "  check             Run lint + format check + typecheck"
	@echo "  pre-commit-install  Install pre-commit hooks"
	@echo "  fetch-assignments NAME=<name>  Fetch LaTeX assignment templates into docs/assignments/<name>"
	@echo "  clean             Remove output files"

sync:
	cd code && uv sync

lint:
	cd code && uv run ruff check $(SRC_DIR)

format:
	cd code && uv run ruff format $(SRC_DIR)

typecheck:
	cd code && uv run ty check $(SRC_DIR)

run:
	cd code && $(PY) $(SRC_DIR)/main.py

test:
	@echo CODE_DIR=$(CODE_DIR)

create-code-project:
ifndef CODE_DIR
	$(error CODE_DIR is required. Usage: make create-code-project CODE_DIR=<code-directory-name>)
endif
	mkdir -p $(CODE_DIR)
	cd $(CODE_DIR) && uv init --bare .
	mkdir -p $(CODE_DIR)/$(SRC_DIR) $(CODE_DIR)/$(DATA_DIR) $(CODE_DIR)/$(DATA_DIR)/raw $(CODE_DIR)/$(DATA_DIR)/processed $(CODE_DIR)/$(OUTPUT_DIR) $(CODE_DIR)/$(OUTPUT_DIR)/figures $(CODE_DIR)/$(TABLES_DIR) $(CODE_DIR)/$(SCRIPTS_DIR)
	touch $(CODE_DIR)/$(SRC_DIR)/__init__.py $(CODE_DIR)/$(SRC_DIR)/main.py $(CODE_DIR)/$(SCRIPTS_DIR)/__init__.py
	touch $(CODE_DIR)/$(DATA_DIR)/.gitkeep $(CODE_DIR)/$(DATA_DIR)/raw/.gitkeep $(CODE_DIR)/$(DATA_DIR)/processed/.gitkeep
	cd $(CODE_DIR) && uv add --dev ruff ty
	cd $(CODE_DIR) && uv add numpy scipy sympy pandas polars matplotlib seaborn scikit-learn statsmodels jupyterlab

fetch-assignments:
ifndef NAME
	$(error NAME is required. Usage: make fetch-assignments NAME=<assignment-name>)
endif
	mkdir -p $(LATEX_DOCS_ASSIGNMENTS_DIR)
	curl -L $(LATEX_TEMPLATE_REPOSITORY_URL)/archive/refs/heads/$(BRANCH).zip -o $(TMP_ZIP)
	unzip -q $(TMP_ZIP) -d $(TMP_DIR)
	mv $(TMP_DIR)/*/$(LATEX_ASSIGNMENT_REPO_DIR) $(LATEX_DOCS_ASSIGNMENTS_DIR)/$(NAME)
	rm -rf $(TMP_DIR) $(TMP_ZIP)

fetch-lecture-notes:
	mkdir -p $(LATEX_DOCS_LECTURE_NOTES_DIR)
	curl -L $(LATEX_TEMPLATE_REPOSITORY_URL)/archive/refs/heads/$(BRANCH).zip -o $(TMP_ZIP)
	unzip -q $(TMP_ZIP) -d $(TMP_DIR)
	mv $(TMP_DIR)/*/$(LATEX_LECTURE_NOTES_REPO_DIR) $(LATEX_DOCS_LECTURE_NOTES_DIR)
	rm -rf $(TMP_DIR) $(TMP_ZIP)