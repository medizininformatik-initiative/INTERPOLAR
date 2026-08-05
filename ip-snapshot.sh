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
#      ./ip-snapshot.sh deactivate  <name_date>
#
#  Hinweis: Der Dateiname darf **keine** Pfadangaben (/, ..) enthalten,
#           sonst wird das Skript mit einer Fehlermeldung beendet.
#====================================================================

# ---------- Hilfetext ----------
print_usage() {
    cat <<EOF
Usage: ${0##*/} <action> <name>

  <action>   \"list\"        – listet alle Snapshots auf
             \"create\"      – legt einen Snapshot <name>.sql.gz an
             \"pseudonymize\" – erzeugt einen pseudonymisierten Snapshot <name_date>_pseud.sql.gz
             \"delete\"      – löscht einen Snapshot <name_date>.sql.gz
             \"activate\"    – aktiviert einen Snapshot <name_date>.sql.gz, d.h. es wird eine Datenbank für diesen Snapshot angelegt.
             \"deactivate\"  – deaktiviert einen Snapshot <name_date>.sql.gz, d.h. die Datenbank für diesen Snapshot wird gelöscht.

  <name>     beliebiger String (ohne Pfad‑Komponenten), <name> | <name_date>
  --with-pseudonymized
             nur bei \"create\": erzeugt direkt zusätzlich <name_date>_pseud.sql.gz
  --chunk-size <rows>
             nur bei \"pseudonymize\" oder \"create --with-pseudonymized\":
             Anzahl der pro Verarbeitungsschritt gelesenen Zeilen (Standard: 25000)

Beispiele:
  $0 list                            → listet alle .sql.gz-Dateien (ohne Endung) im Ordner Snapshots auf
  $0 create  snapshot                → erzeugt  snapshot_<Datum>.sql.gz
  $0 create  snapshot --with-pseudonymized
                                      → erzeugt  snapshot_<Datum>.sql.gz und snapshot_<Datum>_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 → erzeugt  snapshot_20250929_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 --chunk-size 10000
                                      → verarbeitet höchstens 10000 Zeilen pro Block
  $0 delete  snapshot_20250929       → löscht   snapshot_20250929.sql.gz
  $0 activate  snapshot_20250929     → erstellt eine Datenbank 'snapshot_20250929'
  $0 deactivate  snapshot_20250929   → löscht die Datenbank 'snapshot_20250929'
EOF
}

# ---------- Eingaben prüfen ----------
#if [[ $# -lt 1 ]]; then
#    echo "Fehler: mind. 1 Argument erwartet." >&2
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
                echo "Fehler: --chunk-size erwartet eine positive ganze Zahl." >&2
                exit 3
            fi
            chunk_size="$2"
            chunk_size_set=true
            shift 2
            ;;
        *)
            echo "Fehler: unbekannte Option \"$1\"." >&2
            exit 3
            ;;
    esac
done

if [[ "$action" == "create" ]]; then
    if [[ "$chunk_size_set" == "true" && "$with_pseudonymized" != "true" ]]; then
        echo "Fehler: --chunk-size benötigt --with-pseudonymized." >&2
        exit 3
    fi
elif [[ "$action" == "pseudonymize" ]]; then
    if [[ "$with_pseudonymized" == "true" ]]; then
        echo "Fehler: --with-pseudonymized ist nur bei \"create\" erlaubt." >&2
        exit 3
    fi
elif [[ "$with_pseudonymized" == "true" || "$chunk_size_set" == "true" ]]; then
    echo "Fehler: Optionen zur Pseudonymisierung sind bei \"$action\" nicht erlaubt." >&2
    exit 3
fi

