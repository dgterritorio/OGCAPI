#!/bin/bash
#
# Ensure .env file contains all required variables (add missing ones, keep existing untouched)
#

ENV_FILE=".env"

# Create .env file if it doesn’t exist
if [[ ! -f "$ENV_FILE" ]]; then
  touch "$ENV_FILE"
  echo "# Auto-generated .env file" >> "$ENV_FILE"
fi

# Complete reference list of required variables that we must keep updated (including commented ones)
read -r -d '' REQUIRED_VARS <<'EOF'
HOST_URL=http://localhost
POSTGRES_DB="geodb"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="postgres"
POSTGRES_HOST_AUTH_METHOD=trust
LOCAL_DATABASE_URL=postgresql://postgres:postgres@postgis:5432/geodb
REMOTE_CAOP_HOST="postgis_caop"
REMOTE_CAOP_PORT="5432"
REMOTE_CAOP_DB="caop"
REMOTE_CAOP_USER="caop_user"
REMOTE_CAOP_PASSWORD="caop_password"
REMOTE_CAOP_URL=postgresql://caop_user:caop_password@postgis_caop:5432/caop
REMOTE_INSPIRE_HOST="postgis_inspire"
REMOTE_INSPIRE_PORT="5432"
REMOTE_INSPIRE_DB="inspire"
REMOTE_INSPIRE_USER="inspire_user"
REMOTE_INSPIRE_PASSWORD="inspire_password"
REMOTE_INSPIRE_URL=postgresql://inspire_user:inspire_password@postgis_inspire:5432/inspire
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
USER_MATOMO=user
PASSWORD_MATOMO=matomo

SQLALCHEMY_DATABASE_URI=sqlite:////GeoHealthCheck/DB/data.db

# Core variables settings, change at will.
#GHC_RETENTION_DAYS = 30
#GHC_RUN_FREQUENCY = 'hourly'
GHC_MINIMAL_RUN_FREQUENCY_MINS=2
GHC_RUNNER_IN_WEBAPP=True
GHC_NOTIFICATIONS=True
GHC_NOTIFICATIONS_VERBOSITY=True
GHC_ADMIN_EMAIL='info@xxxxxx.net'
# GHC_NOTIFICATIONS_EMAIL=['xxxx@xxxx.net','xxx@xxxx.net']
# GHC_SMTP_SERVER='smtp.xxxxx.com'
# GHC_SMTP_PORT=587
# GHC_SMTP_TLS=True
# #GHC_SMTP_SSL=False
# GHC_SMTP_USERNAME=''
# GHC_SMTP_PASSWORD=''
GHC_LOG_LEVEL=20
GHC_SITE_TITLE='GeoHealthCheck of the OGC API Service from DGT'
GHC_SITE_URL='xxxxxxx.xxxxxxx.xxx.xx'
GHC_SELF_REGISTER=True
GHC_REQUIRE_WEBAPP_AUTH=False
#GHC_VERIFY_SSL=True
# GHC_USER_PLUGINS=GeoHealthCheck.plugins.user.mywmsprobe,GeoHealthCheck.plugins.user.mywmsprobe2

# Optionally set container Timezone
CONTAINER_TIMEZONE=Europe/London

# Optionally: set language
# LC_ALL=nl_NL.UTF-8
# LANG=nl_NL.UTF-8
# LANGUAGE=nl_NL.UTF-8
EOF

# Append missing lines to .env (preserve existing values)
while IFS= read -r LINE; do
  [[ -z "$LINE" ]] && continue  # skip empty lines

  if [[ "$LINE" =~ ^# ]]; then
    # Commented lines: only add if not present
    if ! grep -Fxq "$LINE" "$ENV_FILE"; then
      echo "$LINE" >> "$ENV_FILE"
    fi
  else
    VAR_NAME=$(echo "$LINE" | cut -d '=' -f 1)
    if ! grep -q "^${VAR_NAME}=" "$ENV_FILE"; then
      echo "$LINE" >> "$ENV_FILE"
    fi
  fi
done <<< "$REQUIRED_VARS"

echo "✅ .env file updated (missing variables added, existing preserved)."
