# Course Project Template

A structured template for organizing course-related work, combining a Python data analysis environment with LaTeX document management.

## Directory Structure

```
course-project-template/
├── code/                   # Python project (managed with uv)
│   ├── src/                # Source code
│   │   └── main.py
│   ├── data/
│   │   ├── raw/            # Original, unmodified data
│   │   └── processed/      # Cleaned/transformed data
│   ├── output/
│   │   ├── figures/        # Generated plots
│   │   └── tables/         # Generated tables
│   ├── scripts/            # Utility/automation scripts
│   └── pyproject.toml
├── docs/                   # LaTeX documents (assignments, lecture notes)
├── exams/                  # Exam materials
├── papers/                 # Reference papers
└── problem-sets/           # Problem set files
```

## Prerequisites

- [uv](https://docs.astral.sh/uv/) — Python package and project manager
- `make` — task runner
- `curl` — for fetching LaTeX templates

## Setup

Install Python dependencies:

```bash
make sync
```

## Usage

### Python Development

| Command          | Description                         |
| ---------------- | ----------------------------------- |
| `make run`       | Run `src/main.py`                   |
| `make lint`      | Lint with ruff                      |
| `make format`    | Format with ruff                    |
| `make typecheck` | Type-check with ty                  |
| `make check`     | Lint + format check + typecheck (no files modified) |
| `make jupyter`   | Start JupyterLab                    |
| `make clean`     | Remove generated output files       |

### Creating a New Code Sub-project

Scaffold a self-contained uv Python project inside a new directory:

```bash
make create-code-project CODE_DIR=<directory-name>
```

This runs `uv init --bare` then `uv add` for all dependencies. To change the default package set, edit the `DEPS` and `DEV_DEPS` variables at the top of the Makefile.

### LaTeX Templates

Fetch assignment templates from the [latex_templates](https://github.com/utkucm/latex_templates) repository:

```bash
make fetch-assignments NAME=<assignment-name>
# → places template in docs/assignments/<assignment-name>/
```

Fetch lecture notes template:

```bash
make fetch-lecture-notes
# → places template in docs/lecture_notes/
```

## Python Dependencies

Core packages in `code/pyproject.toml`:

- **Data**: `pandas`, `polars`, `numpy`, `scipy`, `sympy`, `openpyxl`
- **Modeling**: `statsmodels`, `linearmodels`, `scikit-learn`
- **Visualization**: `matplotlib`, `seaborn`
- **Notebooks**: `jupyterlab`
- **Dev**: `ruff` (linting/formatting), `ty` (type checking)

The default list is defined by `DEPS` and `DEV_DEPS` at the top of the [Makefile](Makefile).

Requires Python 3.13+.

## License

MIT
