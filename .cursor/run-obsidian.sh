#!/usr/bin/env bash
# Launch Obsidian on the VM's virtual desktop (the same X display used by
# computer-use). Intended to run as a long-lived `terminals` process so its
# logs stay visible and it can be restarted easily.
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"

# Electron needs a runtime dir; fall back to a writable one if unset.
if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -w "${XDG_RUNTIME_DIR:-/nonexistent}" ]; then
  export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
  mkdir -p "$XDG_RUNTIME_DIR"
  chmod 700 "$XDG_RUNTIME_DIR"
fi

# Make sure the vault exists and themes are linked before launching.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/vault-setup.sh"

echo "[run-obsidian] launching Obsidian on DISPLAY=$DISPLAY"
# --no-sandbox is required for Electron/Chromium inside the container.
exec obsidian --no-sandbox --disable-gpu
