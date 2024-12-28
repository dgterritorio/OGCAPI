import psycopg2
import argparse
import yaml, sys
from utils import sanitize_name, load_template, update_pygeoapi_config

# Command-line arguments parser
parser = argparse.ArgumentParser(description='Generate SQL views and PyGeoAPI YAML configuration for distinct values.')
parser.add_argument('--database', default='geodb', help='Name of the PostgreSQL database')
parser.add_argument('--user', required=True, help='PostgreSQL username')
parser.add_argument('--password', required=False, help='PostgreSQL password')
parser.add_argument('--host', default='localhost', help='PostgreSQL host, default is localhost')
parser.add_argument('--port', default='5432', help='PostgreSQL port, default is 5432')
parser.add_argument('--table1', required=True, help='Table to be queried')
parser.add_argument('--table2', required=True, help='Table containing the geometry to query from')
parser.add_argument('--column', required=True, help='Column name to select geometry on table2, default is Municipio')
parser.add_argument('--template', default='template_joined_view.yml', help='Path to YAML template file, default is template.yml')
parser.add_argument('--config', default='./docker.config.yml', help='Path to the pygeoapi configuration file to update')
args = parser.parse_args()

# Establish database connection
DATABASE = args.database
USER = args.user
PASSWORD = args.password
HOST = args.host
PORT = args.port
TABLE1 = args.table1
TABLE2 = args.table2
COLUMN = args.column

# Load the YAML template
yml_template = load_template(args.template)

# Connect to PostgreSQL database
try:
    conn = psycopg2.connect(
        dbname=DATABASE, user=USER, password=PASSWORD, host=HOST, port=PORT
    )
    cursor = conn.cursor()
except Exception as e:
    print("Error: Unable to connect to the database", file=sys.stderr)
    print(e, file=sys.stderr)
    sys.exit(1)

# Query the specified table for unique values in the specified column
try:
    cursor.execute(f"SELECT DISTINCT \"{COLUMN}\" FROM {TABLE2};")
    distinct_values = cursor.fetchall()

    # for row in distinct_values:
    #     print(row)

except Exception as e:
    print(f"Error: Unable to query the table '{TABLE2}'", file=sys.stderr)
    print(e, file=sys.stderr)
    cursor.close()
    conn.close()
    sys.exit(1)

# List to store yml configuration entries
yml_entries = []

# Loop through unique values in the specified column and create SQL views and yml configuration entries
for distinct_value_tuple in distinct_values:
    distinct_value = distinct_value_tuple[0]
    print(distinct_value)
    sanitized_value = sanitize_name(distinct_value)
    view_name = f"v_{TABLE1}_{sanitized_value}"

    # Create SQL view for each unique value in the specified column
    try:
        cursor.execute(
            f"""
            CREATE OR REPLACE VIEW {view_name} AS
            SELECT a.* FROM {TABLE1} a
            JOIN {TABLE2} b
            ON ST_Contains(b.geometry, a.geometry) 
             WHERE b.\"{COLUMN}\" = %s;
            """,
            (distinct_value,)
        )        
        conn.commit()
        print(f"SQL view '{view_name}' created successfully.")
    except Exception as e:
        print(f"Error: Unable to create view for {COLUMN} '{distinct_value}'", file=sys.stderr)
        print(e, file=sys.stderr)
        conn.rollback()
        continue

    # Calculate the bounding box for the view
    try:
        cursor.execute(
            f"""
            SELECT ST_Extent(geometry) FROM {view_name};
            """
        )
        bbox_result = cursor.fetchone()[0]
        if bbox_result is None:
            print(f"Warning: No geometry found for view '{view_name}', skipping bounding box.")
            bbox = [-180.0, -90.0, 180.0, 90.0]  # Default bbox in case of missing geometries
        else:
            bbox = [float(coord) for coord in bbox_result.replace('BOX(', '').replace(')', '').replace(',', ' ').split()]
    except Exception as e:
        print(f"Error: Unable to calculate bounding box for view '{view_name}'", file=sys.stderr)
        print(e, file=sys.stderr)
        conn.rollback()
        continue


     # Create yml configuration entry
    yml_entry = yml_template.copy()
    yml_entry_str = yaml.dump(yml_entry)
    yml_entry_str = yml_entry_str.replace('table_original', TABLE1.upper())
    yml_entry_str = yml_entry_str.replace('column_original', distinct_value)
    yml_entry_str = yml_entry_str.replace('column_clean', sanitized_value)
    yml_entry_str = yml_entry_str.replace('view_name', view_name)
    yml_entry_str = yml_entry_str.replace('view_bbox', f'{bbox}')
    yml_entry = yaml.safe_load(yml_entry_str)

     # Add a resource key for easy identification
    yml_entry['resource_key'] = TABLE1 + '_' + sanitized_value
    yml_entries.append(yml_entry)

# Close the database connection
cursor.close()
conn.close()

# Update the pygeoapi configuration
update_pygeoapi_config(args.config, yml_entries)
