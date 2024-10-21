import yaml
import re
import sys
from unidecode import unidecode

def sanitize_name(name):
    # Remove accents and special characters, replace spaces with underscores, and convert to lowercase
    sanitized = unidecode(name)
    sanitized = re.sub(r'[^a-zA-Z0-9_]', '_', sanitized)
    return sanitized.lower()

def load_template(template_path):
    try:
        with open(template_path, 'r') as template_file:
            yml_template = yaml.safe_load(template_file)
        return yml_template
    except Exception as e:
        print(f"Error: Unable to load YAML template from '{template_path}'", file=sys.stderr)
        print(e, file=sys.stderr)
        sys.exit(1)

def update_pygeoapi_config(config_path, new_entries):
    try:
        # Load existing pygeoapi configuration
        with open(config_path, 'r') as yml_file:
            pygeoapi_config = yaml.safe_load(yml_file)

        if(pygeoapi_config is None):
            raise ValueError('Please provide a valid yml.')

        # Ensure 'resources' section exists
        if 'resources' not in pygeoapi_config:
            raise ValueError('Please provide a valid yml.')

        # Prepare to update the resources section
        resources = pygeoapi_config['resources']
        
        if resources is None:
            resources = {}

        # Remove existing entries that match new entries by key
        for entry in new_entries:
            resource_key = entry.get('resource_key')
            if resources is not None and resource_key in resources:
                del resources[resource_key]

        # Add new entries to 'resources'
        for entry in new_entries:
            resource_key = entry.get('resource_key')
            resources[resource_key] = entry
            # Remove the 'resource_key' field from the entry
            del resources[resource_key]['resource_key']

        # Write updated configuration back to file
        with open(config_path, 'w') as yml_file:
            yaml.dump(pygeoapi_config, yml_file, default_flow_style=False, allow_unicode=True, sort_keys=False)

        print(f"YAML configuration has been updated in '{config_path}'")
    except Exception as e:
        print(f"Error: Unable to update YAML configuration in '{config_path}'", file=sys.stderr)
        print(e, file=sys.stderr)
        sys.exit(1)