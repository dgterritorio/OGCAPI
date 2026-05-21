FROM geopython/pygeoapi:0.23.2

RUN python3 -m venv --system-site-packages /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install pygeoapi-plugins 