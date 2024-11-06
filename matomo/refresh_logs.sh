#!/bin/bash

echo "*** Start import with following username"

INPUT_FILE="/apache/access_log.log"
NUM_ROWS="1000"
DESTINATION_FILE="/tmp/temp.log"

# File to store last read line
LAST_LINE_FILE=".lastline_$(basename "$INPUT_FILE")"

# Check of last line already exists
if [ -f "$LAST_LINE_FILE" ]; then
    LAST_LINE=$(cat "$LAST_LINE_FILE")
else
    LAST_LINE=1
fi

# Calculate last row
END_LINE=$((LAST_LINE + NUM_ROWS - 1))

# Number of lines in INPUT file
TOTAL_LINES=$(wc -l < "$INPUT_FILE")

# Check if there are new lines to read
if [ "$TOTAL_LINES" -lt "$LAST_LINE" ]; then
    echo "There are no new lines to read."
    exit 0
fi

# If END_LINE is greater of end line, select last line of the file
if [ "$TOTAL_LINES" -lt "$END_LINE" ]; then
    END_LINE="$TOTAL_LINES"
fi

# Extract the set to ingest
sed -n "${LAST_LINE},${END_LINE}p" "$INPUT_FILE" > "$DESTINATION_FILE"

# Update LAST_LINE for the next run
LAST_LINE=$((END_LINE + 1))
echo "$LAST_LINE" > "$LAST_LINE_FILE"

# Ingest the set of rows of this run
python3 /var/www/html/misc/log-analytics/import_logs.py --url=http://matomo \
 --login=$USER_MATOMO --password=$PASSWORD_MATOMO --idsite=1 --recorders=4 /tmp/temp.log \
&& /var/www/html/console core:archive --force-all-websites --url='http://matomo'

echo "*** Finish import with credentials"