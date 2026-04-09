# Dev Infra

Local Docker stack for day-to-day development on macOS.

This directory is linked to `~/.config/dev-infra` by Home Manager and is meant to be used with `docker compose`.
When you build through the repo helper commands, that path resolves back to this checkout as a writable symlink, so edits made from either path land in Git.

## What It Starts

- Portainer
- MySQL
- PostgreSQL
- Redis
- MinIO

All services are defined in [`compose.yml`](compose.yml).

## Files

- [`compose.yml`](compose.yml): main Docker Compose stack
- [`mysql/Dockerfile`](mysql/Dockerfile): builds the local MySQL image with bootstrap SQL baked in
- [`mysql-init/001-admin-superuser.sql`](mysql-init/001-admin-superuser.sql): grants the MySQL `admin` user full privileges for local development

## Default Access

### Portainer

- URL: `https://localhost:9443`
- Username: `admin`
- Password: `adminadmin!!`

### MySQL

- Host: `127.0.0.1`
- Port: `3306`
- Default database: `playground`
- Admin user: `admin`
- Admin password: `adminadmin!!`
- Root password: `adminadmin!!`

### PostgreSQL

- Host: `127.0.0.1`
- Port: `5432`
- Default database: `playground`
- User: `admin`
- Password: `adminadmin!!`

### Redis

- Host: `127.0.0.1`
- Port: `6379`
- Password: none

### MinIO

- S3 API: `http://127.0.0.1:9000`
- Console: `http://127.0.0.1:9001`
- Root user: `admin`
- Root password: `adminadmin!!`
- Image: `minio/minio:RELEASE.2025-04-22T22-12-26Z`

## First Use

1. Apply the Nix config.

```sh
cd /path/to/your/nix-config
nix run .#build-switch
exec zsh -l
```

2. Start the stack.

```sh
docker compose -f ~/.config/dev-infra/compose.yml up -d --build
```

3. Open Portainer.

```text
https://localhost:9443
```

The TLS certificate is self-signed on first boot, so the browser may show a warning.

## Daily Commands

Start everything:

```sh
docker compose -f ~/.config/dev-infra/compose.yml up -d
```

Rebuild after changing the dev stack definition:

```sh
docker compose -f ~/.config/dev-infra/compose.yml up -d --build
```

Stop everything:

```sh
docker compose -f ~/.config/dev-infra/compose.yml down
```

Check running containers:

```sh
docker compose -f ~/.config/dev-infra/compose.yml ps
```

Tail logs:

```sh
docker compose -f ~/.config/dev-infra/compose.yml logs -f
```

Restart one service:

```sh
docker compose -f ~/.config/dev-infra/compose.yml restart mysql
docker compose -f ~/.config/dev-infra/compose.yml restart postgres
docker compose -f ~/.config/dev-infra/compose.yml restart redis
docker compose -f ~/.config/dev-infra/compose.yml restart portainer
docker compose -f ~/.config/dev-infra/compose.yml restart minio
```

## Reset Everything

If you change initial usernames, passwords, or database names, recreate the stack with volumes removed so Docker reruns the init logic.

```sh
docker compose -f ~/.config/dev-infra/compose.yml down -v --remove-orphans
docker compose -f ~/.config/dev-infra/compose.yml up -d
```

This removes:

- MySQL data
- PostgreSQL data
- Redis data
- Portainer data
- MinIO data

## Colima Behavior

Colima is configured in the main Nix config as a Home Manager `launchd` user service. That means:

- it should start automatically when the macOS user logs in after the config is applied
- if you want it immediately in the current session before the next login, run `colima start` manually once
- avoid declaratively pinning `~/.colima/default/colima.yaml` via Home Manager profile settings unless the file can stay writable, because Colima rewrites it during startup

Useful checks:

```sh
colima status
docker context show
docker info
```

## Notes

- This stack is intentionally local-only and optimized for convenience, not security.
- MySQL and PostgreSQL defaults are meant for development.
- Portainer admin initialization uses a baked bcrypt hash for `adminadmin!!` and only applies to a fresh Portainer data volume.
- MinIO is pinned to `RELEASE.2025-04-22T22-12-26Z` so the local stack stays on a pre-pricing-change image line unless you explicitly choose to upgrade it later.
- The stack is designed to run from the Home Manager symlink at `~/.config/dev-infra`, so avoid reintroducing relative bind mounts for tracked files unless they point to a real non-store path.
