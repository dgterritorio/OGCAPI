# OCG API Simple

*Keep it simple*

## Quick Setup

You will need `docker` and `docker-compose` installed in your system, in order to run this infrastructure. 

## Start pygeoapi

Type:

```
docker compose up
```

Or, if you want to run it in the background

```
docker compose up -d
```


## Environment Variables

This compositions read secrets from an environment file on this folder: ```.env```.

Create this file with the following format, replacing "POSTGRES_PASSWORD=postgres" by a reasonable value.

```
HOST_URL=http://localhost
POSTGRES_DB="geodb"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="postgres"
POSTGRES_HOST_AUTH_METHOD=trust
LOCAL_DATABASE_URL=postgresql://postgres:postgres@postgis:5432/geodb
REMOTE_CAOP_HOST="caop.host.db"
REMOTE_CAOP_PORT="5433"
REMOTE_CAOP_DB="dgt_local"
REMOTE_CAOP_USER="caop_user"
REMOTE_CAOP_PASSWORD="caop_password"
REMOTE_CAOP_URL=postgresql://caop_user:caop_password@caop.host.db:5433/dgt_local
REMOTE_INSPIRE_HOST="inspire.host.db"
REMOTE_INSPIRE_PORT="5434"
REMOTE_INSPIRE_DB="dgt_local"
REMOTE_INSPIRE_USER="inspire_user"
REMOTE_INSPIRE_PASSWORD="inspire_password"
REMOTE_INSPIRE_URL=postgresql://inspire_user:inspire_password@inspire.host.db:5434/dgt_local
```

For Matomo we need also:

```
MYSQL_PASSWORD=matomo
MYSQL_DATABASE=matomo
MYSQL_USER=matomo
MARIADB_ROOT_PASSWORD=matomo
MATOMO_DATABASE_ADAPTER=mysql
MATOMO_DATABASE_TABLES_PREFIX=matomo_
MATOMO_DATABASE_USERNAME=matomo
MATOMO_DATABASE_PASSWORD=matomo
MATOMO_DATABASE_DBNAME=matomo
MARIADB_AUTO_UPGRADE=1
MARIADB_INITDB_SKIP_TZINFO=1
```

## Setup Matomo

Go to [http:localhost:8081](http:localhost:8081) and follow the wizard. Confirm everything until you initialized the DB. 

In the *Superuser* section please use 

```
username: user
password: matomo
```

(Otherwise you have to change this manually in ./matomo/refresh_logs.sh command)

In the *Set up a Website* section please use `http://localhost` as *Website URL*. 

Confirm all the next steps until you arrive to the end of the wizard (login screen).

The stats from the logs are refreshed every minute. So wait a minute before logging in.

When the containers are running, run this one-time configuration command:

```
docker compose exec matomo bash -c 'echo "proxy_uri_header = 1" >> /var/www/html/config/config.ini.php'
```

## Troubleshooting

## GeoHealthCheck is able to run the probe

If GHC cannot reach  to https://ogcapi.dgterritorio.gov.pt/, it is most likely a network problem, as all the containers are in the same composition.

These steps would solve the problem:
* Enter the ghc_web container: ```docker exec -it ghc_web bash```
* Install ping (iputils-ping) and nano
* Ping the apache container and get its internal IP address
* Add this IP address on /etc/hosts and make it point ogcapi.dgterritorio.gov.pt
* It should work now, no need for restart!


## License

This project is released under an [MIT License](./LICENSE)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)