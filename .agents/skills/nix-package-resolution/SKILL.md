---
name: nix-package-resolution
description: Determine how to add software to a Nix-based setup. Use when a user wants to install, enable, remove, or declaratively manage an app, CLI, browser extension, or integration in Nix, nix-darwin, Home Manager, Homebrew-through-nix, or a third-party flake. Especially useful when deciding whether the package already exists in nixpkgs, whether a community flake is justified, how to handle unfree software, and how to validate the final integration.
---

# Nix Package Resolution

## Overview

Resolve package requests in this order: understand the target repo's install surfaces, check whether nixpkgs already supports the software, choose the narrowest integration path that matches the repo, then validate with Nix evaluation or build.

Prefer reproducible, repo-native solutions over ad hoc installs.

## Workflow

### 1. Inspect the target repository first

Identify how the repo already manages software before proposing changes.

Check for:

- `environment.systemPackages`
- `home.packages`
- `programs.*`
- `homebrew`, `casks`, `masApps`
- overlay loading
- existing third-party flake inputs
- helper scripts such as `build-switch`, `darwin-rebuild`, `home-manager switch`

Use `rg` on the repo before making assumptions. Match the existing structure unless the user explicitly wants a new pattern.

### 2. Decide the install surface

Choose the smallest surface that fits the software:

- Use `programs.*` modules when a first-class module already exists and provides useful integration.
- Use `environment.systemPackages` for machine-wide CLI tools.
- Use `home.packages` for per-user packages in Home Manager-managed repos.
- Use nix-managed Homebrew only when the repo already uses Homebrew for macOS GUI apps or when Nix packaging is weak and the repo accepts Homebrew.
- Use overlays only when patching or overriding packaging behavior is actually required.

Do not mix unrelated installation paths without a reason.

### 3. Check nixpkgs first

Use current primary sources. Package availability is unstable.

Check, in order:

1. Local evaluation if the repo already pins nixpkgs and `nix` is available.
2. `search.nixos.org` package search.
3. `NixOS/nixpkgs` on GitHub for package names, aliases, modules, and open package requests.

Prefer official nixpkgs packages when they exist and build on the target system.

For macOS, verify platform support such as `aarch64-darwin` instead of assuming Linux support implies Darwin support.

### 4. If nixpkgs does not provide it, choose the fallback

Use this decision order:

1. Third-party flake
Use when the package is actively maintained, widely used, versioned, and integrates cleanly with the current flake.

2. Existing Homebrew path in the repo
Use when the software is a macOS GUI app, packaging is poor in Nix, or the repo already manages casks declaratively.

3. Policy/config-based integration
Use when the thing being added is not best represented as a package, such as some browser extensions or app-specific policy files.

4. Overlay/custom package
Use only when the package source is stable and you actually need to package it yourself.

### 5. Evaluate a third-party flake critically

Before adding a flake, verify:

- supported systems include the target platform
- the flake follows the repo's `nixpkgs` and `home-manager` inputs when appropriate
- the README documents the intended integration path
- the repo looks maintained enough for the user's risk tolerance
- package names and module names are current

When the flake offers multiple channels, prefer the most reproducible option by default unless the user asks for latest/beta behavior.

### 6. Handle unfree software explicitly

Do not assume global `allowUnfree = true` solves every case.

Remember:

- The target repo's `pkgs` may allow unfree.
- A separate flake output may evaluate its own nixpkgs instance and still reject unfree packages.
- `inputs.some-flake.packages.${system}` can fail even when the main repo allows unfree.

If an external package set fails on unfree:

- first confirm whether the repo already allows unfree in its own nixpkgs config
- then prefer importing the external source through the current `pkgs` context if that is clean and maintainable
- otherwise use a different integration path that preserves declarative behavior

Do not silently switch approaches. Explain why the first path failed.

### 7. Treat browser extensions and app integrations as special cases

Browser extensions are often not just "install package X".

Check whether the integration also needs:

- native messaging hosts
- policy files
- allowed browser identifiers
- app-specific defaults IDs on macOS
- companion GUI or CLI applications

Example pattern:

- Browser package via flake or nixpkgs
- Extension via Home Manager `profiles.*.extensions.packages`
- Native bridge via `nativeMessagingHosts`
- Extra OS integration via `environment.etc` or app-specific module options

If a README documents a preferred extension path, follow it unless evaluation proves it is broken in the current repo.

### 8. Prefer first-class modules over raw packages when they add real behavior

Examples:

- `programs._1password`
- `programs._1password-gui`
- browser modules that manage profiles, policies, extensions, or defaults

Use the module when it adds activation logic, app linking, policy generation, or profile management that a raw package would miss.

### 9. Validate the exact path you chose

After wiring the package, validate the specific integration instead of stopping at a code edit.

Useful checks:

- `nix eval` for options you changed
- `nix build .#... --dry-run` for full system or home configuration
- package attribute evaluation to confirm names and platform support
- lockfile changes after adding flake inputs

When debugging, evaluate the narrowest failing expression first.

### 10. Report tradeoffs clearly

Summarize:

- whether nixpkgs officially supports it
- which path you chose and why
- what alternatives were rejected
- what validation succeeded
- whether the change is fully declarative or partly policy-based

## Heuristics

- Prefer nixpkgs over third-party flakes.
- Prefer third-party flakes over custom packaging when the flake is maintained.
- Prefer repo-consistent Homebrew only for repos that already manage Homebrew.
- Prefer module options over raw package lists when the module adds real integration.
- Prefer policy-based extension installs only when package-based extension handling is unavailable, blocked, or less maintainable.
- Treat unfree failures from external package sets as an evaluation-context problem before treating them as a package-availability problem.

## Fast Checks

For package questions, usually gather these facts before editing:

1. Where this repo installs software today.
2. Whether nixpkgs already contains the software.
3. Whether the target system is supported.
4. Whether the software is unfree.
5. Whether the integration needs more than a package.
6. What command proves the final wiring evaluates or builds.

## Output Standard

When using this skill, end with a short answer that states:

- chosen integration path
- key reason for that path
- validation performed
- remaining caveats, if any
