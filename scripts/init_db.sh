#!/usr/bin/env bash

set -x
set -eo pipefail

if ! command -v psql; then
  echo >&2 "Error: 'psql' is not installed."
  exit 1
fi

if ! command -v sqlx; then
  echo >&2 "Error: 'sqlx' is not installed."
  echo >&2 -e "Use:\n    \`cargo install sqlx-cli --no-default-features --features rustls,postgres\`\nto install it."
  exit 1
fi

# Check if a custom user has been set, otherwise default to 'postgres'
DB_USER=${POSTGRES_USER:=postgres}
# Check if a custom password has been set, otherwise default to 'password'
DB_PASSWORD=${POSTGRES_PASSWORD:=password}
# Check if a custom database name has been set, otherwise default to 'newsletter'
DB_NAME=${POSTGRES_NAME:=newsletter}
# Check if a custom port has been set, otherwise default to '5432'
DB_PORT=${POSTGRES_PORT:=5433}
# Check if a custom host has been set, otherwise default to 'locahost'
DB_HOST=${POSTGRES_HOST:=localhost}

# launch postgres using docker
if [[ -z "${SKIP_DOCKER}" ]]; then
  docker run \
    -e POSTGRES_USER=${DB_USER} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD} \
    -e POSTGRES_NAME=${DB_NAME} \
    -p "${DB_PORT}":5432 \
    -d postgres \
    postgres -N 1000
fi

# Keep pinging Potgres until it's ready to accept commands
export PGPASSWORD="${DB_PASSWORD}"
until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do
  echo >&2 "Postgres is still unavailable - sleeping"
  sleep 1
done

echo >&2 "Postgres is up and running on port ${DB_PORT}!"

DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
export DATABASE_URL
sqlx database create
sqlx migrate run

echo >&2 "Postgres has been migrated, ready to go!"
