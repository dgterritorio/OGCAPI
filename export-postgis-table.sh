docker run -v /tmp/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr \
  -f GPKG /tmp/data/output.gpkg \
  PG:"dbname='COS' host='192.168.1.105' port='5432' user='jsimoes' password=$POSTGRES_PASS" \
  "cos2018v2"

docker run -v /tmp/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr   \
-f GPKG /tmp/data/cadastralparcel.gpkg   PG:"dbname='inspire' host='192.168.10.53' port='5432' user='cpogcapi2025' password=$POSTGRES_PASS"   "inspire.cadastralparcel"


docker run -v /tmp/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr   \
-f GPKG /tmp/data/cadastralparcel.gpkg   PG:"dbname='inspire' host='192.168.10.53' port='5432' user='cpogcapi2025' password=$POSTGRES_PASS"   "inspire.cadastralparcel"


docker run -v /tmp/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_distritos.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_distritos"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_freguesias.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_freguesias"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_municipios.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_municipios"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_nuts1.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_nuts1"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_nuts2.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_nuts2"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_nuts3.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_nuts3"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_trocos.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_trocos"

docker run -v /home/byteroad/git/ogcapi-simple/data:/tmp/data \
ghcr.io/osgeo/gdal:ubuntu-full-3.8.4  \
ogr2ogr  \
  -f 'GPKG' /tmp/data/cont_distritos.gpkg   PG:"dbname='caop' host='192.168.10.102' port='5432' user='ogc_api' password=$POSTGRES_PASS"   "caop2024.cont_distritos"