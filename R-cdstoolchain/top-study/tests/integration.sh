#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/top-study-integration.XXXXXX")
network="top-study-test-$$"
database="top-study-test-db-$$"
cleanup() {
  docker rm -f -v "$database" >/dev/null 2>&1 || true
  docker network rm "$network" >/dev/null 2>&1 || true
}
trap cleanup EXIT
mkdir -p "$work/R-cdstoolchain" "$work/R-dataprocessor"
cp -R "$root/R-cdstoolchain/top-study" "$work/R-cdstoolchain/"
cp "$root/run-top-study.sh" "$work/"
cp "$root/R-cdstoolchain/top-study/tests/phases.toml" "$work/R-dataprocessor/dataprocessor_config.toml"
printf 'DB_NAME = "probe"\n' > "$work/R-cdstoolchain/top-study/database.toml"
cat > "$work/cds_hub_db_config.toml" <<EOF
DB_HOST = "$database"
DB_PORT = 5432
DB_NAME = "probe"
DB_DATAPROCESSOR_USER = "probe"
DB_DATAPROCESSOR_PASSWORD = "probe"
EOF
cat > "$work/docker-compose.yml" <<EOF
services:
  r-env:
    image: interpolar-r-env:latest
    volumes:
      - ./R-dataprocessor/dataprocessor_config.toml:/src/R-dataprocessor/dataprocessor_config.toml:ro
      - ./cds_hub_db_config.toml:/src/cds_hub_db_config.toml:ro
    networks: [internal]
  top-study:
    image: ghcr.io/onto-med/top-interpolar-algorithms:1
    volumes:
      - ./R-cdstoolchain/top-study/tests/models:/opt/app/models:ro
networks:
  internal:
    external: true
    name: $network
EOF
docker run --rm --network none --read-only --tmpfs /tmp \
  --mount "type=bind,src=$root/R-cdstoolchain/top-study,dst=/runner,readonly" \
  --entrypoint bash "$(cat "$root/R-cdstoolchain/top-study/image.txt")" /runner/tests/check-catalog.sh
# Use the original laboratory and encounter models from the actual image.
for model in anaemia encounters; do
  docker run --rm --network none --read-only --entrypoint cat \
    "$(cat "$root/R-cdstoolchain/top-study/image.txt")" "/opt/app/models/$model.json" \
    > "$work/R-cdstoolchain/top-study/tests/models/$model.json"
done
mkdir "$work/reference-models"
docker run --rm --network none --read-only --entrypoint tar \
  "$(cat "$root/R-cdstoolchain/top-study/image.txt")" -C /opt/app -cf - models \
  | tar -C "$work/reference-models" -xf -
git -C "$work" init -q
git -C "$work" -c user.name=Test -c user.email=test@example.invalid commit -q --allow-empty -m fixture
docker network create --internal "$network" >/dev/null
docker run -d --name "$database" --network "$network" \
  -e POSTGRES_USER=probe -e POSTGRES_PASSWORD=probe -e POSTGRES_DB=probe \
  --mount "type=bind,src=$root/R-cdstoolchain/top-study/tests/seed.sql,dst=/docker-entrypoint-initdb.d/seed.sql,readonly" \
  postgres:16-alpine >/dev/null
ready=false
for _attempt in $(seq 1 30); do
  if docker exec "$database" psql -U probe -d probe -Atc \
    'SELECT count(*) FROM db2dataprocessor_out.v_condition_last_version' 2>/dev/null | grep -qx 12; then
    ready=true; break
  fi
  sleep 1
done
[[ "$ready" == true ]]
(cd "$work" && docker compose run --rm --no-deps \
  --volume "$work/R-cdstoolchain/top-study:/runner:ro" \
  --entrypoint Rscript r-env /runner/tests/check-associations.R)
bash "$work/run-top-study.sh"
output=$(find "$work/outputLocal/top-study" -mindepth 1 -maxdepth 1 -type d)
docker run --rm --network none --read-only --tmpfs /tmp \
  --mount "type=bind,src=$output,dst=/run,readonly" \
  --mount "type=bind,src=$work/outputGlobal/top-study/$(basename "$output"),dst=/global,readonly" \
  --mount "type=bind,src=$root/R-cdstoolchain/top-study,dst=/runner,readonly" \
  --entrypoint Rscript interpolar-r-env:latest /runner/tests/verify.R
(cd "$work" && docker compose run --rm --no-deps \
  --volume "$work/R-cdstoolchain/top-study:/runner:ro" --volume "$output:/baseline:ro" \
  --volume "$work/reference-models/models:/reference-models:ro" \
  --entrypoint Rscript r-env /runner/tests/check-plausibility.R)
docker exec "$database" psql -U probe -d probe -c \
  'ALTER TABLE db2dataprocessor_out.v_observation_last_version RENAME COLUMN analysis_unit TO missing_unit' >/dev/null
