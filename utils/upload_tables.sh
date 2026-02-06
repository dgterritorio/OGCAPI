#!/bin/bash

# Ensure Poetry is installed and available in PATH
if ! command -v poetry &> /dev/null
then
    echo "Poetry could not be found. Please install Poetry first."
    exit
fi

if [ -n "$REMOTE_COS_PASSWORD" ]; then
    PASSWORD_ARG="--password $REMOTE_COS_PASSWORD"
else
    PASSWORD_ARG=""
fi

echo "Uploading cos2018v3 table"
# Load cos2018v3
poetry run python3 ./upload_tables.py --host postgis  --database $REMOTE_COS_DB --user $REMOTE_COS_USER $PASSWORD_ARG --table cos2018v3 --input /data/COS2018v3_municipios.shp
# Load cos2023v1
poetry run python3 ./upload_tables.py --host postgis  --database $REMOTE_COS_DB --user $REMOTE_COS_USER $PASSWORD_ARG --table cos2023v1 --input /data/COS2023v1_municipios.shp

exit 0
