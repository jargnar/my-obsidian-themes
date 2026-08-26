#!/usr/bin/env bash
# Create / refresh the Obsidian sample vault used to preview the themes in this
# repository. Idempotent: safe to run on every boot. It (re)links each theme
# folder into the vault, seeds sample notes, and registers the vault with
# Obsidian so it opens automatically without the first-run vault picker.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

VAULT="${OBSIDIAN_VAULT:-$HOME/ObsidianVault}"
OBS_CONFIG_DIR="${OBSIDIAN_CONFIG_DIR:-$HOME/.config/obsidian}"

echo "[vault-setup] repo root: $REPO_ROOT"
echo "[vault-setup] vault:     $VAULT"

mkdir -p "$VAULT/.obsidian/themes" "$VAULT/Notes"

# --- Link every theme in the repo into the vault -----------------------------
# A theme folder is any top-level directory that has both manifest.json and
# theme.css. We symlink so edits to the repo's CSS are reflected live in the
# vault (reload Obsidian appearance to see changes).
DEFAULT_THEME=""
shopt -s nullglob
for manifest in "$REPO_ROOT"/*/manifest.json; do
  theme_dir="$(dirname "$manifest")"
  [ -f "$theme_dir/theme.css" ] || continue
  theme_name="$(basename "$theme_dir")"
  link="$VAULT/.obsidian/themes/$theme_name"
  rm -rf "$link"
  ln -s "$theme_dir" "$link"
  echo "[vault-setup] linked theme: $theme_name"
  [ -z "$DEFAULT_THEME" ] && DEFAULT_THEME="$theme_name"
done
shopt -u nullglob

if [ -z "$DEFAULT_THEME" ]; then
  echo "[vault-setup] WARNING: no themes (manifest.json + theme.css) found in $REPO_ROOT" >&2
fi

# Classic Lotus Organizer section tabs, used to preview rainbow folder glyphs.
for section in Calendar "To Do" Address Notepad Planner Calls; do
  section_dir="$VAULT/$section"
  mkdir -p "$section_dir"
  note="$section_dir/${section}.md"
  if [ ! -f "$note" ]; then
    printf '# %s\n\nSection divider from a 1990s personal organizer.\n' "$section" > "$note"
  fi
done

# --- Seed sample notes (only if missing, so edits are preserved) --------------
if [ ! -f "$VAULT/Welcome.md" ]; then
  cat > "$VAULT/Welcome.md" <<'MD'
# Theme preview vault

This vault exists to preview the Obsidian themes in this repository.

Switch themes from **Settings -> Appearance -> Themes**. All repo themes
are linked into `.obsidian/themes/` automatically:

- Aqua 2000
- Hobonichi Techo
- Lotus Organizer
- Newton MessagePad
- Palm OS Memo Pad
- Vercel Noir
- Windows 3.1 Cardfile
- Windows Vista Aero
- Windows XP Luna
- Luna Graph

Open the notes in the **Notes** folder to exercise headings, code, callouts,
tables, and other elements that the themes style.

> [!tip] Live editing
> The theme folders are symlinks back into the git repo, so editing a
> `theme.css` and reloading appearance updates the preview immediately.
MD
fi

if [ ! -f "$VAULT/Notes/Elements.md" ]; then
  cat > "$VAULT/Notes/Elements.md" <<'MD'
# Elements showcase

## Headings

# H1 heading
## H2 heading
### H3 heading

## Text styles

Normal text with **bold**, *italic*, ~~strikethrough~~, `inline code`, and a
[link to obsidian.md](https://obsidian.md).

## Lists & tasks

- Bullet one
- Bullet two
  - Nested bullet

1. Ordered one
2. Ordered two

- [x] Completed task
- [ ] Pending task

## Blockquote

> The purpose of these themes is to restyle Obsidian's desktop UI.

## Callouts

> [!note] Note callout
> Callouts pick up accent colors from the active theme.

> [!warning] Warning callout
> This exercises the `mod-warning` styling.

## Table

| Theme                 | Author | Version |
| --------------------- | ------ | ------- |
| Aqua 2000             | Suhas  | 3.0.3   |
| Hobonichi Techo       | Suhas  | 1.0.0   |
| Lotus Organizer       | Suhas  | 1.0.0   |
| Newton MessagePad     | Suhas  | 1.0.0   |
| Palm OS Memo Pad      | Suhas  | 1.0.0   |
| Vercel Noir           | Suhas  | 3.0.3   |
| Windows 3.1 Cardfile  | Suhas  | 1.0.0   |
| Windows Vista Aero    | Suhas  | 3.1.3   |
| Windows XP Luna       | Suhas  | 3.1.3   |
| Luna Graph            | Suhas  | 1.0.0   |

## Code block

```js
function greet(name) {
  return `Hello, ${name}!`;
}
console.log(greet("Obsidian"));
```
MD
fi

# --- Vault-local Obsidian config --------------------------------------------
python3 - "$VAULT" "$DEFAULT_THEME" <<'PY'
import json, os, sys
vault, default_theme = sys.argv[1], sys.argv[2]
cfg = os.path.join(vault, ".obsidian")
os.makedirs(cfg, exist_ok=True)

def merge(name, updates):
    path = os.path.join(cfg, name)
    data = {}
    if os.path.exists(path):
        try:
            with open(path) as f:
                data = json.load(f)
        except Exception:
            data = {}
    data.update(updates)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

# Dark mode + apply a repo theme by default so the preview is immediately useful.
appearance = {"theme": "obsidian", "baseFontSize": 16}
if default_theme:
    appearance["cssTheme"] = default_theme
merge("appearance.json", appearance)

# Trust the vault and skip onboarding popups.
merge("app.json", {"promptDelete": False})
PY

# --- Register the vault with Obsidian so it opens on launch -------------------
python3 - "$VAULT" "$OBS_CONFIG_DIR" <<'PY'
import hashlib, json, os, sys, time
vault, obs_dir = sys.argv[1], sys.argv[2]
os.makedirs(obs_dir, exist_ok=True)
path = os.path.join(obs_dir, "obsidian.json")
data = {"vaults": {}}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        data = {"vaults": {}}
data.setdefault("vaults", {})

vault_id = hashlib.sha256(vault.encode()).hexdigest()[:16]
# Ensure only our vault is marked open so Obsidian goes straight into it.
for v in data["vaults"].values():
    v["open"] = False
data["vaults"][vault_id] = {"path": vault, "ts": int(time.time() * 1000), "open": True}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
print(f"[vault-setup] registered vault id {vault_id}")
PY

echo "[vault-setup] done. Default theme: ${DEFAULT_THEME:-<none>}"
