#!/bin/bash
# db_vacuum.sh

# PostgreSQL-Datenbank-Vacuum-Script für CDS Hub
# Autor: Sebastian Stäubert, Henner Kruse
# Version: 1.3 (mit -f/--force-Modus)

# ========================
# HILFE-AUSGABE
# ========================
show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] [CONTAINER_NAME]

Führt VACUUM (VERBOSE, ANALYZE) auf allen Tabellen in allen Benutzerschemata
der PostgreSQL-Datenbank im Docker-Container aus.

Optionen:
  -y, --yes               Force-Modus: Startet ohne Benutzerabfrage
  -f, --force             Führt VACUUM FULL auch aus, wenn keine toten Tupel vorhanden sind
  -h, --help              Zeigt diese Hilfe an

Beispiel:
  $(basename "$0")
  $(basename "$0") -y
  $(basename "$0") -y -f
  $(basename "$0") -f cds_hub

Hinweise:
  - Der Container muss laufen und die Datenbank erreichbar sein.
  - Benötigt: docker, docker compose, psql im Container.
  - VACUUM FULL wird nur ausgeführt, wenn tote Tupel vorhanden sind (Standard).
  - Mit -f wird VACUUM FULL auch bei 0 toten Tupeln durchgeführt.
  - Im Force-Modus (-y) wird automatisch verarbeitet.

EOF
}

# ========================
# PARAMETER VERARBEITEN
# ========================
YES_MODE=false
FORCE_MODE=false
CONTAINER="cds_hub"

while [[ $# -gt 0 ]]; do
  case $1 in
    -y|--yes)
      YES_MODE=true
      shift
      ;;
    -f|--force)
      FORCE_MODE=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -*)
      echo "❌ Unbekannter Parameter: $1"
      show_help
      exit 1
      ;;
    *)
      # Container-Name als erster Parameter
      CONTAINER="$1"
      shift
      ;;
  esac
done

# ========================
# KONFIGURATION
# ========================
DB_NAME="cds_hub_db"
DB_USER="cds_hub_db_admin"

# ========================
# HILFSFUNKTIONEN
# ========================
log() {
  echo "✅ $*"
}

warn() {
  echo "⚠️  $*" >&2
}

error() {
  echo "❌ $*" >&2
}

# ========================
# PRÜFE, OB DOCKER COMPOSE VERFÜGBAR IST
# ========================
DOCKER_COMPOSE_CMD=""

if command -v docker-compose &> /dev/null; then
  DOCKER_COMPOSE_CMD="docker-compose"
elif command -v docker &> /dev/null; then
  if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
  else
    error "❌ Kein 'docker-compose' oder 'docker compose' gefunden."
    exit 1
  fi
else
  error "❌ Docker ist nicht installiert oder nicht im PATH."
  exit 1
fi

log "🔧 Verwende: ${DOCKER_COMPOSE_CMD}"

# ========================
# LADEN DER SCHEMAS
# ========================
echo "🔍 Lade alle Schemata aus der Datenbank..."
mapfile -t SCHEMAS < <(
  docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
    SELECT nspname 
    FROM pg_namespace 
    WHERE nspname NOT LIKE 'pg_%' 
      AND nspname NOT IN ('information_schema', 'pg_toast')
      AND nspname NOT LIKE 'pg_temp%'
      AND nspname NOT LIKE 'pg_toast_temp%'
    ORDER BY nspname;
  " | tr -d ' \t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
)

