# Data upload utility

This folder contains python scripts to upload Shapefiles to the PostGIS database, to create automatically SQL views and to update pygeoapy configurations.

To init the environment you need to install poetry, then run

```
poetry shell
poetry install
```

To load table crus and update docker.config.yml

```
poetry run python3 ./upload_tables.py --user postgres --password SOMEPASSWORD
```

To generate views for crus and update docker.config.yml

```
poetry run python3 ./create_views.py --user postgres --password SOMEPASSWORD --table crus --column Municipio
```