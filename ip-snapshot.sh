#!/usr/bin/env bash
#====================================================================
#  script‑name : ip-snapshot.sh
#  Zweck      : Erzeugt oder löscht eine Datei, deren Name als
#               Argument übergeben wird.
#
#  Aufruf:
#      ./ip-snapshot.sh list
#      ./ip-snapshot.sh create  <Dateiname>
#      ./ip-snapshot.sh delete  <Dateiname>
#
#  Hinweis: Der Dateiname darf **keine** Pfadangaben (/, ..) enthalten,
#           sonst wird das Skript mit einer Fehlermeldung beendet.
#====================================================================

# ---------- Hilfetext ----------
print_usage() {
    cat <<EOF
Usage: ${0##*/} <action> <name>

  <action>   \"list\"    – listet alle Snapshots auf
             \"create\"  – legt einen Snapshot <name>.sql.bz an
             \"delete\"  – löscht einen Snapshot <name>.sql.bz

  <name>     beliebiger String (ohne Pfad‑Komponenten)

Beispiele:
  $0 list                        → listet alle .sql.bz-Dateien im Ordner Snapshots auf
  $0 create  snapshot            → erzeugt  snapshot_<Datum>.sql.bz
  $0 delete  snapshot_20250929   → löscht   snapshot_20250929.sql.bz
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

# Ziel‑Datei (immer mit .sql.bz‑Erweiterung)
file="${name}.sql.bz"


# Vollständiger Pfad zur Datei
file_path="${DIR}/${file}"


# ---------- Aktionen ----------
case "$action" in
    list)
        echo "Liste alle Dateien im Verzeichnis 'Snapshots' auf:"
        if find "$DIR" -maxdepth 1 -type f -name '*.sql.bz' -print -quit | grep -q . ; then
            #ls -lisa Snapshots/*.sql.bz;
            find "$DIR" -type f -name '*.sql.bz' -printf '%f\n' | sed 's/\.sql\.bz$//'
        else
            echo "Keine Snapshots vorhanden."
        fi
        ;;

    create)
        if [[ -e "$file_path" ]]; then
            echo "Hinweis: Snapshot \"$file_path\" existiert bereits – überschreibe."
        fi
        # Beispiel‑Inhalt: aktuelle Zeit + Hinweis
        {
            echo "Datei \"$file_path\" erzeugt am $(date +"%Y-%m-%d %H:%M:%S")"
            echo "Erstellt von $(whoami) auf $(hostname)"
        } > "$file_path"
        echo "Datei \"$file_path\" wurde angelegt."
        ;;

    delete)
        # ------------------------------------------------------------
        # 1. Existenz‑ und Typ‑Prüfung
        # ------------------------------------------------------------
        if [[ ! -f "$file_path" ]]; then
            echo "Warnung: Snapshot \"$file\" existiert nicht (oder ist keine reguläre Datei)."
            # kein exit – das Skript läuft weiter
            # break
            exit 0
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

    *)
        echo "Fehler: unbekannte Aktion \"$action\". Erlaubt sind \"create\" oder \"delete\"." >&2
        print_usage
        exit 3
        ;;
esac

exit 0