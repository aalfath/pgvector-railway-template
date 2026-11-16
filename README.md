# pgvector on Railway

Railway template for [pgvector](https://github.com/pgvector/pgvector), open-source vector similarity search for PostgreSQL, running on PostgreSQL 18.

This repo is what the template builds: a `Dockerfile` that pins the official image `pgvector/pgvector:0.8.7-pg18-trixie` by digest, a first-start script (`initdb/10-pgvector.sh`) and a small start script (`railway-entrypoint.sh`).

## What you get

- **pgvector 0.8.7 on PostgreSQL 18.7** (official Docker image, Debian trixie). The `vector` extension is already created in the default database and in `template1`, so new databases get it too.
- **Persistent data** on a Railway volume mounted at `/var/lib/postgresql` (`PGDATA=/var/lib/postgresql/18/docker`).
- **Generated password**: `POSTGRES_PASSWORD` is a random 32-character secret. There is no default password.
- **TLS**: a self-signed certificate is generated on first start, kept on the volume and renewed 30 days before it expires. Clients using `sslmode=prefer` or `require` get an encrypted connection.
- **HNSW-friendly settings**: `maintenance_work_mem=512MB` and `shared_buffers=512MB` are set on first start (with `ALTER SYSTEM`, so you can change them later), and dynamic shared memory lives in the data directory, so parallel HNSW index builds don't fail with "could not resize shared memory segment" on the container's small `/dev/shm`.
- **Private and public access**: other services connect over Railway's private network with `${{pgvector.DATABASE_URL}}`. A TCP proxy on port 5432 gives `DATABASE_PUBLIC_URL` for tools outside Railway (psql, DBeaver, notebooks).
- **Clean redeploys**: the start script turns Railway's SIGTERM into a fast shutdown, so Postgres checkpoints and stops within the 60 s draining window.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `POSTGRES_USER` | `postgres` | Superuser name |
| `POSTGRES_PASSWORD` | `${{secret(32)}}` | Generated at deploy time |
| `POSTGRES_DB` | `railway` | Default database |
| `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` | references | libpq-style connection settings for other services |
| `DATABASE_URL` | private URL | `postgresql://…@${{RAILWAY_PRIVATE_DOMAIN}}:5432/…` |
| `DATABASE_PUBLIC_URL` | public URL | Through the TCP proxy |
| `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `60` | Time Postgres gets to shut down on redeploy |

Optional, not in the template (add them to the service if you need them):

- `PG_SHARED_BUFFERS` (default `512MB`), `PG_EFFECTIVE_CACHE_SIZE` (`1536MB`), `PG_MAINTENANCE_WORK_MEM` (`512MB`), `PG_WORK_MEM` (`16MB`): used only when the database is first created. To change them later, run `ALTER SYSTEM SET maintenance_work_mem = '2GB';` and redeploy.
- `PG_DYNAMIC_SHARED_MEMORY_TYPE` (default `mmap`): set to `posix` to use `/dev/shm` instead.
- `SSL_CERT_DAYS` (default `820`): lifetime of the generated certificate.

## Connect

From another Railway service: set `DATABASE_URL=${{pgvector.DATABASE_URL}}`.

From your machine: copy `DATABASE_PUBLIC_URL` from the service's Variables tab, then

```sh
psql "$DATABASE_PUBLIC_URL"
```

```sql
CREATE TABLE items (id bigserial PRIMARY KEY, content text, embedding vector(1536));
CREATE INDEX ON items USING hnsw (embedding vector_cosine_ops);
SELECT id, content FROM items ORDER BY embedding <=> '[...]' LIMIT 5;
```

## Updates

Deployers get Railway's "update available" notice when this repo's `main` branch changes. Each change is listed in [CHANGELOG.md](CHANGELOG.md); read it before you apply an update.

- **pgvector updates** (0.8.7 → 0.8.8) swap the image. After the redeploy, run `ALTER EXTENSION vector UPDATE;` in each database that uses it.
- **PostgreSQL minor updates** (18.7 → 18.8) only need the redeploy.
- **PostgreSQL major upgrades** (18 → 19) are never applied automatically: they need `pg_upgrade` or a dump and restore, and the changelog will say so first.

## License

The wrapper in this repo is MIT. pgvector is under the [PostgreSQL License](https://github.com/pgvector/pgvector/blob/master/LICENSE).
