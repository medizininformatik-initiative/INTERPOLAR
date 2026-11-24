#!/usr/bin/env bash
# Check the executable entries and titles from the current TOP models.
set -euo pipefail
: > /tmp/catalog.tsv
for file in /opt/app/models/*.json; do
  jq -r --arg model "$(basename "$file" .json)" -f /runner/algorithm-list.jq "$file" >> /tmp/catalog.tsv
done
[[ -s /tmp/catalog.tsv ]]
awk -F '\t' 'NF != 3 || $1 == "" || $2 == "" || $3 == "" {exit 1}' /tmp/catalog.tsv
printf 'PASS: model names, phenotype IDs and titles from the current TOP models.\n'
