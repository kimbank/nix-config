# GitHub Workflow Scripts

`.github/scripts/` contains helper scripts that exist to support GitHub workflow automation. These scripts are not general local setup tools; they exist to keep workflow logic readable, reusable, and easier to test outside inline YAML shell blocks.

This directory is organized by workflow concern, not by individual file. Prefer a workflow-specific subdirectory when a workflow has helper scripts today or is likely to gain more later.

Current conventions:

- Keep workflow support code under a subdirectory named after the automation or integration it serves.
- Let the top-level README act as the index for `.github/scripts/`.
- Add a task-local `README.md` only when a specific workflow directory grows enough to need its own operational notes.

## dot-config-mirror

`dot-config-mirror/` contains the helper script used to publish `modules/shared/config` from this repository into the standalone `kimbank/.config` mirror repository.

Files:

- `dot-config-mirror/publish-config-mirrors.sh`: subtree split/push helper used by the publish workflow

Example:

```sh
export PUBLISH_GITHUB_TOKEN=YOUR_TOKEN
bash ./.github/scripts/dot-config-mirror/publish-config-mirrors.sh config
```

This is a mirror publish, not bidirectional sync. The target branch is force-updated from this repo's subtree history, so the standalone `.config` repo should be treated as an output, not the source of truth.
