# Kimbank Nix Config

macOS-first Nix configuration that follows the same high-level layout as the reference `nixos-config` repository.

## Layout

```text
.
├── flake.nix
├── apps/
│   └── aarch64-darwin/       # `nix run .#...` helper scripts
│       ├── apply
│       ├── build
│       ├── build-switch
│       ├── clean
│       └── rollback
├── hosts/
│   └── darwin/
│       └── default.nix       # Host-level nix-darwin entrypoint
├── modules/
│   ├── darwin/               # macOS-only packages, files, Dock, Homebrew
│   │   ├── casks.nix
│   │   ├── dock/
│   │   │   └── default.nix
│   │   ├── files.nix
│   │   ├── home-manager.nix
│   │   ├── pf.nix
│   │   └── packages.nix
│   └── shared/               # Shared packages, shell config, files
│       ├── config/           # App config trees tracked in this repo
│       │   ├── dev-infra/
│       │   │   ├── README.md
│       │   │   ├── compose.yml
│       │   │   ├── mysql/
│       │   │   │   └── Dockerfile
│       │   │   └── mysql-init/
│       │   │   │   └── 001-admin-superuser.sql
│       │   ├── ghostty/
│       │   ├── nvim/
│       │   ├── vscode/
│       │   └── wezterm/
│       ├── pkgs/             # Small repo-local packages missing from nixpkgs
│       │   └── im-select.nix
│       ├── default.nix
│       ├── files.nix
│       ├── home-manager.nix
│       └── packages.nix
└── overlays/
    ├── README.md
    └── ytsurf.nix
```

## For macOS

This repository currently targets Apple Silicon macOS with the Nix system string `aarch64-darwin`.

### 1. Install dependencies

```sh
xcode-select --install
```

### 2. Install Nix

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

Open a new terminal after installation so `nix` is available in your `PATH`.

### 3. Enable flakes and nix-command

Add this to `/etc/nix/nix.conf`:

```conf
experimental-features = nix-command flakes
```

Or use:

```sh
nix --extra-experimental-features 'nix-command flakes' <command>
# ex
# nix --extra-experimental-features 'nix-command flakes' run .#build-switch
```

troubleshoot: nix notfound

```sh
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --extra-experimental-features 'nix-command flakes' run .#build-switch
```

### 4. Clone this repository

The clone path is not special. Any location is fine as long as you run commands from the repository root.

Example:

```sh
cd ~
git clone https://github.com/kimbank/nix-config.git
# or ssh
# git clone git@github.com:kimbank/nix-config.git
cd nix-config
```

### 5. Set your git identity first

`nix run .#apply` reads your current `git user.name` and `git user.email` and writes them into this repository.

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### 6. Run apply with the correct macOS login user

`apply` uses the current macOS login account from `whoami`.

- Log in as the actual macOS account you want to manage with Nix.
- Then run `apply` from the repository root.
- If your macOS account is `kimbank`, run it while logged in as `kimbank`.

```sh
nix run .#apply
```

What `apply` updates:

- macOS login username
- git user name
- git user email

### 7. Review packages

