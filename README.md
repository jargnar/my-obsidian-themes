# my-obsidian-themes

Four standalone Obsidian desktop themes, each a folder with `manifest.json` and `theme.css`:

| Folder | Palette | Client surfaces | Body guard |
| --- | --- | --- | --- |
| `Aqua 2000` | Early-2000s Aqua, graphite + glossy blue | Dark | `body.theme-dark:not(.is-mobile)` |
| `Vercel Noir` | Neutral / no chromatic UI accents | Dark | `body.theme-dark:not(.is-mobile)` |
| `Windows XP Luna` | Luna Blue chrome, yellow spiral notepad | Light in both schemes | `body:is(.theme-dark, .theme-light):not(.is-mobile)` |
| `Windows Vista Aero` | Aero glass chrome, yellow spiral notepad | Light in both schemes | `body:is(.theme-dark, .theme-light):not(.is-mobile)` |

Target app version is **Obsidian 1.13.7** (`minAppVersion` in every manifest). Desktop-only by design: mobile keeps stock UI.

**If you are adding a fifth theme, or changing titlebar / sidebar / traffic-light geometry, read [`docs/obsidian-theme-authoring.md`](docs/obsidian-theme-authoring.md) first.** It is the field notes from shipping the shared chrome in PR #4: native DOM, `--frame-*-space` math, the ribbon-width trap, sidedock clones, new-tab flex order, and icon-token leaks.

Preview scripts live in [`.cursor/`](.cursor/). They symlink every theme folder into `~/ObsidianVault/.obsidian/themes/` so edits to repo CSS show up after a reload.
