CODE_DIR                      ?= code
PY                            := uv run python
SRC_DIR                       := src
DATA_DIR                      := data
DATA_RAW_DIR                  := data/raw
DATA_PROCESSED_DIR            := data/processed
OUTPUT_DIR                    := output
FIGS_DIR                      := output/figures
TABLES_DIR                    := output/tables
SCRIPTS_DIR                   := scripts
NOTEBOOKS_DIR                 := notebooks
BRANCH                        := main
LATEX_DOCS_ASSIGNMENTS_DIR    := docs/assignments
LATEX_DOCS_LECTURE_NOTES_DIR  := docs
LATEX_DOCS_PRESENTATIONS_DIR  := docs/presentations

-include .env
export

DEPS := numpy scipy sympy pandas polars matplotlib seaborn \
        scikit-learn statsmodels linearmodels openpyxl jupyterlab
DEV_DEPS := ruff ty

.PHONY: help sync lint format typecheck run check jupyter clean create-code-project fetch-assignments fetch-lecture-notes fetch-presentation watch-docs sync-docs

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
	@echo "  jupyter                               Start JupyterLab"
	@echo "  clean                                 Remove generated output files"
	@echo "  create-code-project CODE_DIR=<name>   Scaffold a new Python sub-project"
	@echo "  fetch-assignments NAME=<name>         Fetch LaTeX assignment template"
	@echo "  fetch-lecture-notes                   Fetch LaTeX lecture notes template"
	@echo "  fetch-presentation NAME=<name>        Fetch LaTeX beamer presentation template"
	@echo "  sync-docs                             Sync PDFs from docs/ to Dropbox once"
	@echo "  watch-docs                            Watch docs/ and sync PDFs to Dropbox on change"

sync:
	cd $(CODE_DIR) && uv sync

lint:
	cd $(CODE_DIR) && uv run ruff check $(SRC_DIR)

format:
	cd $(CODE_DIR) && uv run ruff format $(SRC_DIR)

typecheck:
	cd $(CODE_DIR) && uv run ty check $(SRC_DIR)

run:
	cd $(CODE_DIR) && $(PY) $(SRC_DIR)/main.py

check:
	cd $(CODE_DIR) && uv run ruff check $(SRC_DIR)
	cd $(CODE_DIR) && uv run ruff format --check $(SRC_DIR)
	cd $(CODE_DIR) && uv run ty check $(SRC_DIR)

jupyter:
	cd $(CODE_DIR) && uv run jupyter lab

clean:
	find $(CODE_DIR)/$(OUTPUT_DIR) -type f ! -name '.gitkeep' -delete

# Usage: $(call fetch-latex-template,<repo-subdir>,<destination-path>)
define fetch-latex-template
@if [ -z "$(LATEX_TEMPLATE_REPO_URL)" ]; then \
	echo "Error: LATEX_TEMPLATE_REPO_URL is not set. Export it or define it in .env"; exit 1; \
fi
@if [ -d "$(2)" ]; then \
	echo "Error: $(2) already exists. Remove it first."; exit 1; \
fi
@mkdir -p "$(dir $(2))"
@TMP=$$(mktemp -d); \
	git clone --filter=blob:none --sparse --branch $(BRANCH) "$(LATEX_TEMPLATE_REPO_URL)" "$$TMP" && \
	git -C "$$TMP" sparse-checkout set $(1) && \
	mv "$$TMP/$(1)" "$(2)" && \
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
	         $(CODE_DIR)/$(SCRIPTS_DIR) \
			 $(CODE_DIR)/$(NOTEBOOKS_DIR)

	touch $(CODE_DIR)/$(SRC_DIR)/__init__.py \
	      $(CODE_DIR)/$(SRC_DIR)/main.py \
	      $(CODE_DIR)/$(SCRIPTS_DIR)/__init__.py \
	      $(CODE_DIR)/$(DATA_RAW_DIR)/.gitkeep \
	      $(CODE_DIR)/$(DATA_PROCESSED_DIR)/.gitkeep \
		  $(CODE_DIR)/$(NOTEBOOKS_DIR)/.gitkeep
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

sync-docs:
	@if [ -z "$(DROPBOX_DOCS_DIR)" ]; then \
		echo "Error: DROPBOX_DOCS_DIR is not set. Define it in .env"; exit 1; \
	fi
	@DEST=$$(echo "$(DROPBOX_DOCS_DIR)" | sed "s|^~|$$HOME|"); \
		mkdir -p "$$DEST" && \
		rsync -a --include='*/' --include='*.pdf' --exclude='*' --prune-empty-dirs docs/ "$$DEST/"

watch-docs:
	@if [ -z "$(DROPBOX_DOCS_DIR)" ]; then \
		echo "Error: DROPBOX_DOCS_DIR is not set. Define it in .env"; exit 1; \
	fi
	@which fswatch > /dev/null 2>&1 || { echo "Error: fswatch not installed. Run: brew install fswatch"; exit 1; }
	@echo "Watching docs/ for PDF changes..."
	@DEST=$$(echo "$(DROPBOX_DOCS_DIR)" | sed "s|^~|$$HOME|"); \
		mkdir -p "$$DEST" && \
		fswatch -o --include='\.pdf$$' --exclude='.*' -r docs/ | \
		xargs -n1 -I{} rsync -a --include='*/' --include='*.pdf' --exclude='*' --prune-empty-dirs docs/ "$$DEST/"

fetch-beamer-presentation:
ifndef NAME
	$(error NAME is required. Usage: make fetch-presentation NAME=<presentation-name>)
endif
	$(call fetch-latex-template,beamer_presentation,$(LATEX_DOCS_PRESENTATIONS_DIR)/$(NAME))
