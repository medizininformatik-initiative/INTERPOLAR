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
assert_detection "R-cds2db/cds2db/inst/extdata/Table_Description_Definition.xlsx" "$generated_only"
assert_detection "R-cds2db/cds2db/inst/extdata/Table_Description.xlsx" "$generated_only"
assert_detection "R-dataprocessor/dataprocessor/inst/extdata/Dataprocessor_Table_Description.xlsx" "$generated_only"
assert_detection "R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx" "$generated_only"
assert_detection "tools/install-pgformatter.sh" "$generated_only"
assert_detection "tools/check-table-description-consistency.R" "$generated_only"
assert_detection "tools/test-check-table-description-consistency.R" "$generated_only"
assert_detection "README.md" "$no_checks"

echo "SQL check detection tests passed."

format_only=$'format=true\ngenerated=false'
both_checks=$'format=true\ngenerated=true'

assert_detection "" "$no_checks"
assert_detection $'README.md\nR-cdstoolchain/pseudonym/tests/testthat/test-cli.R' "$no_checks"
assert_detection $'README.md\nPostgres-cds_hub/sql/template/table.sql' "$generated_only"
assert_detection "Postgres-cds_hub/sql/base/020_db_config_tools.sql" "$format_only"
assert_detection "Postgres-cds_hub/sql/base/140_cre_table_typ_cds2db_in.sql" "$generated_only"
assert_detection "Postgres-cds_hub/sql/init/start.sql" "$format_only"
assert_detection "Postgres-cds_hub/sql/recalculations/fix.sql" "$format_only"
assert_detection "tools/detect-sql-checks.sh" "$both_checks"
assert_detection ".github/workflows/sql-checks.yml" "$both_checks"

# Exercise the cache with a disposable Git index, never the working repository.
cache_key_script="${repo_root}/tools/generated-sql-cache-key.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
git init -q "$test_root"
cd "$test_root"
empty_key="$("$cache_key_script")"

assert_input_and_cache() {
  local input_file="$1"
  local expected="$2"
  local first_key second_key
  assert_detection "$input_file" "$expected"
  mkdir -p "$(dirname "$input_file")"
  printf 'first content\n' > "$input_file"
  git add -- "$input_file"
  first_key="$("$cache_key_script")"
  printf 'changed content\n' > "$input_file"
  git add -- "$input_file"
  second_key="$("$cache_key_script")"
  if [[ "$expected" == *'generated=true'* ]]; then
    [[ "$first_key" != "$empty_key" && "$second_key" != "$first_key" ]] || {
      echo "Relevant input did not invalidate cache: $input_file" >&2
      exit 1
    }
  else
    [[ "$first_key" == "$empty_key" && "$second_key" == "$empty_key" ]] || {
      echo "Unrelated input invalidated cache: $input_file" >&2
      exit 1
    }
  fi
  git rm -q -f -- "$input_file"
  [[ "$("$cache_key_script")" == "$empty_key" ]] || {
    echo "Removal did not restore cache key: $input_file" >&2
    exit 1
  }
}

for package in \
  R-etlutils/etlutils \
  R-cds2db/cds2db \
  R-cdstoolchain/pseudonym \
  Postgres-cds_hub/R-initcdstoolchain/initcdstoolchain; do
  for relative_file in R/nested/code.R DESCRIPTION NAMESPACE .Rbuildignore \
    configure src/native.c inst/extdata/rules.xlsx; do
    assert_input_and_cache "$package/$relative_file" "$generated_only"
  done
  for relative_file in tests/testthat/test-cli.R tests/fixtures/cli.R \
    man/helper.Rd vignettes/intro.Rmd docs/guide.md README.md NEWS.md; do
    assert_input_and_cache "$package/$relative_file" "$no_checks"
  done
done

