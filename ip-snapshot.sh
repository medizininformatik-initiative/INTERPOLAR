#!/usr/bin/env bash
set -o pipefail
#====================================================================
#  script‑name : ip-snapshot.sh
#  Zweck      : Erzeugt oder löscht eine Datei, deren Name als
#               Argument übergeben wird.
#
#  Aufruf:
#      ./ip-snapshot.sh list
#      ./ip-snapshot.sh create  <name> [--with-pseudonymized] [--chunk-size <rows>]
#      ./ip-snapshot.sh pseudonymize  <name_date> [--chunk-size <rows>]
#      ./ip-snapshot.sh delete  <name_date>
#      ./ip-snapshot.sh activate  <name_date>
#      ./ip-snapshot.sh deactivate  <name_date>|ip_<name_date>
#
#  Hinweis: Der Dateiname darf **keine** Pfadangaben (/, ..) enthalten,
#           sonst wird das Skript mit einer Fehlermeldung beendet.
#====================================================================

# ---------- Hilfetext ----------
print_usage() {
    cat <<EOF
Usage: ${0##*/} <action> <name>

  <action>   "list"        – lists all snapshots
             "create"      – creates a snapshot <name>.sql.gz
             "pseudonymize" – creates a pseudonymized snapshot <name_date>_pseud.sql.gz
             "delete"      – deletes a snapshot <name_date>.sql.gz
             "activate"    – activates a snapshot <name_date>.sql.gz by creating a database for it
             "deactivate"  – deactivates a snapshot database; accepts <name_date> and the
                              ip_<name_date> name printed by "list"

  <name>     any string without path components, <name> | <name_date>
  --with-pseudonymized
             only for "create": also creates <name_date>_pseud.sql.gz
  --chunk-size <rows>
             only for "pseudonymize" or "create --with-pseudonymized":
             number of rows read per processing chunk (default: 25000)

Examples:
  $0 list                            → lists all .sql.gz files without extensions in Snapshots
  $0 create  snapshot                → creates snapshot_<date>.sql.gz
  $0 create  snapshot --with-pseudonymized
                                      → creates snapshot_<date>.sql.gz and snapshot_<date>_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 → creates snapshot_20250929_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 --chunk-size 10000
                                      → processes at most 10000 rows per chunk
  $0 delete  snapshot_20250929       → deletes snapshot_20250929.sql.gz
  $0 activate  snapshot_20250929     → creates database 'ip_snapshot_20250929'
  $0 deactivate  snapshot_20250929   → drops database 'ip_snapshot_20250929'
  $0 deactivate  ip_snapshot_20250929
                                      → drops the same database
EOF
}

# ---------- Eingaben prüfen ----------
#if [[ $# -lt 1 ]]; then
#    echo "Error: at least one argument is required." >&2
#    print_usage
#    exit 1
#fi


action=$1
name=$2
DIR=Snapshots
with_pseudonymized=false
chunk_size=25000
chunk_size_set=false

if [[ -z "$action" ]]; then
    print_usage
    exit 1
fi

if [[ $# -ge 2 ]]; then
    shift 2
else
    shift "$#"
fi
while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-pseudonymized)
            with_pseudonymized=true
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
        *)
            echo "Error: unknown option \"$1\"." >&2
            exit 3
            ;;
    esac
done

if [[ "$action" == "create" ]]; then
    if [[ "$chunk_size_set" == "true" && "$with_pseudonymized" != "true" ]]; then
        echo "Error: --chunk-size requires --with-pseudonymized." >&2
        exit 3
    fi
elif [[ "$action" == "pseudonymize" ]]; then
    if [[ "$with_pseudonymized" == "true" ]]; then
        echo "Error: --with-pseudonymized is only allowed with \"create\"." >&2
        exit 3
    fi
elif [[ "$with_pseudonymized" == "true" || "$chunk_size_set" == "true" ]]; then
    echo "Error: pseudonymization options are not allowed with \"$action\"." >&2
    exit 3
fi

# Nur einfache Dateinamen/DB-Namen zulassen, weil der Name auch in SQL-DB-Namen verwendet wird.
if [[ "$action" =~ ^(create|pseudonymize|delete|activate|deactivate)$ && ! "$name" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Error: the name may only contain letters, numbers, and underscores." >&2
    exit 2
fi

# Ziel‑Datei (immer mit .sql.gz‑Erweiterung)
file="${name}.sql.gz"

# Vollständiger Pfad zur Datei
file_path="${DIR}/${file}"

# Name der Snapshot-Datenbank. Bei "deactivate" darf auch der vollständige,
# von "list" ausgegebene Datenbankname übergeben werden.
if [[ "$action" == "deactivate" && "$name" == ip_* ]]; then
    db_name="$name"
else
    db_name="ip_${name}"
fi

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
        printf '%s\n' "-v"
        printf '%s\n' "${host_path}:${container_path}"
    fi
}

database_exists() {
    local database_name="$1"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = '${database_name}';" | grep -q 1
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

database_snapshot_checksum() {
    local database_name="$1"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -tAc \
        "SELECT shobj_description(oid, 'pg_database') FROM pg_database WHERE datname = '${database_name}';"
}

set_database_snapshot_checksum() {
    local database_name="$1"
    local checksum="$2"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
        "COMMENT ON DATABASE ${database_name} IS 'INTERPOLAR snapshot SHA-256: ${checksum}';"
}

database_matches_snapshot() {
    local database_name="$1"
    local checksum="$2"
    local database_comment
    database_comment="$(database_snapshot_checksum "${database_name}")"
    [[ "${database_comment}" == "INTERPOLAR snapshot SHA-256: ${checksum}" ]]
}

set_database_read_only() {
    local database_name="$1"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
        "ALTER DATABASE ${database_name} SET default_transaction_read_only=on;"
}

rename_database() {
    local database_name="$1"
    local target_database_name="$2"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
        "ALTER DATABASE ${database_name} RENAME TO ${target_database_name};"
}

drop_database_if_exists() {
    local database_name="$1"
    if database_exists "${database_name}" ; then
        docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
            "DROP DATABASE ${database_name} WITH (FORCE);"
    fi
}

cleanup_failed_pseudonymized_database() {
    local target_database_name="$1"
    if ! database_exists "${target_database_name}" ; then
        return
    fi
    echo "Removing incomplete pseudonymized target database '${target_database_name}'..."
    if ! drop_database_if_exists "${target_database_name}" ; then
        echo "Error: target database '${target_database_name}' could not be removed." >&2
        echo "Remove it manually before retrying." >&2
    fi
}

ask_before_overwrite_file() {
    local target_file="$1"
    if [[ -e "$target_file" ]]; then
        echo "Note: file \"$target_file\" already exists."
        while true; do
            read -rp "Overwrite file \"$target_file\"? [y/N] " answer
            case "$answer" in
                [Yy]* )
                    echo "Overwriting file \"$target_file\"..."
                    break
                    ;;
                [Nn]*|"" )
                    echo "Operation cancelled."
                    exit 1
                    ;;
                * )
                    echo "Please answer 'y' or 'n'."
                    ;;
            esac
        done
    fi
}

