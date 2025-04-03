import geopandas as gpd
from sqlalchemy import create_engine
import argparse
import sys
import yaml
from utils import load_template, update_pygeoapi_config

# Command-line arguments parser
parser = argparse.ArgumentParser(description='Upload a shapefile/geopackage to PostgreSQL and generate a YAML entry.')
parser.add_argument('--database', default='geodb', help='Name of the PostgreSQL database')
parser.add_argument('--user', required=True, help='PostgreSQL username')
parser.add_argument('--password', required=False, help='PostgreSQL password')
parser.add_argument('--host', default='localhost', help='PostgreSQL host, default is localhost')
parser.add_argument('--port', default='5432', help='PostgreSQL port, default is 5432')
parser.add_argument('--table', default='crus', help='Table name to create from the shapefile/geopackage')
parser.add_argument('--primary_key', default='objectid', help='Column name to use as the primary key for the new table')
parser.add_argument('--input', default='../data/CRUS+_31_mar_2025.shp', help='Path to the shapefile or geopackage file to import')
parser.add_argument('--template', default='template_table.yml', help='Path to YAML template file, default is template.yml')
parser.add_argument('--config', default='./docker.config.yml', help='Path to the pygeoapi configuration file to update')
args = parser.parse_args()

# Establish database connection
DATABASE = args.database
USER = args.user
PASSWORD = args.password
HOST = args.host
PORT = args.port
TABLE = args.table
INPUT_FILE = args.input
PRIMARY_KEY = args.primary_key

# Load the YAML template
yml_template = load_template(args.template)

# Import shapefile or geopackage to PostgreSQL
try:
    # Create SQLAlchemy engine for database connection
    if PASSWORD is not None:
        engine = create_engine(f'postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}')
    else:
        engine = create_engine(f'postgresql://{USER}@{HOST}:{PORT}/{DATABASE}')
        
    # Load the input file using GeoPandas
    if INPUT_FILE.endswith('.shp'):
        gdf = gpd.read_file(INPUT_FILE)
    elif INPUT_FILE.endswith('.gpkg'):
        gdf = gpd.read_file(INPUT_FILE, layer=0)
    else:
        print("Error: Unsupported file format. Please provide a shapefile (.shp) or a geopackage (.gpkg).", file=sys.stderr)
        sys.exit(1)

    # Check projection and convert to EPSG:4326 if necessary
    if gdf.crs is not None and gdf.crs.to_epsg() != 4326:
        print(f"Converting CRS from {gdf.crs} to EPSG:4326.")
        gdf = gdf.to_crs(epsg=4326)

    # Write GeoDataFrame to PostgreSQL with specified primary key
    print(f"Writing geodataframe to table.")
    gdf.to_postgis(TABLE, engine, if_exists='replace', index=True, index_label=PRIMARY_KEY, chunksize=10000)
    print(f"Table '{TABLE}' created successfully in the database from the file '{INPUT_FILE}'.")
except Exception as e:
    print("Error: Unable to import the input file to the database", file=sys.stderr)
    print(e, file=sys.stderr)
    sys.exit(1)

# Create a single YAML configuration entry
yml_entry = yml_template.copy()
yml_entry_str = yaml.dump(yml_entry)
yml_entry_str = yml_entry_str.replace('my_table_name_upper', TABLE.upper())
yml_entry_str = yml_entry_str.replace('my_table_name_lower', TABLE.lower())
yml_entry = yaml.safe_load(yml_entry_str)

# Add a resource key for easy identification
yml_entry['resource_key'] = TABLE.lower()

# Update the pygeoapi configuration
update_pygeoapi_config(args.config, [yml_entry])