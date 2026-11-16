#!/bin/bash
# Runs once, when the database is first created (docker-entrypoint-initdb.d).
# - creates the vector extension in the default database and in template1,
#   so databases created later have it too
# - stores memory settings with ALTER SYSTEM (postgresql.auto.conf), so they
#   can be changed later with ALTER SYSTEM and a restart
set -euo pipefail

for db in "$POSTGRES_DB" template1; do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" -c 'CREATE EXTENSION IF NOT EXISTS vector;'
done

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
ALTER SYSTEM SET shared_buffers = '${PG_SHARED_BUFFERS:-512MB}';
ALTER SYSTEM SET effective_cache_size = '${PG_EFFECTIVE_CACHE_SIZE:-1536MB}';
ALTER SYSTEM SET maintenance_work_mem = '${PG_MAINTENANCE_WORK_MEM:-512MB}';
ALTER SYSTEM SET work_mem = '${PG_WORK_MEM:-16MB}';
SQL
echo "pgvector: extension 'vector' created in ${POSTGRES_DB} and template1"
