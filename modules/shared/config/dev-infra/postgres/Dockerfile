# Keep the upstream Debian-based PostgreSQL 18 image for the existing data volume.
FROM postgres:18 AS pg-bigm-builder

ARG PG_BIGM_VERSION=v1.2-20250903

# Build against this PostgreSQL major version; build tools stay in this stage.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential ca-certificates git libicu-dev "postgresql-server-dev-${PG_MAJOR}" \
 && rm -rf /var/lib/apt/lists/*

# Only the native shared library is needed; skip LLVM bitcode generation.
RUN git clone --depth 1 --branch "${PG_BIGM_VERSION}" \
      https://github.com/pgbigm/pg_bigm.git /tmp/pg_bigm \
 && make -C /tmp/pg_bigm USE_PGXS=1 \
      PG_CONFIG="/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" with_llvm=no \
 && make -C /tmp/pg_bigm USE_PGXS=1 \
      PG_CONFIG="/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" with_llvm=no \
      DESTDIR=/pg-bigm install

FROM postgres:18

COPY --from=pg-bigm-builder /pg-bigm/ /