for input_file in \
  Dockerfile_R .dockerignore Dockerfile_R.dockerignore .Rprofile tools/styler-style.R \
  Postgres-cds_hub/generate-sql.sh \
  Postgres-cds_hub/R-initcdstoolchain/CreateDatabaseScripts.R \
  Postgres-cds_hub/sql/template/nested/table.sql \
  Postgres-cds_hub/sql/base/140_cre_table_typ_cds2db_in.sql \
  Postgres-cds_hub/sql/start.sql \
  R-cds2db/cds2db/inst/extdata/Table_Description_Definition.xlsx \
  R-cds2db/cds2db/inst/extdata/Table_Description.xlsx \
  R-dataprocessor/dataprocessor/inst/extdata/Dataprocessor_Table_Description.xlsx \
  R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx \
  R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx \
  tools/generated-sql-cache-key.sh tools/check-generated-sql.sh \
  tools/check-table-description-consistency.R tools/test-check-table-description-consistency.R \
  tools/install-pgformatter.sh; do
  assert_input_and_cache "$input_file" "$generated_only"
done
assert_input_and_cache "tools/detect-sql-checks.sh" "$both_checks"
assert_input_and_cache ".github/workflows/sql-checks.yml" "$both_checks"
assert_input_and_cache "tools/format-sql.sh" "$both_checks"
assert_input_and_cache "README.md" "$no_checks"
assert_input_and_cache "Database_Snapshot_Pseudonymization.md" "$no_checks"
assert_input_and_cache "R-cdstoolchain/StartSnapshotPseudonymizationPreflight.R" "$no_checks"
assert_input_and_cache "R-dataprocessor/dataprocessor/R/analysis.R" "$no_checks"
assert_input_and_cache "tools/test-detect-sql-checks.sh" "$no_checks"
assert_input_and_cache "Postgres-cds_hub/sql/base/020_db_config_tools.sql" "$format_only"

# Identical contents under different relevant names, and executable-bit changes,
# must not reuse a previous result. Deletions/renames are detected by path alone.
mkdir -p Postgres-cds_hub/sql/template
printf 'same content\n' > Postgres-cds_hub/sql/template/first.sql
git add .
first_key="$("$cache_key_script")"
git mv Postgres-cds_hub/sql/template/first.sql Postgres-cds_hub/sql/template/second.sql
[[ "$("$cache_key_script")" != "$first_key" ]]
first_key="$("$cache_key_script")"
git update-index --chmod=+x Postgres-cds_hub/sql/template/second.sql
[[ "$("$cache_key_script")" != "$first_key" ]]
assert_detection $'Postgres-cds_hub/sql/template/first.sql\nPostgres-cds_hub/sql/template/second.sql' "$generated_only"

# A move from production code into tests must still report the removed input.
# Check the actual workflow commands too, so removing the flag breaks this test.
if grep -E '^[[:space:]]+git (diff|diff-tree) ' "${repo_root}/.github/workflows/sql-checks.yml" |
  grep -v -- '--no-renames'; then
  echo "SQL workflow must retain both paths of renames." >&2
  exit 1
fi
production_file="R-cdstoolchain/pseudonym/R/moved_rule.R"
test_file="R-cdstoolchain/pseudonym/tests/fixtures/moved_rule.R"
mkdir -p "$(dirname "$production_file")" "$(dirname "$test_file")"
printf 'exampleRule <- function(x) x\n' > "$production_file"
git add .
git -c user.name='SQL detection test' -c user.email=test@example.invalid commit -qm 'Synthetic baseline'
git mv "$production_file" "$test_file"
git -c user.name='SQL detection test' -c user.email=test@example.invalid commit -qm 'Move code to tests'
assert_detection "$(git -c diff.renames=true diff --name-only HEAD^ HEAD)" "$no_checks"
assert_detection "$(git -c diff.renames=true diff --no-renames --name-only HEAD^ HEAD)" "$generated_only"
assert_detection "$(git -c diff.renames=true diff-tree --no-renames --no-commit-id --name-only -r HEAD)" "$generated_only"

echo "SQL input detection and cache invalidation tests passed."
