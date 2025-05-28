FROM httpd:2.4

RUN mkdir -p /var/cache/apache2/mod_cache_disk \
             /var/cache/apache2/mod_cache_lock && \
    chown -R daemon:daemon /var/cache/apache2/mod_cache_disk \
                          /var/cache/apache2/mod_cache_lock && \
    chmod 700       /var/cache/apache2/mod_cache_disk \
                    /var/cache/apache2/mod_cache_lock

RUN apt update && apt install -yq libapache2-mod-evasive