#!/usr/bin/env bash
# Keep LF line endings: this script is mounted into a Linux container.
# Run the image's boolean composite phenotypes with the unchanged TOP CLI.
set -euo pipefail
umask 077
mkdir -p /run/results /run/logs
printf 'model\tphenotype_id\tstarted_utc\tfinished_utc\tduration_seconds\texit_code\tstatus\tmatched_cases\n' > /run/algorithms.tsv
sha256sum models/*.json > /run/model-checksums.txt
active=false
java_pid=''
heartbeat_pid=''
finish() {
  status=$?
  trap - EXIT INT TERM
  if [[ -n "$java_pid" ]]; then
    kill -TERM "$java_pid" 2>/dev/null || true
    wait "$java_pid" 2>/dev/null || true
  fi
  if [[ -n "$heartbeat_pid" ]]; then
    kill "$heartbeat_pid" 2>/dev/null || true
    wait "$heartbeat_pid" 2>/dev/null || true
  fi
  if [[ "$active" == true ]]; then
    printf '%s\t%s\t%s\t%s\t%s\t%s\tinterrupted\t\n' \
      "$model" "$id" "$started" "$(date -u +%FT%TZ)" "$(( $(date +%s) - start_seconds ))" "$status" >> /run/algorithms.tsv
  fi
  exit "$status"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# Match run_queries.sh: all boolean composite phenotypes, ordered by title.
# Store the list first so a jq failure cannot silently skip a model.
: > /run/algorithm-list.tsv
for model_file in models/*.json; do
  model=$(basename "$model_file" .json)
  jq -er 'type == "array"' "$model_file" >/dev/null
  jq -r '[.[] | select(.entityType == "composite_phenotype" and .dataType == "boolean")]
    | sort_by((.titles[] | select(.lang == "en") | .text) // .titles[0].text)
    | .[] | .id' "$model_file" > /tmp/top-ids
  while IFS= read -r id; do
    [[ "$id" =~ ^[A-Za-z0-9_-]+$ ]] || { echo 'Ungültige Phänotyp-ID.' >&2; exit 1; }
    printf '%s\t%s\n' "$model" "$id" >> /run/algorithm-list.tsv
  done < /tmp/top-ids
done
[[ -s /run/algorithm-list.tsv ]] || { echo 'Keine Algorithmen gefunden.' >&2; exit 1; }
total=$(wc -l < /run/algorithm-list.tsv)
index=0
while IFS=$'\t' read -r model id; do
  index=$((index + 1))
  started=$(date -u +%FT%TZ)
  start_seconds=$(date +%s)
  active=true
  log_file="/run/logs/${model}_${id}.log"
  result_file="/run/results/${model}_${id}.csv"
  partial_file="/run/results/${model}_${id}.partial.csv"
  printf '[%s] START %s/%s %s %s\n' "$started" "$index" "$total" "$model" "$id"
  /opt/java/openjdk/bin/java -jar top-phenotypic-query.jar query -fn --slim \
    -p "$id" "models/$model.json" /run/private/adapter.yml -o "$partial_file" > "$log_file" 2>&1 &
  java_pid=$!
  (
    while sleep 60; do
      printf '[%s] RUNNING %s %s seit %ss\n' "$(date -u +%FT%TZ)" "$model" "$id" "$(( $(date +%s) - start_seconds ))"
    done
  ) &
  heartbeat_pid=$!
  code=0
  wait "$java_pid" || code=$?
  java_pid=''
  kill "$heartbeat_pid" 2>/dev/null || true
  wait "$heartbeat_pid" 2>/dev/null || true
  heartbeat_pid=''
  count=$(tail -n 1 "$log_file" | tr -d '\r')
  if [[ "$code" -eq 0 && ( ! "$count" =~ ^[0-9]+$ || ! -f "$partial_file" ) ]]; then
    code=1
  fi
  if [[ "$code" -eq 0 ]]; then
    mv "$partial_file" "$result_file"
    result_status=completed
  else
    result_status=failed
    count=''
  fi
  duration=$(( $(date +%s) - start_seconds ))
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$model" "$id" "$started" \
    "$(date -u +%FT%TZ)" "$duration" "$code" "$result_status" "$count" >> /run/algorithms.tsv
  active=false
  printf '[%s] %s %s %s Dauer=%ss Treffer=%s Exit=%s\n' \
    "$(date -u +%FT%TZ)" "$result_status" "$model" "$id" "$duration" "$count" "$code"
  [[ "$code" -eq 0 ]] || exit "$code"
done < /run/algorithm-list.tsv
