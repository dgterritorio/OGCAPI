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
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table cos2018v3 --input /data/COS2018v3_municipios.shp --config /pygeoapi/docker.config.yml --template template_cos.yml
# Load cos2018v3 based views
poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --table cos2018v3 --column Municipio --config /pygeoapi/docker.config.yml --template template_view_cos2018v3.yml
# Load cadastro
echo "Uploading CAOP municipios"
# Load CAOP - municipios
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table municipios --input /data/cont_municipios.gpkg --config /pygeoapi/docker.config.yml --template template_municipios.yml
echo "Uploading CAOP freguesias"
# Load CAOP - freguesias
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table freguesias --input /data/cont_freguesias.gpkg --config /pygeoapi/docker.config.yml --template template_freguesias.yml
echo "Uploading CAOP areas administrativas"
# Load CAOP - areas administrativas
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table area_administrativa --input /data/cont_areas_administrativas.gpkg --config /pygeoapi/docker.config.yml --template template_admin.yml
echo "Uploading CAOP nuts1"
# Load CAOP - nuts1
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table nuts1 --input /data/cont_nuts1.gpkg --config /pygeoapi/docker.config.yml --template template_nuts1.yml
echo "Uploading CAOP nuts2"
# Load CAOP - nuts2
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table nuts2 --input /data/cont_nuts2.gpkg --config /pygeoapi/docker.config.yml --template template_nuts2.yml
echo "Uploading CAOP nuts3"
# Load CAOP - nuts3
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table nuts3 --input /data/cont_nuts3.gpkg --config /pygeoapi/docker.config.yml --template template_nuts3.yml
echo "Uploading CAOP trocos"
# Load CAOP - trocos
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table trocos --input /data/cont_trocos.gpkg --config /pygeoapi/docker.config.yml --template template_trocos.yml
echo "Uploading CAOP distritos"
# Load CAOP - distritos
poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER $PASSWORD_ARG --primary_key fid --table distritos --input /data/cont_distritos.gpkg --config /pygeoapi/docker.config.yml --template template_distritos.yml


exit 0
