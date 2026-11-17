#!/usr/bin/env bash
set -euo pipefail

is_manual_base_sql() {
  case "$1" in
    Postgres-cds_hub/sql/base/000_stop_semapore_during_run.sql | \
    Postgres-cds_hub/sql/base/020_db_config_tools.sql | \
    Postgres-cds_hub/sql/base/030_db_parameter.sql | \
    Postgres-cds_hub/sql/base/035_db_log_table_structure.sql | \
    Postgres-cds_hub/sql/base/950_cro_job.sql | \
    Postgres-cds_hub/sql/base/980_dev_and_test.sql | \
    Postgres-cds_hub/sql/base/999_start_semapore_after_run.sql)
      return 0
      ;;
    *) return 1 ;;
  esac
}

# Keep all package inputs except directories used only for tests/documentation.
# Unknown package files stay relevant, including metadata and installed resources.
is_generator_package_input() {
  case "$1" in
    tests/* | man/* | vignettes/* | docs/* | README* | NEWS* | *.Rproj)
      return 1
      ;;
    *) return 0 ;;
  esac
}

is_generated_sql_input() {
  case "$1" in
    R-etlutils/etlutils/*)
      is_generator_package_input "${1#R-etlutils/etlutils/}"; return $? ;;
    R-cds2db/cds2db/*)
      is_generator_package_input "${1#R-cds2db/cds2db/}"; return $? ;;
    R-cdstoolchain/pseudonym/*)
      is_generator_package_input "${1#R-cdstoolchain/pseudonym/}"; return $? ;;
    Postgres-cds_hub/R-initcdstoolchain/initcdstoolchain/*)
      is_generator_package_input "${1#Postgres-cds_hub/R-initcdstoolchain/initcdstoolchain/}"; return $? ;;
    Postgres-cds_hub/sql/base/*.sql)
      ! is_manual_base_sql "$1"; return $? ;;
    Dockerfile_R | .dockerignore | Dockerfile_R.dockerignore | .Rprofile | \
    tools/styler-style.R | \
    Postgres-cds_hub/generate-sql.sh | \
    Postgres-cds_hub/R-initcdstoolchain/*.R | \
    Postgres-cds_hub/sql/template/* | \
    Postgres-cds_hub/sql/start.sql | \
    R-dataprocessor/dataprocessor/inst/extdata/Dataprocessor_Table_Description.xlsx | \
    R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx | \
    R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx | \
    tools/check-generated-sql.sh | \
    tools/check-table-description-consistency.R | \
    tools/test-check-table-description-consistency.R | \
    tools/format-sql.sh | \
    tools/install-pgformatter.sh | \
    tools/detect-sql-checks.sh | \
    tools/generated-sql-cache-key.sh | \
    .github/workflows/sql-checks.yml)
      return 0
      ;;
    *) return 1 ;;
  esac
}

# The cache-key script sources the same classifier without running the detector.
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  return 0
fi

format=false
generated=false
while IFS= read -r changed_file; do
  [ -n "$changed_file" ] || continue
  case "$changed_file" in
    Postgres-cds_hub/sql/init/*.sql | \
    Postgres-cds_hub/sql/recalculations/*.sql | \
    tools/format-sql.sh | \
    tools/check-sql-format.sh | \
    tools/detect-sql-checks.sh | \
    .github/workflows/sql-checks.yml)
      format=true
      ;;
  esac
  if is_manual_base_sql "$changed_file"; then
    format=true
  fi
  if is_generated_sql_input "$changed_file"; then
    generated=true
  fi
done

echo "format=${format}"
echo "generated=${generated}"
