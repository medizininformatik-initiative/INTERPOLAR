#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "${tmp_dir}/Postgres-cds_hub"
cp -R "${repo_root}/Postgres-cds_hub/sql" "${tmp_dir}/Postgres-cds_hub/sql"

(
  "${repo_root}/tools/format-sql.sh" "${tmp_dir}/Postgres-cds_hub/sql"
)

if ! diff -ru \
  --exclude='template' \
  "${repo_root}/Postgres-cds_hub/sql" \
  "${tmp_dir}/Postgres-cds_hub/sql"; then
  cat <<'MSG' >&2

SQL formatting check failed.
Run tools/format-sql.sh locally, or run the GitHub Actions workflow "Format SQL".
MSG
  exit 1
fi
