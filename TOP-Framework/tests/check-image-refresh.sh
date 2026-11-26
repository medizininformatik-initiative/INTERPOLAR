#!/usr/bin/env bash
# Verify that a failed refresh cannot silently use an old image or rotate outputs.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/top-refresh-test.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/TOP-Framework" "$work/bin" "$work/outputLocal/top-study" "$work/outputGlobal/top-study"
cp "$root/TOP-Framework/run-top-study.sh" "$root/TOP-Framework/image.txt" "$work/TOP-Framework/"
touch "$work/TOP-Framework/database.toml"
printf 'private\n' > "$work/outputLocal/top-study/result.txt"
printf 'aggregate\n' > "$work/outputGlobal/top-study/report.txt"
cat > "$work/bin/docker" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$TEST_DOCKER_CALLS"
exit 17
EOF
chmod +x "$work/bin/docker"
code=0
PATH="$work/bin:$PATH" TEST_DOCKER_CALLS="$work/calls.txt" \
  bash "$work/TOP-Framework/run-top-study.sh" > "$work/console.log" 2>&1 || code=$?
[[ "$code" -eq 17 ]]
[[ $(cat "$work/calls.txt") == 'pull ghcr.io/onto-med/top-interpolar-algorithms:latest' ]]
[[ $(cat "$work/outputLocal/top-study/result.txt") == private ]]
[[ $(cat "$work/outputGlobal/top-study/report.txt") == aggregate ]]
[[ ! -d "$work/outputLocal/.top-study.lock" ]]
[[ $(find "$work/outputLocal" "$work/outputGlobal" -type d -name 'top-study_*' | wc -l) -eq 0 ]]
printf 'PASS: latest refresh is mandatory; pull failure preserves outputs and releases the lock.\n'
