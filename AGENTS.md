# AGENTS.md

This repository is a macOS-first `nix-darwin` flake for a single Apple Silicon host.

## Scope

- Target platform is `aarch64-darwin`.
- This repo does not require a fixed absolute checkout path; work from the current repo root and do not assume it lives under `~/nix-config`.
- Do not confuse this repo with `/Users/kimbank/Desktop/nixos-config`, which is a separate upstream/example-style repo and not the default target for edits or validation unless the user explicitly asks to work there.
- Main entrypoint is [`flake.nix`](flake.nix).
- Host entrypoint is [`hosts/darwin/default.nix`](hosts/darwin/default.nix).
- User-level shell and dotfile management is done through Home Manager in [`modules/darwin/home-manager.nix`](modules/darwin/home-manager.nix) and [`modules/shared/home-manager.nix`](modules/shared/home-manager.nix).

## Repository Layout

- `apps/aarch64-darwin/`: helper scripts exposed through `nix run`
- `scripts/`: repo-local helper scripts, grouped by task-specific subdirectory when useful
- `.github/workflows/`: GitHub Actions workflow definitions only
- `.github/scripts/`: scripts that support GitHub workflow automation, grouped by workflow-specific subdirectory
- `hosts/darwin/`: top-level `nix-darwin` host module
- `modules/shared/`: cross-cutting packages, Home Manager programs, overlays
- `modules/darwin/`: macOS-only packages, casks, files, dock behavior, PF rules
- `modules/shared/config/`: app-specific config trees tracked directly in this repository, with the whole tree mirrored out to a standalone repo when needed
- `overlays/`: optional local overlays auto-imported by [`modules/shared/default.nix`](modules/shared/default.nix)

## Clone And Config Trees

- App-specific config under `modules/shared/config/` is tracked directly in this repository.
- A normal `git clone ...` is sufficient; there is no submodule initialization step.
- If a task edits files inside `modules/shared/config/`, stage those parent-repo changes directly before running Nix builds if you want Nix to evaluate the updated working tree contents.

## Mirror Publishing

- `modules/shared/config/` is a source-of-truth tree in this repo and can be mirrored to the standalone `kimbank/.config` GitHub repo.
- Local mirror publishing lives in `.github/scripts/dot-config-mirror/publish-config-mirrors.sh`.
- GitHub Actions mirror publishing lives in `.github/workflows/publish-dot-config-mirror-repo.yml`.
- Mirror publishing is one-way from this repo outward via subtree split plus force-push. Do not assume bidirectional sync with the standalone repo.
- If a task changes the publish mapping, token expectations, or mirror workflow, update `README.md`, `AGENTS.md`, `scripts/README.md`, and `.github/scripts/README.md` in the same task.

## Command Workflow

Use these commands from the repo root:

- `nix run .#apply`: initial template personalization only
- `nix run .#build`: build and verify the Darwin system
- `nix run .#build-switch`: build and switch to the new generation
- `nix run .#rollback`: switch to a previous generation
- `nix run .#clean`: garbage-collect old generations

Important:

- Stage tracked changes before `build` or `build-switch` if you want Nix to see them: `git add .`
- `build-switch` runs `darwin-rebuild switch` via [`apps/aarch64-darwin/build-switch`](apps/aarch64-darwin/build-switch)
- `apply` rewrites placeholder values like `loginUser`, git name, and git email across repo files; do not run it for normal day-to-day edits
- In this environment, `build-switch` usually reaches a macOS `sudo` password prompt and cannot complete unattended beyond that point
- After a successful shell-related switch, refresh the shell with `exec zsh -l`. Do not rely on `source ~/.zshrc` alone, because this Home Manager setup expects variables from `~/.zshenv` as well.

## Where To Change Things

- Shared CLI packages: [`modules/shared/packages.nix`](modules/shared/packages.nix)
- macOS-only Nix packages: [`modules/darwin/packages.nix`](modules/darwin/packages.nix)
- Homebrew GUI apps: [`modules/darwin/casks.nix`](modules/darwin/casks.nix)
- PF-based inbound firewall rules for Screen Sharing/VNC: [`modules/darwin/pf.nix`](modules/darwin/pf.nix)
- Shell behavior, aliases, and `oh-my-zsh`: [`modules/shared/home-manager.nix`](modules/shared/home-manager.nix)
- Docker/Colima user services: [`modules/darwin/home-manager.nix`](modules/darwin/home-manager.nix)
- Managed home files and app config links: [`modules/shared/files.nix`](modules/shared/files.nix) and [`modules/darwin/files.nix`](modules/darwin/files.nix)
- Ghostty-compatible terminal appearance for Ghostty/cmux: [`modules/shared/config/ghostty`](modules/shared/config/ghostty)
- App-specific config content:
  - Local Docker stack guide: [`modules/shared/config/dev-infra/README.md`](modules/shared/config/dev-infra/README.md)
  - Local Docker stack: [`modules/shared/config/dev-infra/compose.yml`](modules/shared/config/dev-infra/compose.yml)
  - Local MySQL image build: [`modules/shared/config/dev-infra/mysql/Dockerfile`](modules/shared/config/dev-infra/mysql/Dockerfile)
  - Local MySQL init SQL: [`modules/shared/config/dev-infra/mysql-init/001-admin-superuser.sql`](modules/shared/config/dev-infra/mysql-init/001-admin-superuser.sql)
  - Ghostty/cmux terminal config: [`modules/shared/config/ghostty`](modules/shared/config/ghostty)
  - Neovim: [`modules/shared/config/nvim`](modules/shared/config/nvim)
  - WezTerm: [`modules/shared/config/wezterm`](modules/shared/config/wezterm)
  - Worktrunk user config: [`modules/shared/config/worktrunk/config.toml`](modules/shared/config/worktrunk/config.toml)
  - VS Code user config: [`modules/shared/config/vscode`](modules/shared/config/vscode)
