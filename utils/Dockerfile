FROM acidrain/python-poetry:3.9-1.8.4

# Set the working directory in the container
WORKDIR /app

# Copy the pyproject.toml and poetry.lock files first to leverage Docker caching
COPY pyproject.toml poetry.lock* /app/

# Install dependencies with Poetry
RUN poetry install --no-root

# Copy the rest of the application code
COPY . /app

# Run the Python script (replace 'your_script.py' with your actual script's name)
CMD ["bash", "upload_tables_and_views.sh"]
