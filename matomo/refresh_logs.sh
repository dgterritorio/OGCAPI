#!/bin/bash
set -eo pipefail

# Simple, robust Apache log import script for Matomo
# Designed for Docker container with cron execution every 60 seconds

# ============================================================================
# Configuration
# ============================================================================
readonly INPUT_FILE="/apache/access_log.log"
readonly NUM_ROWS=1000
readonly MAX_LINES=500000
readonly TEMP_FILE="/state/matomo_import_$$.log"
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

# Simple logging with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Exit with error
die() {
    log "ERROR: $1"
    exit 1
}

# Cleanup on exit
cleanup() {
    rm -f "$TEMP_FILE"
    rm -f "$LOCK_FILE"
}

# Extract timestamp from Apache log line
# Example: 127.0.0.1 - - [10/Oct/2023:13:55:36 +0000] "GET / HTTP/1.1" 200 2326
get_line_timestamp() {
    echo "$1" | sed -n 's/.*\[\([^]]*\)\].*/\1/p'
}

# Compare Apache timestamps (returns 0 if ts1 > ts2)
# Using sort -V for version sort which handles the timestamp format well
timestamp_greater_than() {
    local ts1="$1"
    local ts2="$2"
    
    # If either timestamp is empty, handle gracefully
    [ -z "$ts1" ] || [ -z "$ts2" ] && return 1
    
    # Use sort to compare - if ts1 comes after ts2, it's greater
    [ "$(printf '%s\n%s\n' "$ts2" "$ts1" | sort -V | tail -1)" = "$ts1" ] && [ "$ts1" != "$ts2" ]
}

# ============================================================================
# Main Script
# ============================================================================

# Set trap for cleanup
trap cleanup EXIT

log "Starting Apache log import"

# Check lock file to prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    # Check if lock is stale (older than 5 minutes)
    if [ -n "$(find "$LOCK_FILE" -mmin +5 2>/dev/null)" ]; then
        log "Removing stale lock file"
        rm -f "$LOCK_FILE"
    else
        log "Another import is running, exiting"
        exit 0
    fi
fi

# Create lock file
touch "$LOCK_FILE"

# Validate environment
[ -f "$INPUT_FILE" ] || die "Log file not found: $INPUT_FILE"
[ -n "$USER_MATOMO" ] || die "USER_MATOMO not set"
[ -n "$PASSWORD_MATOMO" ] || die "PASSWORD_MATOMO not set"

# Ensure state directory exists
mkdir -p "$STATE_DIR" || die "Cannot create state directory: $STATE_DIR"

# Get last processed timestamp
LAST_TIMESTAMP=""
if [ -f "$TIMESTAMP_FILE" ]; then
    LAST_TIMESTAMP=$(cat "$TIMESTAMP_FILE" 2>/dev/null || echo "")
    log "Last processed timestamp: $LAST_TIMESTAMP"
else
    log "No previous timestamp found"
fi

# Count total lines
TOTAL_LINES=$(wc -l < "$INPUT_FILE")
log "Total lines in log: $TOTAL_LINES"

# Handle initial run for large files
if [ -z "$LAST_TIMESTAMP" ] && [ "$TOTAL_LINES" -gt "$MAX_LINES" ]; then
    # Start from recent logs only
    START_LINE=$((TOTAL_LINES - MAX_LINES + 1))
    log "Large file on first run, starting from line $START_LINE"
    
    # Get timestamp from start line
    FIRST_LINE=$(sed -n "${START_LINE}p" "$INPUT_FILE")
    LAST_TIMESTAMP=$(get_line_timestamp "$FIRST_LINE")
    
    # If we can't get timestamp, fall back to processing last N lines anyway
    if [ -z "$LAST_TIMESTAMP" ]; then
        log "Could not extract timestamp, processing last $NUM_ROWS lines"
        tail -n "$NUM_ROWS" "$INPUT_FILE" > "$TEMP_FILE"
    fi
fi

# Extract new lines based on timestamp
if [ -n "$LAST_TIMESTAMP" ]; then
    # Process lines with timestamps newer than last processed
    log "Extracting lines newer than: $LAST_TIMESTAMP"
    
    LINE_COUNT=0
    NEWEST_TIMESTAMP="$LAST_TIMESTAMP"
    
    # Read file line by line and extract newer entries
    while IFS= read -r line; do
        # Get timestamp from current line
        CURRENT_TS=$(get_line_timestamp "$line")
        
        # Skip lines without valid timestamp
        [ -z "$CURRENT_TS" ] && continue
        
        # Check if this line is newer than our last processed timestamp
        if timestamp_greater_than "$CURRENT_TS" "$LAST_TIMESTAMP"; then
            echo "$line" >> "$TEMP_FILE"
            LINE_COUNT=$((LINE_COUNT + 1))
            
            # Update newest timestamp
            if timestamp_greater_than "$CURRENT_TS" "$NEWEST_TIMESTAMP"; then
                NEWEST_TIMESTAMP="$CURRENT_TS"
            fi
            
            # Stop if we've collected enough lines
            [ "$LINE_COUNT" -ge "$NUM_ROWS" ] && break
        fi
    done < "$INPUT_FILE"
    
    log "Extracted $LINE_COUNT new lines"
else
    # No timestamp available, process last NUM_ROWS lines
    log "Processing last $NUM_ROWS lines"
    tail -n "$NUM_ROWS" "$INPUT_FILE" > "$TEMP_FILE"
    LINE_COUNT=$(wc -l < "$TEMP_FILE")
    
    # Get timestamp from last line
    if [ "$LINE_COUNT" -gt 0 ]; then
        LAST_LINE=$(tail -1 "$TEMP_FILE")
        NEWEST_TIMESTAMP=$(get_line_timestamp "$LAST_LINE")
    fi
fi

# Check if we have lines to process
if [ "$LINE_COUNT" -eq 0 ] || [ ! -s "$TEMP_FILE" ]; then
    log "No new lines to process"
    exit 0
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
    
    # Update timestamp only on successful import
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