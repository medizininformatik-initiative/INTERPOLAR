#!/bin/sh
set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
cd "$repo_root"

[ -f "docker-compose.yml" ] || {
  echo "ERROR: docker-compose.yml not found. Could not determine repository root." >&2
  exit 1
}

[ -f "R-cdstoolchain/StartCDSToolChain.R" ] || {
  echo "ERROR: R-cdstoolchain/StartCDSToolChain.R not found." >&2
  exit 1
}

docker compose run --rm --no-deps r-env Rscript R-cdstoolchain/StartCDSToolChain.R "$@"

docker compose exec -T cds_hub \
  psql -v ON_ERROR_STOP=1 \
  -U cds_hub_db_admin \
  -d cds_hub_db \
  -c "VACUUM (ANALYZE);"
