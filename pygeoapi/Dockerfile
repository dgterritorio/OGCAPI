FROM geopython/pygeoapi:0.22.0

# Setup Venv (PEP 668 compliance)
RUN python3 -m venv --system-site-packages /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install only the required libraries for the PostgreSQL provider
RUN pip install SQLAlchemy GeoAlchemy2 "pygeofilter[backend-sqlalchemy]"

# Inject your fixed custom provider
COPY pseudo_postgresql.py /pygeoapi/pseudo_postgresql.py
ENV PYTHONPATH="/pygeoapi" 


 
 