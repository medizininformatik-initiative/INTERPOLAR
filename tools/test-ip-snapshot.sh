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

echo "Snapshot command tests passed."
