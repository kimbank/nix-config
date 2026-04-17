# Dev Infra

Local Docker stack for day-to-day development on macOS.

This directory is linked to `~/.config/dev-infra` by Home Manager and is meant to be used with `docker compose`.
When you build through the repo helper commands, that path resolves back to this checkout as a writable symlink, so edits made from either path land in Git.

## What It Starts

- Portainer
- MySQL
- PostgreSQL
- Redis
- RustFS

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

### RustFS

- S3 API: `http://127.0.0.1:9000`
- Console: `http://127.0.0.1:9001`
- Access key: `admin`
- Secret key: `adminadmin!!`
- Image: `rustfs/rustfs:latest`

## First Use

1. Apply the Nix config.

```sh
cd /path/to/your/nix-config
nix run .#build-switch
exec zsh -l
```

2. If Colima was already running before the switch, restart it once so the
   managed Kubernetes setting takes effect in the current session.

```sh
colima stop
colima start --save-config=false
```

3. Confirm the local Kubernetes context is up.

```sh
kubectl config current-context
kubectl get nodes
kubectl cluster-info
```

4. Start the Docker-based local stack.

```sh
docker compose -f ~/.config/dev-infra/compose.yml up -d --build
```

If you are switching from the older MinIO-based stack, clean up the renamed
service once before the first RustFS start:

```sh
docker compose -f ~/.config/dev-infra/compose.yml down --remove-orphans
docker compose -f ~/.config/dev-infra/compose.yml up -d
```

If you no longer need the old MinIO object data, remove its leftover Docker volume separately after you confirm nothing still depends on it.

5. Open Portainer.

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
docker compose -f ~/.config/dev-infra/compose.yml restart rustfs
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
- RustFS data

## Colima Behavior

Colima is configured in the main Nix config as a Home Manager `launchd` user service. That means:

- it should start automatically when the macOS user logs in after the config is applied
- the default profile also enables Colima's built-in k3s cluster for local Kubernetes testing
- if Colima was already running before you applied a config change, restart it once in the current session with `colima stop && colima start --save-config=false`
- this repo manages `~/.colima/default/colima.yaml` declaratively through Home Manager, so a plain `colima start` can fail when Colima tries to rewrite the generated config symlink
- `kubectl` is installed from nixpkgs so you can use the Colima-backed cluster directly from the shell

Useful checks:

```sh
colima status
docker context show
docker info
kubectl config current-context
kubectl get nodes
```

## Notes

- This stack is intentionally local-only and optimized for convenience, not security.
- Colima's built-in k3s is a good fit for local manifest checks, image builds, and basic deployment smoke tests, but it is not a full substitute for production parity with managed Kubernetes platforms.
- Running the Docker stack and k3s in the same Colima VM can feel tight on the default resource settings; if workloads start thrashing, increase Colima CPU and memory in `modules/darwin/home-manager.nix`.
- MySQL and PostgreSQL defaults are meant for development.
- Portainer admin initialization uses a baked bcrypt hash for `adminadmin!!` and only applies to a fresh Portainer data volume.
- RustFS now tracks the upstream `latest` image tag, matching the project's own Docker Compose examples. Expect occasional alpha-to-alpha behavior changes when you pull updates.
- Portainer already follows the upstream `sts` channel tag, so it is effectively on a moving release stream as well.
- MySQL, PostgreSQL, and Redis intentionally stay on major-version tags in this stack so persisted local volumes are less likely to be surprised by automatic major upgrades.
- RustFS keeps the same local `admin` / `adminadmin!!` credentials as the old MinIO setup so existing development tooling can usually be repointed without changing auth values.
- The stack is designed to run from the Home Manager symlink at `~/.config/dev-infra`, so avoid reintroducing relative bind mounts for tracked files unless they point to a real non-store path.
