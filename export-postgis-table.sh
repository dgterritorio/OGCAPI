docker run -v /tmp/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr \
  -f GPKG /tmp/data/output.gpkg \
  PG:"dbname='COS' host='192.168.1.105' port='5432' user='jsimoes' password=$POSTGRES_PASS" \
  "cos2018v2"