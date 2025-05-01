#!/bin/bash

echo "*** Start import with following username"

INPUT_FILE="/apache/access_log.log"
NUM_ROWS="1000"
DESTINATION_FILE="/tmp/temp.log"
DEBUG="1"

# File to store the last line read
LAST_LINE_FILE=".lastline_$(basename "$INPUT_FILE")"

# Check if the LAST_LINE_FILE exists, otherwise start from 1
if [ -f "$LAST_LINE_FILE" ]; then
    LAST_LINE=$(cat "$LAST_LINE_FILE")
else
    LAST_LINE=1
fi

# Calculate the ending line
END_LINE=$((LAST_LINE + NUM_ROWS - 1))

# Get the total number of lines in INPUT_FILE
TOTAL_LINES=$(wc -l < "$INPUT_FILE")

# Check if there are new lines to read
if [ "$TOTAL_LINES" -lt "$LAST_LINE" ]; then
    echo "No new lines to read."

    # If DEBUG is set, print execution paths and variable values
    if [ "$DEBUG" = "1" ]; then
        echo "Debug Information:"
        echo "INPUT_FILE: $INPUT_FILE"
        echo "NUM_ROWS: $NUM_ROWS"
        echo "DESTINATION_FILE: $DESTINATION_FILE"
        echo "LAST_LINE_FILE: $LAST_LINE_FILE"
        echo "LAST_LINE: $LAST_LINE"
        echo "END_LINE: $END_LINE"
        echo "TOTAL_LINES: $TOTAL_LINES"
        echo "Current Directory: $(pwd)"
        echo "Script Path: $(realpath "$0")"
    fi

    exit 0
fi

# If END_LINE exceeds TOTAL_LINES, set it to TOTAL_LINES
if [ "$TOTAL_LINES" -lt "$END_LINE" ]; then
    END_LINE="$TOTAL_LINES"
fi

# Extract lines from LAST_LINE to END_LINE
sed -n "${LAST_LINE},${END_LINE}p" "$INPUT_FILE" > "$DESTINATION_FILE"

# Update LAST_LINE for the next execution
LAST_LINE=$((END_LINE + 1))
echo "$LAST_LINE" > "$LAST_LINE_FILE"

# Ingest the set of rows of this run
python3 /var/www/html/misc/log-analytics/import_logs.py --url=http://matomo \
 --login=$USER_MATOMO --password=$PASSWORD_MATOMO --idsite=1 --recorders=4 /tmp/temp.log \
&& /var/www/html/console core:archive --force-all-websites --url='http://matomo'

echo "*** Finish import with credentials"