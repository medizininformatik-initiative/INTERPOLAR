#!/usr/bin/env bash
set -o pipefail
#====================================================================
#  script‑name : ip-snapshot.sh
#  Zweck      : Erzeugt oder löscht eine Datei, deren Name als
#               Argument übergeben wird.
#
#  Aufruf:
#      ./ip-snapshot.sh list
#      ./ip-snapshot.sh create  <name> [--with-pseudonymized]
#      ./ip-snapshot.sh pseudonymize  <name_date> [--keep-temp-on-error]
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
  --keep-temp-on-error
             nur bei \"pseudonymize\" oder \"create --with-pseudonymized\":
             temporäre Build-Datenbanken bei Fehlern zur Diagnose behalten

Beispiele:
  $0 list                            → listet alle .sql.gz-Dateien (ohne Endung) im Ordner Snapshots auf
  $0 create  snapshot                → erzeugt  snapshot_<Datum>.sql.gz
  $0 create  snapshot --with-pseudonymized
                                      → erzeugt  snapshot_<Datum>.sql.gz und snapshot_<Datum>_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 → erzeugt  snapshot_20250929_pseud.sql.gz
  $0 pseudonymize  snapshot_20250929 --keep-temp-on-error
                                      → behält ip_snapshot_20250929_build und ip_snapshot_20250929_pseud_build bei Fehlern
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
option=$3
option2=$4
DIR=Snapshots

if [[ -z "$action" ]]; then
    print_usage
    exit 1
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
        printf '%s\n' "${host_path}:${container_path}:ro"
    fi
}

