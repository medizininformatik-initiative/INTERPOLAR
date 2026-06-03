#!/bin/bash
# db_vacuum.sh

# Prüfe, ob -f oder -force übergeben wurde
FORCE_MODE=false
if [[ "$1" == "-f" || "$1" == "--force" ]]; then
  FORCE_MODE=true
  # Wenn -f übergeben, dann ist der Container-Name der zweite Parameter
  # Setze CONTAINER: Wenn Parameter übergeben, nutze ihn, sonst cds_hub
  CONTAINER=${2:-cds_hub}
else
  # Normaler Fall: erster Parameter ist der Container-Name
  CONTAINER=${1:-cds_hub}
fi

DB_NAME="cds_hub_db"
DB_USER="cds_hub_db_admin"

#declare -a SCHEMAS=("cds2db_in" "db_log")
declare -a SCHEMAS=("cds2db_in")


# Zähle Tabellen
total_tables=0

for s in "${SCHEMAS[@]}"; do
  # Lade alle Tabellennamen in ein Array
  mapfile -t tables < <(
    docker compose exec "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = '${s}';
    " | tr -d ' \t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
  )
  # Zähle Tabellen
  count=${#tables[@]}
  total_tables=$((total_tables + count))

  # Zeige Tabellen pro Schema (optional)
  # echo "  Schema ${s}: ${count} Tabellen"
done

# Zeige Anzahl der gefundenen Tabellen
echo "✅ ${total_tables} Tabellen in Container '${CONTAINER}' und den Schemata '${SCHEMAS[@]}' gefunden"


# Frage nach Verarbeitung, nur wenn nicht im Force-Modus
if [ "$FORCE_MODE" = false ]; then
  echo -n "Verarbeitung starten? (j/N): "
  read -r answer
  case ${answer:-N} in
    [JjYy]*)
      echo "✅ Verarbeitung gestartet..."
      ;;
    *)
      echo "❌ Verarbeitung abgebrochen."
      exit 0
      ;;
  esac
else
  echo "✅ Force-Modus aktiv – Verarbeitung startet automatisch."
fi


for s in "${SCHEMAS[@]}"; do
  echo "Processing tables from schema ${s}..."

  # Lade alle Tabellennamen in ein Array
  mapfile -t tables < <(
    docker compose exec "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = '${s}';
    " | tr -d ' \t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
  )

  for tablename in "${tables[@]}"; do
    [ -z "$tablename" ] && continue
    echo
    echo "➡️  Vacuuming: ${s}.${tablename}"


    echo "  → Before:"
    before_output=$(docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT 
        'n_live_tup' AS metric, n_live_tup::text AS value 
        FROM pg_stat_user_tables 
        WHERE schemaname = '${s}' AND relname = '${tablename}'
        UNION ALL
        SELECT 
        'n_dead_tup', n_dead_tup::text 
        FROM pg_stat_user_tables 
        WHERE schemaname = '${s}' AND relname = '${tablename}'
        UNION ALL
        SELECT 
        'relpages', relpages::text 
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = '${s}' AND c.relname = '${tablename}'
        ORDER BY metric;
    ")
    
    # Extrahiere n_live_tup und n_dead_tup
    live_before=$(echo "$before_output" | grep "n_live_tup" | awk '{print $3}')
    dead_before=$(echo "$before_output" | grep "n_dead_tup" | awk '{print $3}')
    pages_before=$(echo "$before_output" | grep "relpages" | awk '{print $3}')

    # Zeige vorher
    echo "    - Live tuples: ${live_before}"
    echo "    - Dead tuples: ${dead_before}"
    echo "    - Pages: ${pages_before}"

    # VACUUM FULL in eigener Transaktion
    echo "  → Running VACUUM FULL..."
    docker compose exec "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
      VACUUM FULL ${s}.${tablename};
    "
    # ANAYZE in eigener Transaktion
    echo "  → Running ANALYZE..."
    docker compose exec "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
      ANALYZE ${s}.${tablename};
    "

    echo "  → After:"
    after_output=$(docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT 
        'n_live_tup' AS metric, n_live_tup::text AS value 
        FROM pg_stat_user_tables 
        WHERE schemaname = '${s}' AND relname = '${tablename}'
        UNION ALL
        SELECT 
        'n_dead_tup', n_dead_tup::text 
        FROM pg_stat_user_tables 
        WHERE schemaname = '${s}' AND relname = '${tablename}'
        UNION ALL
        SELECT 
        'relpages', relpages::text 
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = '${s}' AND c.relname = '${tablename}'
        ORDER BY metric;
    ")

    #echo "$after_output"
    #echo "$after_output" | grep "n_live_tup" | awk '{print $3}'
    # Extrahiere n_live_tup und n_dead_tup
    live_after=$(echo "$after_output" | grep "n_live_tup" | awk '{print $3}')
    dead_after=$(echo "$after_output" | grep "n_dead_tup" | awk '{print $3}')
    pages_after=$(echo "$after_output" | grep "relpages" | awk '{print $3}')

        # Zeige nachher
    echo "    - Live tuples: ${live_after}"
    echo "    - Dead tuples: ${dead_after}"
    echo "    - Pages: ${pages_after}"

    # 5. Differenz berechnen
    live_diff=$((live_after - live_before))
    dead_diff=$((dead_after - dead_before))
    pages_diff=$((pages_after - pages_before))

    # Zeige Differenz
    echo "    - Δ Live tuples: ${live_diff:++}${live_diff}"
    echo "    - Δ Dead tuples: ${dead_diff:++}${dead_diff}"
    echo "    - Δ Pages: ${pages_diff:++}${pages_diff}"

    # Optional: Warnung, wenn Daten verloren gingen
    if [ "$live_diff" -lt 0 ]; then
      echo "    ⚠️  Warnung: Anzahl der Live-Tupel ist gesunken! (Möglicher Datenverlust?)"
    fi

  done
done
