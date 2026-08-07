#!/usr/bin/env bash
set -euo pipefail

format=false
generated=false

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
    *)
      return 1
      ;;
  esac
}

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

  case "$changed_file" in
    Dockerfile_R | \
    Postgres-cds_hub/generate-sql.sh | \
    Postgres-cds_hub/R-initcdstoolchain/* | \
    Postgres-cds_hub/R-initcdstoolchain/** | \
    Postgres-cds_hub/sql/template/* | \
    Postgres-cds_hub/sql/template/** | \
    Postgres-cds_hub/sql/start.sql | \
    R-etlutils/* | \
    R-etlutils/** | \
    R-cds2db/cds2db/inst/extdata/Table_Description.xlsx | \
    R-cdstoolchain/pseudonym/* | \
    R-cdstoolchain/pseudonym/** | \
    R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx | \
    tools/check-generated-sql.sh | \
    tools/format-sql.sh | \
    tools/install-pgformatter.sh | \
    tools/detect-sql-checks.sh | \
    .github/workflows/sql-checks.yml)
      generated=true
      ;;
  esac

  case "$changed_file" in
    Postgres-cds_hub/sql/base/*.sql)
      if ! is_manual_base_sql "$changed_file"; then
        generated=true
      fi
      ;;
  esac
done

echo "format=${format}"
echo "generated=${generated}"
