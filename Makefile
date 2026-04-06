PY                         := uv run python
SRC_DIR                    := src
DATA_DIR                   := data
DATA_RAW_DIR               := data/raw
DATA_PROCESSED_DIR         := data/processed
OUTPUT_DIR                 := output
FIGS_DIR                   := output/figures
TABLES_DIR                 := output/tables
SCRIPTS_DIR                := scripts

LATEX_TEMPLATE_REPO_URL    := https://github.com/utkucm/latex_templates
BRANCH                     := main
LATEX_DOCS_ASSIGNMENTS_DIR := docs/assignments
LATEX_DOCS_LECTURE_NOTES_DIR := docs

DEPS := numpy scipy sympy pandas polars matplotlib seaborn \
        scikit-learn statsmodels linearmodels openpyxl jupyterlab
DEV_DEPS := ruff ty

.PHONY: help sync lint format typecheck run check create-code-project fetch-assignments fetch-lecture-notes

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  sync                                  Install dependencies"
	@echo "  lint                                  Run ruff linter"
	@echo "  format                                Run ruff formatter"
	@echo "  typecheck                             Run ty type checker"
	@echo "  check                                 Run lint + format check + typecheck"
	@echo "  run                                   Run src/main.py"
	@echo "  create-code-project CODE_DIR=<name>   Scaffold a new Python sub-project"
	@echo "  fetch-assignments NAME=<name>         Fetch LaTeX assignment template"
	@echo "  fetch-lecture-notes                   Fetch LaTeX lecture notes template"

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

check: lint format typecheck

# Usage: $(call fetch-latex-template,<repo-subdir>,<destination-path>)
define fetch-latex-template
@if [ -d "$(2)" ]; then \
	echo "Error: $(2) already exists. Remove it first."; exit 1; \
fi
@mkdir -p "$(dir $(2))"
@TMP=$$(mktemp -d); \
	curl --fail --silent --show-error -L \
		"$(LATEX_TEMPLATE_REPO_URL)/archive/refs/heads/$(BRANCH).tar.gz" \
		| tar -xz --strip-components=1 -C "$$TMP" && \
	mv "$$TMP/$(1)" "$(2)"; \
	rm -rf "$$TMP"
endef

create-code-project:
ifndef CODE_DIR
	$(error CODE_DIR is required. Usage: make create-code-project CODE_DIR=<name>)
endif
	@if [ -d "$(CODE_DIR)" ]; then \
		echo "Error: $(CODE_DIR) already exists."; exit 1; \
	fi
	mkdir -p $(CODE_DIR)/$(SRC_DIR) \
	         $(CODE_DIR)/$(DATA_RAW_DIR) \
	         $(CODE_DIR)/$(DATA_PROCESSED_DIR) \
	         $(CODE_DIR)/$(FIGS_DIR) \
	         $(CODE_DIR)/$(TABLES_DIR) \
	         $(CODE_DIR)/$(SCRIPTS_DIR)
	touch $(CODE_DIR)/$(SRC_DIR)/__init__.py \
	      $(CODE_DIR)/$(SRC_DIR)/main.py \
	      $(CODE_DIR)/$(SCRIPTS_DIR)/__init__.py \
	      $(CODE_DIR)/$(DATA_RAW_DIR)/.gitkeep \
	      $(CODE_DIR)/$(DATA_PROCESSED_DIR)/.gitkeep
	cd $(CODE_DIR) && uv init --bare .
	cd $(CODE_DIR) && uv add $(DEPS)
	cd $(CODE_DIR) && uv add --dev $(DEV_DEPS)

fetch-assignments:
ifndef NAME
	$(error NAME is required. Usage: make fetch-assignments NAME=<assignment-name>)
endif
	$(call fetch-latex-template,assignments,$(LATEX_DOCS_ASSIGNMENTS_DIR)/$(NAME))

fetch-lecture-notes:
	$(call fetch-latex-template,lecture_notes,$(LATEX_DOCS_LECTURE_NOTES_DIR)/lecture_notes)
