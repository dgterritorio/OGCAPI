#!/bin/bash

echo "*** Start import with following username"
echo $USER_MATOMO

python3 /var/www/html/misc/log-analytics/import_logs.py --url=http://matomo \
 --login=$USER_MATOMO --password=$PASSWORD_MATOMO --idsite=1 --recorders=4 /apache/access_log.log \
&& /var/www/html/console core:archive --force-all-websites --url='http://matomo'

echo "*** Finish import with credentials"