#!/usr/bin/env bash
# One study run against an existing snapshot, using the repository's R runtime.
set -euo pipefail
umask 077
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
tool_dir="$root/TOP-Framework"
[[ -f "$tool_dir/database.toml" ]] || {
  echo 'TOP-Framework/database.example.toml nach database.toml kopieren und DB_NAME setzen.' >&2
  exit 1
}
# Resolve the current image once for template extraction, execution and reporting.
export TOP_STUDY_IMAGE
TOP_STUDY_IMAGE=$(cat "$tool_dir/image.txt")
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
command -v zip >/dev/null && command -v unzip >/dev/null || {
  echo 'Für die TOP-Ausleitung werden zip und unzip benötigt.' >&2
  exit 1
}
version=$(sed -n '1{s/^[[:space:]]*//; s/[[:space:]]*$//; s/^[vV]//; p;}' release-version.txt)
[[ "$version" =~ ^[[:alnum:]][[:alnum:].+-]*$ ]]
report_name=TOP_Report.txt
naming_source="$root/R-dataprocessor/dataprocessor/R/00_Manual_Output.R"
out="$root/outputLocal/top-study"
report_dir="$root/outputGlobal/top-study"
mkdir -p "$root/outputLocal" "$root/outputGlobal"
lock_dir="$root/outputLocal/.top-study.lock"
mkdir "$lock_dir" 2>/dev/null || {
  echo 'Ein TOP-Lauf ist bereits aktiv oder seine Startsperre besteht noch.' >&2
  exit 1
}
trap 'rmdir "$lock_dir"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
docker_user="$(id -u):$(id -g)"
docker_tool_dir="$tool_dir"
docker_out="$out"
docker_local="$root/outputLocal"
docker_global="$root/outputGlobal"
case "$OSTYPE" in
  msys*|cygwin*)
    # Git Bash must leave container paths alone; convert only host mount paths.
    export MSYS_NO_PATHCONV=1
    naming_source=$(cygpath -m "$naming_source")
    docker_tool_dir=$(cygpath -m "$tool_dir")
    docker_out=$(cygpath -m "$out")
    docker_local=$(cygpath -m "$root/outputLocal")
    docker_global=$(cygpath -m "$root/outputGlobal")
    ;;
esac
# Refresh before rotating outputs; a failed pull preserves the previous run.
echo 'Aktuelles TOP-Image herunterladen'
docker pull "$TOP_STUDY_IMAGE"
TOP_STUDY_IMAGE=$(docker image inspect --format '{{index .RepoDigests 0}}' "$TOP_STUDY_IMAGE")
[[ "$TOP_STUDY_IMAGE" == *@sha256:* ]] || {
  echo 'Der Digest des TOP-Images konnte nicht ermittelt werden.' >&2
  exit 1
}
# Rotate before mounting the current run into any processing container.
docker compose run --rm --no-deps --user "$docker_user" \
  --volume "$docker_tool_dir:/runner:ro" \
  --volume "$docker_local:/outputs/outputLocal" \
  --volume "$docker_global:/outputs/outputGlobal" \
  --entrypoint Rscript r-env /runner/initialize-output.R
