#!/bin/bash

# Ensure Poetry is installed and available in PATH
if ! command -v poetry &> /dev/null
then
    echo "Poetry could not be found. Please install Poetry first."
    exit
fi

if [ -n "$POSTGRES_PASSWORD" ]; then
    PASSWORD_ARG="--password $POSTGRES_PASSWORD"
else
    PASSWORD_ARG=""
fi

echo "Uploading CRUS table"
# Load CRUS
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table crus --input /data/CRUS+_31_mar_2025.shp --config /pygeoapi/docker.config.yml --template template_crus.yml
echo "Uploading CRUS childs views"
# Load CRUS based views
poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table crus --column Municipio --config /pygeoapi/docker.config.yml
echo "Uploading cos2018v3 table"
# Load cos2018v3
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table cos2018v3 --input /data/COS2018v3_municipios.shp --config /pygeoapi/docker.config.yml --template template_cos_2018.yml
# Load cos2018v3 based views
poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table cos2018v3 --column Municipio --config /pygeoapi/docker.config.yml --template template_view_cos2018v3.yml
# Load cos2023v1
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table cos2023v1 --input /data/COS2023v1_municipios.shp --config /pygeoapi/docker.config.yml --template template_cos_2023.yml
# Load cos2023v1 based views
poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table cos2023v1 --column Municipio --config /pygeoapi/docker.config.yml --template template_view_cos2023v1.yml

exit 0
