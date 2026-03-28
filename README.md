# Kimbank Nix Config

macOS-first Nix configuration that follows the same high-level layout as the reference `nixos-config` repository.

## Layout

```text
.
├── apps         # Helper commands exposed through `nix run`
├── hosts        # Host-level nix-darwin entrypoint
├── modules      # Darwin-specific and shared modules
└── overlays     # Optional local overlays
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

### 4. Clone this repository

The clone path is not special. Any location is fine as long as you run commands from the repository root.

Example:

```sh
cd ~
git clone https://github.com/kimbank/nix-config.git
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
- macOS-specific Nix packages: `modules/darwin/packages.nix`
- Homebrew casks: `modules/darwin/casks.nix`

### 8. Review shell configuration

This config manages your shell through Home Manager. Review:

- `modules/shared/home-manager.nix`
- `modules/darwin/home-manager.nix`

Like the reference `nixos-config`, this setup assumes your Nix-managed shell config replaces the previous one. Bring over anything important before switching.

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

## Updating After First Install

General workflow:

1. Edit the Nix files.
2. Run `git add .` if you created or changed tracked files.
3. Run `nix run .#build` to verify.
4. Run `nix run .#build-switch` to apply.

Examples:

- Add CLI tools in `modules/shared/packages.nix`
- Add GUI apps in `modules/darwin/casks.nix`
- Adjust shell settings in `modules/shared/home-manager.nix`
- Adjust macOS defaults in `hosts/darwin/default.nix`

## Notes

- The current target platform is `aarch64-darwin`, not `arm64-darwin`.
- `nix run .#apply` is for initial personalization of the template.
- Day-to-day changes are applied with `nix run .#build-switch`.
- On a fresh Mac this should be straightforward. On an already-used Mac, existing `/etc` files, old Homebrew state, or existing shell dotfiles can still conflict during first activation.
