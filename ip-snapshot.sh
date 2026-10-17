#!/usr/bin/env bash
#
# ip-snapshot.sh – Erzeugt, verarbeitet, aktiviert und entfernt INTERPOLAR-Snapshots.
#
# Ein Snapshot ist ein gzip-komprimierter Plain-SQL-Dump der cds_hub-Datenbank
# (Snapshots/<name_date>.sql.gz). Optionale Derivate: pseudonymisierter
# Snapshot (<name_date>_pseud.sql.gz) und Broad-Consent-Snapshot
# (<name_date>_pseud_broad_consent.sql.gz, benötigt den pseudonymisierten
# Snapshot). "activate" stellt eine Snapshot-Datei als read-only-Datenbank
# ip_<name_date> wieder her; "deactivate" löscht diese Datenbank.
#
#  Aufruf:
#      ./ip-snapshot.sh list
#      ./ip-snapshot.sh create  <name> [--with-pseudonymized|--with-broad-consent]
#                                      [--consent-details] [--chunk-size <rows>]
#      ./ip-snapshot.sh pseudonymize  <name_date> [--chunk-size <rows>]
#      ./ip-snapshot.sh create-broad-consent  <name_date_pseud> [--consent-details] [--chunk-size <rows>]
#      ./ip-snapshot.sh review-broad-consent  <name_date_pseud> [--chunk-size <patients>]
#      ./ip-snapshot.sh delete  <name_date>
#      ./ip-snapshot.sh activate  <name_date>
#      ./ip-snapshot.sh deactivate  <name_date>|ip_<name_date>
#      ./ip-snapshot.sh --help
#
#  Optionen (an beliebiger Stelle):
#      --docker-mode compose|swarm   Docker-Aufrufvariante
#                                    (Standard: Auto-Erkennung, Fallback "compose")
#      --with-pseudonymized          (nur create) auch pseudonymisierten Snapshot erzeugen
#      --with-broad-consent          (nur create) zusätzlich Broad-Consent-Snapshot erzeugen
#      --consent-details             zusätzlich patientenbezogene Consent-CSV-Reports schreiben
#      --chunk-size <rows>           Zeilen je Verarbeitungs-Chunk (Standard: 5000)
#      -y, --yes                     alle Rückfragen mit "ja" beantworten
#      -h, --help                    diese Hilfe anzeigen
#
#  Exit-Codes:
#      0  erfolgreich (oder Rückfrage abgebrochen)
#      1  Laufzeitfehler (Snapshot/Datenbank/Docker) oder fehlende Aktion
#      2  Snapshot-Name ungültig oder fehlt
#      3  unbekannte Aktion oder ungültige/unbekannte Option
#
#  Hinweis: Der Dateiname darf **keine** Pfadangaben (/, ..) enthalten,
#           sonst wird das Skript mit einer Fehlermeldung beendet.

set -o pipefail
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${script_dir}"
source "${script_dir}/tools/snapshot-progress.sh"

# ========== Von Nutzer zu setzende Variablen ==========
# Fallback-Docker-Modus, wenn die Auto-Erkennung fehlschlägt.
DOCKER_MODE="compose"

# Lese Version aus release-version.txt
CDS_TOOL_CHAIN_VERSION_TAG=""
if [[ -f "release-version.txt" ]]; then
    CDS_TOOL_CHAIN_VERSION_TAG="$(tr -d '\n ' < release-version.txt)"
    if [[ -z "${CDS_TOOL_CHAIN_VERSION_TAG}" ]]; then
        echo "Warning: release-version.txt is empty." >&2
    fi
fi

DIR=Snapshots
with_pseudonymized=false
with_broad_consent=false
consent_details=false
chunk_size=5000
chunk_size_set=false
assume_yes=false
docker_mode=""
swarm_mount_warning_shown=false