- macOS system defaults: [`hosts/darwin/default.nix`](hosts/darwin/default.nix)
- Dock management: [`modules/darwin/dock/default.nix`](modules/darwin/dock/default.nix)

## Project-Specific Constraints

- Prefer editing Nix modules instead of patching generated files or local dotfiles.
- Home Manager manages `zsh`; changes should go into [`modules/shared/home-manager.nix`](modules/shared/home-manager.nix), not `~/.zshrc`.
- `zsh` uses Home Manager's `oh-my-zsh` integration. Do not assume a user-managed `~/.oh-my-zsh` tree exists or should be edited.
- Worktrunk shell integration for zsh should be managed declaratively in [`modules/shared/home-manager.nix`](modules/shared/home-manager.nix); prefer that over running `wt config shell install`, because this repo treats shell startup as Home Manager-managed state.
- Existing unmanaged dotfiles can block activation. This repo sets `home-manager.backupFileExtension = "hm-backup"` in [`modules/darwin/home-manager.nix`](modules/darwin/home-manager.nix), so first-time activation may move conflicting files aside instead of failing.
- `homebrew.onActivation.autoUpdate` and `upgrade` are enabled, so `build-switch` may update managed casks.
- JetBrains IDEs are expected to be installed and updated through JetBrains Toolbox, which is managed as a Homebrew cask in [`modules/darwin/casks.nix`](modules/darwin/casks.nix).
- Shell aliases such as `webstorm` or `datagrip` rely on Toolbox-generated launchers, so keep the Toolbox shell scripts feature enabled and ensure the scripts live in a PATH directory such as `~/Library/Application Support/JetBrains/Toolbox/scripts` or `~/.local/bin`.
- Zen is installed via Homebrew cask, not via a Zen flake.
- Ghostty-compatible config for Ghostty and `cmux` lives in [`modules/shared/config/ghostty`](modules/shared/config/ghostty), and [`modules/shared/files.nix`](modules/shared/files.nix) links that whole directory into `~/.config/ghostty`.
- Keep the primary Ghostty config file named `config` for `cmux` compatibility, and use `config.ghostty` only as a shim when you need Ghostty tooling to resolve the same settings.
- WezTerm is installed via Homebrew cask, and [`modules/shared/files.nix`](modules/shared/files.nix) links the whole [`modules/shared/config/wezterm`](modules/shared/config/wezterm) directory into `~/.config/wezterm`.
- The standalone `kimbank/.config` repository is a mirror publish target for [`modules/shared/config`](modules/shared/config), not the source of truth.
- Worktrunk user config is stored in [`modules/shared/config/worktrunk/config.toml`](modules/shared/config/worktrunk/config.toml) and linked as the single file `~/.config/worktrunk/config.toml`; do not link the whole `~/.config/worktrunk` directory because Worktrunk needs that directory to remain writable for runtime state such as `approvals.toml`.
- Neovim is installed by Home Manager, but the config is dotfile-style and lives in the repo-managed directory [`modules/shared/config/nvim`](modules/shared/config/nvim). [`modules/shared/files.nix`](modules/shared/files.nix) links that whole directory into `~/.config/nvim`, and plugins are bootstrapped inside the config via `lazy.nvim` rather than `programs.neovim.plugins`.
- Docker CLI comes from nixpkgs, Colima is managed as a Home Manager user service in [`modules/darwin/home-manager.nix`](modules/darwin/home-manager.nix), and [`modules/shared/files.nix`](modules/shared/files.nix) links the entire local Docker stack directory from [`modules/shared/config/dev-infra`](modules/shared/config/dev-infra) to `~/.config/dev-infra`.
- The local Docker stack uses a single [`compose.yml`](modules/shared/config/dev-infra/compose.yml) to start Portainer, MySQL, PostgreSQL, Redis, and MinIO together, and it is meant to be run from the Home Manager symlink at `~/.config/dev-infra`.
- Because `~/.config/dev-infra` is store-backed, avoid runtime bind mounts for tracked files inside that stack. Prefer baking bootstrap assets into a local image, or use runtime inputs that do not require Colima to mount Nix-store-backed paths.
- MySQL bootstrap SQL is stored under [`mysql-init/`](modules/shared/config/dev-infra/mysql-init/001-admin-superuser.sql) and baked into the local MySQL image via [`mysql/Dockerfile`](modules/shared/config/dev-infra/mysql/Dockerfile).
- Portainer's initial admin password is configured directly in [`compose.yml`](modules/shared/config/dev-infra/compose.yml) as a bcrypt hash for the local-only password `adminadmin!!`.
- If the dev stack behavior, credentials, ports, or daily workflow changes, update [`modules/shared/config/dev-infra/README.md`](modules/shared/config/dev-infra/README.md) in the same task.
- VS Code is managed declaratively through Home Manager with `package = null`, which means the actual GUI app is expected to come from outside the HM package install path.
- VS Code keybindings are linked via [`modules/shared/files.nix`](modules/shared/files.nix), while user settings stay writable in `~/Library/Application Support/Code/User/settings.json`.
- Because `programs.vscode.mutableExtensionsDir = true` and no declarative extension list is configured, VS Code extensions are installed, removed, and updated from the UI rather than from this repository.
- The dock module resets the Dock when the current entries differ from the declared list.
- Overlays are auto-loaded from `overlays/`; avoid adding broken or partial overlay files there.
- This worktree may contain uncommitted user edits under `modules/shared/config/vscode` or other config directories. Do not revert them unless explicitly asked.