if [ ${#SCHEMAS[@]} -eq 0 ]; then
  echo "❌ Keine Benutzerschemata gefunden. Abbruch."
  exit 1
fi

echo "✅ Gefunden: ${#SCHEMAS[@]} Schemata: ${SCHEMAS[*]}"

# Zähle Tabellen
total_tables=0

for s in "${SCHEMAS[@]}"; do
  mapfile -t tables < <(
    docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = '${s}';
    " | tr -d ' \t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
  )
  count=${#tables[@]}
  total_tables=$((total_tables + count))
done

echo "✅ ${total_tables} Tabellen in Container '${CONTAINER}' mit den Schemata '${SCHEMAS[@]}' gefunden"

# Frage nach Verarbeitung, nur wenn nicht im Force-Modus
if [ "$YES_MODE" = false ]; then
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

# ========================
# VERARBEITUNG DER TABELLEN
# ========================
for s in "${SCHEMAS[@]}"; do
  echo
  echo "📁 Processing tables from schema ${s}..."

  mapfile -t tables < <(
    docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = '${s}';
    " | tr -d ' \t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
  )

  if [ ${#tables[@]} -eq 0 ]; then
    echo "  → Keine Tabellen gefunden."
    continue
  fi

  for tablename in "${tables[@]}"; do
    [ -z "$tablename" ] && continue
    echo
    echo "➡️  Vacuuming: ${s}.${tablename}"

    # Lade Zustand vor VACUUM
    before_output=$(docker compose exec -T -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
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

    live_before=$(echo "$before_output" | grep "n_live_tup" | awk '{print $3}')
    dead_before=$(echo "$before_output" | grep "n_dead_tup" | awk '{print $3}')
    pages_before=$(echo "$before_output" | grep "relpages" | awk '{print $3}')

    # Zeige Before nur, wenn tote Tupel > 0 oder Force-Modus aktiv
    if [ "$dead_before" -gt 0 ] || [ "$FORCE_MODE" = true ]; then
      echo "  → Before:"
      echo "    Live tuples: $live_before"
      echo "    Dead tuples: $dead_before"
      echo "    Pages:     $pages_before"
    fi

    # Entscheidung: VACUUM FULL ausführen?
    run_vacuum=false
    if [ "$dead_before" -gt 0 ]; then
      run_vacuum=true
    elif [ "$FORCE_MODE" = true ]; then
      run_vacuum=true
    fi

    if [ "$run_vacuum" = true ]; then
      echo "  → Running VACUUM FULL..."
      if ! docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
          VACUUM FULL ${s}.${tablename};
        " > /dev/null 2>&1; then
        echo "❌ Fehler beim VACUUM FULL: ${s}.${tablename}"
      fi

      echo "  → Running ANALYZE..."
      if ! docker compose exec -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        ANALYZE ${s}.${tablename};
        " > /dev/null 2>&1; then
      echo "❌ Fehler beim ANALYZE: ${s}.${tablename}"
      fi

      # Lade Zustand nach VACUUM
      after_output=$(docker compose exec -T -T "${CONTAINER}" /usr/bin/psql -U "${DB_USER}" -d "${DB_NAME}" -t -c "
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

      live_after=$(echo "$after_output" | grep "n_live_tup" | awk '{print $3}')
      dead_after=$(echo "$after_output" | grep "n_dead_tup" | awk '{print $3}')
      pages_after=$(echo "$after_output" | grep "relpages" | awk '{print $3}')

      # Zeige After nur, wenn sich etwas geändert hat oder Force-Modus
      if [ "$dead_after" -gt 0 ] || [ "$dead_after" -lt "$dead_before" ] || [ "$pages_after" -lt "$pages_before" ] ||[ "$FORCE_MODE" = true ]; then
        echo "    - Live tuples: ${live_after}"
        echo "    - Dead tuples: ${dead_after}"
        echo "    - Pages: ${pages_after}"

        live_diff=$((live_after - live_before))
        dead_diff=$((dead_after - dead_before))
        pages_diff=$((pages_after - pages_before))

        echo "    - Δ Live tuples: $live_diff"
        echo "    - Δ Dead tuples: $dead_diff"
        echo "    - Δ Pages: $pages_diff"

        if [ "$live_diff" -lt 0 ]; then
          echo "    ⚠️  Warnung: Anzahl der Live-Tupel ist gesunken! (Möglicher Datenverlust?)"
        fi
      else
        echo "  → After: Keine signifikante Änderung erkannt."
      fi
    else
      echo "  → Keine toten Tupel und kein Force-Modus → VACUUM FULL und ANALYZE übersprungen."
    fi
  done
done

echo
echo "✅ VACUUM und ANALYZE abgeschlossen."