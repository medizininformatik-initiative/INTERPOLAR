# INTERPOLAR Agent Instructions

## Project Context

INTERPOLAR is a CDS tool chain for processing MII KDS FHIR resources. The
repository combines R packages, Docker-based runtime components, database setup
files, REDCap integration, and operational scripts.

Important project areas:

- `R-cds2db/cds2db`: R package for extracting FHIR data into the CDS_HUB
  PostgreSQL database.
- `R-dataprocessor/dataprocessor`: R package for processing CDS_HUB data.
- `R-db2frontend/db2frontend`: R package for synchronizing CDS_HUB and the
  frontend.
- `R-cdstoolchain/cdstoolchain`: R package and scripts for orchestrating the
  tool chain.
- `R-etlutils/etlutils`: shared R utilities used by the other R modules.
- `Postgres-cds_hub`: PostgreSQL configuration and initialization files.
- `REDCap-app` and `REDCap-db`: frontend application and database components.

Prefer repository inspection over assumptions. Check existing implementations,
tests, configuration examples, and module-level documentation before changing
behavior.

## Change Discipline

- Keep diffs minimal and focused on the requested behavior.
- Preserve existing APIs unless the task explicitly requires an API change.
- Preserve local naming and style conventions in the file being edited.
- Do not rewrite unrelated code while making targeted changes.
- Do not edit files that may contain local secrets, site-specific settings, or
  generated data unless the task explicitly asks for it. This includes `.env*`,
  generated output folders, database snapshots, and local data files.
- Treat `*_config.toml` files as potentially local or environment-specific.
  Prefer documented example files such as `*_config_example.toml` when adding
  reusable configuration guidance.

## R Development

- This repository contains multiple R packages below `R-*/<package>`.
- For new reusable R functions, use camelCase names.
- For new local variables, use snake_case names.
- Use explicit package qualifiers in new code where practical, for example
  `data.table::setnames()` or `stringr::str_extract()`.
- Do not add `library()` or `require()` calls inside package code unless the
  surrounding code already uses that pattern and the change needs to preserve it.
- Prefer modern, non-deprecated R APIs.
- For tabular transformations, inspect the surrounding code before choosing
  `data.table`, `data.frame`, or another representation.
- Update roxygen2 documentation when exported signatures or user-visible
  behavior change.
- Add or update focused tests when behavior changes.

## Documentation

- Use roxygen2 for package-level function documentation.
- Keep roxygen2 lines wrapped to a maximum of 100 characters.
- Do not add `@import` or `@importFrom` tags unless explicitly requested.
- If examples cannot run independently, use commented setup or `\dontrun{}`
  only when needed.

## Testing And Verification

- Use focused package tests for R-package changes. Typical package test entry
  points are:
  - `R-cds2db/cds2db/tests/testthat.R`
  - `R-dataprocessor/dataprocessor/tests/testthat.R`
  - `R-cdstoolchain/cdstoolchain/tests/testthat.R`
  - `R-etlutils/etlutils/tests/testthat.R`
- When changing Docker or end-to-end runtime behavior, inspect `README.md`,
  `Install.md`, `Operation.md`, and `docker-compose.yml` for the appropriate
  verification command before running broad checks.
- Report which checks were run. If a check could not be run, report why.

## Repository Metadata

- Keep personal agent preferences out of version control. Local-only notes can
  live under `.agents/`, which is ignored by Git.