# Nur einfache Dateinamen/DB-Namen zulassen, weil der Name auch in SQL-DB-Namen verwendet wird.
if [[ "$action" =~ ^(create|pseudonymize|delete|activate|deactivate)$ && ! "$name" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Fehler: Der Name darf nur Buchstaben, Zahlen und Unterstriche enthalten." >&2
    exit 2
fi

# Ziel‑Datei (immer mit .sql.gz‑Erweiterung)
file="${name}.sql.gz"

# Vollständiger Pfad zur Datei
file_path="${DIR}/${file}"

# Name der Snapshot Datenbank
db_name="ip_${name}"

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
        echo "Fehler: Für die Prüfung des Datenstands wird sha256sum oder shasum benötigt." >&2
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

ask_before_overwrite_file() {
    local target_file="$1"
    if [[ -e "$target_file" ]]; then
        echo "Hinweis: Datei \"$target_file\" existiert bereits!"
        while true; do
            read -rp "Soll die Datei \"$target_file\" wirklich überschrieben werden? [y/N] " answer
            case "$answer" in
                [Yy]* )
                    echo "Datei \"$target_file\" wird überschrieben..."
                    break
                    ;;
                [Nn]*|"" )
                    echo "Vorgang abgebrochen."
                    exit 1
                    ;;
                * )
                    echo "Bitte mit 'y' (ja) oder 'n' (nein) antworten."
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
    local source_file_path="${DIR}/${snapshot_name}.sql.gz"
    local pseudonymized_snapshot_name="${snapshot_name}_pseud"
    local pseudonymized_file_path="${DIR}/${pseudonymized_snapshot_name}.sql.gz"
    local source_build_db="ip_${snapshot_name}_build"
    local target_build_db="ip_${pseudonymized_snapshot_name}_build"
    local source_database_name="ip_${snapshot_name}"
    local target_database_name="ip_${pseudonymized_snapshot_name}"

    if [[ ! -f "${source_file_path}" ]]; then
        echo "Fehler: Snapshot \"${source_file_path}\" existiert nicht."
        exit 1
    fi

    local input_repo_mount_args=()
    while IFS= read -r mount_arg; do
        input_repo_mount_args+=("${mount_arg}")
    done < <(container_input_repo_mount_args)
    echo "Prüfe Pseudonymisierungsregeln und Mapping-Dateien..."
    if ! docker compose run --rm --no-deps "${input_repo_mount_args[@]}" r-env \
        Rscript R-cdstoolchain/StartSnapshotPseudonymizationPreflight.R ; then
        echo "Fehler: Vorprüfung der Pseudonymisierung fehlgeschlagen."
        echo "Der Snapshot wurde nicht eingespielt und es wurden keine Build-Datenbanken angelegt."
        exit 1
    fi
    echo "Vorprüfung der Pseudonymisierung abgeschlossen."

    local source_file_checksum
    if ! source_file_checksum="$(snapshot_file_checksum "${source_file_path}")" ; then
        exit 1
    fi

    if database_exists "${target_database_name}" ; then
        echo "Fehler: Die pseudonymisierte Snapshot-Datenbank '${target_database_name}' existiert bereits."
        echo "Deaktiviere sie vor einer erneuten Pseudonymisierung."
        exit 1
    fi

    ask_before_overwrite_file "${pseudonymized_file_path}"
    local source_database="${source_build_db}"
    if database_exists "${source_database_name}" && database_exists "${source_build_db}" ; then
        echo "Fehler: Sowohl die Snapshot-Datenbank als auch die temporäre Quelldatenbank existieren:"
        echo "  ${source_database_name}"
        echo "  ${source_build_db}"
        echo "Entferne die nicht benötigte Datenbank vor einem erneuten Lauf."
        exit 1
    fi
    if database_exists "${source_database_name}" ; then
        if database_matches_snapshot "${source_database_name}" "${source_file_checksum}" ; then
            source_database="${source_database_name}"
            echo "Verwende die bereits aktivierte Snapshot-Datenbank '${source_database}'."
        else
            echo "Fehler: Die Snapshot-Datenbank '${source_database_name}' gehört nicht eindeutig zur Snapshot-Datei."
            echo "Deaktiviere sie vor einem erneuten Lauf."
            exit 1
        fi
    elif database_exists "${source_build_db}" ; then
        if database_matches_snapshot "${source_build_db}" "${source_file_checksum}" ; then
            echo "Verwende die bereits vollständig eingespielte temporäre Quelldatenbank '${source_build_db}'."
        else
            echo "Fehler: Die temporäre Quelldatenbank '${source_build_db}' gehört nicht eindeutig zur Snapshot-Datei."
            echo "Entferne sie vor einem erneuten Lauf."
            exit 1
        fi
    fi
    if database_exists "${target_build_db}" ; then
        echo "Entferne unvollständige Ziel-Datenbank '${target_build_db}' für den Neustart..."
        if ! drop_database_if_exists "${target_build_db}" ; then
            echo "Fehler: Temporäre Ziel-Datenbank '${target_build_db}' konnte nicht entfernt werden."
            exit 1
        fi
    fi

    SECONDS=0
    if ! database_exists "${source_database}" ; then
        echo "Erzeuge temporäre Quelldatenbank '${source_build_db}'..."
        docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
            "CREATE DATABASE ${source_build_db} WITH OWNER=cds_hub_db_admin;"
        if gzip -cd "${source_file_path}" | docker compose exec -T cds_hub \
            psql -d "${source_build_db}" cds_hub_db_admin ; then
            echo "Temporäre Quelldatenbank '${source_build_db}' eingespielt."
            if ! set_database_snapshot_checksum "${source_build_db}" "${source_file_checksum}" ; then
                echo "Fehler: Der Datenstand der Quelldatenbank konnte nicht vermerkt werden."
                exit 1
            fi
        else
            echo "Fehler: Einspielen der temporären Quelldatenbank '${source_build_db}' fehlgeschlagen."
            echo "Entferne die unvollständig eingespielte Quelldatenbank..."
            if ! drop_database_if_exists "${source_build_db}" ; then
                echo "Fehler: Unvollständige Source-Datenbank '${source_build_db}' konnte nicht entfernt werden."
                echo "Bitte vor einem erneuten Lauf manuell entfernen."
            fi
            exit 1
        fi
    fi

    echo "Erzeuge leere temporäre Ziel-Datenbank '${target_build_db}'..."
    if ! prepare_pseudonymized_target_database "${target_build_db}" ; then
        echo "Fehler: Anlegen der temporären Ziel-Datenbank '${target_build_db}' fehlgeschlagen."
        echo "Bereits angelegte Datenbanken bleiben zur Diagnose erhalten:"
        echo "  ${source_database}"
        echo "  ${target_build_db}"
        exit 1
    fi

    echo "Starte Pseudonymisierung von '${source_database}' nach '${target_build_db}'..."
    if docker compose run --rm --no-deps "${input_repo_mount_args[@]}" r-env \
        Rscript R-cdstoolchain/StartSnapshotPseudonymization.R \
        source-db="${source_database}" \
        target-db="${target_build_db}" \
        chunk-size="${chunk_size}" ; then
        echo "Pseudonymisierung abgeschlossen."
    else
        echo "Fehler: Pseudonymisierung fehlgeschlagen."
        echo "Die beteiligten Datenbanken bleiben zur Diagnose erhalten:"
        echo "  ${source_database}"
        echo "  ${target_build_db}"
        exit 1
    fi

    echo "Erzeuge pseudonymisierten Snapshot '${pseudonymized_file_path}'..."
    if docker compose exec cds_hub pg_dump -U cds_hub_db_admin -d "${target_build_db}" \
        --format=plain --compress=gzip > "${pseudonymized_file_path}" ; then
        echo "Datei \"${pseudonymized_file_path}\" wurde angelegt."
        ls -ho "${pseudonymized_file_path}"
    else
        echo "Fehler: Beim Erstellen des pseudonymisierten Snapshots ist ein Fehler aufgetreten."
        if [[ -e "${pseudonymized_file_path}" && ! -s "${pseudonymized_file_path}" ]]; then
            echo "Datei ${pseudonymized_file_path} existiert, ist jedoch leer -> cleanup."
            rm -f "${pseudonymized_file_path}"
        fi
        echo "Die beteiligten Datenbanken bleiben zur Diagnose erhalten:"
        echo "  ${source_database}"
        echo "  ${target_build_db}"
        exit 1
    fi

    local pseudonymized_file_checksum
    if ! pseudonymized_file_checksum="$(snapshot_file_checksum "${pseudonymized_file_path}")" ; then
        echo "Fehler: Der Datenstand der pseudonymisierten Snapshot-Datei konnte nicht ermittelt werden."
        exit 1
    fi
    if ! set_database_snapshot_checksum "${target_build_db}" "${pseudonymized_file_checksum}" ; then
        echo "Fehler: Der Datenstand der pseudonymisierten Datenbank konnte nicht vermerkt werden."
        exit 1
    fi

    if [[ "${source_database}" == "${source_build_db}" ]]; then
        if ! set_database_read_only "${source_build_db}" ||
            ! rename_database "${source_build_db}" "${source_database_name}" ; then
            echo "Fehler: Die Quelldatenbank konnte nicht als Snapshot-Datenbank beibehalten werden."
            exit 1
        fi
        source_database="${source_database_name}"
    elif ! set_database_read_only "${source_database}" ; then
        echo "Fehler: Die Quelldatenbank konnte nicht in den Read-only-Modus gesetzt werden."
        exit 1
    fi

    if ! set_database_read_only "${target_build_db}" ||
        ! rename_database "${target_build_db}" "${target_database_name}" ; then
        echo "Fehler: Die pseudonymisierte Zieldatenbank konnte nicht als Snapshot-Datenbank beibehalten werden."
        exit 1
    fi

    printf "Dauer Pseudonymisierung: %s s\n" "$SECONDS"
    echo "Die folgenden schreibgeschützten Snapshot-Datenbanken bleiben im Docker-Service 'cds_hub' verfügbar:"
    echo "  ${source_database}"
    echo "  ${target_database_name}"
    echo
    echo "Zum Entfernen der Datenbanken:"
    echo "  ./ip-snapshot.sh deactivate ${snapshot_name}"
    echo "  ./ip-snapshot.sh deactivate ${pseudonymized_snapshot_name}"
    echo
    echo "Die Snapshot-Dateien bleiben dabei erhalten."
    echo
    echo "======================================================================"
    echo "WARNING: Check the pseudonymization issue report for data issues:"
    echo "  outputLocal/snapshot_pseudonymization/reports/snapshot_pseudonymization_issues.xlsx"
    echo "======================================================================"
}


