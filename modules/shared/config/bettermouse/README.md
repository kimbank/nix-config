# BetterMouse settings backup

`bm_cfg_9010.plist` is a settings export from BetterMouse 1.7, build 9010.
It includes MX Master 3S, MX Vertical, and keyboard settings.

This directory is a manually maintained backup, not a live configuration
directory. Home Manager does not link it to `~/.config/bettermouse` or import
it during a Nix switch. BetterMouse stores its live preferences separately at
`~/Library/Preferences/com.naotanhaocan.BetterMouse.plist`.

## Restore

1. Install and launch BetterMouse. This repo declares its Homebrew cask in
   `modules/darwin/casks.nix`.
2. Export your current settings first if you want to keep them; importing this
   backup replaces settings in the app.
3. Open BetterMouse's settings and use its settings import/load action to select
   `bm_cfg_9010.plist` from this directory.
4. Check the scroll and button behavior on your connected mouse. On a new Mac,
   grant BetterMouse Accessibility access when prompted; the export does not
   grant macOS permissions.

Alternatively, quit BetterMouse completely, then run the following from the
repository root:

```sh
open -n -a /Applications/BetterMouse.app --args \
  "$PWD/modules/shared/config/bettermouse/bm_cfg_9010.plist"
```

BetterMouse supports loading an exported settings file through launch arguments
since [build 8805](https://better-mouse.com/version-1-6-8805/).
Do not copy the export directly over the live preferences plist: they have
different structures.

## Updating and publishing

Export settings from BetterMouse and copy the resulting file here when you want
to update the backup. Live app changes do not update this file automatically.
Use the build number in the filename to identify the exporting app version.

This backup intentionally includes the account email and registration/trial
status, as well as device model names. The inspected export contains no license
key, password, or API token. Inspect future exports before publishing them:
some fields are nested binary plists, so a plain text search is insufficient.
This directory is also included in the repository's one-way `.config` mirror
when that mirror is published.
