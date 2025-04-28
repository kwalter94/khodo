#!/usr/bin/env bash

# NOTE: Database needs to be restarted after this operation!
set -eu

POSTGRES_REPORTING_USER="$(echo "SELECT quote_ident(:user);" | psql -q -t -U lucky --variable="user='$POSTGRES_REPORTING_USER'" 2> /dev/null | xargs)"
POSTGRES_REPORTING_PASSWORD="$(echo "SELECT quote_ident(:password)" | psql -q -t -U lucky --variable="password='$POSTGRES_REPORTING_PASSWORD'" 2> /dev/null | xargs)"

psql -U $POSTGRES_USER -d $POSTGRES_DB <<-SQL
  DO \$$
  BEGIN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = '$POSTGRES_REPORTING_USER'
    ) THEN
      CREATE ROLE $POSTGRES_REPORTING_USER WITH LOGIN PASSWORD '$POSTGRES_REPORTING_PASSWORD';
      GRANT USAGE ON SCHEMA public TO $POSTGRES_REPORTING_USER;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO $POSTGRES_REPORTING_USER;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO $POSTGRES_REPORTING_USER;
      ALTER ROLE $POSTGRES_REPORTING_USER SET duckdb.force_execution TO true;
    END IF;
  END \$$;
SQL
