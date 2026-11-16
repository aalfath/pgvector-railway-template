# Changelog

## 0.8.7-pg18 (2026-11-16)

First release.

- pgvector 0.8.7 on PostgreSQL 18.7: `pgvector/pgvector:0.8.7-pg18-trixie@sha256:ab49524d18df7200b74ac9a475e1db6297fc1eb57da4c214c63d10ecc4b754fa`.
- Data on a volume at `/var/lib/postgresql` (`PGDATA=/var/lib/postgresql/18/docker`).
- The `vector` extension is created in the default database and in `template1` on first start.
- Memory defaults set once with `ALTER SYSTEM` on first start: `shared_buffers=512MB`, `effective_cache_size=1536MB`, `maintenance_work_mem=512MB`, `work_mem=16MB`.
- Dynamic shared memory in the data directory (`dynamic_shared_memory_type=mmap`), so parallel HNSW index builds don't fail on a small `/dev/shm`.
- Self-signed TLS certificate generated on first start and renewed before expiry.
- SIGTERM from Railway becomes a fast Postgres shutdown.
