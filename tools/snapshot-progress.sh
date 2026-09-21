#!/usr/bin/env bash
# Observe existing commands without changing their input, output or exit status.
# Status messages go to stderr, never into a redirected SQL/gzip dump.
snapshot_progress_message() {
    local line
    line="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    printf '%s\n' "$line" >&2
    if [[ -n "${snapshot_progress_log:-}" ]]; then
        printf '%s\n' "$line" >> "$snapshot_progress_log" || :
    fi
}

snapshot_database_status() {
    local result
    # Only aggregate wait states; never retrieve query texts, IDs or row values.
    # This covers all sessions in the involved databases, including other jobs.
    result=$(docker compose exec -T \
        -e PGOPTIONS='-c statement_timeout=2000 -c default_transaction_read_only=on' \
        -e PGCONNECT_TIMEOUT=5 cds_hub \
        psql -X -A -t -U cds_hub_db_admin -d postgres \
        -v ON_ERROR_STOP=1 -v source_db="$1" -v target_db="$2" 2>/dev/null <<'SQL'
SELECT count(*) FILTER (WHERE state = 'active'),
       count(*) FILTER (WHERE state = 'active' AND wait_event_type = 'Lock'),
       count(*) FILTER (WHERE state = 'active' AND wait_event_type IS NOT NULL
                        AND wait_event_type <> 'Lock')
FROM pg_stat_activity
WHERE datname IN (:'source_db', :'target_db') AND pid <> pg_backend_pid();
SQL
    ) || result=""
    if [[ "$result" =~ ^[0-9]+\|[0-9]+\|[0-9]+$ ]]; then
        local active locks other
        IFS='|' read -r active locks other <<< "$result"
        printf 'database sessions: active=%s, waiting for locks=%s, other waits=%s (includes other jobs)' "$active" "$locks" "$other"
    else
        printf 'database wait status unavailable'
    fi
}

run_with_snapshot_progress() (
    local label="$1" source_db="$2" target_db="$3" output_file="$4"
    shift 4
    local started=$SECONDS observer_pid status
    local snapshot_progress_log="${DIR:-Snapshots}/snapshot-progress.log"
    if ! touch "$snapshot_progress_log" 2>/dev/null; then
        snapshot_progress_log=""
        printf 'Snapshot progress log unavailable; status is shown in the console.\n' >&2
    fi
    snapshot_progress_message "$label: started; progress log: ${snapshot_progress_log:-unavailable}"
    (
        # Killing the observer also stops its current sleep/status subprocess.
        child_pid=""
        trap 'if [[ -n "$child_pid" ]]; then kill "$child_pid" 2>/dev/null || :; wait "$child_pid" 2>/dev/null || :; fi; exit' TERM INT
        while true; do
            sleep 30 &
            child_pid=$!
            wait "$child_pid" || exit
            child_pid=""
            size=""
            if [[ -n "$output_file" && -f "$output_file" ]]; then
                size="; compressed bytes written=$(stat -c %s "$output_file" 2>/dev/null || stat -f %z "$output_file" 2>/dev/null || printf unavailable)"
            fi
            snapshot_progress_message "$label: not finished; elapsed=$((SECONDS - started))s$size"
            (snapshot_progress_message "$label: $(snapshot_database_status "$source_db" "$target_db")") &
            # The status call is deliberately separate from the workload.
            child_pid=$!
            wait "$child_pid" || :
            child_pid=""
        done
    ) &
    observer_pid=$!
    trap 'kill "$observer_pid" 2>/dev/null || :; wait "$observer_pid" 2>/dev/null || :' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    if "$@"; then status=0; else status=$?; fi
    kill "$observer_pid" 2>/dev/null || :
    wait "$observer_pid" 2>/dev/null || :
    trap - EXIT
    snapshot_progress_message "$label: finished with exit status $status; elapsed=$((SECONDS - started))s; progress log: ${snapshot_progress_log:-unavailable}"
    exit "$status"
)