database_exists() {
    local database_name="$1"
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -tAc \
        "SELECT 1 FROM pg_database WHERE datname = '${database_name}';" | grep -q 1
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
    local keep_temp_on_error="${2:-false}"
    local source_file_path="${DIR}/${snapshot_name}.sql.gz"
    local pseudonymized_snapshot_name="${snapshot_name}_pseud"
    local pseudonymized_file_path="${DIR}/${pseudonymized_snapshot_name}.sql.gz"
    local source_build_db="ip_${snapshot_name}_build"
    local target_build_db="ip_${pseudonymized_snapshot_name}_build"

    if [[ ! -f "${source_file_path}" ]]; then
        echo "Fehler: Snapshot \"${source_file_path}\" existiert nicht."
        exit 1
    fi
    ask_before_overwrite_file "${pseudonymized_file_path}"

    if database_exists "${source_build_db}" ; then
        echo "Fehler: Temporäre Source-Datenbank '${source_build_db}' existiert bereits."
        exit 1
    fi
    if database_exists "${target_build_db}" ; then
        echo "Fehler: Temporäre Ziel-Datenbank '${target_build_db}' existiert bereits."
        exit 1
    fi

    SECONDS=0
    echo "Erzeuge temporäre Source-Datenbank '${source_build_db}'..."
    docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c \
        "CREATE DATABASE ${source_build_db} WITH OWNER=cds_hub_db_admin;"
    if gzip -cd "${source_file_path}" | docker compose exec -T cds_hub psql -d "${source_build_db}" cds_hub_db_admin ; then
        echo "Temporäre Source-Datenbank '${source_build_db}' eingespielt."
    else
        echo "Fehler: Einspielen der temporären Source-Datenbank '${source_build_db}' fehlgeschlagen."
        if [[ "${keep_temp_on_error}" != "true" ]]; then
            drop_database_if_exists "${source_build_db}"
        fi
        exit 1
    fi

    echo "Erzeuge leere temporäre Ziel-Datenbank '${target_build_db}'..."
    if ! prepare_pseudonymized_target_database "${target_build_db}" ; then
        echo "Fehler: Anlegen der temporären Ziel-Datenbank '${target_build_db}' fehlgeschlagen."
        if [[ "${keep_temp_on_error}" != "true" ]]; then
            drop_database_if_exists "${source_build_db}"
            drop_database_if_exists "${target_build_db}"
        fi
        exit 1
    fi

    echo "Starte Pseudonymisierung von '${source_build_db}' nach '${target_build_db}'..."
    local input_repo_mount_args=()
    while IFS= read -r mount_arg; do
        input_repo_mount_args+=("${mount_arg}")
    done < <(container_input_repo_mount_args)
    if docker compose run --rm --no-deps "${input_repo_mount_args[@]}" r-env \
        Rscript R-cdstoolchain/StartSnapshotPseudonymization.R \
        source-db="${source_build_db}" \
        target-db="${target_build_db}" ; then
        echo "Pseudonymisierung abgeschlossen."
    else
        echo "Fehler: Pseudonymisierung fehlgeschlagen."
        if [[ "${keep_temp_on_error}" == "true" ]]; then
            echo "Temporäre Build-Datenbanken bleiben zur Diagnose erhalten:"
            echo "  ${source_build_db}"
            echo "  ${target_build_db}"
        else
            drop_database_if_exists "${source_build_db}"
            drop_database_if_exists "${target_build_db}"
        fi
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
        if [[ "${keep_temp_on_error}" == "true" ]]; then
            echo "Temporäre Build-Datenbanken bleiben zur Diagnose erhalten:"
            echo "  ${source_build_db}"
            echo "  ${target_build_db}"
        else
            drop_database_if_exists "${source_build_db}"
            drop_database_if_exists "${target_build_db}"
        fi
        exit 1
    fi

    drop_database_if_exists "${source_build_db}"
    drop_database_if_exists "${target_build_db}"
    printf "Dauer Pseudonymisierung: %s s\n" "$SECONDS"
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
        if [[ -n "${option}" && "${option}" != "--with-pseudonymized" ]]; then
            echo "Fehler: unbekannte Option \"${option}\". Erlaubt ist nur \"--with-pseudonymized\"." >&2
            exit 3
        fi
        if [[ -n "${option2}" && "${option2}" != "--keep-temp-on-error" ]]; then
            echo "Fehler: unbekannte Option \"${option2}\". Erlaubt ist nur \"--keep-temp-on-error\"." >&2
            exit 3
        fi
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

        if [[ "${option}" == "--with-pseudonymized" ]]; then
            keep_temp_on_error=false
            if [[ "${option2}" == "--keep-temp-on-error" ]]; then
                keep_temp_on_error=true
            fi
            create_pseudonymized_snapshot "${snapshot_name_date}" "${keep_temp_on_error}"
        fi
        ;;

    pseudonymize)
        if [[ -n "${option}" && "${option}" != "--keep-temp-on-error" ]]; then
            echo "Fehler: unbekannte Option \"${option}\". Erlaubt ist nur \"--keep-temp-on-error\"." >&2
            exit 3
        fi
        keep_temp_on_error=false
        if [[ "${option}" == "--keep-temp-on-error" ]]; then
            keep_temp_on_error=true
        fi
        create_pseudonymized_snapshot "${name}" "${keep_temp_on_error}"
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
            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "CREATE DATABASE ${db_name} WITH OWNER=cds_hub_db_admin;" > ${logfile} 2>&1 ; then
                echo "Snapshot Datenbank '${db_name}' angelegt."
            else
                echo "Fehler: Anlegen der Snapshot Datenbank '${db_name}' fehlgeschlagen."
                exit 1
            fi

            # Snapshot-Datei in zuvor angelegte Snapshot-Datenbank einspielen
            if gzip -cd ${file_path} | docker compose exec -T cds_hub psql -d ${db_name} cds_hub_db_admin >> ${logfile} 2>&1 ; then
                echo "Snapshot Datenbank '${db_name}' eingespielt."
                if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "ALTER DATABASE ${db_name} SET default_transaction_read_only=on ;" >> ${logfile} 2>&1 ; then
                    echo "Snapshot Datenbank '${db_name}' in 'read-only' Modus gesetzt."
                else
                    echo "Fehler: Setzen des 'read-only' Modus in der Snapshot Datenbank '${db_name}' fehlgeschlagen."
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
                echo "Snapshot Datenbank '${db_name}' existiert."
                
                # ------------------------------------------------------------
                # 2. Rückfrage an den Benutzer
                # ------------------------------------------------------------
                while true; do
                    read -rp "Soll der Snapshot \"${db_name}\" wirklich gelöscht werden? [y/N] " answer
                    case "$answer" in
                        [Yy]* )
                            # ------------------------------------------------
                            # 3. Snapshot löschen und Ergebnis prüfen
                            # ------------------------------------------------
                            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "DROP DATABASE ${db_name} WITH (FORCE);" ; then
                                echo "Snapshot \"${db_name}\" wurde gelöscht."
                            else
                                echo "Fehler: Konnte Snapshot \"${db_name}\" nicht löschen." >&2
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
            else
                echo "Fehler: Snapshot Datenbank '${db_name}' existiert nicht."
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
