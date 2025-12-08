FROM postgis/postgis:15-3.3-alpine

RUN mkdir -p /docker-entrypoint-initdb.d

ADD ./initDB.sql /docker-entrypoint-initdb.d/initDB.sql

