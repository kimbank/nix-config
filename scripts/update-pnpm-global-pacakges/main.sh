#!/usr/bin/env bash
set -euo pipefail

pnpm up -g @openai/codex --latest
pnpm up -g opencode-ai --latest
