#!/bin/bash
set -eo pipefail

# Apache log import script for Matomo - Timestamp-based tracking
# Designed for Docker container with cron execution every 60 seconds

# ============================================================================
# Configuration
# ============================================================================
readonly INPUT_FILE="/apache/access_log.log"
readonly NUM_ROWS=2000
readonly MAX_LINES=10000
readonly TEMP_FILE="/tmp/matomo_import_$$.log"
readonly STATE_DIR="${STATE_DIR:-/state}"
readonly TIMESTAMP_FILE="${STATE_DIR}/.last_timestamp"
readonly LOCK_FILE="${STATE_DIR}/.import.lock"

# Matomo settings
readonly MATOMO_URL="http://matomo"
readonly MATOMO_SITE_ID=1
readonly MATOMO_RECORDERS=4

# ============================================================================
# Functions
# ============================================================================

# Logging to stderr to avoid output capture issues
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

die() {
    log "ERROR: $1"
    exit 1
}

cleanup() {
    rm -f "$TEMP_FILE"
    rm -f "$LOCK_FILE"
}

# Extract timestamp from Apache log line
get_line_timestamp() {
    echo "$1" | sed -n 's/.*\[\([^]]*\)\].*/\1/p'
}

# Convert Apache timestamp to epoch seconds for comparison
timestamp_to_epoch() {
    local ts="$1"
    # Replace all '/' with space
    ts="${ts//\// }"
    # Replace first ':' after year with space
    ts="${ts/:/ }"
    date -d "$ts" +%s 2>/dev/null || echo 0
}

# ============================================================================
# Main Script
# ============================================================================
# Before exiting, ensure cleanup is done
trap cleanup EXIT

log "Starting Apache log import"

# Check lock
if [ -f "$LOCK_FILE" ]; then
    if [ -n "$(find "$LOCK_FILE" -mmin +5 2>/dev/null)" ]; then
        log "Removing stale lock file"
        rm -f "$LOCK_FILE"
    else
        log "Another import is running, exiting"
        exit 0
    fi
fi
touch "$LOCK_FILE"

# Validate
[ -f "$INPUT_FILE" ] || die "Log file not found: $INPUT_FILE"
[ -n "$USER_MATOMO" ] || die "USER_MATOMO not set"
[ -n "$PASSWORD_MATOMO" ] || die "PASSWORD_MATOMO not set"
mkdir -p "$STATE_DIR" || die "Cannot create state directory"

# Get state
LAST_TIMESTAMP=""
LAST_EPOCH=0
if [ -f "$TIMESTAMP_FILE" ]; then
    LAST_TIMESTAMP=$(cat "$TIMESTAMP_FILE" 2>/dev/null || echo "")
    if [ -n "$LAST_TIMESTAMP" ]; then
        LAST_EPOCH=$(timestamp_to_epoch "$LAST_TIMESTAMP")
        log "Last processed: $LAST_TIMESTAMP (epoch: $LAST_EPOCH)"
    fi
fi

# Count total lines
TOTAL_LINES=$(wc -l < "$INPUT_FILE")
log "Total lines in log: $TOTAL_LINES"

# Process logs
LINE_COUNT=0
NEWEST_TIMESTAMP=""
NEWEST_EPOCH=0

if [ -z "$LAST_TIMESTAMP" ] || [ "$LAST_EPOCH" -eq 0 ]; then
    # Initial run - process last NUM_ROWS lines
    log "Initial run, processing last $NUM_ROWS lines"
    tail -n "$NUM_ROWS" "$INPUT_FILE" > "$TEMP_FILE"
    LINE_COUNT=$(wc -l < "$TEMP_FILE")
else
    # Find approximate position using binary search
    # For large files, start from recent portion only
    if [ "$TOTAL_LINES" -gt "$MAX_LINES" ]; then
        START_FROM=$((TOTAL_LINES - MAX_LINES))
        log "Large file, searching from line $START_FROM"
    else
        START_FROM=1
    fi
    
    # Extract lines newer than last timestamp
    log "Extracting lines newer than: $LAST_TIMESTAMP"
    
    # Process file from START_FROM, looking for newer timestamps
    while IFS= read -r line; do
        # Get timestamp
        current_ts=$(get_line_timestamp "$line")
        [ -z "$current_ts" ] && continue

        # Convert to epoch
        current_epoch=$(timestamp_to_epoch "$current_ts")
        [ "$current_epoch" -eq 0 ] && continue

        echo "Processing line: $line"
        echo "current_ts='$current_ts', current_epoch='$current_epoch', LAST_EPOCH='$LAST_EPOCH'"


        # Check if newer
        if [ "$current_epoch" -gt $((LAST_EPOCH + 1)) ]; then
            echo "$line" >> "$TEMP_FILE"
            
            # Check line count
            count=$(wc -l < "$TEMP_FILE" 2>/dev/null || echo 0)
            [ "$count" -ge "$NUM_ROWS" ] && break
        fi
    done < <(tail -n "+$START_FROM" "$INPUT_FILE")

    LINE_COUNT=$(wc -l < "$TEMP_FILE" 2>/dev/null || echo 0)
    log "Extracted $LINE_COUNT new lines"
fi

# Check if we have data
if [ "$LINE_COUNT" -eq 0 ] || [ ! -s "$TEMP_FILE" ]; then
    log "No new lines to process"
    exit 0
fi

# Get newest timestamp from last line
LAST_LINE=$(tail -1 "$TEMP_FILE")
NEWEST_TIMESTAMP=$(get_line_timestamp "$LAST_LINE")
if [ -z "$NEWEST_TIMESTAMP" ]; then
    log "Warning: Could not extract timestamp from last line"
    NEWEST_TIMESTAMP="$LAST_TIMESTAMP"
fi

# Import to Matomo
log "Importing $LINE_COUNT lines to Matomo"

if python3 /var/www/html/misc/log-analytics/import_logs.py \
    --url="$MATOMO_URL" \
    --login="$USER_MATOMO" \
    --password="$PASSWORD_MATOMO" \
    --idsite="$MATOMO_SITE_ID" \
    --recorders="$MATOMO_RECORDERS" \
    "$TEMP_FILE"; then
    
    # Update state only on success
    if [ -n "$NEWEST_TIMESTAMP" ]; then
        echo "$NEWEST_TIMESTAMP" > "$TIMESTAMP_FILE"
        log "Updated timestamp to: $NEWEST_TIMESTAMP"
    fi
    
    # Archive
    log "Running Matomo archive"
    /var/www/html/console core:archive --force-all-websites --url="$MATOMO_URL" || \
        log "Warning: Archive command failed (non-fatal)"
    
    log "Import completed successfully"
else
    die "Matomo import failed"
fi