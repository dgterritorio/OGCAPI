#!/usr/bin/env bash
# Reload log files into matomo

python3 /var/www/html/misc/log-analytics/import_logs.py --url=http://matomo \
 --login=user --password=matomo --idsite=1 --recorders=4 /apache/access_log.log \
&& /var/www/html/console core:archive --force-all-websites --url='http://matomo'