start_seconds=$(date +%s)
started=$(date -u -d "@$start_seconds" +%FT%TZ)
archive_timestamp=$(date -u -d "@$start_seconds" +%Y-%m-%d_%H-%M-%SZ)
phase=initialization
container=''
command_pid=''
# Only allowlisted aggregate files enter the public report. TOP ZIPs stay local.
write_report() {
  {
    printf 'TOP-Studienanalyse — Lauf %s\n\n' "$run_id"
    printf 'GESAMTSTATUS UND LAUFZEIT\n'
    if [[ -f "$out/run-summary.tsv" ]]; then cat "$out/run-summary.tsv"; else echo 'Lauf noch nicht abgeschlossen.'; fi
    printf '\nERGEBNISSE JE ALGORITHMUS\n'
    if [[ -f "$out/algorithms.tsv" ]]; then cat "$out/algorithms.tsv"; else echo 'Noch keine Algorithmus-Ergebnisse verfügbar.'; fi
    printf '\nFALLAUSWAHL UND DATENQUALITÄT\n'
    echo 'study_cases: ausgewählte Studienfälle; total_hospital_cases: unterschiedliche Krankenhausfälle im Snapshot.'
    echo 'total_ward_contact_rows: alle Stationszuordnungszeilen, einschließlich Dubletten.'
    echo 'ignored_missing_encounter_contacts: ignorierte Zuordnungszeilen ohne passenden Encounter.'
    echo 'ignored_distinct_encounter_ids: unterschiedliche nicht gefundene IDs; NULL zählt hier nicht mit.'
    echo 'missing_encounter_id_contacts: Zuordnungszeilen mit NULL-ID.'
    echo 'missing_start_contacts / missing_main_reference_contacts / missing_hospital_case_contacts: fehlender Beginn / fehlende Hauptfallreferenz / nicht gefundener Krankenhausfall.'
    echo 'unknown_ward_contacts: unbekannte Station; ambiguous_first_contacts: Hauptfälle mit mehrdeutigem Erstkontakt.'
    echo 'invalid_contacts: alle beanstandeten Zuordnungszeilen, einschließlich ignorierter Zeilen. Fehlerkategorien können sich überschneiden.'
    if [[ -f "$out/preparation.json" ]]; then cat "$out/preparation.json"; else echo 'Prüfung noch nicht abgeschlossen; Zahlen nicht verfügbar.'; fi
    printf '\nPLAUSIBILITÄTSPRÜFUNG\n'
    if [[ -f "$out/plausibility.txt" ]]; then cat "$out/plausibility.txt"; else echo 'Prüfung noch nicht abgeschlossen; Zahlen nicht verfügbar.'; fi
    printf '\nVERSIONEN\n'
    for file in revision.txt versions.json top-image.txt framework-version.txt model-checksums.txt; do
      if [[ -f "$out/$file" ]]; then printf '\n%s\n' "$file"; cat "$out/$file"; fi
    done
    printf '\n'
  } > "$out/$report_name.tmp"
  mv "$out/$report_name.tmp" "$out/$report_name"
}
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
  context="${archive_timestamp}_toolchain-${version}_unknown"
  if [[ -s "$out/archive-context.txt" ]]; then
    context=$(cat "$out/archive-context.txt")
  fi
  archive_name="top-framework_$context.zip"
  if write_report &&
    (cd "$out" && zip -qjT "$report_dir/.$archive_name" "$report_name") &&
    mv "$report_dir/.$archive_name" "$report_dir/$archive_name"; then
    rm -f "$out/$report_name"
    echo "Ausleitung: $report_dir/$archive_name"
  else
    rm -f "$report_dir/.$archive_name"
    echo 'TOP-Ausleitungs-ZIP konnte nicht erstellt werden.' >&2
    if [[ "$status" -eq 0 ]]; then status=1; fi
  fi
  echo "Laufstatus: $outcome (Exit $status). Ausgabe: $out"
  rmdir "$lock_dir"
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
printf '%s\n' "$TOP_STUDY_IMAGE" > "$out/top-image.txt"
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
docker compose run --rm --no-deps --user "$docker_user" --name "$container" \
  --volume "$docker_tool_dir:/runner:ro" --volume "$docker_out:/run" \
  --volume "$naming_source:/manual-output.R:ro" \
  --entrypoint Rscript r-env /runner/prepare.R "$version" "$start_seconds" > "$out/preparation.log" 2>&1 &
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
docker compose -f docker-compose.yml -f TOP-Framework/compose.yml run --rm --no-deps --user "$docker_user" \
  --name "$container" --volume "$docker_tool_dir:/runner:ro" --volume "$docker_out:/run" top-study \
  2>&1 | tee "$out/progress.log" &
command_pid=$!
wait_for_command
phase=plausibility
container="top-study-plausibility-$run_id"
echo "[$(date -u +%FT%TZ)] Aggregierte Plausibilitätsprüfung starten"
docker compose run --rm --no-deps --user "$docker_user" --name "$container" \
  --volume "$docker_tool_dir:/runner:ro" --volume "$docker_out:/run" \
  --entrypoint Rscript r-env /runner/plausibility.R > "$out/plausibility.log" 2>&1 &
command_pid=$!
wait_for_command || {
  code=$?
  echo 'Plausibilitätsprüfung fehlgeschlagen; Details stehen lokal in plausibility.log.' >&2
  exit "$code"
}
phase=finished