## macOS Integration Guidance

- Prefer first-class `nix-darwin` or Home Manager options when they exist. If macOS behavior is controlled by a preference key without a dedicated typed option, use [`system.defaults.CustomUserPreferences`] or [`system.defaults.CustomSystemPreferences`] rather than inventing unsupported `system.defaults.*` keys.
- `system.defaults.*`, `CustomUserPreferences`, and `CustomSystemPreferences` primarily write preferences; removing or commenting out a previously set key does not necessarily delete the existing macOS `defaults` value. If a setting seems to "stick" after being removed from Nix, check whether the host still has the old value and clear it explicitly when needed.
- Accessibility preferences under `com.apple.universalaccess` may behave as host-scoped user defaults on fresh macOS installs. Prefer Home Manager's `targets.darwin.currentHostDefaults` for those keys instead of `system.defaults.universalaccess` when initial activation reliability matters.
- If a macOS preference key is undocumented or community-discovered, keep the configuration declarative but add a short comment explaining what it does and that it is not an Apple-documented key.
- For user-level files that do not have a first-class module option, prefer Home Manager-managed files (`home.file`) over editing live files in `$HOME`.
- For small Darwin-only helper CLIs that are missing from `nixpkgs`, prefer a local Nix package in the repo over ad hoc install scripts or adding extra Homebrew taps, especially when the upstream source is small and easy to build reproducibly.
- Use the existing Homebrew path primarily for GUI apps and other cases where Nix packaging is weak. Do not add third-party Homebrew taps when a simple local derivation is more reproducible and easier to maintain.
- For inbound network allowlists on macOS, prefer a declarative `pf` module under [`modules/darwin/`](modules/darwin/) over ad hoc `pfctl` shell commands. Preserve Apple's default anchor chain unless the task is explicitly replacing the full PF policy.
- Shell startup hooks only affect newly started shells. Do not assume they will retroactively change behavior in already-open terminals or on app focus changes.

## Validation Expectations

For most config changes:

1. Edit the relevant Nix files.
2. Stage tracked changes with `git add .` when needed.
3. Run `nix run .#build`.
4. If the user wants the config applied, run `nix run .#build-switch`.

If you cannot run a verification step, say so explicitly.

## Documentation Expectations

- After completing a task, review whether the change should also update documentation such as `AGENTS.md`, `README.md`, inline comments, or app-specific notes.
- Treat `README.md` as part of the deliverable when repository layout, install surfaces, commands, workflow, or user-visible behavior changes.
- If behavior, commands, install surfaces, caveats, or workflow expectations changed, update the relevant docs in the same task when practical instead of leaving the repo in a code-updated but doc-stale state.
- When updating `AGENTS.md`, prefer reusable guidance and maintenance heuristics over one-off task notes so future work benefits from the change.

## Editing Guidance

- Keep the package split intact: shared CLI tools in `modules/shared`, Darwin-only items in `modules/darwin`.
- Preserve the current single-host shape unless the user explicitly asks for multi-host expansion.
- Avoid unnecessary churn in `flake.lock`.
- Do not remove or rewrite user-specific values unless the task is explicitly about re-personalizing the repo.
- This worktree may already contain unrelated edits. Do not revert user changes such as the current `README.md` modification.
- Treat `modules/shared/config/` as parent-repo-owned content unless the user explicitly asks to export or mirror one of those directories elsewhere.
- Do not edit the standalone `.config` mirror repository directly as part of normal config work unless the user explicitly asks for mirror-repo surgery.
