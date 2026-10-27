#!/usr/bin/env bash
# One study run against an existing snapshot, using the repository's R runtime.
set -euo pipefail
umask 077
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$root"
tool_dir="$root/R-cdstoolchain/top-study"
[[ -f "$tool_dir/database.toml" ]] || {
  echo 'R-cdstoolchain/top-study/database.example.toml nach database.toml kopieren und DB_NAME setzen.' >&2
  exit 1
}
# One image reference for template extraction, execution and version reporting.
export TOP_STUDY_IMAGE
TOP_STUDY_IMAGE=$(cat "$tool_dir/image.txt")
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
out="$root/outputLocal/top-study/$run_id"
mkdir -p "$out"
started=$(date -u +%FT%TZ)
start_seconds=$(date +%s)
phase=initialization
container=''
command_pid=''
finalize() {
  status=$?
  trap - EXIT INT TERM
  if [[ -n "$container" ]]; then docker stop -t 10 "$container" >/dev/null 2>&1 || true; fi
  if [[ -n "$command_pid" ]]; then wait "$command_pid" 2>/dev/null || true; fi
  # Credentials are temporary; raw TOP logs and results remain local.
  rm -f "$out/private/adapter.yml"
  if [[ "$phase" == finished && "$status" -eq 0 ]]; then outcome=completed; else outcome=failed_or_interrupted; fi
  {
    printf 'started_utc\tfinished_utc\tduration_seconds\texit_code\tstatus\tphase\n'
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$started" "$(date -u +%FT%TZ)" \
      "$(( $(date +%s) - start_seconds ))" "$status" "$outcome" "$phase"
  } > "$out/run-summary.tsv"
  echo "Laufstatus: $outcome (Exit $status). Ausgabe: $out"
  echo 'Rückmeldung: run-summary.tsv, algorithms.tsv, preparation.json, versions.json, model-checksums.txt, revision.txt (soweit vorhanden).'
  exit "$status"
}
# Waiting on a background command lets Bash handle Ctrl+C/TERM immediately.
# Both preparation and TOP share the same active-container cleanup in finalize.
wait_for_command() {
  local code=0
  wait "$command_pid" || code=$?
  command_pid=''
  container=''
  return "$code"
}
trap finalize EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
git rev-parse HEAD > "$out/revision.txt"
if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  printf 'Working tree has tracked modifications.\n' >> "$out/revision.txt"
fi
phase=extract_template
echo "[$(date -u +%FT%TZ)] TOP-Vorlage auslesen"
docker run --rm --network none --read-only --entrypoint /usr/bin/unzip "$TOP_STUDY_IMAGE" \
  -p /opt/app/top-phenotypic-query.jar default_adapter_configuration/Default_Interpolar_Adapter.yml > "$out/original.yml"
phase=prepare
container="top-study-prepare-$run_id"
echo "[$(date -u +%FT%TZ)] Studienadapter vorbereiten"
docker compose run --rm --no-deps --name "$container" \
  --volume "$tool_dir:/runner:ro" --volume "$out:/run" \
  --entrypoint Rscript r-env /runner/prepare.R > "$out/preparation.log" 2>&1 &
command_pid=$!
wait_for_command || {
  code=$?
  echo 'Vorbereitung fehlgeschlagen; Details stehen lokal in preparation.log.' >&2
  exit "$code"
}
phase=top
container="top-study-run-$run_id"
echo "[$(date -u +%FT%TZ)] Vollständige TOP-Studienanalyse starten"
# A pipe streams progress; pipefail preserves the container exit status.
docker compose -f docker-compose.yml -f R-cdstoolchain/top-study/compose.yml run --rm --no-deps \
  --name "$container" --volume "$tool_dir:/runner:ro" --volume "$out:/run" top-study \
  2>&1 | tee "$out/progress.log" &
command_pid=$!
wait_for_command
phase=finished
