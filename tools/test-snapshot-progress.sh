#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${repo_root}/tools/snapshot-progress.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
DIR="$test_dir"
# Accelerate only the observer in this test; no production interval option.
sleep() { command sleep 0.05; }
docker() { printf '2|1|0\n'; }
write_dump() {
    printf 'unchanged dump bytes\n'
    command sleep 0.2
}
# The observer reads only file metadata while the command writes the dump.
# shellcheck disable=SC2094
run_with_snapshot_progress "Test export" source target "$test_dir/dump" write_dump \
    > "$test_dir/dump" 2> "$test_dir/console"
printf 'unchanged dump bytes\n' > "$test_dir/expected"
cmp "$test_dir/expected" "$test_dir/dump"
rg -q 'compressed bytes written=21' "$test_dir/console"
rg -q 'waiting for locks=1' "$test_dir/console"
cmp "$test_dir/console" "$test_dir/snapshot-progress.log"
# A failed status probe must not fail the actual command or expose stderr.
docker() { printf 'PRIVATE diagnostic\n' >&2; return 1; }
run_with_snapshot_progress "Unavailable status" source target "" write_dump \
    > /dev/null 2> "$test_dir/unavailable"
rg -q 'database wait status unavailable' "$test_dir/unavailable"
if rg -q 'PRIVATE' "$test_dir/unavailable" "$test_dir/snapshot-progress.log"; then exit 1; fi
fail_command() { return 17; }
if run_with_snapshot_progress "Failed workload" source target "" fail_command 2> "$test_dir/failure"; then
    echo 'Workload failure was swallowed.' >&2
    exit 1
else
    status=$?
    [[ $status -eq 17 ]]
fi
# No observer should continue appending after its workload has ended.
cp "$test_dir/snapshot-progress.log" "$test_dir/finished-log"
command sleep 0.15
cmp "$test_dir/snapshot-progress.log" "$test_dir/finished-log"
echo 'Snapshot progress tests passed.'
