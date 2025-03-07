# Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, FCGI, MapServer e GDAL
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-fcgid mapserver-bin gdal-bin && \
    rm -rf /var/lib/apt/lists/*

# Enable FCGI on Apache
RUN a2enmod fcgid

RUN mkdir -p /var/www/mapserver

# Copy config files
COPY apache-mapserver.conf /etc/apache2/sites-available/000-default.conf
COPY mapfile.map /var/www/mapserver/mapfile.map
COPY mapserv.fcgi /var/www/mapserver/mapserv.fcgi

RUN chmod +x /var/www/mapserver/mapserv.fcgi

# GDAL caching (VSICURL)
RUN mkdir -p /tmp/vsicurl_cache

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
