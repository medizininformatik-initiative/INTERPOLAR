#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

generated_sql_dir="${tmp_dir}/sql"

INTERPOLAR_DB_SQL_TARGET_DIR="$generated_sql_dir" \
INTERPOLAR_GENERATOR_R_LIB_DIR="${tmp_dir}/r-lib" \
  bash "${repo_root}/Postgres-cds_hub/generate-sql.sh"

compare_file() {
  local relative_path="$1"

  diff -u \
    <(normalize_generated_sql "${repo_root}/Postgres-cds_hub/sql/${relative_path}") \
    <(normalize_generated_sql "${generated_sql_dir}/${relative_path}")
}

normalize_generated_sql() {
  sed \
    -e '/^-- Create time:/d' \
    -e '/^-- Rights definition file last update :/d' \
    -e '/^-- Rights definition file size        :/d' \
    "$1"
}

compare_file "start.sql"

while IFS= read -r -d '' generated_file; do
  relative_path="${generated_file#${generated_sql_dir}/}"
  compare_file "$relative_path"
done < <(
  find "${generated_sql_dir}/base" -type f -name '*.sql' -print0 |
    while IFS= read -r -d '' sql_file; do
      if head -n 5 "$sql_file" | grep -q "This file is generated"; then
        printf '%s\0' "$sql_file"
      fi
    done |
    sort -z
)

while IFS= read -r -d '' committed_file; do
  relative_path="${committed_file#${repo_root}/Postgres-cds_hub/sql/}"
  if [ ! -f "${generated_sql_dir}/${relative_path}" ]; then
    echo "Committed generated SQL has no generated counterpart: ${relative_path}" >&2
    exit 1
  fi
done < <(
  find "${repo_root}/Postgres-cds_hub/sql/base" -type f -name '*.sql' -print0 |
    while IFS= read -r -d '' sql_file; do
      if head -n 5 "$sql_file" | grep -q "This file is generated"; then
        printf '%s\0' "$sql_file"
      fi
    done |
    sort -z
)
