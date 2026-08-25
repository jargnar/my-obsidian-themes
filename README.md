# my-obsidian-themes

Five standalone Obsidian desktop themes, each a folder with `manifest.json` and `theme.css`:

| Folder | Palette | Client surfaces | Body guard |
| --- | --- | --- | --- |
| `Aqua 2000` | Early-2000s Aqua, graphite + glossy blue | Dark | `body.theme-dark:not(.is-mobile)` |
| `Vercel Noir` | Neutral / no chromatic UI accents | Dark | `body.theme-dark:not(.is-mobile)` |
| `Windows XP Luna` | Luna Blue chrome, yellow spiral notepad | Light in both schemes | `body:is(.theme-dark, .theme-light):not(.is-mobile)` |
| `Windows Vista Aero` | Aero glass chrome, yellow spiral notepad | Light in both schemes | `body:is(.theme-dark, .theme-light):not(.is-mobile)` |
| `Lotus Organizer` | Burgundy leather, brass rings, cream Filofax pages | Light in both schemes | `body:is(.theme-dark, .theme-light):not(.is-mobile)` |

Target app version is **Obsidian 1.13.7** (`minAppVersion` in every manifest). Desktop-only by design: mobile keeps stock UI.

**If you are adding another theme, or changing titlebar / sidebar / traffic-light geometry, read [`docs/obsidian-theme-authoring.md`](docs/obsidian-theme-authoring.md) first.** It is the field notes from shipping the shared chrome in PR #4: native DOM, `--frame-*-space` math, the ribbon-width trap, sidedock clones, new-tab flex order, and icon-token leaks.

Preview scripts live in [`.cursor/`](.cursor/). They symlink every theme folder into `~/ObsidianVault/.obsidian/themes/` so edits to repo CSS show up after a reload.

## 1990s note-taking homages

The first four themes already cover Aqua, a modern dark client, and XP/Vista yellow legal pads. A fifth period theme should clone **Windows XP Luna** (light notepad + saturated chrome) and pick a product whose chrome is not another cobalt titlebar.

| Homage | Why it works here | Why we skipped or shipped it |
| --- | --- | --- |
| **Lotus Organizer 2.1 / 97** | The Filofax-on-Windows PIM. Burgundy cover, brass rings, rainbow section tabs. Instantly readable as a 90s notebook and visually opposite XP Luna. | **Shipped.** |
| Newton MessagePad Notes | Green LCD, hardware bezel, handwriting-era cream. Distinct, but more PDA than desk PIM. | Strong follow-up if we want a green client. |
| HyperCard | Card stacks, Home button, System 7 chrome. Great for a stacked-tab experiment. | Needs stacked-tab work the geometry chapter has not restyled. |
| Windows 3.1 Cardfile | Beige 3D index cards. Period-perfect, quieter than Organizer. | Easy Luna clone if we want a muted light theme. |
| Palm OS Memo Pad | Grayscale-green graffiti LCD. Very specific, limited palette. | Better as a dark-green Aqua-family theme. |
| ECCO Pro | Power-user outliner. Famous, visually plain. | Not wild enough for a fifth theme. |
| Lotus Notes R4/R5 | Green workspace tabs. Groupware, not a personal notebook. | Different metaphor. |
| Magic Cap | Rooms and desks. Conceptual, hard to map onto Obsidian chrome. | Fun, poor fit. |
