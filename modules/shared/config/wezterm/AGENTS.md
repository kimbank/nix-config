# AGENTS.md

This directory contains the dotfile-style WezTerm configuration that is linked into
`~/.config/wezterm` by the parent Nix repo.

The standalone `kimbank/.config` repository is treated as a mirror output of the
parent config tree, not the source of truth.

## Scope

- Keep this repository focused on WezTerm runtime configuration files.
- Prefer small, explicit Lua modules over large monolithic config files.
- Assume this config is launched from macOS Finder as well as from interactive shells.

## macOS Launch Behavior

- Finder-launched apps inherit a sparse `PATH`. When documenting or scripting external launch
  flows, prefer absolute paths such as
  `/Applications/WezTerm.app/Contents/MacOS/wezterm` instead of relying on shell PATH setup.
- If `gui-startup` is implemented, it must respect external launch requests by passing the incoming
  `cmd` through to `mux.spawn_window(cmd)`. Otherwise `wezterm start --cwd ...` and similar calls
  can appear to do nothing on first launch.
- `gui-startup` logic should avoid spawning custom windows unconditionally. Reserve that behavior
  for explicit opt-in flows so normal app launches and Finder integrations still open the requested
  working directory.

## Startup Monitor

- `startup-monitor.lua` is opt-in and should only create the monitor layout when
  `WEZTERM_STARTUP_MONITOR=1` is set.
- Normal WezTerm launches should not open the monitor workspace by default.
- When focusing a pane created during startup, use pane APIs such as `pane:activate()` rather than
  non-existent window helper methods.

## Finder Quick Action Notes

- A practical Finder integration on macOS is a Quick Action named `Open in WezTerm`.
- The Quick Action should call:
  `/Applications/WezTerm.app/Contents/MacOS/wezterm start --new-tab --cwd "<target>"`
- If Finder should bring WezTerm to the front after spawning, use AppleScript separately:
  `/usr/bin/osascript -e 'tell application "WezTerm" to activate'`
- `--new-tab` affects the case where a GUI instance is already running. First-launch behavior still
  depends on `gui-startup` respecting the incoming `cmd`.

## Validation

- After editing this repo, sanity-check config loading with `wezterm show-keys` or another command
  that parses the config without requiring a full interactive session.
- The parent repo tracks this directory directly, so stage parent-level changes here before
  running Nix builds or switches if you want Nix to evaluate the updated working tree contents.
