# AGENTS.md

This repository is a macOS-first `nix-darwin` flake for a single Apple Silicon host.

## Scope

- Target platform is `aarch64-darwin`.
- Main entrypoint is [`flake.nix`](/Users/kimbank/Desktop/nix-config/flake.nix).
- Host entrypoint is [`hosts/darwin/default.nix`](/Users/kimbank/Desktop/nix-config/hosts/darwin/default.nix).
- User-level shell and dotfile management is done through Home Manager in [`modules/darwin/home-manager.nix`](/Users/kimbank/Desktop/nix-config/modules/darwin/home-manager.nix) and [`modules/shared/home-manager.nix`](/Users/kimbank/Desktop/nix-config/modules/shared/home-manager.nix).

## Repository Layout

- `apps/aarch64-darwin/`: helper scripts exposed through `nix run`
- `hosts/darwin/`: top-level `nix-darwin` host module
- `modules/shared/`: cross-cutting packages, Home Manager programs, overlays
- `modules/darwin/`: macOS-only packages, casks, files, dock behavior
- `overlays/`: optional local overlays auto-imported by [`modules/shared/default.nix`](/Users/kimbank/Desktop/nix-config/modules/shared/default.nix)

## Command Workflow

Use these commands from the repo root:

- `nix run .#apply`: initial template personalization only
- `nix run .#build`: build and verify the Darwin system
- `nix run .#build-switch`: build and switch to the new generation
- `nix run .#rollback`: switch to a previous generation
- `nix run .#clean`: garbage-collect old generations

Important:

- Stage tracked changes before `build` or `build-switch` if you want Nix to see them: `git add .`
- `build-switch` runs `darwin-rebuild switch` via [`apps/aarch64-darwin/build-switch`](/Users/kimbank/Desktop/nix-config/apps/aarch64-darwin/build-switch)
- `apply` rewrites placeholder values like `loginUser`, git name, and git email across repo files; do not run it for normal day-to-day edits

## Where To Change Things

- Shared CLI packages: [`modules/shared/packages.nix`](/Users/kimbank/Desktop/nix-config/modules/shared/packages.nix)
- macOS-only Nix packages: [`modules/darwin/packages.nix`](/Users/kimbank/Desktop/nix-config/modules/darwin/packages.nix)
- Homebrew GUI apps: [`modules/darwin/casks.nix`](/Users/kimbank/Desktop/nix-config/modules/darwin/casks.nix)
- Shell behavior and aliases: [`modules/shared/home-manager.nix`](/Users/kimbank/Desktop/nix-config/modules/shared/home-manager.nix)
- Managed home files: [`modules/shared/files.nix`](/Users/kimbank/Desktop/nix-config/modules/shared/files.nix) and [`modules/darwin/files.nix`](/Users/kimbank/Desktop/nix-config/modules/darwin/files.nix)
- macOS system defaults: [`hosts/darwin/default.nix`](/Users/kimbank/Desktop/nix-config/hosts/darwin/default.nix)
- Dock management: [`modules/darwin/dock/default.nix`](/Users/kimbank/Desktop/nix-config/modules/darwin/dock/default.nix)

## Project-Specific Constraints

- Prefer editing Nix modules instead of patching generated files or local dotfiles.
- Home Manager manages `zsh`; changes should go into [`modules/shared/home-manager.nix`](/Users/kimbank/Desktop/nix-config/modules/shared/home-manager.nix), not `~/.zshrc`.
- Existing unmanaged dotfiles can block activation. Home Manager collision checks will fail the switch rather than silently overwrite files unless backup behavior is explicitly configured.
- `homebrew.onActivation.autoUpdate` and `upgrade` are enabled, so `build-switch` may update managed casks.
- The dock module resets the Dock when the current entries differ from the declared list.
- Overlays are auto-loaded from `overlays/`; avoid adding broken or partial overlay files there.

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
