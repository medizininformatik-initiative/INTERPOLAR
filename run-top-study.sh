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
report_dir="$root/outputGlobal/top-study/$run_id"
mkdir -p "$out" "$report_dir"
docker_tool_dir="$tool_dir"
docker_out="$out"
docker_report_dir="$report_dir"
case "$OSTYPE" in
  msys*|cygwin*)
    # Git Bash must leave container paths alone; convert only host mount paths.
    export MSYS_NO_PATHCONV=1
    docker_tool_dir=$(cygpath -m "$tool_dir")
    docker_out=$(cygpath -m "$out")
    docker_report_dir=$(cygpath -m "$report_dir")
    ;;
esac
started=$(date -u +%FT%TZ)
start_seconds=$(date +%s)
phase=initialization
container=''
command_pid=''
# The report contains aggregates; completed TOP ZIPs are published separately.
write_report() {
  {
    printf 'TOP-Studienanalyse — Lauf %s\n\n' "$run_id"
    printf 'GESAMTSTATUS UND LAUFZEIT\n'
    if [[ -f "$out/run-summary.tsv" ]]; then cat "$out/run-summary.tsv"; else echo 'Lauf noch nicht abgeschlossen.'; fi
    printf '\nERGEBNISSE JE ALGORITHMUS\n'
    echo 'entry_type unterscheidet Algorithmus und Zwischenkriterium; Zwischenkriterien sind keine eigenständigen Krankheitsnachweise.'
    echo 'Vollständige TOP-Ergebnisse: results/<model>_<phenotype_id>.zip (nur abgeschlossene Exporte).'
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
    printf '\nVERSIONEN\n'
    for file in revision.txt versions.json model-checksums.txt; do
      if [[ -f "$out/$file" ]]; then printf '\n%s\n' "$file"; cat "$out/$file"; fi
    done
    printf '\n'
  } > "$report_dir/report.txt.tmp"
  mv "$report_dir/report.txt.tmp" "$report_dir/report.txt"
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
  write_report
  echo "Laufstatus: $outcome (Exit $status). Ausgabe: $out"
  echo "Ausleitung: $report_dir (report.txt und results/*.zip)"
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
  --volume "$docker_tool_dir:/runner:ro" --volume "$docker_out:/run" \
  --entrypoint Rscript r-env /runner/prepare.R > "$out/preparation.log" 2>&1 &
command_pid=$!
wait_for_command || {
  code=$?
  echo 'Vorbereitung fehlgeschlagen; Details stehen lokal in preparation.log.' >&2
  exit "$code"
}
write_report
phase=top
container="top-study-run-$run_id"
echo "[$(date -u +%FT%TZ)] Vollständige TOP-Studienanalyse starten"
# A pipe streams progress; pipefail preserves the container exit status.
docker compose -f docker-compose.yml -f R-cdstoolchain/top-study/compose.yml run --rm --no-deps \
  --name "$container" --volume "$docker_tool_dir:/runner:ro" --volume "$docker_out:/run" --volume "$docker_report_dir:/export" top-study \
  2>&1 | tee "$out/progress.log" &
command_pid=$!
wait_for_command
phase=finished
