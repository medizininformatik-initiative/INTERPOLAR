#!/bin/sh
set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir" && pwd)"
cd "$repo_root"

# Prüfung auf docker-compose oder docker compose
if command -v docker-compose >/dev/null 2>&1; then
  docker_cmd="docker-compose"
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  docker_cmd="docker compose"
else
  echo "ERROR: Kein gültiges Docker-Compose-Tool gefunden." >&2
  echo "Bitte stellen Sie sicher, dass entweder 'docker-compose' oder 'docker compose' installiert und in der PATH-Umgebung verfügbar ist." >&2
  exit 1
fi

[ -f "docker-compose.yml" ] || {
  echo "ERROR: docker-compose.yml not found. Could not determine repository root." >&2
  exit 1
}

[ -f "R-cdstoolchain/StartCDSToolChain.R" ] || {
  echo "ERROR: R-cdstoolchain/StartCDSToolChain.R not found." >&2
  exit 1
}

$docker_cmd run --rm --no-deps r-env Rscript R-cdstoolchain/StartCDSToolChain.R "$@"

$docker_cmd exec -T cds_hub \
  psql -v ON_ERROR_STOP=1 \
  -U cds_hub_db_admin \
  -d cds_hub_db \
  -c "VACUUM (ANALYZE);"
