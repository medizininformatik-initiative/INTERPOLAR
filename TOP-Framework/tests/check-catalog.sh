#!/usr/bin/env bash
# Check the classification against the actual pinned image, not fixture models.
set -euo pipefail
: > /tmp/catalog.tsv
for file in /opt/app/models/*.json; do
  jq -r --arg model "$(basename "$file" .json)" -f /runner/algorithm-list.jq "$file" >> /tmp/catalog.tsv
done
[[ $(wc -l < /tmp/catalog.tsv) -eq 118 ]]
[[ $(awk -F '\t' '$4 == "Zwischenkriterium" {n++} END {print n}' /tmp/catalog.tsv) -eq 3 ]]
awk -F '\t' 'NF != 4 || $3 == "" {exit 1}' /tmp/catalog.tsv
grep -q $'delirium\t5f66498f-afb1-4d7d-b00f-ba5a933d8cda\t.*\tZwischenkriterium' /tmp/catalog.tsv
grep -q $'fall_injuries\t83f23c3f-062a-45f2-aab4-f5429ef670ca\t.*\tZwischenkriterium' /tmp/catalog.tsv
[[ $(awk -F '\t' '$4 == "Fallzählung" {n++} END {print n}' /tmp/catalog.tsv) -eq 1 ]]
[[ $(cut -f 1 /tmp/catalog.tsv | sort -u | wc -l) -eq 16 ]]
grep -q $'encounters\td84be769-3f95-48be-925a-78b8df679856\t.*\tFallzählung' /tmp/catalog.tsv
grep -q $'delirium\tce5297ae-2f40-4849-8cb3-24b2dd1064ab\t.*\tZwischenkriterium' /tmp/catalog.tsv
printf 'PASS: 118 titled entries in 16 models, three intermediate criteria and one encounter count.\n'
