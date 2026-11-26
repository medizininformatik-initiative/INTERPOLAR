#!/usr/bin/env bash
set -euo pipefail

started_at=$(date -u +%Y-%m-%d_%H-%M-%SZ)
IFS= read -r version < /opt/app/release-version.txt || [[ -n "$version" ]]
version=$(printf '%s' "$version" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
version=${version#[vV]}
[[ "$version" =~ ^[[:alnum:]][[:alnum:].+-]*$ ]] || {
  echo "Invalid INTERPOLAR release version" >&2
  exit 1
}

# TOP uses the same connection settings for its queries.
content_type=$(PGPASSWORD="${DB_PASS:-}" psql -XAtw -v ON_ERROR_STOP=1 \
  -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
  -c "SELECT parameter_value FROM db2dataprocessor_out.v_db_parameter WHERE parameter_name = 'database_content_type'" \
  2>/dev/null) || content_type=
snapshot_date=unknown
if [[ "$DB_NAME" =~ ^ip_.+_([0-9]{8})(_pseud)?(_broad_consent)?(_build)?$ ]]; then
  digits=${BASH_REMATCH[1]}
  pseud_marker=${BASH_REMATCH[2]}
  candidate="${digits:0:4}-${digits:4:2}-${digits:6:2}"
  if date -u -d "$candidate" +%F >/dev/null 2>&1; then
    snapshot_date=$candidate
  fi
  if [[ -z "$content_type" ]]; then
    if [[ -n "$pseud_marker" ]]; then
      content_type=pseudonymized_snapshot
    else
      content_type=snapshot
    fi
  fi
elif [[ -z "$content_type" && "$DB_NAME" == cds_hub_db ]]; then
  content_type=live
fi
case "$content_type" in
  unpseudonymized_snapshot|snapshot) origin="snapshot-$snapshot_date" ;;
  pseudonymized_snapshot) origin="pseudonymized_snapshot-$snapshot_date" ;;
  live) origin=live ;;
  *) origin=unknown ;;
esac

bash run_queries.sh "$@"

archive_name="top-framework_${started_at}_toolchain-${version}_${origin}.zip"
for scope in outputGlobal outputLocal; do
  source_dir="$PWD/results/$scope"
  archive_dir="$PWD/results/archives/$scope"
  mapfile -d '' -t files < <(find "$source_dir" -type f -print0)
  (( ${#files[@]} > 0 )) || continue
  mkdir -p "$archive_dir"
  destination="$archive_dir/$archive_name"
  temporary_dir=$(mktemp -d "$archive_dir/.top-archive.XXXXXX")
  trap 'rm -rf -- "$temporary_dir"' EXIT
  zip -qjT "$temporary_dir/$archive_name" "${files[@]}"
  # Creating a hard link publishes the verified ZIP and fails if the name exists.
  ln "$temporary_dir/$archive_name" "$destination"
  rm -- "${files[@]}"
  find "$source_dir" -depth -type d -empty -delete
  rm -r -- "$temporary_dir"
  trap - EXIT
  printf 'TOP result archive: %s\n' "$destination"
done