# ---------- Aktionen ----------
case "$action" in
    list)
        echo "Liste alle Snapshots im Verzeichnis '${DIR}' auf:"
        if find "${DIR}" -maxdepth 1 -type f -name '*.sql.gz' -print -quit | grep -q . ; then
            find "${DIR}" -maxdepth 1 -type f -name '*.sql.gz' -print | sort | while IFS= read -r snapshot_file; do
                snapshot_base="${snapshot_file##*/}"
                snapshot_name="${snapshot_base%.sql.gz}"
                snapshot_size_kb="$(du -k "${snapshot_file}" | awk '{print $1}')"
                printf '%s\t%sKB\n' "${snapshot_name}" "${snapshot_size_kb}"
            done
        else
            echo "Keine Snapshots im Verzeichnis ${DIR} vorhanden."
        fi
        echo "---"
        echo "Liste alle aktivierten Snapshots in der Datenbank auf:"
        if ! docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "
            SELECT   d.datname                                    AS database,
                     pg_size_pretty(pg_database_size(d.datname))  AS size
            FROM pg_database d
            WHERE d.datname LIKE 'ip\_%'   -- Escape-Unterstrich, weil _ ein Wildcard-Zeichen ist
            ORDER BY pg_database_size(d.datname) DESC;" ; then
            echo "Keine aktivierten Snapshot in der Datenbank."
        fi
        ;;

    create)
        # Ziel‑Datei mit Datum
        file_date="${name}_$(date +%Y%m%d).sql.gz"
        snapshot_name_date="${name}_$(date +%Y%m%d)"
        # Vollständiger Pfad zur Datei mit Datum
        file_date_path="${DIR}/${file_date}"


        if [[ -e "$file_date_path" ]]; then
            echo "Hinweis: Snapshot \"$file_date_path\" existiert bereits!"
            
            # ------------------------------------------------------------
            # 2. Rückfrage an den Benutzer
            # ------------------------------------------------------------
            while true; do
                read -rp "Soll die Datei \"$file_date_path\" wirklich überschrieben werden? [y/N] " answer
                case "$answer" in
                    [Yy]* )
                        # ------------------------------------------------
                        # 3. JA, überschreiben -> weiter im Script
                        # ------------------------------------------------
                        echo "Snapshot \"$file_date_path\" wird überschrieben..."
                        break
                        ;;
                    [Nn]*|"" )
                        echo "Erstellung von Snapshot \"$file_date_path\" abgebrochen."
                        exit 1
                        ;;
                    * )
                        echo "Bitte mit 'y' (ja) oder 'n' (nein) antworten."
                        ;;
                esac
            done
        fi

        # Beispiel‑Inhalt: aktuelle Zeit + Hinweis
        #{
        #    echo "Datei \"$file_path\" erzeugt am $(date +"%Y-%m-%d %H:%M:%S")"
        #    echo "Erstellt von $(whoami) auf $(hostname)"
        #} > "$file_path"

        # Snapshot erstellen
        SECONDS=0;
        if docker compose exec cds_hub pg_dump -U cds_hub_db_admin -d cds_hub_db --format=plain --exclude-extension=pg_cron --exclude-table=db_config.v_cron_jobs --exclude-table='*.*_raw*' --compress=gzip > $file_date_path; then
            echo "Datei \"${file_date_path}\" wurde angelegt."
            ls -ho ${file_date_path}
        else
            echo "Fehler: Beim Erstellen des Snapshots in Datei \"${file_date_path}\" ist ein Fehler aufgetreten."
            # cleanup
            if [[ -e "${file_date_path}" && ! -s "$file_date_path" ]]; then 
                echo "Datei ${file_date_path} existiert, ist jedoch leer -> cleanup.";
                rm -rf ${file_date_path}
            fi
            exit 1
        fi
        printf "Dauer: %s s\n" "$SECONDS";

        if [[ "${with_pseudonymized}" == "true" ]]; then
            create_pseudonymized_snapshot \
                "${snapshot_name_date}" \
                "${chunk_size}"
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
            echo "Fehler: Snapshot \"$file\" existiert nicht (oder ist keine reguläre Datei)."
            # kein exit – das Skript läuft weiter
            # break
            exit 1
        fi

        # ------------------------------------------------------------
        # 2. Rückfrage an den Benutzer
        # ------------------------------------------------------------
        while true; do
            read -rp "Soll die Datei \"$file_path\" wirklich gelöscht werden? [y/N] " answer
            case "$answer" in
                [Yy]* )
                    # ------------------------------------------------
                    # 3. Löschen und Ergebnis prüfen
                    # ------------------------------------------------
                    if rm "$file_path"; then
                        echo "Snapshot \"$file_path\" wurde gelöscht."
                    else
                        echo "Fehler: Konnte \"$file_path\" nicht löschen." >&2
                    fi
                    break
                    ;;
                [Nn]*|"" )
                    echo "Löschvorgang abgebrochen."
                    break
                    ;;
                * )
                    echo "Bitte mit 'y' (ja) oder 'n' (nein) antworten."
                    ;;
            esac
        done
        ;;

    activate)
        if [[ -e "${file_path}" ]]; then
            echo "Hinweis: Snapshot Datei \"${file_path}\" existiert."

            if database_exists "${db_name}" ; then
                echo "Fehler: Snapshot Datenbank '${db_name}' existiert bereits."
                exit 1
            fi

            logfile="${file_path}_activate_$(date +%Y%m%d-%H%M%S).log"
            SECONDS=0;

            # Snapshot-Datenbank anlegen
            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "CREATE DATABASE ${db_name} WITH OWNER=cds_hub_db_admin;" > "${logfile}" 2>&1 ; then
                echo "Snapshot Datenbank '${db_name}' angelegt."
            else
                echo "Fehler: Anlegen der Snapshot Datenbank '${db_name}' fehlgeschlagen."
                exit 1
            fi

            # Snapshot-Datei in zuvor angelegte Snapshot-Datenbank einspielen
            if gzip -cd "${file_path}" | docker compose exec -T cds_hub psql -d "${db_name}" cds_hub_db_admin >> "${logfile}" 2>&1 ; then
                echo "Snapshot Datenbank '${db_name}' eingespielt."
                if ! snapshot_checksum="$(snapshot_file_checksum "${file_path}")" ; then
                    exit 1
                fi
                if ! set_database_snapshot_checksum "${db_name}" "${snapshot_checksum}" >> "${logfile}" 2>&1 ; then
                    echo "Fehler: Der Datenstand der Snapshot Datenbank '${db_name}' konnte nicht vermerkt werden."
                    exit 1
                fi
                if set_database_read_only "${db_name}" >> "${logfile}" 2>&1 ; then
                    echo "Snapshot Datenbank '${db_name}' in 'read-only' Modus gesetzt."
                else
                    echo "Fehler: Setzen des 'read-only' Modus in der Snapshot Datenbank '${db_name}' fehlgeschlagen."
                    exit 1
                fi
            else
                echo "Fehler: Einspielen der Snapshot Datenbank '${db_name}' fehlgeschlagen."
                exit 1
            fi

        else
            echo "Fehler: Snapshot \"$file_path\" existiert nicht."
            exit 1
        fi
        printf "Dauer: %s s\n" "$SECONDS"
        ;;

    deactivate)
        #if [[ -e "${file_path}" ]]; then
        #    echo "Hinweis: Snapshot \"${file_path}\" existiert."

            if database_exists "${db_name}" ; then
                echo "Snapshot-Datenbank '${db_name}' ist aktiviert."
                
                # ------------------------------------------------------------
                # 2. Rückfrage an den Benutzer
                # ------------------------------------------------------------
                while true; do
                    read -rp "Soll die Snapshot-Datenbank \"${db_name}\" wirklich deaktiviert werden? Die Snapshot-Datei bleibt erhalten. [y/N] " answer
                    case "$answer" in
                        [Yy]* )
                            # ------------------------------------------------
                            # 3. Snapshot-Datenbank deaktivieren und Ergebnis prüfen
                            # ------------------------------------------------
                            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "DROP DATABASE ${db_name} WITH (FORCE);" ; then
                                echo "Snapshot-Datenbank \"${db_name}\" wurde deaktiviert."
                            else
                                echo "Fehler: Snapshot-Datenbank \"${db_name}\" konnte nicht deaktiviert werden." >&2
                            fi
                            break
                            ;;
                        [Nn]*|"" )
                            echo "Deaktivierung abgebrochen."
                            break
                            ;;
                        * )
                            echo "Bitte mit 'y' (ja) oder 'n' (nein) antworten."
                            ;;
                    esac
                done
            else
                echo "Fehler: Snapshot-Datenbank '${db_name}' ist nicht aktiviert."
                exit 1
            fi
            
        #else
        #    echo "Fehler: Snapshot \"$file_path\" existiert nicht."
        #    exit 1
        #fi
        ;;
    *)
        echo "Fehler: unbekannte Aktion \"$action\". Erlaubt sind \"create\", \"list\", \"activate\", \"deactivate\" oder \"delete\"." >&2
        print_usage
        exit 3
        ;;
esac

exit 0
