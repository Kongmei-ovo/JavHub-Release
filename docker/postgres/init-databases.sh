#!/usr/bin/env sh
set -eu

javhub_db="${JAVHUB_DB_NAME:-javhub}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -v javhub_db="$javhub_db" <<'SQL'
SELECT format('CREATE DATABASE %I', :'javhub_db')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'javhub_db')\gexec
SQL
