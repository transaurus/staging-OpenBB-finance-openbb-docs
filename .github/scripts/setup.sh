#!/bin/bash
# Generated setup script for: https://github.com/OpenBB-finance/openbb-docs
# Docusaurus 3.7.0, npm, Node >=20

set -e

REPO_URL="https://github.com/OpenBB-finance/openbb-docs"
BRANCH="main"

echo "[INFO] Cloning repository..."
if [ -d "source-repo" ]; then
    rm -rf source-repo
fi

git clone --depth 1 --branch "$BRANCH" "$REPO_URL" source-repo
cd source-repo

echo "[INFO] Node version: $(node -v)"
echo "[INFO] NPM version: $(npm -v)"

echo "[INFO] Applying content fixes..."
# Fix duplicate React imports in Icon components (generated SVGR files have both
# "import * as React from 'react'" and "import React, { SVGProps } from 'react'")
for f in src/components/Icons/Bullseye.tsx src/components/Icons/Desktop.tsx src/components/Icons/YCombinator.tsx; do
    if [ -f "$f" ]; then
        sed -i '1{/^import \* as React from "react"$/d}' "$f"
        echo "[INFO] Fixed duplicate React import in $f"
    fi
done

# Fix duplicate sidebar translation key: two "AI Features" categories with no unique key
# workspace/developers/ai-features and workspace/analysts/ai-features both labeled "AI Features"
python3 -c "
import json
files = {
    'content/workspace/developers/ai-features/_category_.json': 'developers-ai-features',
    'content/workspace/analysts/ai-features/_category_.json': 'analysts-ai-features',
}
for path, key in files.items():
    with open(path) as f:
        data = json.load(f)
    data['key'] = key
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    print(f'[INFO] Added key={key!r} to {path}')
"

echo "[INFO] Installing dependencies..."
npm ci --legacy-peer-deps

echo "[INFO] Running write-translations..."
npm run write-translations

echo "[INFO] Verifying i18n output..."
if [ -d "i18n" ]; then
    find i18n -type f -name "*.json" | head -20
    COUNT=$(find i18n -type f -name "*.json" | wc -l)
    echo "[INFO] Generated $COUNT JSON files"
else
    echo "[ERROR] i18n directory not found"
    exit 1
fi

echo "[INFO] Running build..."
npm run build

echo "[INFO] Verifying build output..."
if [ -d "build" ] && [ -n "$(ls -A build)" ]; then
    COUNT=$(find build -type f | wc -l)
    echo "[INFO] Build directory contains $COUNT files"
else
    echo "[ERROR] build/ directory missing or empty"
    exit 1
fi

echo "[INFO] Setup completed successfully!"
