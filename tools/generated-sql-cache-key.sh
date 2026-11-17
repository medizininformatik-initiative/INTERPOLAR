#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tools/detect-sql-checks.sh
source "${script_dir}/detect-sql-checks.sh"

# Hash the checked-out index (as in Actions): names, content hashes and modes.
# Additions, removals and renames change the key; unrelated files do not.
git ls-files --stage -z |
  while IFS= read -r -d '' entry; do
    input_file="${entry#*$'\t'}"
    if is_generated_sql_input "$input_file"; then
      printf '%s\0' "$entry"
    fi
  done | git hash-object --stdin