Search packages at [NixOS Search](https://search.nixos.org/packages).

Review these files:

- `modules/shared/packages.nix`
- `modules/darwin/packages.nix`
- `modules/darwin/casks.nix`

Current split:

- Shared CLI packages: `modules/shared/packages.nix`
- Small repo-local shared packages: `modules/shared/pkgs/`
- macOS-specific Nix packages: `modules/darwin/packages.nix`
- Homebrew casks: `modules/darwin/casks.nix`
- macOS PF rules for Screen Sharing/VNC: `modules/darwin/pf.nix`
- JetBrains IDEs: install `jetbrains-toolbox` as a cask, then let Toolbox manage IDE installs and updates

### 8. Review shell configuration

This config manages your shell through Home Manager. Review:

- `modules/shared/home-manager.nix`
- `modules/darwin/home-manager.nix`
- `modules/shared/config/ghostty` for Ghostty-compatible terminal appearance that `cmux` reads from `~/.config/ghostty/config`

Like the reference `nixos-config`, this setup assumes your Nix-managed shell config replaces the previous one. Bring over anything important before switching.

JetBrains Toolbox users can keep IDE launchers such as `webstorm` and `datagrip` on `PATH` by enabling Toolbox shell scripts. This repo includes the default Toolbox scripts directory in shell startup so aliases such as `we` and `dg` work in new shells once Toolbox has created those launchers.

Node runtime switching is managed through Home Manager's `programs.mise` integration rather than a fixed `nodejs_*` package in Nix. The global default Node version comes from `mise`, and project-local `.tool-versions`, `.nvmrc`, or `.node-version` files can override it automatically in new shells. After entering a project with one of those files, run `mise install` once if that version is not already present.

### 9. Stage the repo before building

If you are using git, stage the files first so Nix sees the current working tree contents.

```sh
git add .
```

### 10. Verify the build

```sh
nix run .#build
```

### 11. Apply the configuration

```sh
nix run .#build-switch
```

`build-switch` usually reaches a macOS `sudo` password prompt. If you changed shell configuration, refresh the session with:

```sh
exec zsh -l
```

## Updating After First Install

General workflow:

1. Edit the Nix files.
2. Run `git add .` if you created or changed tracked files, including app config under `modules/shared/config/`.
3. Run `nix run .#build` to verify.
4. Run `nix run .#build-switch` to apply.

For Node projects, use `mise` to inspect or install runtime versions:

```sh
mise ls --current
mise install
```

## Standalone Config Mirrors

`nix-config` is the source of truth for the full [`modules/shared/config`](modules/shared/config) tree.

The standalone [`kimbank/.config`](https://github.com/kimbank/.config) repository is treated as a mirror output for environments that only need the config tree outside this full Nix repo.

This repository includes:

- `.github/scripts/dot-config-mirror/publish-config-mirrors.sh` for local manual publishing or workflow use
- `.github/workflows/publish-dot-config-mirror-repo.yml` for automatic publishing on pushes to `main`

The publish flow uses `git subtree split` on `modules/shared/config` and force-pushes the resulting history to the mirror repository branch. Do not make direct commits in the mirror repo unless you intentionally want them overwritten by the next publish.

### GitHub Actions setup

Create a secret in `nix-config` named `DOT_CONFIG_MIRROR_REPO_TOKEN`.

If you store it as an environment secret instead of a repository secret, attach it to the GitHub environment named `publish dot config mirror repo`, which is the environment used by the workflow.

Recommended scope:

- Fine-grained personal access token
- Repository access limited to `kimbank/.config`
- Repository permission `Contents: Read and write`

`GITHUB_TOKEN` from the `nix-config` Actions run is not intended for pushing to other repositories, so the workflow uses this separate secret for cross-repo publishing.

### Manual publish

```sh
export PUBLISH_GITHUB_TOKEN=YOUR_TOKEN
bash ./.github/scripts/dot-config-mirror/publish-config-mirrors.sh config
```

If you prefer the same repository over SSH locally, override the destination URL:

```sh
CONFIG_MIRROR_URL=git@github.com:kimbank/.config.git \
  bash ./.github/scripts/dot-config-mirror/publish-config-mirrors.sh config
```

The first successful publish after moving away from submodules will replace the target branch history in `kimbank/.config` with the subtree-derived history from this repo.

Examples:

- Add CLI tools in `modules/shared/packages.nix`
- Add small repo-local CLI packages in `modules/shared/pkgs/`
- Add GUI apps in `modules/darwin/casks.nix`
- Add `jetbrains-toolbox` in `modules/darwin/casks.nix`, then manage WebStorm/DataGrip installs inside Toolbox
- Adjust the local Docker stack in `modules/shared/config/dev-infra/compose.yml`
- Adjust Ghostty or `cmux` terminal appearance in `modules/shared/config/ghostty`
- Adjust Colima auto-start and profile settings in `modules/darwin/home-manager.nix`
- Adjust PF-based inbound VNC allowlists in `modules/darwin/pf.nix`
- Adjust the local MySQL image bootstrap in `modules/shared/config/dev-infra/mysql/Dockerfile`
- Adjust shell settings in `modules/shared/home-manager.nix`
- Adjust macOS defaults in `hosts/darwin/default.nix`

## Screen Sharing Over Tailscale

Inbound Screen Sharing/VNC filtering is managed declaratively in
`modules/darwin/pf.nix`.

After applying with `nix run .#build-switch`, inspect the loaded VNC rules with:

```sh
sudo pfctl -a org.nixos.vnc-screen-sharing -sr
```

The local Docker stack is intended to be run from the Home Manager-managed path `~/.config/dev-infra/compose.yml`. Because that path is a symlink into the Nix store, avoid adding relative bind mounts for tracked repo files; prefer image-baked assets or other approaches that do not require Colima to mount store-backed paths at runtime.

## Docker On macOS

This repo installs Docker tooling with a split that matches the existing package layout:

- `modules/shared/packages.nix`: Docker CLI from nixpkgs
- `modules/darwin/home-manager.nix`: Colima login-time service and profile settings
- `modules/shared/config/dev-infra/compose.yml`: Portainer, MySQL, PostgreSQL, Redis, MinIO stack linked under `~/.config/dev-infra/`
- `modules/shared/config/dev-infra/README.md`: detailed usage guide for the local stack

Typical first run after `nix run .#build-switch`:

```sh
docker compose -f ~/.config/dev-infra/compose.yml up -d
```

Portainer will then be available at [https://localhost:9443](https://localhost:9443). The initial certificate is self-signed, so the browser may show a warning the first time.
The local DB and object storage services bind only to `127.0.0.1` on ports `3306`, `5432`, `6379`, `9000`, and `9001`.
The default MySQL and PostgreSQL database name is `playground`. PostgreSQL uses `admin` as the superuser, the MySQL stack initializes both `root` and a local `admin` account with full privileges for local development, Portainer initializes the `admin` account with the password `adminadmin!!`, and MinIO exposes its S3 API on `http://127.0.0.1:9000` plus the web console on `http://127.0.0.1:9001` with `admin` / `adminadmin!!`.
Colima is configured to start automatically at user login through Home Manager's macOS `launchd` integration. If you want it immediately in the current session before your next login, you can still run `colima start` once manually.
If you change the initial DB usernames, passwords, or database names later, remove the related Docker volumes before recreating the containers so the new initialization values can take effect.
For the full command reference and reset workflow, see [`modules/shared/config/dev-infra/README.md`](modules/shared/config/dev-infra/README.md).

## Notes

- For local-only GitHub bucket setup that should stay out of the Nix modules, use [`scripts/github-local-auth/setup-github-local-auth.sh`](scripts/github-local-auth/setup-github-local-auth.sh). It reads the configured 1Password items, writes local `~/.ssh` and `~/.gitconfig` state, and updates bucket-level `~/Github/*/.envrc` files. Pass `--danger` if you intentionally want plaintext `GH_TOKEN` values written into those `.envrc` files instead of `op://...` references.
- The current target platform is `aarch64-darwin`, not `arm64-darwin`.
- `nix run .#apply` is for initial personalization of the template.
- Day-to-day changes are applied with `nix run .#build-switch`.
- If you change repo structure, workflow, or user-visible behavior, update this README alongside the code so the documented layout and commands stay current.
- On a fresh Mac this should be straightforward. On an already-used Mac, existing `/etc` files, old Homebrew state, or existing shell dotfiles can still conflict during first activation.
