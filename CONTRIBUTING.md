# Contributing

These guidelines are for maintainers and contributors working on this
repository's code.

## Contributing

Bugs, questions, and change requests can be filed as GitHub issues. Larger
changes should be discussed in an issue or discussion before implementation so
that the goal, scope, and expected behavior are clear.

Code changes are submitted through pull requests. A pull request should describe
the purpose of the change, link relevant issues, and list the checks that were
run. Keep pull requests focused where possible and avoid unrelated refactorings
in the same PR.

## Development

Before committing, run the relevant tests or checks locally. The appropriate
checks depend on the module that was changed.

### Formatting R Code

Before each commit that touches R code, format the affected R code with the
repository formatter:

```sh
Rscript tools/style-changed.R
```

Use `Rscript tools/style-full.R` when you intentionally want to re-run the
formatter across the complete configured R scope.
`tools/style-changed.R` includes R files changed against `origin/develop` and
R files currently changed in the working tree or index.

`tools/style-full.R` can be started from the repository root or from a
subdirectory. It temporarily switches to the repository root and restores the
previous working directory afterwards.

For faster RStudio workflows, use `tools/style-current-file.R` for the active
saved editor file or `tools/style-current-package.R` for the active package
project. Both wrappers use the same formatter functions as the full repository
run and restore the previous working directory afterwards.

The formatter uses:

- `.editorconfig` for editor and whitespace rules
- `tools/styler-style.R` for the `styler` style definition
- `tools/style.R` for the shared formatter implementation
- `tools/style-changed.R` for formatting changed R files only
- `tools/style-full.R` for formatting the complete configured R scope
- `tools/style-current-file.R` and `tools/style-current-package.R` for smaller
  RStudio-triggered formatting runs

The formatting covers the repository's R project areas, including the R code
under `Postgres-cds_hub/R-initcdstoolchain`.

### Setting Up RStudio

After checking out or updating the repository, make sure `styler` is installed
locally:

```r
install.packages("styler")
```

Then open the RStudio project from the repository root and restart the R session
so that `.Rprofile` is loaded. The RStudio addins provided by `styler` will then
use the style definition configured in this repository. A dedicated keyboard
shortcut for the styler addin, for example for the active file, is recommended.

Saving normally in RStudio does not replace the formatting run. Before committing,
`Rscript tools/style-changed.R` remains the expected local formatting run.

### Checking Style Locally

The same style check intended for CI can be run locally with:

```sh
Rscript tools/check-style.R
```

The check formats with `tools/style.R` and fails if a Git diff remains
afterwards. If the check fails, review and commit the generated formatting
changes.
