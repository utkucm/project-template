# Course Project Template

A structured template for organizing course-related work, combining a Python data analysis environment with LaTeX document management.

## Directory Structure

```
course-project-template/
├── <code-dir>/             # Python project created with make create-code-project
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
├── admin/                  # Administrative files (syllabi, course info)
├── docs/                   # LaTeX documents (assignments, lecture notes)
├── exams/                  # Exam materials
├── papers/                 # Reference papers
└── problem-sets/           # Problem set files
```

## Prerequisites

- [uv](https://docs.astral.sh/uv/) — Python package and project manager
- `make` — task runner
- `curl` — for fetching LaTeX templates

## Usage

### Creating a Code Project

Scaffold a uv Python project inside a new directory:

```bash
make create-code-project CODE_DIR=<name>
```

This runs `uv init --bare` then installs all default dependencies. To change the default package set, edit the `DEPS` and `DEV_DEPS` variables at the top of the [Makefile](Makefile).

### Python Development

All dev targets accept an optional `CODE_DIR` argument (defaults to `code`):

```bash
make sync                        # install dependencies
make sync CODE_DIR=myproject     # explicit directory
```

| Command          | Description                                         |
| ---------------- | --------------------------------------------------- |
| `make sync`      | Install dependencies                                |
| `make run`       | Run `src/main.py`                                   |
| `make lint`      | Lint with ruff                                      |
| `make format`    | Format with ruff                                    |
| `make typecheck` | Type-check with ty                                  |
| `make check`     | Lint + format check + typecheck (no files modified) |
| `make jupyter`   | Start JupyterLab                                    |
| `make clean`     | Remove generated output files                       |

### LaTeX Templates

Fetch assignment templates from the [latex_templates](https://github.com/utkucm/latex_templates) repository:

```bash
make fetch-assignments NAME=<assignment-name>
# → docs/assignments/<assignment-name>/
```

Fetch lecture notes template:

```bash
make fetch-lecture-notes
# → docs/lecture_notes/
```

Fetch beamer presentation template:

```bash
make fetch-beamer-presentation NAME=<presentation-name>
# → docs/presentations/<presentation-name>/
```

Fetch paper template:

```bash
make fetch-paper
# → docs/paper/
```

## Python Dependencies

Default packages installed by `create-code-project`:

- **Data**: `pandas`, `polars`, `numpy`, `scipy`, `sympy`, `openpyxl`
- **Modeling**: `statsmodels`, `linearmodels`, `scikit-learn`
- **Visualization**: `matplotlib`, `seaborn`
- **Notebooks**: `jupyterlab`
- **Dev**: `ruff` (linting/formatting), `ty` (type checking)

Requires Python 3.13+.

## License

MIT
