#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
detector="${repo_root}/tools/detect-sql-checks.sh"

assert_detection() {
  local changed_file="$1"
  local expected="$2"
  local actual

  actual="$(printf '%s\n' "$changed_file" | "$detector")"
  if [ "$actual" != "$expected" ]; then
    printf 'Unexpected SQL check detection for %s\nExpected:\n%s\nActual:\n%s\n' \
      "$changed_file" "$expected" "$actual" >&2
    return 1
  fi
}

generated_only=$'format=false\ngenerated=true'
no_checks=$'format=false\ngenerated=false'

assert_detection "Dockerfile_R" "$generated_only"
assert_detection "R-etlutils/etlutils/R/lib_table.R" "$generated_only"
assert_detection "R-cdstoolchain/pseudonym/R/pseudonymize_table.R" "$generated_only"
assert_detection "R-dataprocessor/dataprocessor/inst/extdata/Dataprocessor_Table_Description.xlsx" "$generated_only"
assert_detection "R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx" "$generated_only"
assert_detection "tools/install-pgformatter.sh" "$generated_only"
assert_detection "README.md" "$no_checks"

echo "SQL check detection tests passed."
