#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sql_root="${1:-${repo_root}/Postgres-cds_hub/sql}"
format_scope="${2:-manual}"

if ! command -v pg_format >/dev/null 2>&1; then
  echo "pg_format is required. Install pgFormatter or run the GitHub 'Format SQL' workflow." >&2
  exit 127
fi

if [ "$format_scope" != "manual" ] && [ "$format_scope" != "all" ]; then
  echo "Usage: tools/format-sql.sh [sql-root] [manual|all]" >&2
  exit 2
fi

sql_targets=(
  "${sql_root}/base"
  "${sql_root}/init"
  "${sql_root}/recalculations"
)

if [ "$format_scope" = "all" ]; then
  sql_targets=("${sql_root}/start.sql" "${sql_targets[@]}")
fi

format_options=(
  --keyword-case 2
  --type-case 1
  --function-case 0
  --spaces 4
  --wrap-limit 10000
  --no-extra-line
)

cleanup_sql_file() {
  perl -pi -e 's/[ \t]+$//; 1 while s/^([ \t]*) +\t/$1\t/;' "$1"
}

is_generated_sql_file() {
  head -n 5 "$1" | grep -q "This file is generated"
}

format_sql_file() {
  local sql_file="$1"

  if [ "$format_scope" = "manual" ] && is_generated_sql_file "$sql_file"; then
    return
  fi

  pg_format "${format_options[@]}" --inplace "$sql_file"
  cleanup_sql_file "$sql_file"
}

for target in "${sql_targets[@]}"; do
  if [ -f "$target" ]; then
    format_sql_file "$target"
  elif [ -d "$target" ]; then
    while IFS= read -r -d '' sql_file; do
      format_sql_file "$sql_file"
    done < <(find "$target" -type f -name '*.sql' -print0 | sort -z)
  fi
done
