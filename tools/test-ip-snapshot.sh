#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "${test_dir}"' EXIT

cp "${repo_root}/ip-snapshot.sh" "${test_dir}/ip-snapshot.sh"
mkdir "${test_dir}/Snapshots"

snapshot_script="${test_dir}/ip-snapshot.sh"
database_name="ip_snapshot_20260903_pseud"
expected_file_name="snapshot_20260903_pseud"

set +e
output="$(cd "${test_dir}" && "${snapshot_script}" delete "${database_name}" 2>&1)"
status=$?
set -e

if [[ ${status} -eq 0 ]]; then
    echo "Expected delete with a snapshot database name to fail." >&2
    exit 1
fi

if [[ "${output}" != *"\"${database_name}\" is a snapshot database name, not a snapshot file name."* ]]; then
    echo "Expected the error to identify the snapshot database name." >&2
    exit 1
fi

if [[ "${output}" != *"delete ${expected_file_name}"* ]]; then
    echo "Expected the error to show the delete command without the database prefix." >&2
    exit 1
fi

# Emulate PostgreSQL identifier folding and case-sensitive connection names without
# accessing Docker or an existing database. Keep state across CLI invocations.
mkdir "${test_dir}/bin" "${test_dir}/databases"
export SNAPSHOT_TEST_DATABASES="${test_dir}/databases"
export PATH="${test_dir}/bin:${PATH}"
cat > "${test_dir}/bin/docker" <<'DOCKER'
#!/usr/bin/env python3
import os
from pathlib import Path
import re
import sys

args = sys.argv[1:]
state = Path(os.environ["SNAPSHOT_TEST_DATABASES"])

def database(name):
    path = state / name
    if not path.exists():
        sys.exit(f"Database does not exist: {name}")
    return path

# Processing itself is outside this shell test; verify its database arguments.
if args[:2] == ["compose", "run"]:
    for arg in args:
        if arg.startswith(("source-db=", "target-db=")):
            database(arg.split("=", 1)[1])
    sys.exit(0)

connection = args[args.index("-d") + 1]
if connection != "postgres":
    database(connection)
if "pg_dump" in args:
    import gzip
    sys.stdout.buffer.write(gzip.compress(b"SELECT 1;\n"))
    sys.exit(0)
if "-tAc" in args:
    sql = args[args.index("-tAc") + 1]
    name = re.search(r"datname = '([^']+)'", sql)[1]
    if (state / name).exists():
        print((state / name).read_text() if "shobj_description" in sql else "1")
elif "-c" in args:
    sql = args[args.index("-c") + 1]
    identifiers = re.findall(r'(?:DATABASE|RENAME TO) ("[^"]+"|\w+)', sql)
    names = [name[1:-1] if name.startswith('"') else name.lower() for name in identifiers]
    if sql.startswith("CREATE DATABASE"):
        (state / names[0]).touch(exist_ok=False)
    elif sql.startswith("DROP DATABASE"):
        database(names[0]).unlink()
    elif sql.startswith("COMMENT ON DATABASE"):
        database(names[0]).write_text(re.search(r" IS '([^']+)'", sql)[1])
    elif sql.startswith("ALTER DATABASE"):
        path = database(names[0])
        if "RENAME TO" in sql:
            path.rename(state / names[1])
    elif not sql.startswith("CREATE SCHEMA"):
        sys.exit(f"Unexpected SQL in snapshot test: {sql}")
else:
    sys.stdin.read()
DOCKER
chmod +x "${test_dir}/bin/docker"

# Supply only synthetic configuration in the isolated test directory.
mkdir "${test_dir}/R-dataprocessor" "${test_dir}/Input-Repo"
printf 'DB_DATAPROCESSOR_USER = "dataprocessor"\n' > "${test_dir}/cds_hub_db_config.toml"
printf 'INPUT_REPO_PATH = "./Input-Repo"\n' > "${test_dir}/R-dataprocessor/dataprocessor_config.toml"

run_snapshot() {
    if ! output="$(cd "${test_dir}" && "${snapshot_script}" "$@" 2>&1)"; then
        printf '%s\n' "${output}" >&2
        exit 1
    fi
}

for snapshot_name in snapshot_20260903 MiXeD_20260903 SNAPSHOT_20260903; do
    printf 'SELECT 1;\n' | gzip > "${test_dir}/Snapshots/${snapshot_name}.sql.gz"
    run_snapshot activate "${snapshot_name}"
    [[ -f "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}" ]]
    run_snapshot deactivate "ip_${snapshot_name}" <<< 'y'
    [[ ! -e "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}" ]]

    # Retry paths must also drop incomplete targets with the exact name.
    touch "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}_pseud_build"
    run_snapshot pseudonymize "${snapshot_name}"
    for suffix in '' _pseud; do
        [[ -f "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}${suffix}" ]]
        [[ ! -e "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}${suffix}_build" ]]
    done
    touch "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}_pseud_broad_consent_build"
    run_snapshot create-broad-consent "${snapshot_name}_pseud"
    [[ -f "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}_pseud_broad_consent" ]]
    for suffix in '' _pseud _pseud_broad_consent; do
        run_snapshot deactivate "${snapshot_name}${suffix}" <<< 'y'
        [[ ! -e "${SNAPSHOT_TEST_DATABASES}/ip_${snapshot_name}${suffix}" ]]
        [[ -f "${test_dir}/Snapshots/${snapshot_name}${suffix}.sql.gz" ]]
    done
done

echo "Snapshot command tests passed."
