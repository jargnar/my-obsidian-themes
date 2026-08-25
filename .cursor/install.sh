#!/usr/bin/env bash
# Idempotent environment bootstrap for the Obsidian themes repo.
#
# Installs the Obsidian desktop app (pinned to the version the themes target),
# fetches the Obsidian docs for offline reference, and prepares a sample vault
# with every repo theme linked in. Safe to run repeatedly.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Version the themes declare compatibility with (manifest.json -> minAppVersion).
OBSIDIAN_VERSION="${OBSIDIAN_VERSION:-1.13.7}"
DEB_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb"

# --- 1. Install Obsidian (skip if the pinned version is already present) ------
installed_version="$(dpkg-query -W -f='${Version}' obsidian 2>/dev/null || true)"
if [ "$installed_version" = "$OBSIDIAN_VERSION" ]; then
  echo "[install] Obsidian $OBSIDIAN_VERSION already installed"
else
  echo "[install] installing Obsidian $OBSIDIAN_VERSION"
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -fsSL -o "$tmp_deb" "$DEB_URL"
  sudo apt-get update -qq
  sudo apt-get install -y -q "$tmp_deb"
  rm -f "$tmp_deb"
fi

# --- 2. Obsidian documentation for offline reference -------------------------
DOCS_DIR="${OBSIDIAN_DOCS_DIR:-$HOME/obsidian-docs}"
clone_or_update() {
  local url="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    echo "[install] updating docs: $dest"
    git -C "$dest" pull --ff-only --quiet || echo "[install] WARN: could not update $dest"
  else
    echo "[install] cloning docs: $url"
    git clone --depth 1 --quiet "$url" "$dest" || echo "[install] WARN: could not clone $url"
  fi
}
mkdir -p "$DOCS_DIR"
# Developer docs include the CSS variables reference used for theming.
clone_or_update "https://github.com/obsidianmd/obsidian-developer-docs.git" "$DOCS_DIR/developer-docs"
# End-user help docs (UI concepts, features).
clone_or_update "https://github.com/obsidianmd/obsidian-help.git" "$DOCS_DIR/help"

# --- 3. Sample vault + theme links ------------------------------------------
"$SCRIPT_DIR/vault-setup.sh"

echo "[install] done"
