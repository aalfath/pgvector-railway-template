# pgvector 0.8.7 on PostgreSQL 18, official image pinned by digest.
FROM pgvector/pgvector:0.8.7-pg18-trixie@sha256:ab49524d18df7200b74ac9a475e1db6297fc1eb57da4c214c63d10ecc4b754fa

# PostgreSQL 18 data layout. Mount the Railway volume at /var/lib/postgresql.
ENV PGDATA=/var/lib/postgresql/18/docker

# First-start setup: enable the vector extension and set memory defaults.
COPY initdb/ /docker-entrypoint-initdb.d/
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 0755 /usr/local/bin/railway-entrypoint.sh /docker-entrypoint-initdb.d/*.sh

EXPOSE 5432
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD []
