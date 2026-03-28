# AGENTS.md

This repository is a macOS-first `nix-darwin` flake for a single Apple Silicon host.

## Scope

- Target platform is `aarch64-darwin`.
- Canonical working copy for this repo is `/Users/kimbank/nix-config`.
- Do not confuse this repo with `/Users/kimbank/Desktop/nixos-config`, which is a separate upstream/example-style repo and not the default target for edits or validation unless the user explicitly asks to work there.
- Main entrypoint is [`flake.nix`](/Users/kimbank/nix-config/flake.nix).
- Host entrypoint is [`hosts/darwin/default.nix`](/Users/kimbank/nix-config/hosts/darwin/default.nix).
- User-level shell and dotfile management is done through Home Manager in [`modules/darwin/home-manager.nix`](/Users/kimbank/nix-config/modules/darwin/home-manager.nix) and [`modules/shared/home-manager.nix`](/Users/kimbank/nix-config/modules/shared/home-manager.nix).

## Repository Layout

- `apps/aarch64-darwin/`: helper scripts exposed through `nix run`
- `hosts/darwin/`: top-level `nix-darwin` host module
- `modules/shared/`: cross-cutting packages, Home Manager programs, overlays
- `modules/darwin/`: macOS-only packages, casks, files, dock behavior
- `modules/shared/config/`: app-specific config tracked as git submodules
- `overlays/`: optional local overlays auto-imported by [`modules/shared/default.nix`](/Users/kimbank/nix-config/modules/shared/default.nix)

## Clone And Submodules

- This repository uses git submodules under `modules/shared/config/`.
- Clone with `git clone --recurse-submodules ...` or run `git submodule update --init --recursive` after cloning.
- [`flake.nix`](/Users/kimbank/nix-config/flake.nix) sets `inputs.self.submodules = true;` so Nix includes submodule contents during evaluation.
- If a task edits files inside `modules/shared/config/nvim` or `modules/shared/config/wezterm`, commit and push those repositories first, then stage the updated gitlink in the parent repo.

## Command Workflow

Use these commands from the repo root:

- `nix run .#apply`: initial template personalization only
- `nix run .#build`: build and verify the Darwin system
- `nix run .#build-switch`: build and switch to the new generation
- `nix run .#rollback`: switch to a previous generation
- `nix run .#clean`: garbage-collect old generations

Important:

- Stage tracked changes before `build` or `build-switch` if you want Nix to see them: `git add .`
- `build-switch` runs `darwin-rebuild switch` via [`apps/aarch64-darwin/build-switch`](/Users/kimbank/nix-config/apps/aarch64-darwin/build-switch)
- `apply` rewrites placeholder values like `loginUser`, git name, and git email across repo files; do not run it for normal day-to-day edits
- In this environment, `build-switch` usually reaches a macOS `sudo` password prompt and cannot complete unattended beyond that point
- After a successful shell-related switch, refresh the shell with `exec zsh -l`. Do not rely on `source ~/.zshrc` alone, because this Home Manager setup expects variables from `~/.zshenv` as well.

## Where To Change Things

- Shared CLI packages: [`modules/shared/packages.nix`](/Users/kimbank/nix-config/modules/shared/packages.nix)
- macOS-only Nix packages: [`modules/darwin/packages.nix`](/Users/kimbank/nix-config/modules/darwin/packages.nix)
- Homebrew GUI apps: [`modules/darwin/casks.nix`](/Users/kimbank/nix-config/modules/darwin/casks.nix)
- Shell behavior, aliases, `oh-my-zsh`, and Neovim plugin wiring: [`modules/shared/home-manager.nix`](/Users/kimbank/nix-config/modules/shared/home-manager.nix)
- Managed home files and app config links: [`modules/shared/files.nix`](/Users/kimbank/nix-config/modules/shared/files.nix) and [`modules/darwin/files.nix`](/Users/kimbank/nix-config/modules/darwin/files.nix)
- App-specific config content:
  - Neovim: [`modules/shared/config/nvim`](/Users/kimbank/nix-config/modules/shared/config/nvim)
  - WezTerm: [`modules/shared/config/wezterm`](/Users/kimbank/nix-config/modules/shared/config/wezterm)
  - VS Code user config: [`modules/shared/config/vscode`](/Users/kimbank/nix-config/modules/shared/config/vscode)
  - VS Code extension declarations: [`modules/shared/config/vscode/extensions.nix`](/Users/kimbank/nix-config/modules/shared/config/vscode/extensions.nix)
- macOS system defaults: [`hosts/darwin/default.nix`](/Users/kimbank/nix-config/hosts/darwin/default.nix)
- Dock management: [`modules/darwin/dock/default.nix`](/Users/kimbank/nix-config/modules/darwin/dock/default.nix)

## Project-Specific Constraints

- Prefer editing Nix modules instead of patching generated files or local dotfiles.
- Home Manager manages `zsh`; changes should go into [`modules/shared/home-manager.nix`](/Users/kimbank/nix-config/modules/shared/home-manager.nix), not `~/.zshrc`.
- `zsh` uses Home Manager's `oh-my-zsh` integration. Do not assume a user-managed `~/.oh-my-zsh` tree exists or should be edited.
- Existing unmanaged dotfiles can block activation. This repo sets `home-manager.backupFileExtension = "hm-backup"` in [`modules/darwin/home-manager.nix`](/Users/kimbank/nix-config/modules/darwin/home-manager.nix), so first-time activation may move conflicting files aside instead of failing.
- `homebrew.onActivation.autoUpdate` and `upgrade` are enabled, so `build-switch` may update managed casks.
- Zen is installed via Homebrew cask, not via a Zen flake.
- WezTerm is installed via Homebrew cask, but its config comes from [`modules/shared/config/wezterm`](/Users/kimbank/nix-config/modules/shared/config/wezterm) through [`modules/shared/files.nix`](/Users/kimbank/nix-config/modules/shared/files.nix).
- Neovim is installed and wrapped by Home Manager. [`modules/shared/home-manager.nix`](/Users/kimbank/nix-config/modules/shared/home-manager.nix) owns the generated `~/.config/nvim/init.lua`, which sources `~/.config/nvim/local-init.lua`. Do not try to replace the whole `~/.config/nvim/init.lua` target directly through `home.file`.
- VS Code is managed declaratively through Home Manager with `package = null`, which means settings/extensions are managed but the actual GUI app is expected to come from outside the HM package install path.
- VS Code settings and keybindings are linked via [`modules/shared/files.nix`](/Users/kimbank/nix-config/modules/shared/files.nix), while extension selection lives in [`modules/shared/config/vscode/extensions.nix`](/Users/kimbank/nix-config/modules/shared/config/vscode/extensions.nix).
- Because `programs.vscode.mutableExtensionsDir = false`, UI-installed or UI-removed extensions will not persist once the Home Manager config is applied again.
- The dock module resets the Dock when the current entries differ from the declared list.
- Overlays are auto-loaded from `overlays/`; avoid adding broken or partial overlay files there.
- This worktree may contain uncommitted user edits under `modules/shared/config/vscode` or other config directories. Do not revert them unless explicitly asked.

## Validation Expectations

For most config changes:

1. Edit the relevant Nix files.
2. Stage tracked changes with `git add .` when needed.
3. Run `nix run .#build`.
4. If the user wants the config applied, run `nix run .#build-switch`.

If you cannot run a verification step, say so explicitly.

## Editing Guidance

- Keep the package split intact: shared CLI tools in `modules/shared`, Darwin-only items in `modules/darwin`.
- Preserve the current single-host shape unless the user explicitly asks for multi-host expansion.
- Avoid unnecessary churn in `flake.lock`.
- Do not remove or rewrite user-specific values unless the task is explicitly about re-personalizing the repo.
- This worktree may already contain unrelated edits. Do not revert user changes such as the current `README.md` modification.
- If a change touches a submodule, treat it as a separate Git repository with its own commit/push cycle before updating the parent repo pointer.
