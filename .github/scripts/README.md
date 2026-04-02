# GitHub Workflow Scripts

Use `.github/workflows/` for workflow YAML and `.github/scripts/` for scripts that support those workflows.

Inside `.github/scripts/`, prefer a workflow-specific subdirectory when a workflow has more than one helper script or is likely to grow over time.

Current layout:

- `dot-config-mirror/publish-config-mirrors.sh`: exports the repo-managed config tree to the standalone `kimbank/.config` mirror repository

Example:

```sh
export PUBLISH_GITHUB_TOKEN=YOUR_TOKEN
bash ./.github/scripts/dot-config-mirror/publish-config-mirrors.sh config
```

This is a mirror publish, not bidirectional sync. The target branch is force-updated from this repo's subtree history, so the standalone `.config` repo should be treated as an output, not the source of truth.
