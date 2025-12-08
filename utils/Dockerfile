FROM acidrain/python-poetry:3.9-1.8.4

WORKDIR /app

COPY pyproject.toml poetry.lock* /app/

RUN poetry install --no-root

COPY . /app

CMD ["bash", "upload_tables.sh"]