prepare_pseudonymized_target_database() {
    local target_database_name="$1"
    local dataprocessor_user
    dataprocessor_user="$(toml_value DB_DATAPROCESSOR_USER)"

    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
        "CREATE DATABASE ${target_database_name} WITH OWNER=${dataprocessor_user};"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d "${target_database_name}" -c \
        "CREATE SCHEMA db_log AUTHORIZATION ${dataprocessor_user};
         CREATE SCHEMA db2dataprocessor_out AUTHORIZATION ${dataprocessor_user};"
}

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
    if ! docker compose run --rm --no-deps "${input_repo_mount_args[@]}" r-env \
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
        docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
            "CREATE DATABASE ${source_build_db} WITH OWNER=cds_hub_db_admin;"
        if gzip -cd "${source_file_path}" | docker compose exec -T cds_hub \
            psql -d "${source_build_db}" cds_hub_db_admin ; then
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

    echo "Checking database values and pseudonym mapping..."
    if ! docker compose run --rm --no-deps "${input_repo_mount_args[@]}" r-env \
        Rscript R-cdstoolchain/StartSnapshotPseudonymization.R \
        source-db="${source_database}" ; then
        cleanup_failed_pseudonymized_database "${target_build_db}"
        echo "The fully restored source database remains available for continuing:"
        echo "  ${source_database}"
        echo
        echo "Continue afterwards with:"
        echo "  ./ip-snapshot.sh pseudonymize ${snapshot_name} --chunk-size ${chunk_size}"
        exit 1
    fi
    echo "Database values and pseudonym mapping are complete."

    echo "Creating empty temporary target database '${target_build_db}'..."
    if ! prepare_pseudonymized_target_database "${target_build_db}" ; then
        echo "Error: creating temporary target database '${target_build_db}' failed."
        cleanup_failed_pseudonymized_database "${target_build_db}"
        echo "The source database remains available for continuing:"
        echo "  ${source_database}"
        exit 1
    fi

    echo "Starting pseudonymization from '${source_database}' to '${target_build_db}'..."
    if docker compose run --rm --no-deps "${input_repo_mount_args[@]}" r-env \
        Rscript R-cdstoolchain/StartSnapshotPseudonymization.R \
        source-db="${source_database}" \
        target-db="${target_build_db}" \
        chunk-size="${chunk_size}" ; then
        echo "Pseudonymization completed."
    else
        echo "Error: pseudonymization failed."
        cleanup_failed_pseudonymized_database "${target_build_db}"
        echo "The source database remains available for continuing:"
        echo "  ${source_database}"
        echo
        echo "After fixing the error, continue with:"
        echo "  ./ip-snapshot.sh pseudonymize ${snapshot_name} --chunk-size ${chunk_size}"
        exit 1
    fi

    echo "Creating pseudonymized snapshot '${pseudonymized_file_path}'..."
    if docker compose exec cds_hub pg_dump -U cds_hub_db_admin -d "${target_build_db}" \
        --format=plain --compress=gzip > "${pseudonymized_file_path}" ; then
        echo "File \"${pseudonymized_file_path}\" created."
        ls -ho "${pseudonymized_file_path}"
    else
        echo "Error: creating the pseudonymized snapshot failed."
        if [[ -e "${pseudonymized_file_path}" && ! -s "${pseudonymized_file_path}" ]]; then
            echo "File ${pseudonymized_file_path} exists but is empty; cleaning it up."
            rm -f "${pseudonymized_file_path}"
        fi
        cleanup_failed_pseudonymized_database "${target_build_db}"
        echo "The source database remains available for continuing:"
        echo "  ${source_database}"
        exit 1
    fi

    local pseudonymized_file_checksum
    if ! pseudonymized_file_checksum="$(snapshot_file_checksum "${pseudonymized_file_path}")" ; then
        echo "Error: pseudonymized snapshot file provenance could not be determined."
        cleanup_failed_pseudonymized_database "${target_build_db}"
        exit 1
    fi
    if ! set_database_snapshot_checksum "${target_build_db}" "${pseudonymized_file_checksum}" ; then
        echo "Error: pseudonymized database provenance could not be recorded."
        cleanup_failed_pseudonymized_database "${target_build_db}"
        exit 1
    fi

    if [[ "${source_database}" == "${source_build_db}" ]]; then
        if ! set_database_read_only "${source_build_db}" ||
            ! rename_database "${source_build_db}" "${source_database_name}" ; then
            echo "Error: source database could not be retained as a snapshot database."
            cleanup_failed_pseudonymized_database "${target_build_db}"
            exit 1
        fi
        source_database="${source_database_name}"
    elif ! set_database_read_only "${source_database}" ; then
        echo "Error: source database could not be set to read-only mode."
        cleanup_failed_pseudonymized_database "${target_build_db}"
        exit 1
    fi

    if ! set_database_read_only "${target_build_db}" ||
        ! rename_database "${target_build_db}" "${target_database_name}" ; then
        echo "Error: pseudonymized target database could not be retained as a snapshot database."
        cleanup_failed_pseudonymized_database "${target_build_db}"
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


