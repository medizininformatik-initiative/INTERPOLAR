#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${INTERPOLAR_PROJECT_ROOT:-$(cd "${script_dir}/.." && pwd)}"
source_sql_dir="${INTERPOLAR_DB_SQL_SOURCE_DIR:-${repo_root}/Postgres-cds_hub/sql}"
target_sql_dir="${INTERPOLAR_DB_SQL_TARGET_DIR:-${repo_root}/Postgres-cds_hub/generated/sql}"
tmp_sql_dir="${target_sql_dir}.tmp"
r_lib_dir="${INTERPOLAR_GENERATOR_R_LIB_DIR:-${repo_root}/Postgres-cds_hub/generated/r-lib}"
skip_generator_install="${INTERPOLAR_GENERATOR_SKIP_INSTALL:-false}"

copy_sql_dir_if_exists() {
  local source_dir="$1"
  local target_dir="$2"

  if [ -d "$source_dir" ]; then
    mkdir -p "$target_dir"
    cp -R "${source_dir}/." "$target_dir/"
  fi
}

copy_manual_base_sql() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"
  for sql_file in "$source_dir"/*.sql; do
    [ -e "$sql_file" ] || continue
    if ! head -n 5 "$sql_file" | grep -q "This file is generated"; then
      cp "$sql_file" "$target_dir/"
    fi
  done
}

rm -rf "$tmp_sql_dir"
mkdir -p "$tmp_sql_dir"

copy_sql_dir_if_exists "${source_sql_dir}/init" "${tmp_sql_dir}/init"
copy_sql_dir_if_exists "${source_sql_dir}/recalculations" "${tmp_sql_dir}/recalculations"
copy_manual_base_sql "${source_sql_dir}/base" "${tmp_sql_dir}/base"

if [ "$skip_generator_install" = "true" ]; then
  INTERPOLAR_PROJECT_ROOT="$repo_root" \
  INTERPOLAR_DB_SQL_SOURCE_DIR="$source_sql_dir" \
  INTERPOLAR_DB_SQL_TARGET_DIR="$tmp_sql_dir" \
    Rscript "${repo_root}/Postgres-cds_hub/R-initcdstoolchain/CreateDatabaseScripts.R"
else
  mkdir -p "$r_lib_dir"
  R_LIBS_USER="$r_lib_dir" \
    R CMD INSTALL --preclean --no-multiarch --with-keep.source \
    "${repo_root}/Postgres-cds_hub/R-initcdstoolchain/initcdstoolchain"

  INTERPOLAR_PROJECT_ROOT="$repo_root" \
  INTERPOLAR_DB_SQL_SOURCE_DIR="$source_sql_dir" \
  INTERPOLAR_DB_SQL_TARGET_DIR="$tmp_sql_dir" \
  R_LIBS_USER="$r_lib_dir" \
    Rscript "${repo_root}/Postgres-cds_hub/R-initcdstoolchain/CreateDatabaseScripts.R"
fi

rm -rf "$target_sql_dir"
mkdir -p "$(dirname "$target_sql_dir")"
mv "$tmp_sql_dir" "$target_sql_dir"

if command -v pg_format >/dev/null 2>&1; then
  bash "${repo_root}/tools/format-sql.sh" "$target_sql_dir" all
else
  echo "Generated SQL was not formatted because pg_format is not installed." >&2
fi

echo "Generated CDS-HUB SQL scripts in ${target_sql_dir}"
