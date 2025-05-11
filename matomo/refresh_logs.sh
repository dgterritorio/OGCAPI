#!/bin/bash
set -euo pipefail

echo "*** Start import with line-offset tracking ***"

INPUT_FILE="/apache/access_log.log"
NUM_ROWS=1000
DESTINATION_FILE="/tmp/temp.log"
LAST_LINE_FILE=".lastline_$(basename "$INPUT_FILE")"

# Read last processed line or start at 1
if  [ -f "$LAST_LINE_FILE" ]; then
LAST_LINE=$(<"$LAST_LINE_FILE")
else
LAST_LINE=1
fi

# Count total lines in log
TOTAL_LINES=$(wc -l < "$INPUT_FILE")

# If no new lines, exit
if  [ "$TOTAL_LINES" -le "$LAST_LINE" ]; then
echo "No new lines to process."
exit 0
fi

# Compute end line (process up to NUM_ROWS or all new lines)
END_LINE=$(( LAST_LINE + NUM_ROWS - 1 ))
if [ "$END_LINE" -gt "$TOTAL_LINES" ]; then
END_LINE=$TOTAL_LINES
fi

# Extract new lines
sed -n "${LAST_LINE},${END_LINE}p" "$INPUT_FILE" > "$DESTINATION_FILE"

# Update LAST_LINE for next run
NEXT_LINE=$(( END_LINE + 1 ))
printf "%d" "$NEXT_LINE" > "$LAST_LINE_FILE"

# Send to matomo
python3 /var/www/html/misc/log-analytics/import_logs.py --url=http://matomo \
 --login=$USER_MATOMO --password=$PASSWORD_MATOMO --idsite=1 --recorders=4 "$DESTINATION_FILE" \
&& /var/www/html/console core:archive --force-all-websites --url='http://matomo'

echo "*** Finish import ***"

