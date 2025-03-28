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
    poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table crus --input /data/CRUS+_31_julho2024.shp --config /pygeoapi/docker.config.yml --template template_crus.yml
    echo "Uploading CRUS childs views"
    # Load CRUS based views
    poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table crus --column Municipio --config /pygeoapi/docker.config.yml
    echo "Uploading COS table"
    # Load COS
    poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table cos --input /data/COS2018v2_municipios.gpkg --config /pygeoapi/docker.config.yml --template template_cos.yml
    # Load COS based views
    poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --table cos --column Municipio --config /pygeoapi/docker.config.yml --template template_cos_view.yml
    # echo "Uploading cadastro table"
    # # Load cadastro
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key id --table cadastro --input /data/cadastralparcel.gpkg --config /pygeoapi/docker.config.yml --template template_cadastro.yml
    # echo "Uploading CAOP municipios"
    # # Load CAOP - municipios
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table caop --input /data/cont_municipios.gpkg --config /pygeoapi/docker.config.yml --template template_municipios.yml
    # echo "Uploading CAOP freguesias"
    # # Load CAOP - freguesias
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table freguesias --input /data/cont_freguesias.gpkg --config /pygeoapi/docker.config.yml --template template_freguesias.yml
    # echo "Uploading CAOP areas administrativas"
    # # Load CAOP - areas administrativas
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table admin --input /data/cont_areas_administrativas.gpkg --config /pygeoapi/docker.config.yml --template template_admin.yml
    # echo "Uploading CAOP nuts1"
    # # Load CAOP - nuts1
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table nuts1 --input /data/cont_nuts1.gpkg --config /pygeoapi/docker.config.yml --template template_nuts1.yml
    # echo "Uploading CAOP nuts2"
    # # Load CAOP - nuts2
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table nuts2 --input /data/cont_nuts2.gpkg --config /pygeoapi/docker.config.yml --template template_nuts2.yml
    # echo "Uploading CAOP nuts3"
    # # Load CAOP - nuts3
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table nuts3 --input /data/cont_nuts3.gpkg --config /pygeoapi/docker.config.yml --template template_nuts3.yml
    # echo "Uploading CAOP trocos"
    # # Load CAOP - trocos
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table trocos --input /data/cont_trocos.gpkg --config /pygeoapi/docker.config.yml --template template_trocos.yml
    # echo "Uploading CAOP distritos"
    # # Load CAOP - distritos
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --password $POSTGRES_PASSWORD --primary_key fid --table distritos --input /data/cont_distritos.gpkg --config /pygeoapi/docker.config.yml --template template_distritos.yml
else
    echo "Uploading CRUS table"
    # Load CRUS
    poetry run python3 ./upload_tables.py --host postgis --database $POSTGRES_DB  --user $POSTGRES_USER --table crus --input /data/CRUS+_31_julho2024.shp --config /pygeoapi/docker.config.yml --template template_crus.yml
    echo "Uploading CRUS childs views"
    # Load CRUS based views
    poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --table crus --column Municipio --config /pygeoapi/docker.config.yml
    echo "Uploading COS table"
    # Load COS
    poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --table cos --input /data/COS2018v2_municipios.gpkg --config /pygeoapi/docker.config.yml --template template_cos.yml
    # Load COS based views
    poetry run python3 ./create_views.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --table cos --column Municipio --config /pygeoapi/docker.config.yml --template template_cos_view.yml
    # echo "Uploading cadastro table"
    # # Load cadastro
    # poetry run python3 ./upload_tables.py --host postgis --database $POSTGRES_DB --user $POSTGRES_USER --table cadastro --primary_key id --input /data/cadastralparcel.gpkg --config /pygeoapi/docker.config.yml --template template_cadastro.yml
    # echo "Uploading CAOP municipios"
    # # Load CAOP - municipios
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table caop --input /data/cont_municipios.gpkg --config /pygeoapi/docker.config.yml --template template_municipios.yml
    # echo "Uploading CAOP freguesias"
    # # Load CAOP - freguesias
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table freguesias --input /data/cont_freguesias.gpkg --config /pygeoapi/docker.config.yml --template template_freguesias.yml
    # echo "Uploading CAOP areas administrativas"
    # # Load CAOP - areas administrativas
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table admin --input /data/cont_areas_administrativas.gpkg --config /pygeoapi/docker.config.yml --template template_admin.yml
    # echo "Uploading CAOP nuts1"
    # # Load CAOP - nuts1
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table nuts1 --input /data/cont_nuts1.gpkg --config /pygeoapi/docker.config.yml --template template_nuts1.yml
    # echo "Uploading CAOP nuts2"
    # # Load CAOP - nuts2
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table nuts2 --input /data/cont_nuts2.gpkg --config /pygeoapi/docker.config.yml --template template_nuts2.yml
    # echo "Uploading CAOP nuts3"
    # # Load CAOP - nuts3
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table nuts3 --input /data/cont_nuts3.gpkg --config /pygeoapi/docker.config.yml --template template_nuts3.yml
    # echo "Uploading CAOP trocos"
    # # Load CAOP - trocos
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table trocos --input /data/cont_trocos.gpkg --config /pygeoapi/docker.config.yml --template template_trocos.yml
    # echo "Uploading CAOP distritos"
    # # Load CAOP - distritos
    # poetry run python3 ./upload_tables.py --host postgis  --database $POSTGRES_DB --user $POSTGRES_USER --primary_key fid --table distritos --input /data/cont_distritos.gpkg --config /pygeoapi/docker.config.yml --template template_distritos.yml


fi


exit 0