# ---------- Hilfetext ----------
print_usage() {
    cat <<EOF
Usage: ${0##*/} [--docker-mode compose|swarm] <action> <name>

  <action>   "list"         – lists all snapshots
             "create"       – creates a snapshot <name>.sql.gz
             "pseudonymize" – creates a pseudonymized snapshot <name_date>_pseud.sql.gz
             "create-broad-consent"
                            – creates a Broad Consent snapshot from an activated snapshot database
             "review-broad-consent"
                            – reviews Consent decisions without creating a snapshot
             "delete"       – deletes only a snapshot file <name_date>.sql.gz;
                              expects the file name without the database prefix "ip_"
             "activate"     – activates a snapshot <name_date>.sql.gz by creating a database for it
             "deactivate"   – deactivates a snapshot database; accepts <name_date> and the
                              ip_<name_date> name printed by "list"

  <name>     any string without path components, <name> | <name_date>
  --with-pseudonymized
             only for "create": also creates <name_date>_pseud.sql.gz
  --with-broad-consent
             only for "create": also creates the pseudonymized snapshot and
             <name_date>_pseud_broad_consent.sql.gz
  --consent-details
             with "create-broad-consent" or "create --with-broad-consent":
             also writes detailed patient-level Consent CSV reports
  --chunk-size <rows>
             only for "pseudonymize", "create-broad-consent", "review-broad-consent", or
             "create --with-pseudonymized|--with-broad-consent":
             number of rows read per processing chunk (default: 5000);
             for "review-broad-consent": number of patients per block
  -y, --yes  answer all confirmation prompts with "yes"
  -h, --help show this help

Exit codes:
  0  success (or a confirmation prompt was cancelled)
  1  runtime error or missing action
  2  invalid or missing snapshot name
  3  unknown action or invalid/unknown option

Examples:
  $0 list                            → lists all .sql.gz files without extensions in Snapshots
  $0 create  snapshot                → creates snapshot_<date>.sql.gz
  $0 create  snapshot --with-pseudonymized
                                       → creates snapshot_<date>.sql.gz and snapshot_<date>_pseud.sql.gz
  $0 create  snapshot --with-broad-consent
                                       → additionally creates snapshot_<date>_pseud_broad_consent.sql.gz
  $0 pseudonymize  snapshot_20250929 → creates snapshot_20250929_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 --chunk-size 10000
                                       → processes at most 10000 rows per chunk
  $0 review-broad-consent  snapshot_20250929_pseud
                                       → reviews Consent decisions without creating a snapshot
  $0 create-broad-consent  snapshot_20250929_pseud
                                       → creates snapshot_20250929_pseud_broad_consent.sql.gz
  $0 delete  snapshot_20250929       → deletes snapshot_20250929.sql.gz
  $0 activate  snapshot_20250929     → creates database 'ip_snapshot_20250929'
  $0 deactivate  snapshot_20250929   → drops database 'ip_snapshot_20250929'
  $0 deactivate  ip_snapshot_20250929
                                       → drops the same database
EOF
}

# ========== Docker Helpers ==========
# Ermittelt, wie Docker angesprochen werden kann.
# Ausgabe: "swarm", "compose" oder "unknown".
detect_docker_mode() {
    local swarm_info
    swarm_info="$(docker info --format '{{.Swarm.LocalNodeState}} {{.Swarm.ControlAvailable}}' 2>/dev/null)"
    if [[ "${swarm_info}" == "active true" ]]; then
        echo "swarm"
        return
    fi
    if docker compose version >/dev/null 2>&1 || docker-compose version >/dev/null 2>&1; then
        echo "compose"
        return
    fi
    echo "unknown"
}

# Warnt nur, wenn der angeforderte Modus nicht zum erkannten passt.
validate_docker_mode() {
    local requested_mode="$1"
    local detected_mode
    detected_mode="$(detect_docker_mode)"
    if [[ "${detected_mode}" == "unknown" ]]; then
        echo "Warning: could not auto-detect the Docker environment; using requested mode '${requested_mode}'." >&2
        return 0
    fi
    if [[ "${requested_mode}" != "${detected_mode}" ]]; then
        echo "Warning: requested Docker mode '${requested_mode}' does not match the detected mode '${detected_mode}'." >&2
        echo "         Commands may fail. Verify your Docker setup if problems occur." >&2
    fi
    return 0
}

# Gibt die Task-ID eines laufenden Swarm-Service-Containers aus.
# $1: Service-Name-Fragment (z. B. interpolar_cds_hub)
# $2: Image-Name ohne Tag (optional, zur eindeutigen Auswahl)
swarm_task_id() {
    local service_fragment="$1"
    local image_name="${2:-}"
    local filters=(-f "name=${service_fragment}")
    if [[ -n "${image_name}" && -n "${CDS_TOOL_CHAIN_VERSION_TAG}" ]]; then
        filters+=(-f "ancestor=${image_name}:${CDS_TOOL_CHAIN_VERSION_TAG}")
    fi
    local task_id
    task_id="$(docker ps -q "${filters[@]}" | head -n 1)"
    if [[ -z "${task_id}" ]]; then
        echo "Error: no running swarm task found for '${service_fragment}'." >&2
        return 1
    fi
    printf '%s\n' "${task_id}"
}

# Führt einen Befehl im cds_hub-Container aus (compose oder swarm).
# Wird auch von tools/snapshot-progress.sh (snapshot_db_exec) verwendet.
db_exec() {
    if [[ "${DOCKER_MODE}" == "swarm" ]]; then
        local task_id
        task_id="$(swarm_task_id interpolar_cds_hub interpolar-cds_hub)" || return 1
        docker exec -i "${task_id}" "$@"
    else
        docker compose exec -T cds_hub "$@"
    fi
}

# Führt einen Befehl in der R-Umgebung aus.
# Aufruf: run_r_env [-v <host>:<container>[:ro]] ... [--] <cmd...>
# Compose: "docker compose run --rm --no-deps" mit eigenem Container.
# Swarm:   "docker exec" im laufenden r-env-Task; ad-hoc-Mounts sind dort
#          nicht möglich und werden mit einer Warnung übersprungen.
# Exit-Code 2 bei Fehlkonfiguration (kein Kommando, kein Swarm-Task).
run_r_env() {
    local volume_args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v)
                if [[ $# -lt 2 ]]; then
                    echo "Error: run_r_env: -v requires a volume specification." >&2
                    return 2
                fi
                volume_args+=(-v "$2")
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done
    if [[ $# -eq 0 ]]; then
        echo "Error: run_r_env: no command given." >&2
        return 2
    fi
    if [[ "${DOCKER_MODE}" == "swarm" ]]; then
        if [[ ${#volume_args[@]} -gt 0 && "${swarm_mount_warning_shown}" != "true" ]]; then
            swarm_mount_warning_shown=true
            echo "Warning: swarm mode cannot mount ad hoc volumes; configure mounts in the swarm stack instead." >&2
        fi
        local task_id
        task_id="$(swarm_task_id interpolar_r-env interpolar-r-env)" || return 2
        docker exec -i "${task_id}" "$@"
    else
        docker compose run --rm --no-deps ${volume_args[@]+"${volume_args[@]}"} r-env "$@"
    fi
}

# ========== Konfigurations-Helpers (TOML / Input-Repo) ==========
toml_file_value() {
    local file_path="$1"
    local key="$2"
    awk -F '=' -v key="$key" '
        $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
            value=$2
            sub(/#.*/, "", value)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            if (value ~ /^\[/) {
                sub(/^\[/, "", value)
                sub(/\]$/, "", value)
                split(value, value_parts, ",")
                value=value_parts[1]
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            }
            gsub(/^"|"$/, "", value)
            print value
            exit
        }
    ' "${file_path}"
}

toml_value() {
    local key="$1"
    toml_file_value cds_hub_db_config.toml "${key}"
}

input_repo_root_path() {
    local current_path="${1%/}"
    local parent_path
    while [[ "${current_path##*/}" != "Input-Repo" ]]; do
        parent_path="$(dirname "${current_path}")"
        if [[ "${parent_path}" == "${current_path}" ]]; then
            echo "Error: INPUT_REPO_PATH is not located within an Input-Repo directory: $1" >&2
            return 1
        fi
        current_path="${parent_path}"
    done
    printf '%s\n' "${current_path}"
}

container_input_repo_mount_args() {
    local input_repo_path
    local host_path
    local container_path
    input_repo_path="$(toml_file_value R-dataprocessor/dataprocessor_config.toml INPUT_REPO_PATH)"
    if [[ -z "${input_repo_path}" ]]; then
        return
    fi
    if [[ "${input_repo_path}" = /* ]]; then
        host_path="${input_repo_path}"
        container_path="${input_repo_path}"
    else
        host_path="${PWD}/${input_repo_path#./}"
        container_path="/src/${input_repo_path#./}"
    fi
    if [[ -d "${host_path}" ]]; then
        host_path="$(input_repo_root_path "${host_path}")" || return
        container_path="$(input_repo_root_path "${container_path}")" || return
        printf '%s\n' "-v"
        printf '%s\n' "${host_path}:${container_path}"
    fi
}

# ========== Datenbank-Helpers ==========
database_exists() {
    [[ "$(db_exec psql -U cds_hub_db_admin -d postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = '$1';" 2>/dev/null)" == "1" ]]
}

snapshot_file_checksum() {
    local snapshot_file="$1"
    if command -v sha256sum >/dev/null 2>&1 ; then
        sha256sum "${snapshot_file}" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1 ; then
        shasum -a 256 "${snapshot_file}" | awk '{print $1}'
    else
        echo "Error: sha256sum or shasum is required to verify the snapshot data." >&2
        return 1
    fi
}

# Gibt den Datenbank-Kommentar aus, der die Provenienz des Snapshots enthält.
database_snapshot_checksum() {
    local database_name="$1"
    db_exec psql -U cds_hub_db_admin -d postgres -tAc \
        "SELECT shobj_description(oid, 'pg_database') FROM pg_database WHERE datname = '${database_name}';"
}

# Speichert die Provenienz (SHA-256 der Snapshot-Datei) als Datenbank-Kommentar.
set_database_snapshot_checksum() {
    local database_name="$1"
    local checksum="$2"
    db_exec psql -U cds_hub_db_admin -d postgres -c \
        "COMMENT ON DATABASE \"${database_name}\" IS 'INTERPOLAR snapshot SHA-256: ${checksum}';"
}

# Prüft, ob eine Datenbank eindeutig zu einer Snapshot-Datei gehört.
database_matches_snapshot() {
    local database_name="$1"
    local checksum="$2"
    local database_comment
    database_comment="$(database_snapshot_checksum "${database_name}")"
    [[ "${database_comment}" == "INTERPOLAR snapshot SHA-256: ${checksum}" ]]
}

# Löscht eine Datenbank ohne Rückfrage, falls sie existiert.
# Wird für das Aufräumen unvollständiger "_build"-Datenbanken (Retry-Pfad)
# verwendet; interaktive Rückfragen gehören in den aufrufenden Flow.
drop_database_if_exists() {
    local database_name="$1"
    if database_exists "${database_name}"; then
        db_exec psql -U cds_hub_db_admin -d postgres \
            -c "DROP DATABASE \"${database_name}\" WITH (FORCE);"
    fi
}

# Rückfrage mit Default "Nein"; -y/--yes überspringt die Frage.
confirm() {
    local prompt="$1"
    if [[ "${assume_yes}" == "true" ]]; then
        return 0
    fi
    local answer=""
    read -r -p "${prompt} [y/N] " answer
    case "${answer}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

ask_before_overwrite_file() {
    local file_path="$1"
    if [[ -f "${file_path}" ]]; then
        echo "${file_path} already exists."
        if ! confirm "Overwrite \"${file_path}\"?"; then
            echo "Operation cancelled."
            exit 1
        fi
        echo "Overwriting \"${file_path}\" ..."
    fi
}

# ========== Analyse-Datenbanken (Pseudonymisierung / Broad Consent) ==========
# Entfernt eine unvollständige Analyse-Datenbank nach einem Fehler.
cleanup_failed_analysis_database() {
    local db_name="$1"
    local db_label="$2"
    if [[ -z "${db_name}" ]] || ! database_exists "${db_name}"; then
        return 0
    fi
    echo "Removing incomplete ${db_label} database '${db_name}'..."
    if ! drop_database_if_exists "${db_name}"; then
        echo "Error: ${db_label} database '${db_name}' could not be removed." >&2
        echo "Remove it manually before retrying." >&2
    fi
}

# Legt die Ziel-Datenbank einer Analyse an (Owner + Schemata db_log/db2dataprocessor_out).
# Bei Fehler wird die Ziel-DB aufgeräumt und mit dem aufgetretenen Exit-Code zurückgekehrt.
prepare_snapshot_analysis_target_database() {
    local target_db="$1"
    local db_label="$2"
    local db_dataprocessor_user
    db_dataprocessor_user="$(toml_value DB_DATAPROCESSOR_USER)"
    if [[ -z "${db_dataprocessor_user}" ]]; then
        echo "Error: CDS_TOOL_CHAIN_DB_DATAPROCESSOR_USER is not set in the cds_hub_db_config.toml." >&2
        return 1
    fi
    echo "Creating ${db_label} database \"${target_db}\""
    echo "Executing: db_exec psql -U cds_hub_db_admin -d postgres -c \"CREATE DATABASE ...\""
    if ! db_exec psql -U cds_hub_db_admin -d postgres \
        -c "CREATE DATABASE \"${target_db}\" WITH OWNER=${db_dataprocessor_user};"; then
        echo "Error: failed to create the ${db_label} database '${target_db}'." >&2
        return 1
    fi
    if ! db_exec psql -U cds_hub_db_admin -d "${target_db}" \
        -c "CREATE SCHEMA db_log AUTHORIZATION ${db_dataprocessor_user};
            CREATE SCHEMA db2dataprocessor_out AUTHORIZATION ${db_dataprocessor_user};"; then
        echo "Error: failed to create schemas db_log/db2dataprocessor_out on database '${target_db}'." >&2
        cleanup_failed_analysis_database "${target_db}" "${db_label}"
        return 1
    fi
}

# Exportiert eine Datenbank als gzip-komprimierten Dump in eine Datei.
# Bei Fehler oder leerer Datei wird die Datei aufgeräumt.
export_snapshot_database() {
    local build_db="$1"
    local file_path="$2"
    local progress_label="$3"
    local rc=0
    run_with_snapshot_progress "${progress_label}" "${build_db}" "" "${file_path}" \
        db_exec pg_dump -U cds_hub_db_admin -d "${build_db}" \
            --format=plain --compress=gzip > "${file_path}" || rc=$?
    if [[ ${rc} -ne 0 || ! -s "${file_path}" ]]; then
        if [[ -e "${file_path}" && ! -s "${file_path}" ]]; then
            echo "File ${file_path} exists but is empty; cleaning it up."
            rm -f -- "${file_path}"
        fi
        return 1
    fi
    echo "File \"${file_path}\" created."
    ls -ho "${file_path}"
}

# Setzt eine Datenbank auf read-only.
set_database_read_only() {
    local database_name="$1"
    db_exec psql -U cds_hub_db_admin -d postgres \
        -c "ALTER DATABASE \"${database_name}\" SET default_transaction_read_only=on;"
}

# Benennt eine Datenbank um (z. B. _build -> finaler Snapshot-Name).
rename_database() {
    local database_name="$1"
    local target_database_name="$2"
    db_exec psql -U cds_hub_db_admin -d postgres \
        -c "ALTER DATABASE \"${database_name}\" RENAME TO \"${target_database_name}\";"
}

# Prüft vor dem Snapshot-Erstellen die Vollständigkeit des Pseudonym-Mappings
# gegen die Live-Datenbank (R-Skript läuft über run_r_env mit Input-Repo-Mounts).
check_live_database_pseudonym_mapping() {
    local chunk_size="$1"

    if [[ "${with_pseudonymized}" != "true" ]]; then
        return
    fi

    local input_repo_mount_args=()
    while IFS= read -r mount_arg; do
        input_repo_mount_args+=("${mount_arg}")
    done < <(container_input_repo_mount_args)

    echo "Checking pseudonym mapping against the current database before creating the snapshot..."
    if ! run_with_snapshot_progress "Snapshot mapping check" cds_hub_db "" "" \
        run_r_env ${input_repo_mount_args[@]+"${input_repo_mount_args[@]}"} -- \
        Rscript R-cdstoolchain/StartSnapshotPseudonymization.R \
        source-db=cds_hub_db ; then
        echo "Fix the pseudonym mapping and run the create command again."
        echo "Continue afterwards with:"
        if [[ "${with_broad_consent}" == "true" ]]; then
            echo "  ./ip-snapshot.sh create ${name} --with-broad-consent --chunk-size ${chunk_size}"
        else
            echo "  ./ip-snapshot.sh create ${name} --with-pseudonymized --chunk-size ${chunk_size}"
        fi
        exit 1
    fi
    echo "Current database pseudonym mapping is complete."
}

# Erzeugt aus der Snapshot-Datei den pseudonymisierten Snapshot
# (Preflight, Restore der Quelle, Analyse-Run, Export, Provenienz).
create_pseudonymized_snapshot() {
    local snapshot_name="$1"
    local chunk_size="$2"
    local reuse_source_database="${3:-true}"
    local source_file_path="${DIR}/${snapshot_name}.sql.gz"
    local pseudonymized_snapshot_name="${snapshot_name}_pseud"
    local pseudonymized_file_path="${DIR}/${pseudonymized_snapshot_name}.sql.gz"
    local source_build_db="ip_${snapshot_name}_build"
    local target_build_db="ip_${pseudonymized_snapshot_name}_build"
    local source_database_name="ip_${snapshot_name}"
    local target_database_name="ip_${pseudonymized_snapshot_name}"

    if [[ ! -f "${source_file_path}" ]]; then
        echo "Error: snapshot \"${source_file_path}\" does not exist."
        exit 1
    fi

    local input_repo_mount_args=()
    while IFS= read -r mount_arg; do
        input_repo_mount_args+=("${mount_arg}")
    done < <(container_input_repo_mount_args)
    echo "Checking pseudonymization rules and mapping files..."
    if ! run_r_env ${input_repo_mount_args[@]+"${input_repo_mount_args[@]}"} -- \
        Rscript R-cdstoolchain/StartSnapshotPseudonymizationPreflight.R ; then
        echo "Continue afterwards with:"
        echo "  ./ip-snapshot.sh pseudonymize ${snapshot_name} --chunk-size ${chunk_size}"
        exit 1
    fi
    echo "Pseudonymization preflight completed."

    local source_file_checksum
    if ! source_file_checksum="$(snapshot_file_checksum "${source_file_path}")" ; then
        exit 1
    fi

    if database_exists "${target_database_name}" ; then
        echo "Error: pseudonymized snapshot database '${target_database_name}' already exists."
        echo "Deactivate it before running pseudonymization again."
        exit 1
    fi

    ask_before_overwrite_file "${pseudonymized_file_path}"
    local source_database="${source_build_db}"
    if [[ "${reuse_source_database}" == "true" ]]; then
        if database_exists "${source_database_name}" && database_exists "${source_build_db}" ; then
            echo "Error: both the snapshot database and the temporary source database exist:"
            echo "  ${source_database_name}"
            echo "  ${source_build_db}"
            echo "Remove the database that is not needed before retrying."
            exit 1
        fi
        if database_exists "${source_database_name}" ; then
            if database_matches_snapshot "${source_database_name}" "${source_file_checksum}" ; then
                source_database="${source_database_name}"
                echo "Reusing activated snapshot database '${source_database}'."
            else
                echo "Error: snapshot database '${source_database_name}' cannot be matched unambiguously to the snapshot file."
                echo "Deactivate it before retrying."
                exit 1
            fi
        elif database_exists "${source_build_db}" ; then
            if database_matches_snapshot "${source_build_db}" "${source_file_checksum}" ; then
                echo "Reusing fully restored temporary source database '${source_build_db}'."
            else
                echo "Error: temporary source database '${source_build_db}' cannot be matched unambiguously to the snapshot file."
                echo "Remove it before retrying."
                exit 1
            fi
        fi
    else
        if database_exists "${source_database_name}" ; then
            echo "Error: snapshot database '${source_database_name}' is already activated."
            echo "Deactivate it before starting a complete new snapshot run."
            exit 1
        fi
        if database_exists "${source_build_db}" ; then
            echo "Removing existing temporary source database '${source_build_db}' for the complete new snapshot run..."
            if ! drop_database_if_exists "${source_build_db}" ; then
                echo "Error: temporary source database '${source_build_db}' could not be removed."
                exit 1
            fi
        fi
    fi
    if database_exists "${target_build_db}" ; then
        echo "Removing incomplete target database '${target_build_db}' before restarting..."
        if ! drop_database_if_exists "${target_build_db}" ; then
            echo "Error: temporary target database '${target_build_db}' could not be removed."
            exit 1
        fi
    fi

    SECONDS=0
    if ! database_exists "${source_database}" ; then
        echo "Creating temporary source database '${source_build_db}'..."
        db_exec psql -U cds_hub_db_admin -d postgres -c \
            "CREATE DATABASE \"${source_build_db}\" WITH OWNER=cds_hub_db_admin;"
        if gzip -cd "${source_file_path}" | db_exec psql -U cds_hub_db_admin -d "${source_build_db}" ; then
            echo "Temporary source database '${source_build_db}' restored."
            if ! set_database_snapshot_checksum "${source_build_db}" "${source_file_checksum}" ; then
                echo "Error: source database provenance could not be recorded."
                exit 1
            fi
        else
            echo "Error: restoring temporary source database '${source_build_db}' failed."
            echo "Removing the incompletely restored source database..."
            if ! drop_database_if_exists "${source_build_db}" ; then
                echo "Error: incomplete source database '${source_build_db}' could not be removed."
                echo "Remove it manually before retrying."
            fi
            exit 1
        fi
    fi

    echo "Creating empty temporary target database '${target_build_db}'..."
    if ! prepare_snapshot_analysis_target_database "${target_build_db}" "temporary target" ; then
        echo "Error: creating temporary target database '${target_build_db}' failed."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        echo "The source database remains available for continuing:"
        echo "  ${source_database}"
        exit 1
    fi

    local consent_mount_args=()
    if [[ -f "R-cdstoolchain/consent_config.toml" ]]; then
        consent_mount_args=(-v "${PWD}/R-cdstoolchain/consent_config.toml:/src/R-cdstoolchain/consent_config.toml:ro")
    fi
    echo "Starting pseudonymization from '${source_database}' to '${target_build_db}'..."
    if run_with_snapshot_progress "Snapshot pseudonymization" "${source_database}" "${target_build_db}" "" \
        run_r_env ${input_repo_mount_args[@]+"${input_repo_mount_args[@]}"} \
            ${consent_mount_args[@]+"${consent_mount_args[@]}"} -- \
        Rscript R-cdstoolchain/StartSnapshotPseudonymization.R \
        source-db="${source_database}" \
        target-db="${target_build_db}" \
        chunk-size="${chunk_size}" ; then
        echo "Pseudonymization completed."
    else
        echo "Error: pseudonymization failed."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        echo "The source database remains available for continuing:"
        echo "  ${source_database}"
        echo
        echo "After fixing the error, continue with:"
        echo "  ./ip-snapshot.sh pseudonymize ${snapshot_name} --chunk-size ${chunk_size}"
        exit 1
    fi

    echo "Creating pseudonymized snapshot '${pseudonymized_file_path}'..."
    if ! export_snapshot_database "${target_build_db}" "${pseudonymized_file_path}" "Pseudonymized snapshot export" ; then
        echo "Error: creating the pseudonymized snapshot failed."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        echo "The source database remains available for continuing:"
        echo "  ${source_database}"
        exit 1
    fi

    local pseudonymized_file_checksum
    if ! pseudonymized_file_checksum="$(snapshot_file_checksum "${pseudonymized_file_path}")" ; then
        echo "Error: pseudonymized snapshot file provenance could not be determined."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        exit 1
    fi
    if ! set_database_snapshot_checksum "${target_build_db}" "${pseudonymized_file_checksum}" ; then
        echo "Error: pseudonymized database provenance could not be recorded."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        exit 1
    fi

    if [[ "${source_database}" == "${source_build_db}" ]]; then
        if ! set_database_read_only "${source_build_db}" ||
            ! rename_database "${source_build_db}" "${source_database_name}" ; then
            echo "Error: source database could not be retained as a snapshot database."
            cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
            exit 1
        fi
        source_database="${source_database_name}"
    elif ! set_database_read_only "${source_database}" ; then
        echo "Error: source database could not be set to read-only mode."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        exit 1
    fi

    if ! set_database_read_only "${target_build_db}" ||
        ! rename_database "${target_build_db}" "${target_database_name}" ; then
        echo "Error: pseudonymized target database could not be retained as a snapshot database."
        cleanup_failed_analysis_database "${target_build_db}" "pseudonymized target"
        exit 1
    fi

    printf "Pseudonymization duration: %s s\n" "$SECONDS"
    echo "The following read-only snapshot databases remain available in the 'cds_hub' Docker service:"
    echo "  ${source_database}"
    echo "  ${target_database_name}"
    echo
    echo "To remove the databases:"
    echo "  ./ip-snapshot.sh deactivate ${snapshot_name}"
    echo "  ./ip-snapshot.sh deactivate ${pseudonymized_snapshot_name}"
    echo
    echo "The snapshot files remain available."
    echo
    echo "======================================================================"
    echo "WARNING: Check the pseudonymization issue report for data issues:"
    echo "  outputLocal/snapshot_pseudonymization/reports/snapshot_pseudonymization_issues.xlsx"
    echo "======================================================================"
}

# Erzeugt aus einer aktivierten pseudonymisierten Snapshot-Datenbank
# den Broad-Consent-Snapshot (Auswahl per R-Skript, Export, Provenienz).
create_broad_consent_snapshot() {
    local snapshot_name="$1"
    local chunk_size="$2"
    local source_database_name="ip_${snapshot_name}"
    local broad_consent_snapshot_name="${snapshot_name}_broad_consent"
    local broad_consent_file_path="${DIR}/${broad_consent_snapshot_name}.sql.gz"
    local target_build_db="ip_${broad_consent_snapshot_name}_build"
    local target_database_name="ip_${broad_consent_snapshot_name}"

    if ! database_exists "${source_database_name}" ; then
        echo "Error: source snapshot database '${source_database_name}' is not activated."
        echo "Activate or create it before creating the Broad Consent snapshot."
        exit 1
    fi
    if database_exists "${target_database_name}" ; then
        echo "Error: Broad Consent snapshot database '${target_database_name}' already exists."
        echo "Deactivate it before creating the Broad Consent snapshot again."
        exit 1
    fi

    ask_before_overwrite_file "${broad_consent_file_path}"
    if database_exists "${target_build_db}" ; then
        echo "Removing incomplete Broad Consent target database '${target_build_db}' before restarting..."
        if ! drop_database_if_exists "${target_build_db}" ; then
            echo "Error: incomplete Broad Consent target database '${target_build_db}' could not be removed."
            exit 1
        fi
    fi

    SECONDS=0
    echo "Creating empty Broad Consent target database '${target_build_db}'..."
    if ! prepare_snapshot_analysis_target_database "${target_build_db}" "Broad Consent target" ; then
        echo "Error: creating Broad Consent target database '${target_build_db}' failed."
        cleanup_failed_analysis_database "${target_build_db}" "Broad Consent target"
        exit 1
    fi

    echo "Creating Broad Consent snapshot data from '${source_database_name}'..."
    if run_with_snapshot_progress "Broad Consent snapshot selection" "${source_database_name}" "${target_build_db}" "" \
        run_r_env -- \
        Rscript R-cdstoolchain/StartBroadConsentSnapshot.R \
        source-db="${source_database_name}" \
        target-db="${target_build_db}" \
        chunk-size="${chunk_size}" consent-details="${consent_details}" ; then
        echo "Broad Consent snapshot data created."
    else
        echo "Error: creating Broad Consent snapshot data failed."
        cleanup_failed_analysis_database "${target_build_db}" "Broad Consent target"
        exit 1
    fi

    echo "Creating Broad Consent snapshot file '${broad_consent_file_path}'..."
    if ! export_snapshot_database "${target_build_db}" "${broad_consent_file_path}" "Broad Consent snapshot export" ; then
        echo "Error: creating the Broad Consent snapshot file failed."
        cleanup_failed_analysis_database "${target_build_db}" "Broad Consent target"
        exit 1
    fi

    local broad_consent_file_checksum
    if ! broad_consent_file_checksum="$(snapshot_file_checksum "${broad_consent_file_path}")" ; then
        echo "Error: Broad Consent snapshot file provenance could not be determined."
        cleanup_failed_analysis_database "${target_build_db}" "Broad Consent target"
        exit 1
    fi
    if ! set_database_snapshot_checksum "${target_build_db}" "${broad_consent_file_checksum}" ; then
        echo "Error: Broad Consent snapshot database provenance could not be recorded."
        cleanup_failed_analysis_database "${target_build_db}" "Broad Consent target"
        exit 1
    fi
    if ! set_database_read_only "${target_build_db}" ||
        ! rename_database "${target_build_db}" "${target_database_name}" ; then
        echo "Error: Broad Consent target database could not be retained as a snapshot database."
        cleanup_failed_analysis_database "${target_build_db}" "Broad Consent target"
        exit 1
    fi

    printf "Broad Consent snapshot duration: %s s\n" "$SECONDS"
    echo "The read-only Broad Consent snapshot database remains available:"
    echo "  ${target_database_name}"
    echo
    echo "To remove the database:"
    echo "  ./ip-snapshot.sh deactivate ${broad_consent_snapshot_name}"
    echo
}

# Ruft die angeforderten Snapshot-Derivate laut Optionen auf.
create_requested_snapshot_derivatives() {
    local snapshot_name="$1"
    local chunk_size="$2"
    local reuse_source_database="$3"

    if [[ "${with_pseudonymized}" == "true" ]]; then
        create_pseudonymized_snapshot \
            "${snapshot_name}" \
            "${chunk_size}" \
            "${reuse_source_database}"
    fi
    if [[ "${with_broad_consent}" == "true" ]]; then
        create_broad_consent_snapshot \
            "${snapshot_name}_pseud" \
            "${chunk_size}"
    fi
}

# ---------- Eingaben prüfen ----------
# Original-Argumente merken, damit --docker-mode an jeder Stelle stehen kann.
original_args=("$@")
args=()

# Erster Durchlauf: --docker-mode, -y/--yes und -h/--help überall extrahieren.
i=0
while [[ $i -lt $# ]]; do
    case "${original_args[$i]}" in
        --docker-mode)
            if [[ $((i + 1)) -ge $# ]] || ! [[ "${original_args[$((i + 1))]}" =~ ^(compose|swarm)$ ]]; then
                echo "Error: --docker-mode expects 'compose' or 'swarm'." >&2
                exit 3
            fi
            docker_mode="${original_args[$((i + 1))]}"
            i=$((i + 2))
            ;;
        -y|--yes)
            assume_yes=true
            i=$((i + 1))
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            args+=("${original_args[$i]}")
            i=$((i + 1))
            ;;
    esac
done

set -- ${args[@]+"${args[@]}"}

action="${1:-}"
name="${2:-}"

if [[ -z "${action}" ]]; then
    print_usage
    exit 1
fi

# Zweiter Durchlauf: restliche Optionen nach Aktion und Name.
shift 2 2>/dev/null || shift "$#"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --docker-mode)
            if [[ $# -lt 2 || ! "$2" =~ ^(compose|swarm)$ ]]; then
                echo "Error: --docker-mode expects 'compose' or 'swarm'." >&2
                exit 3
            fi
            docker_mode="$2"
            shift 2
            ;;
        --with-pseudonymized)
            with_pseudonymized=true
            shift
            ;;
        --with-broad-consent)
            with_broad_consent=true
            with_pseudonymized=true
            shift
            ;;
        --consent-details)
            consent_details=true
            shift
            ;;
        --chunk-size)
            if [[ $# -lt 2 || ! "$2" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: --chunk-size expects a positive integer." >&2
                exit 3
            fi
            chunk_size="$2"
            chunk_size_set=true
            shift 2
            ;;
        -y|--yes)
            assume_yes=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: unknown option \"$1\"." >&2
            exit 3
            ;;
    esac
done

# Docker-Modus konfigurieren
if [[ -n "${docker_mode}" ]]; then
    if ! validate_docker_mode "${docker_mode}"; then
        exit 3
    fi
    DOCKER_MODE="${docker_mode}"
else
    docker_mode="$(detect_docker_mode)"
    DOCKER_MODE="${docker_mode}"
    echo "Docker mode auto-detected: ${docker_mode}"
fi

if [[ "${consent_details}" == "true" && "${action}" != "create-broad-consent" && ! ( "${action}" == "create" && "${with_broad_consent}" == "true" ) ]]; then
    echo "Error: --consent-details requires create-broad-consent or create --with-broad-consent." >&2
    exit 3
fi

if [[ "${action}" == "create" ]]; then
    if [[ "${chunk_size_set}" == "true" && "${with_pseudonymized}" != "true" ]]; then
        echo "Error: --chunk-size requires --with-pseudonymized or --with-broad-consent." >&2
        exit 3
    fi
elif [[ "${action}" =~ ^(pseudonymize|create-broad-consent|review-broad-consent)$ ]]; then
    if [[ "${with_pseudonymized}" == "true" || "${with_broad_consent}" == "true" ]]; then
        echo "Error: --with-pseudonymized and --with-broad-consent are only allowed with \"create\"." >&2
        exit 3
    fi
elif [[ "${with_pseudonymized}" == "true" || "${with_broad_consent}" == "true" || "${chunk_size_set}" == "true" ]]; then
    echo "Error: snapshot processing options are not allowed with \"${action}\"." >&2
    exit 3
fi

# Nur einfache Dateinamen/DB-Namen zulassen, weil der Name auch in SQL-DB-Namen verwendet wird.
if [[ "${action}" =~ ^(create|pseudonymize|create-broad-consent|review-broad-consent|delete|activate|deactivate)$ && ! "${name}" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Error: the name may only contain letters, numbers, and underscores." >&2
    exit 2
fi

# Ziel-Datei (immer mit .sql.gz-Erweiterung)
file="${name}.sql.gz"

# Vollständiger Pfad zur Datei
file_path="${DIR}/${file}"

# SQL-Datenbanknamen werden doppelt quotiert, damit PostgreSQL die Großschreibung erhält.
# Name der Snapshot-Datenbank. Bei "deactivate" darf auch der vollständige,
# von "list" ausgegebene Datenbankname übergeben werden.
if [[ "${action}" == "deactivate" && "${name}" == ip_* ]]; then
    db_name="${name}"
else
    db_name="ip_${name}"
fi

# ---------- Aktionen ----------
case "${action}" in
    list)
        echo "Listing all snapshots in directory '${DIR}':"
        if find "${DIR}" -maxdepth 1 -type f -name '*.sql.gz' -print -quit | grep -q . ; then
            find "${DIR}" -maxdepth 1 -type f -name '*.sql.gz' -print | sort | while IFS= read -r snapshot_file; do
                snapshot_base="${snapshot_file##*/}"
                snapshot_name="${snapshot_base%.sql.gz}"
                snapshot_size_kb="$(du -k "${snapshot_file}" | awk '{print $1}')"
                printf '%s\t%sKB\n' "${snapshot_name}" "${snapshot_size_kb}"
            done
        else
            echo "No snapshots found in directory ${DIR}."
        fi
        echo "---"
        echo "Listing all activated snapshot databases:"
        if ! db_exec psql -U cds_hub_db_admin -d postgres -c "
            SELECT   d.datname                                    AS database,
                     pg_size_pretty(pg_database_size(d.datname))  AS size
            FROM pg_database d
            WHERE d.datname LIKE 'ip\_%'   -- Escape-Unterstrich, weil _ ein Wildcard-Zeichen ist
            ORDER BY pg_database_size(d.datname) DESC;" ; then
            echo "No activated snapshot databases found."
        fi
        ;;

    create)
        # Ziel-Datei mit Datum
        file_date="${name}_$(date +%Y%m%d).sql.gz"
        snapshot_name_date="${name}_$(date +%Y%m%d)"
        # Vollständiger Pfad zur Datei mit Datum
        file_date_path="${DIR}/${file_date}"

        if [[ -e "${file_date_path}" ]]; then
            echo "Note: snapshot \"${file_date_path}\" already exists."
            if ! confirm "Overwrite file \"${file_date_path}\"?"; then
                echo "Snapshot creation cancelled for \"${file_date_path}\"."
                exit 1
            fi
            echo "Overwriting snapshot \"${file_date_path}\"..."
        fi

        # Snapshot erstellen
        snapshot_started_at=$(date +%s)
        SECONDS=0
        check_live_database_pseudonym_mapping "${chunk_size}"
        if run_with_snapshot_progress "Snapshot export" cds_hub_db "" "${file_date_path}" \
            db_exec pg_dump -U cds_hub_db_admin -d cds_hub_db --format=plain --exclude-extension=pg_cron --exclude-table=db_config.v_cron_jobs --exclude-table='*.*_raw*' --compress=gzip > "${file_date_path}"; then
            echo "File \"${file_date_path}\" created."
            ls -ho "${file_date_path}"
        else
            echo "Error: creating snapshot file \"${file_date_path}\" failed."
            # Cleanup
            if [[ -e "${file_date_path}" && ! -s "${file_date_path}" ]]; then
                echo "File ${file_date_path} exists but is empty; cleaning it up."
                rm -f "${file_date_path}"
            fi
            exit 1
        fi
        printf "Duration: %s s\n" "${SECONDS}"

        create_requested_snapshot_derivatives \
            "${snapshot_name_date}" \
            "${chunk_size}" \
            false
        printf "Total snapshot duration: %s s\n" "$(( $(date +%s) - snapshot_started_at ))"
        ;;

    pseudonymize)
        create_pseudonymized_snapshot "${name}" "${chunk_size}"
        ;;

    review-broad-consent)
        if ! database_exists "ip_${name}" ; then
            echo "Error: source snapshot database 'ip_${name}' is not activated." >&2
            exit 1
        fi
        run_r_env -- \
            Rscript R-cdstoolchain/StartBroadConsentSnapshot.R \
            source-db="ip_${name}" review-only=true chunk-size="${chunk_size}"
        ;;
    create-broad-consent)
        create_broad_consent_snapshot "${name}" "${chunk_size}"
        ;;

    delete)
        # Existenz- und Typ-Prüfung
        if [[ ! -f "${file_path}" ]]; then
            if [[ "${name}" == ip_* ]]; then
                snapshot_file_name="${name#ip_}"
                echo "Error: \"${name}\" is a snapshot database name, not a snapshot file name." >&2
                echo "The \"delete\" action only deletes snapshot files and expects the name without the \"ip_\" prefix." >&2
                echo "To delete the snapshot file, run: $0 delete ${snapshot_file_name}" >&2
                exit 1
            fi
            echo "Error: snapshot \"${file}\" does not exist or is not a regular file."
            exit 1
        fi

        # Rückfrage vor dem Löschen
        if confirm "Delete file \"${file_path}\"?"; then
            if rm "${file_path}"; then
                echo "Snapshot \"${file_path}\" deleted."
            else
                echo "Error: could not delete \"${file_path}\"." >&2
            fi
        else
            echo "Deletion cancelled."
        fi
        ;;

    activate)
        if [[ -e "${file_path}" ]]; then
            echo "Snapshot file \"${file_path}\" found."

            if database_exists "${db_name}" ; then
                echo "Error: snapshot database '${db_name}' already exists."
                exit 1
            fi

            logfile="${file_path}_activate_$(date +%Y%m%d-%H%M%S).log"
            SECONDS=0

            # Snapshot-Datenbank anlegen
            if db_exec psql -U cds_hub_db_admin -d postgres -c "CREATE DATABASE \"${db_name}\" WITH OWNER=cds_hub_db_admin;" > "${logfile}" 2>&1 ; then
                echo "Snapshot database '${db_name}' created."
            else
                echo "Error: creating snapshot database '${db_name}' failed."
                exit 1
            fi

            # Snapshot-Datei in zuvor angelegte Snapshot-Datenbank einspielen
            if gzip -cd "${file_path}" | db_exec psql -U cds_hub_db_admin -d "${db_name}" >> "${logfile}" 2>&1 ; then
                echo "Snapshot database '${db_name}' restored."
                if ! snapshot_checksum="$(snapshot_file_checksum "${file_path}")" ; then
                    exit 1
                fi
                if ! set_database_snapshot_checksum "${db_name}" "${snapshot_checksum}" >> "${logfile}" 2>&1 ; then
                    echo "Error: snapshot database '${db_name}' provenance could not be recorded."
                    exit 1
                fi
                if set_database_read_only "${db_name}" >> "${logfile}" 2>&1 ; then
                    echo "Snapshot database '${db_name}' set to read-only mode."
                else
                    echo "Error: setting snapshot database '${db_name}' to read-only mode failed."
                    exit 1
                fi
            else
                echo "Error: restoring snapshot database '${db_name}' failed."
                exit 1
            fi

        else
            echo "Error: snapshot \"${file_path}\" does not exist."
            exit 1
        fi
        printf "Duration: %s s\n" "${SECONDS}"
        ;;

    deactivate)
        if database_exists "${db_name}" ; then
            echo "Snapshot database '${db_name}' is activated."
            if confirm "Deactivate snapshot database \"${db_name}\"? The snapshot file will remain available."; then
                if db_exec psql -U cds_hub_db_admin -d postgres -c "DROP DATABASE \"${db_name}\" WITH (FORCE);" ; then
                    echo "Snapshot database \"${db_name}\" deactivated."
                else
                    echo "Error: snapshot database \"${db_name}\" could not be deactivated." >&2
                fi
            else
                echo "Deactivation cancelled."
            fi
        else
            echo "Error: snapshot database '${db_name}' is not activated."
            exit 1
        fi
        ;;
    *)
        echo "Error: unknown action \"${action}\". Allowed actions are \"create\", \"pseudonymize\", \"create-broad-consent\", \"review-broad-consent\", \"list\", \"activate\", \"deactivate\", and \"delete\"." >&2
        print_usage
        exit 3
        ;;
esac

exit 0