code=0
bash "$work/run-top-study.sh" || code=$?
[[ "$code" -ne 0 ]]
last=$(find "$work/outputLocal/top-study" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
grep -q $'\tfailed_or_interrupted\tplausibility' "$last/run-summary.tsv"
grep -q 'ABGLEICH DER FALLAUSWAHL' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
[[ ! -d "$work/outputGlobal/top-study/$(basename "$last")/results" ]]
[[ $(find "$last/results" -name '*.zip' | wc -l) -eq 13 ]]
docker exec "$database" psql -U probe -d probe -c \
  'ALTER TABLE db2dataprocessor_out.v_observation_last_version RENAME COLUMN missing_unit TO analysis_unit' >/dev/null
printf 'PASS: failed audit keeps partial aggregates and complete TOP ZIPs locally.\n'
# Other data errors still block preparation, even with ignored missing encounters.
docker exec "$database" psql -U probe -d probe -c \
  "UPDATE db2dataprocessor_out.v_encounter_last_version SET enc_period_start=NULL WHERE enc_id='early_hospital_w0'" >/dev/null
code=0
bash "$work/run-top-study.sh" || code=$?
[[ "$code" -ne 0 ]]
last=$(find "$work/outputLocal/top-study" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
grep -q '"invalid_contacts": 8' "$last/preparation.json"
grep -q '"missing_start_contacts": 1' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
grep -q 'failed_or_interrupted' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
grep -q '"ignored_missing_encounter_contacts": 7' "$last/preparation.json"
[[ ! -f "$last/algorithms.tsv" && ! -f "$last/private/adapter.yml" ]]
docker exec "$database" psql -U probe -d probe -c \
  "UPDATE db2dataprocessor_out.v_encounter_last_version SET enc_period_start='2026-01-15' WHERE enc_id='early_hospital_w0'" >/dev/null
printf 'PASS: missing encounters are ignored, but missing contact dates still block the run.\n'
# A data-query failure must stop the runner and preserve a non-success summary.
docker exec "$database" psql -U probe -d probe -c \
  'ALTER TABLE db2dataprocessor_out.v_observation_last_version RENAME TO missing_observation' >/dev/null
code=0
bash "$work/run-top-study.sh" || code=$?
[[ "$code" -ne 0 ]]
last=$(find "$work/outputLocal/top-study" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
grep -q 'failed_or_interrupted' "$last/run-summary.tsv"
grep -q 'failed_or_interrupted' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
grep -q $'\tfailed\t' "$last/algorithms.tsv"
[[ ! -f "$last/private/adapter.yml" ]]
[[ ! -d "$work/outputGlobal/top-study/$(basename "$last")/results" ]]
printf 'PASS: completed study-only run and controlled failure. Artifacts: %s\n' "$work"
# Exercise a user interruption while TOP is waiting for a database lock.
docker exec "$database" psql -U probe -d probe -c \
  'ALTER TABLE db2dataprocessor_out.missing_observation RENAME TO v_observation_last_version' >/dev/null
docker exec "$database" psql -U probe -d probe -c \
  'BEGIN; LOCK TABLE db2dataprocessor_out.v_observation_last_version IN ACCESS EXCLUSIVE MODE; SELECT pg_sleep(120)' >/dev/null &
lock_pid=$!
sleep 1
bash "$work/run-top-study.sh" > "$work/interruption-console.log" 2>&1 &
launcher_pid=$!
found=false
for _attempt in $(seq 1 60); do
  if grep -q 'START 1/' "$work/interruption-console.log"; then found=true; break; fi
  sleep 0.1
done
[[ "$found" == true ]]
kill -TERM "$launcher_pid"
code=0
wait "$launcher_pid" || code=$?
[[ "$code" -eq 143 ]]
last=$(find "$work/outputLocal/top-study" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
grep -q 'failed_or_interrupted' "$last/run-summary.tsv"
grep -q 'failed_or_interrupted' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
grep -q $'\tinterrupted\t' "$last/algorithms.tsv"
[[ ! -d "$work/outputGlobal/top-study/$(basename "$last")/results" ]]
[[ ! -f "$last/private/adapter.yml" ]]
# Stop only the synthetic lock holder; container cleanup removes its transaction.
docker exec "$database" psql -U probe -d probe -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND query LIKE 'BEGIN; LOCK TABLE%';" >/dev/null
wait "$lock_pid" 2>/dev/null || true
printf 'PASS: user interruption recorded and credentials removed.\n'
# Preparation uses the same wait/cleanup path; interrupt it before TOP starts.
sed -i.bak '1i\
cat("TEST preparation waiting\\n"); flush.console(); Sys.sleep(120)\
' "$work/R-cdstoolchain/top-study/prepare.R"
bash "$work/run-top-study.sh" > "$work/preparation-interruption.log" 2>&1 &
launcher_pid=$!
found=false
for _attempt in $(seq 1 100); do
  last=$(find "$work/outputLocal/top-study" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
  if grep -q 'TEST preparation waiting' "$last/preparation.log" 2>/dev/null; then found=true; break; fi
  sleep 0.1
done
[[ "$found" == true ]]
kill -TERM "$launcher_pid"
code=0
wait "$launcher_pid" || code=$?
[[ "$code" -eq 143 ]]
grep -q $'\tfailed_or_interrupted\tprepare' "$last/run-summary.tsv"
grep -q 'failed_or_interrupted' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
grep -q 'Zahlen nicht verfügbar' "$work/outputGlobal/top-study/$(basename "$last")/report.txt"
[[ ! -f "$last/algorithms.tsv" && ! -f "$last/private/adapter.yml" ]]
[[ -z $(docker ps -q --filter "name=top-study-prepare-$(basename "$last")") ]]
printf 'PASS: preparation interruption recorded and container stopped.\n'
