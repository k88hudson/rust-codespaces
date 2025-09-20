#!/usr/bin/env bash
set -euo pipefail

WS="/workspaces/$(basename "$PWD")"
SRC="/opt/prebuilt-target"
DST="$WS/target"

mkdir -p "$DST"
# Only copy if target is empty
if [ -z "$(ls -A "$DST" 2>/dev/null || true)" ]; then
  echo "Seeding target/ from prebuilt image..."
  rsync -a "$SRC/" "$DST/"
fi

# Set up hooks
mise run install:hooks
