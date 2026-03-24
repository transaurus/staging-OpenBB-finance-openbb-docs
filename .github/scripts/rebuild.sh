#!/usr/bin/env bash
set -euo pipefail

# Rebuild script for OpenBB-finance/openbb-docs
# Runs on existing source tree (no clone). Installs deps, builds.

# --- Node version ---
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -f "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    nvm install 20
    nvm use 20
fi

# --- Package manager + dependencies ---
npm install --legacy-peer-deps

# --- Build ---
npm run build

echo "[DONE] Build complete."
