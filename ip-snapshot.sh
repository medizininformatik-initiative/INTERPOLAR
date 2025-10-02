#!/usr/bin/env bash
#====================================================================
#  script‑name : ip-snapshot.sh
#  Zweck      : Erzeugt oder löscht eine Datei, deren Name als
#               Argument übergeben wird.
#
#  Aufruf:
#      ./ip-snapshot.sh list
#      ./ip-snapshot.sh create  <name>
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
             \"delete\"      – löscht einen Snapshot <name_date>.sql.gz
             \"activate\"    – aktiviert einen Snapshot <name_date>.sql.gz, d.h. es wird eine Datenbank für diesen Snapshot angelegt.
             \"deactivate\"  – deaktiviert einen Snapshot <name_date>.sql.gz, d.h. die Datenbank für diesen Snapshot wird gelöscht.

  <name>     beliebiger String (ohne Pfad‑Komponenten), <name> | <name_date>

Beispiele:
  $0 list                            → listet alle .sql.gz-Dateien im Ordner Snapshots auf
  $0 create  snapshot                → erzeugt  snapshot_<Datum>.sql.gz
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


# Nur einfache Dateinamen zulassen (keine Pfade, keine Leerzeichen)
if [[ "$name" =~ [[:space:]/\$ ]]; then
    echo "Fehler: Der Name darf keine Leerzeichen oder Pfad‑Zeichen enthalten." >&2
    exit 2
fi

# Ziel‑Datei (immer mit .sql.gz‑Erweiterung)
file="${name}.sql.gz"

# Vollständiger Pfad zur Datei
file_path="${DIR}/${file}"

# Name der Snapshot Datenbank
db_name="ip_${name}"


# ---------- Aktionen ----------
case "$action" in
    list)
        echo "Liste alle Snapshots im Verzeichnis '${DIR}' auf:"
        if find "${DIR}" -maxdepth 1 -type f -name '*.sql.gz' -print -quit | grep -q . ; then
            #ls -lisa Snapshots/*.sql.gz;
            find "${DIR}" -type f -name '*.sql.gz' -printf '%f\n' | sed 's/\.sql\.gz$//'
        else
            echo "Keine Snapshots im Verzeichnis ${DIR} vorhanden."
        fi
        echo "---"
        echo "Liste alle aktivierten Snapshots in der Datenbank auf:"
        if ! docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres --list |grep "ip_" ; then
            echo "Keine aktivierten Snapshot in der Datenbank."
        fi
        ;;

    create)
        # Ziel‑Datei mit Datum
        file_date="${name}_$(date +\%Y%m%d).sql.gz"
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
        if docker compose exec cds_hub pg_dump -U cds_hub_db_admin -d cds_hub_db --format=plain --compress=gzip > $file_date_path; then
            echo "Datei \"$file_date_path\" wurde angelegt."
        else
            echo "Fehler: Beim Erstellen des Snapshots in Datei \"$file_date_path\" ist ein Fehler aufgetreten."
            exit 1
        fi
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
            echo "Hinweis: Snapshot \"${file_path}\" existiert."

            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres --list |grep ${db_name} ; then
                echo "Fehler: Snapshot Datenbank '${db_name}' existiert bereits."
                exit 1
            fi

            if docker compose exec -T cds_hub psql -U cds_hub_db_admin -d postgres -c "CREATE DATABASE ${db_name} WITH OWNER=cds_hub_db_admin;" ; then
                echo "Snapshot Datenbank '${db_name}' angelegt."
            else
                echo "Fehler: Anlegen der Snapshot Datenbank '${db_name}' fehlgeschlagen."
                exit 1
            fi

            if zcat ${file_path} | docker compose exec -T cds_hub psql -d ${db_name} cds_hub_db_admin > ${file_path}.log 2>&1 ; then
                echo "Snapshot Datenbank '${db_name}' eingespielt."
            else
                echo "Fehler: Einspielen der Snapshot Datenbank '${db_name}' fehlgeschlagen."
                exit 1
            fi

        else
            echo "Fehler: Snapshot \"$file_path\" existiert nicht."
            exit 1
        fi
        ;;
    *)
        echo "Fehler: unbekannte Aktion \"$action\". Erlaubt sind \"create\" oder \"delete\"." >&2
        print_usage
        exit 3
        ;;
esac

exit 0