# ---------- Aktionen ----------
case "$action" in
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
        if ! docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "
            SELECT   d.datname                                    AS database,
                     pg_size_pretty(pg_database_size(d.datname))  AS size
            FROM pg_database d
            WHERE d.datname LIKE 'ip\_%'   -- Escape-Unterstrich, weil _ ein Wildcard-Zeichen ist
            ORDER BY pg_database_size(d.datname) DESC;" ; then
            echo "No activated snapshot databases found."
        fi
        ;;

    create)
        # Ziel‑Datei mit Datum
        file_date="${name}_$(date +%Y%m%d).sql.gz"
        snapshot_name_date="${name}_$(date +%Y%m%d)"
        # Vollständiger Pfad zur Datei mit Datum
        file_date_path="${DIR}/${file_date}"


        if [[ -e "$file_date_path" ]]; then
            echo "Note: snapshot \"$file_date_path\" already exists."
            
            # ------------------------------------------------------------
            # 2. Rückfrage an den Benutzer
            # ------------------------------------------------------------
            while true; do
                read -rp "Overwrite file \"$file_date_path\"? [y/N] " answer
                case "$answer" in
                    [Yy]* )
                        # ------------------------------------------------
                        # 3. JA, überschreiben -> weiter im Script
                        # ------------------------------------------------
                        echo "Overwriting snapshot \"$file_date_path\"..."
                        break
                        ;;
                    [Nn]*|"" )
                        echo "Snapshot creation cancelled for \"$file_date_path\"."
                        exit 1
                        ;;
                    * )
                        echo "Please answer 'y' or 'n'."
                        ;;
                esac
            done
        fi

        # Beispiel‑Inhalt: aktuelle Zeit + Hinweis
        #{
        #    echo "File \"$file_path\" created at $(date +"%Y-%m-%d %H:%M:%S")"
        #    echo "Created by $(whoami) on $(hostname)"
        #} > "$file_path"

        # Snapshot erstellen
        SECONDS=0;
        if docker compose exec cds_hub pg_dump -U cds_hub_db_admin -d cds_hub_db --format=plain --exclude-extension=pg_cron --exclude-table=db_config.v_cron_jobs --exclude-table='*.*_raw*' --compress=gzip > $file_date_path; then
            echo "File \"${file_date_path}\" created."
            ls -ho ${file_date_path}
        else
            echo "Error: creating snapshot file \"${file_date_path}\" failed."
            # cleanup
            if [[ -e "${file_date_path}" && ! -s "$file_date_path" ]]; then 
                echo "File ${file_date_path} exists but is empty; cleaning it up.";
                rm -rf ${file_date_path}
            fi
            exit 1
        fi
        printf "Duration: %s s\n" "$SECONDS";

        if [[ "${with_pseudonymized}" == "true" ]]; then
            create_pseudonymized_snapshot \
                "${snapshot_name_date}" \
                "${chunk_size}" \
                false
        fi
        ;;

    pseudonymize)
        create_pseudonymized_snapshot "${name}" "${chunk_size}"
        ;;

    delete)
        # ------------------------------------------------------------
        # 1. Existenz‑ und Typ‑Prüfung
        # ------------------------------------------------------------
        if [[ ! -f "$file_path" ]]; then
            echo "Error: snapshot \"$file\" does not exist or is not a regular file."
            # kein exit – das Skript läuft weiter
            # break
            exit 1
        fi

        # ------------------------------------------------------------
        # 2. Rückfrage an den Benutzer
        # ------------------------------------------------------------
        while true; do
            read -rp "Delete file \"$file_path\"? [y/N] " answer
            case "$answer" in
                [Yy]* )
                    # ------------------------------------------------
                    # 3. Löschen und Ergebnis prüfen
                    # ------------------------------------------------
                    if rm "$file_path"; then
                        echo "Snapshot \"$file_path\" deleted."
                    else
                        echo "Error: could not delete \"$file_path\"." >&2
                    fi
                    break
                    ;;
                [Nn]*|"" )
                    echo "Deletion cancelled."
                    break
                    ;;
                * )
                    echo "Please answer 'y' or 'n'."
                    ;;
            esac
        done
        ;;

    activate)
        if [[ -e "${file_path}" ]]; then
            echo "Snapshot file \"${file_path}\" found."

            if database_exists "${db_name}" ; then
                echo "Error: snapshot database '${db_name}' already exists."
                exit 1
            fi

            logfile="${file_path}_activate_$(date +%Y%m%d-%H%M%S).log"
            SECONDS=0;

            # Snapshot-Datenbank anlegen
            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "CREATE DATABASE ${db_name} WITH OWNER=cds_hub_db_admin;" > "${logfile}" 2>&1 ; then
                echo "Snapshot database '${db_name}' created."
            else
                echo "Error: creating snapshot database '${db_name}' failed."
                exit 1
            fi

            # Snapshot-Datei in zuvor angelegte Snapshot-Datenbank einspielen
            if gzip -cd "${file_path}" | docker compose exec -T cds_hub psql -d "${db_name}" cds_hub_db_admin >> "${logfile}" 2>&1 ; then
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
            echo "Error: snapshot \"$file_path\" does not exist."
            exit 1
        fi
        printf "Duration: %s s\n" "$SECONDS"
        ;;

    deactivate)
        #if [[ -e "${file_path}" ]]; then
        #    echo "Note: snapshot \"${file_path}\" exists."

            if database_exists "${db_name}" ; then
                echo "Snapshot database '${db_name}' is activated."
                
                # ------------------------------------------------------------
                # 2. Rückfrage an den Benutzer
                # ------------------------------------------------------------
                while true; do
                    read -rp "Deactivate snapshot database \"${db_name}\"? The snapshot file will remain available. [y/N] " answer
                    case "$answer" in
                        [Yy]* )
                            # ------------------------------------------------
                            # 3. Snapshot-Datenbank deaktivieren und Ergebnis prüfen
                            # ------------------------------------------------
                            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "DROP DATABASE ${db_name} WITH (FORCE);" ; then
                                echo "Snapshot database \"${db_name}\" deactivated."
                            else
                                echo "Error: snapshot database \"${db_name}\" could not be deactivated." >&2
                            fi
                            break
                            ;;
                        [Nn]*|"" )
                            echo "Deactivation cancelled."
                            break
                            ;;
                        * )
                            echo "Please answer 'y' or 'n'."
                            ;;
                    esac
                done
            else
                echo "Error: snapshot database '${db_name}' is not activated."
                exit 1
            fi
            
        #else
        #    echo "Error: snapshot \"$file_path\" does not exist."
        #    exit 1
        #fi
        ;;
    *)
        echo "Error: unknown action \"$action\". Allowed actions are \"create\", \"pseudonymize\", \"list\", \"activate\", \"deactivate\", and \"delete\"." >&2
        print_usage
        exit 3
        ;;
esac

exit 0
