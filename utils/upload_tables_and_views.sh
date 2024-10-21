#!/bin/bash

# Ensure Poetry is installed and available in PATH
if ! command -v poetry &> /dev/null
then
    echo "Poetry could not be found. Please install Poetry first."
    exit
fi

# Load CRUS
poetry run python3 ./upload_tables.py --host postgis  --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table crus --input /data/CRUS+_31_julho2024.shp --config /pygeoapi/docker.config.yml

# Load CRUS based views
poetry run python3 ./create_views.py --host postgis --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table crus --column Municipio --config /pygeoapi/docker.config.yml

exit 0
