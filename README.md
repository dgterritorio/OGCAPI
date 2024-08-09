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

Create this file with the following format, replacing "SOMEPASSWORD" by reasonable values.

```
POSTGRES_PASSWORD="SOMEPASSWORD"
POSTGRES_DB="SOMEPASSWORD"
POSTGRES_USER="SOMEPASSWORD"
PYGEOAPI_CONFIG=docker-config.yml
PYGEOAPI_OPENAPI=example-openapi.yml
```

## License

This project is released under an [MIT License](./LICENSE)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
