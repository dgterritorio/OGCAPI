#!/bin/bash

# Ensure Poetry is installed and available in PATH
if ! command -v poetry &> /dev/null
then
    echo "Poetry could not be found. Please install Poetry first."
    exit
fi


if [ -n "$POSTGRES_PASSWORD" ]; then
    echo "Uploading CRUS table"
    # Load CRUS
    poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table crus --input /data/CRUS+_31_julho2024.shp --config /pygeoapi/docker.config.yml
    echo "Uploading CRUS childs views"
    # Load CRUS based views
    poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table crus --column Municipio --config /pygeoapi/docker.config.yml

else
    echo "Uploading CRUS table"
    # Load CRUS
    poetry run python3 ./upload_tables.py --host postgis --database $POSTGRES_DB  --user $POSTGRES_USER --table crus --input /data/CRUS+_31_julho2024.shp --config /pygeoapi/docker.config.yml
    echo "Uploading CRUS childs views"
    # Load CRUS based views
    poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --table crus --column Municipio --config /pygeoapi/docker.config.yml

fi


exit 0
