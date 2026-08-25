# Obsidian theme authoring notes

Field notes for the next human or AI who adds another theme, or who has to touch titlebar / sidebar / traffic-light geometry in this repo.

These notes were written against **Obsidian 1.13.7** desktop (`minAppVersion` in every `manifest.json`). Native quotes come from the app stylesheet extracted from `/opt/Obsidian/resources/obsidian.asar` to `/tmp/obsidian-css/app.css` in the Cloud Agent VM. Class names and variables drift between Obsidian releases; re-extract `app.css` and re-check the selectors below before trusting this document on a newer build.

Official companion reading, cloned by `.cursor/install.sh` into `~/obsidian-docs/`:

- `~/obsidian-docs/developer-docs/en/Themes/App themes/Build a theme.md`
- `~/obsidian-docs/developer-docs/en/Themes/App themes/Theme guidelines.md`
- `~/obsidian-docs/developer-docs/en/Reference/CSS variables/CSS variables.md`

This document is the unofficial half: the DOM, the traps, and the geometry this repo already solved.

---

## 1. What this repo actually is

Not a plugin. Not a snippet pack. Eight **standalone community-style themes**.

Each theme is a top-level folder that contains exactly two required files:

```text
Aqua 2000/
  manifest.json
  theme.css
Lotus Organizer/
  manifest.json
  theme.css
Newton MessagePad/
  manifest.json
  theme.css
Palm OS Memo Pad/
  manifest.json
  theme.css
Vercel Noir/
  manifest.json
  theme.css
Windows 3.1 Cardfile/
  manifest.json
  theme.css
Windows XP Luna/
  manifest.json
  theme.css
Windows Vista Aero/
  manifest.json
  theme.css
```

Obsidian lists themes by **folder name**. Official docs also require the folder name to match `manifest.json` `name` exactly. Restart Obsidian after renaming either.

A theme **cannot import another theme's CSS**. There is no shared `geometry.css`. The desktop chrome chapter is therefore **duplicated verbatim** in every `theme.css` (~605 lines). The only intentional difference in that chapter is the body guard:

| Family | Guard | Why |
| --- | --- | --- |
| Aqua 2000, Vercel Noir | `body.theme-dark:not(.is-mobile)` | Dark clients. If the user flips Appearance to Light, these themes go inert and stock light UI returns. |
| Windows XP Luna, Windows Vista Aero, Lotus Organizer, Newton MessagePad, Windows 3.1 Cardfile, Palm OS Memo Pad | `body:is(.theme-dark, .theme-light):not(.is-mobile)` | Period-accurate **light clients** even when the user picked Dark. They also set `color-scheme: light`. |

If you copy geometry into a new theme and keep the wrong guard, either the chrome never applies or it fails when the user toggles the base color scheme.

Line counts on `main` at the time of writing:

| File | Lines |
| --- | ---: |
| `Aqua 2000/theme.css` | 1929 |
| `Vercel Noir/theme.css` | 1817 |
| `Windows XP Luna/theme.css` | 2190 |
| `Windows Vista Aero/theme.css` | 2186 |
| `Lotus Organizer/theme.css` | 2252 |
| `Newton MessagePad/theme.css` | 2184 |
| `Windows 3.1 Cardfile/theme.css` | 2176 |
| `Palm OS Memo Pad/theme.css` | 2180 |

Light-client themes are longer because they add a **notebook paper + settings readability** chapter after the shared geometry. Aqua / Noir stop after editor polish and folder glyphs. Binding decorations differ: XP/Vista use a top spiral, Organizer uses left brass rings, Newton uses a bottom silk bar, Cardfile uses a top letter strip, Palm uses a bottom graffiti silk.

Current versions:

| Theme | `manifest.json` version |
| --- | --- |
| Aqua 2000 | 3.0.3 |
| Vercel Noir | 3.0.3 |
| Windows XP Luna | 3.1.3 |
| Windows Vista Aero | 3.1.3 |
| Lotus Organizer | 1.0.0 |
| Newton MessagePad | 1.0.0 |
| Windows 3.1 Cardfile | 1.0.0 |
| Palm OS Memo Pad | 1.0.0 |

Bump the theme you edited. Geometry-only changes that land in every theme file should bump every theme.

---

## 2. Recipe: add another theme

Do this, in order.

1. **Pick a family.**
   - Dark editor + dark or mid chrome that is readable with the same ink as the panes: clone **Aqua 2000** or **Vercel Noir**.
   - Light notepad / Explorer panes + saturated titlebar: clone **Windows XP Luna** (solid cobalt), **Windows Vista Aero** (frosted glass), **Lotus Organizer** (burgundy leather), **Newton MessagePad** (black + LCD), **Windows 3.1 Cardfile** (navy + gray 3D), or **Palm OS Memo Pad** (charcoal + olive LCD). Do not clone Aqua and then try to force a light editor; you will re-hit the icon-leak and Settings dark-on-dark bugs.

2. **Copy a whole folder.** Name it exactly as it should appear in Settings → Appearance → Themes. Example: `System 7/`.

3. **Edit `manifest.json`.**

   ```json
   {
     "name": "System 7",
     "author": "Your Name",
     "version": "1.0.0",
     "minAppVersion": "1.13.7"
   }
   ```

   `name` must equal the folder name. Restart Obsidian after this change; CSS reloads do not pick up manifest edits.

4. **Keep the geometry chapter byte-for-byte** except the body guard. Search for `DESKTOP CHROME GEOMETRY` and do not "simplify" it. The traps in sections 8–12 are why it looks verbose.

5. **Retheme only the `--suite-*` tokens** in the first palette block, then the OBSIDIAN VARIABLE MAP if a core/plugin surface still looks wrong.

6. **If the titlebar is a different luminance than the editor / sidebar,** set these explicitly. Do not hope inheritance works.

   ```css
   --suite-control-text: #ffffff;              /* glyphs on chrome */
   --suite-control-icon-filter: drop-shadow(…); /* optional, XP/Vista */
   --suite-side-tab-active-text: #0d428b;      /* ink on the active cream/cyan tile */
   --suite-icon: …;                            /* pane / nav icons, NOT chrome */
   --suite-sidebar-icon: …;                    /* file-explorer row, NOT chrome */
   ```

7. **Symlink and reload.** `.cursor/vault-setup.sh` already links every `*/manifest.json` + `theme.css` folder. After adding a folder, re-run that script or relaunch via `.cursor/run-obsidian.sh`. Then **Settings → Appearance → Themes → your name**, then `Ctrl+R`.

8. **Do not share a CSS file.** If you are tempted to extract geometry into `_chrome.css` and `@import` it: Obsidian community themes are a single `theme.css`. A local `@import` of a sibling file will not ship as a community theme and is easy to break in this repo's symlink setup. Duplicate the chapter.

---

## 3. Official packaging rules this repo follows

From Obsidian's own theme guidelines, plus what we verified in 1.13.7:

- A theme is `manifest.json` + `theme.css`. Nothing else is required.
- **No remote assets.** Community themes must not fetch fonts or images. XP / Vista / Organizer rings and paper grain are `data:image/svg+xml,…` URLs.
- **No `!important`.** Every theme has zero. Specificity comes from long `body…` selectors. Snippets and user overrides should still be able to win.
- Prefer **CSS variables** over restyling every component. The OBSIDIAN VARIABLE MAP exists so core and plugins pick up the palette without per-widget rules.
- Official docs say: put scheme-independent variables on `body`, colors on `.theme-dark` / `.theme-light`, and use `:root` sparingly (plugin authors hang things there). This repo puts almost everything on the guarded `body…` selector so mobile is untouched.
- `minAppVersion` is a compatibility floor, not a compiler. Bump it only when you rely on a newer selector or variable.

This repo's extra constraint: **desktop-only**. Every qualified rule is `:not(.is-mobile)`. Phone/tablet keep stock Obsidian. Do not drop that guard "to make the selector shorter."

---

## 4. `theme.css` chapter map

Every file is the same story in the same order. Keep new rules in the matching chapter.

1. **File comment** — name, version, desktop-only promise, design intent.
2. **Palette** — `--suite-*` tokens only. This is the theme. Everything else should reference these.
3. **OBSIDIAN VARIABLE MAP** — `--suite-*` → `--background-*`, `--text-*`, `--tab-*`, `--icon-*`, `--color-base-*`, `--titlebar-*`, `--ribbon-*`, `--status-bar-*`, graph/canvas, etc.
4. **DESKTOP CHROME GEOMETRY** — titlebar row, root tabs, sidedock icon tabs, traffic-light safe area, flex order. **Copy verbatim. Change only the body guard.**
5. **SURFACES, NAVIGATION, AND STANDARD CONTROLS** — ribbon, splits, nav, buttons, inputs, tooltips, status bar, scrollbars.
6. **EDITOR AND DOCUMENT POLISH** — headings, code, tables, callouts, reduced-motion, narrow-width tweaks.
7. **PERIOD FOLDER GLYPHS** — extra folder body on file-explorer titles. Native disclosure chevron stays.
8. **NOTEBOOK PAPER, PERIOD WINDOWS, AND SETTINGS READABILITY** — every light-client theme. Light root panes, period binding (top spiral, left rings, silk bar, letter strip, or graffiti), Settings ink-on-paper, modal window frames. Aqua / Noir do not have this chapter.

### 4.1 Palette tokens you will actually paint with

Names are shared across themes even when the hues differ. The important clusters:

| Cluster | Role |
| --- | --- |
| `--suite-base-00` … `--suite-base-100` | Neutral scale, remapped to `--color-base-*` for core/plugin compatibility. Looking unused inside `theme.css` does **not** mean you can delete them. |
| `--suite-accent-*`, `--suite-link`, `--suite-caret`, `--suite-selection` | Interactive accent and editor caret. |
| `--suite-desk-bg`, `--suite-editor-bg`, `--suite-sidebar-bg`, `--suite-panel-bg` | Big surfaces. On XP/Vista, desk is the blue/teal "wallpaper" behind the notepad. |
| `--suite-text*`, `--suite-icon*` | **Pane** ink. Wrong on a blue titlebar. |
| `--suite-sidebar-*` | Left/right dock **content**, including `--suite-sidebar-icon`. Also wrong on a blue titlebar. |
| `--suite-chrome-*` | Titlebar / top tab strip material. |
| `--suite-control-*` | Square chrome buttons (+, tab list, sidebar toggles). `--suite-control-text` is the glyph color on chrome. |
| `--suite-tab-*` | Root document tabs. |
| `--suite-side-tab-*` | Sidedock icon tiles. `--suite-side-tab-active-text` is dark ink on the depressed cream/cyan tile. |
| `--suite-ghost-*` | Hover/active treatment for in-pane `.clickable-icon` (view header, nav). |
| `--suite-status-*` | Status bar. On XP/Vista this is also blue chrome and needs the same icon pin as the titlebar. |

Light-client extras that are not in Aqua / Noir: spiral / grain / paper tokens, window-frame chrome, Start-green (XP uses it for the ribbon orb; Vista currently defines unused copies; Organizer / Newton / Cardfile / Palm reuse it for period home capsules). Organizer, Newton, Cardfile, and Palm also define `--suite-paper-lines`.

### 4.2 Why the variable map exists

Obsidian 1.13.7 exposes 400+ CSS variables. Plugins and core read `--background-primary`, `--icon-color`, `--tab-text-color`, `--color-base-20`, not `--suite-editor-bg`.

The map is the contract:

```css
--background-primary: var(--suite-editor-bg);
--icon-color: var(--suite-icon);
--icon-color-hover: var(--suite-icon-hover);
--icon-color-active: var(--suite-icon-active);
--icon-color-focused: var(--suite-icon-active); /* body default; chrome overrides this */
--icon-opacity: 1; /* native default is 0.85; washed-out inactive glyphs if you leave it */
--header-height: var(--suite-header-height);
--ribbon-width: 42px; /* native default is 44px; see §9 */
--titlebar-background: var(--suite-chrome-solid);
```

`--color-base-*` looks unused in-file. Keep the mapping. Community plugins and some core surfaces still consume the scale.

---

## 5. Body classes that change layout

`document.body` is the theme switchboard. These were the ones that mattered while debugging chrome:

| Class | Meaning |
| --- | --- |
| `theme-dark` / `theme-light` | Settings → Appearance → Base color scheme. Independent of `cssTheme`. |
| `is-mobile` | Phone/tablet. All of our rules opt out. |
| `mod-macos` / `mod-windows` / `mod-linux` | Platform. This Cloud VM is `mod-linux`. |
| `is-frameless` | Electron frameless window. |
| `is-hidden-frameless` | Default desktop: native titlebar hidden; chrome lives in `.workspace-tabs.mod-top`. |
| `is-fullscreen` | Traffic lights / caption buttons gone. Use `--suite-edge-gap` only. |
| `is-popout-window` | Popped-out pane. macOS `--frame-left-space` becomes a flat `80px`. |
| `is-focused` | Window focus. Native swaps `--titlebar-background` → `--titlebar-background-focused`. |
| `show-ribbon` | Left ribbon visible. **Absence** of this class is how Obsidian zeros `--ribbon-width`. |
| `hider-ribbon` / `hide-ribbon` | Plugin conventions (Style Settings / Hider-style). They can hide the ribbon **without** zeroing `--ribbon-width`. |
| `is-grabbing` | Tab/pane drag. Native turns off some `-webkit-app-region: drag`. |

Window-frame styles (Settings → Appearance → Window frame style) also matter. **Hidden frameless** is what these themes were designed for. Official docs' `--titlebar-*` tokens mainly paint the visible **Obsidian frame** titlebar. In `is-hidden-frameless`, that element is `display: none` on macOS and transparent on Windows/Linux. The row you actually see is `.workspace-tab-header-container`.

---

## 6. Workspace DOM (the map we wish we had on day one)

Typical desktop tree:

```text
body.mod-linux.is-hidden-frameless.theme-dark
  .titlebar                          /* visually gone in hidden-frameless */
  .app-container
    .workspace
      .workspace-ribbon.mod-left     /* display:none when ribbon hidden */
      .workspace-split.mod-left-split.mod-sidedock
        .workspace-tabs.mod-top.mod-top-left-space
          .workspace-tab-header-container
            .workspace-tab-header-container-inner   /* Files / Search / Bookmarks icon tabs */
            .workspace-tab-header-new-tab           /* CLONE — hide it */
            .workspace-tab-header-spacer
            .workspace-tab-header-tab-list          /* CLONE — hide it */
            .sidebar-toggle-button.mod-left
        .workspace-tab-container
          .workspace-leaf[data-type=file-explorer]
            .nav-header                             /* DIFFERENT ROW. Dark-on-light on XP/Vista. */
            .nav-files-container
      .workspace-split.mod-root
        .workspace-tabs.mod-top[.mod-top-left-space][.mod-top-right-space]
          .workspace-tab-header-container
            .workspace-tab-header-container-inner   /* document tabs */
            .workspace-tab-header-new-tab           /* the real + */
            .workspace-tab-header-spacer            /* flex-grow: 1; drag region */
            .workspace-tab-header-tab-list
            .sidebar-toggle-button.mod-left         /* only when left dock is closed */
            .sidebar-toggle-button.mod-right        /* only when right dock is closed */
      .workspace-split.mod-right-split.mod-sidedock
        …same header clones as left…
      .status-bar
```

### 6.1 Splits and the "which strip owns the traffic-light padding?" question

| Class | Role |
| --- | --- |
| `.workspace-split.mod-root` | Editor / graph / canvas. |
| `.workspace-split.mod-left-split` / `.mod-right-split` | Side docks. |
| `.mod-sidedock` | Marks a dock. |
| `.is-sidedock-collapsed` | Dock closed. The leftover strip is a resize handle, not a useful header. |
| `.workspace-tabs.mod-top` | The top header of that split. |
| `.mod-top-left-space` | Lands on the **leftmost open** top tab strip. Open left dock → left dock has it. Closed left dock → **root** has it. |
| `.mod-top-right-space` | Same idea on the right, for Windows/Linux caption buttons. |

Traffic-light padding must target `.workspace-tabs.mod-top-left-space > .workspace-tab-header-container`, not "the left split" and not "the root." If you pad the wrong strip, either the editor tabs sit under the lights when the sidebar is closed, or the sidebar icons sit under the lights when it is open.

### 6.2 Children of `.workspace-tab-header-container`

Native (1.13.7) is a horizontal flex row (`display: flex`, `height: var(--header-height)`):

1. `.workspace-tab-header-container-inner` — `flex: 0 1 auto` natively. Document tabs in root; icon tabs in a dock.
2. `.workspace-tab-header-new-tab`
3. `.workspace-tab-header-spacer` — `flex-grow: 1`. On top tabs, also `-webkit-app-region: drag`.
4. `.workspace-tab-header-tab-list`
5. `.sidebar-toggle-button.mod-left` and/or `.mod-right` depending on which docks are closed.

Native also applies `-webkit-app-region: drag` to the whole top container in hidden-frameless, and `no-drag` on the clickable controls. Keep clickable things `no-drag` or macOS users cannot press them.

### 6.3 Native hide/show of + and tab-list

From `app.css`:

```css
.workspace-tab-header-tab-list,
.workspace-tab-header-new-tab {
  display: none;
}
.titlebar .workspace-tab-header-tab-list,
.titlebar .workspace-tab-header-new-tab,
.mod-root .workspace-tab-header-tab-list,
.mod-root .workspace-tab-header-new-tab {
  display: flex;
}
```

Sidedocks **already contain** those nodes. Core just hides them. The moment a theme restyles `.workspace-tab-header-new-tab` / `.workspace-tab-header-tab-list` and sets `display: flex` (we do, to size the root + and ☰), **the sidedock clones come back.**

In an open left dock those clones are the first flex items (default `order: 0`) and they are the controls that slide under the traffic lights when the dock is narrow. Re-hide them after you un-hide chrome controls:

```css
.workspace-split:is(.mod-left-split, .mod-right-split)
  .workspace-tabs.mod-top
  :is(.workspace-tab-header-new-tab, .workspace-tab-header-tab-list) {
  display: none;
}
```

That rule lives immediately after the shared "make every chrome control a 30×30 square" block on purpose.

### 6.4 Root tabs vs sidedock tabs

Root markdown / empty tabs hide `.workspace-tab-header-inner-icon`. You see a title + close. Sidedock tabs hide titles and close buttons (`--sidebar-tab-text-display` / native `display: none` on close). You see Lucide icons only.

Do not style `.workspace-tab-header` as if those two worlds were the same widget. This repo scopes document-tab chrome to `.workspace-split.mod-root` and icon-tile chrome to `.mod-left-split` / `.mod-right-split`.

### 6.5 Native new-tab overlap

```css
.workspace-tab-header-new-tab {
  margin-inline-start: -4px;
}
```

Core tucks the + slightly under the last tab. The geometry chapter zeros that (`margin-left: 0`) so the + sits immediately after the last title with `--suite-chrome-gap` instead of overlapping it.

### 6.6 Native sidedock inner padding

```css
.mod-left-split .workspace-tab-header-container .workspace-tab-header-container-inner,
.mod-right-split .workspace-tab-header-container .workspace-tab-header-container-inner {
  padding: 1px 0 7px;
  margin: 6px 0 0 0;
  gap: 3px;
}
```

If you set a 40px header and 28px tiles and forget to override this, the icon row looks vertically drunk. The geometry chapter resets `margin`, `padding`, `height`, and `inset` on that inner.

### 6.7 Native tab curves

`.workspace-tab-header::before` / `::after` draw `--tab-curve` (6px) corner pieces. Active root tabs also paint a connecting `box-shadow` in those pseudos. This repo sets `content: none` on those, and on the chrome-control `::before`/`::after`, so the 30×30 squares do not grow mystery bumps.

### 6.8 Native macOS right-toggle is `position: fixed`

```css
.mod-macos.is-hidden-frameless:not(.is-popout-window) .sidebar-toggle-button.mod-right {
  position: fixed;
  top: 0;
  right: 0;
  padding-right: var(--size-4-2);
}
.mod-macos.is-hidden-frameless:not(.is-popout-window)
  .workspace .workspace-tabs.mod-top-right-space .workspace-tab-header-container {
  padding-right: 38px;
}
```

The geometry chapter beats this with `position: relative; inset: auto; transform: none; isolation: isolate` on every chrome control. If you drop those resets, the right toggle floats over the caption-button well (or the fake right edge) instead of sitting in the flex row.

### 6.9 Width of an open left dock

There is **no useful native `min-width`** on `.mod-left-split`. Width comes from `~/ObsidianVault/.obsidian/workspace.json` (`left.width`) and from the user dragging the split. That is why shrinking the sidebar used to shove icon tabs under the traffic lights: the row overflow-clipped to the right, into the padding… unless the content box was squeezed to zero, in which case the first flex items sat in the well.

This repo sets:

```css
.workspace-split.mod-left-split:not(.is-sidedock-collapsed) {
  min-width: calc(var(--suite-macos-safe-left) + var(--suite-left-chrome-min));
}
```

`--suite-left-chrome-min` is three 28px tiles + borders + the 30px collapse control + gaps. On Linux `--suite-macos-safe-left` is `0px`, so the floor is just the chrome. On macOS it includes the traffic-light well.

`overflow: hidden` on the header **does not clip into `padding-left`**. Children are clipped at the padding edge. Padding is the safe well; `min-width` is what stops the content box from collapsing to zero.

---

## 7. `--frame-*-space` and the macOS traffic lights

Native comment block in `app.css` (around the titlebar section) is worth reading in full. The numbers:

```css
.mod-macos {
  --frame-left-space: calc(80px - var(--ribbon-width));
  --frame-right-space: 0px;
}
.mod-macos.is-popout-window {
  --frame-left-space: 80px;
}
.mod-windows,
.mod-linux {
  --frame-left-space: 0px;
  --frame-right-space: 126px;
}
```

Native padding on the strip that owns the corner:

```css
.is-hidden-frameless:not(.is-fullscreen)
  .workspace-tabs.mod-top-left-space .workspace-tab-header-container {
  padding-left: calc(var(--size-4-2) + var(--frame-left-space));
}
.is-hidden-frameless:not(.is-fullscreen)
  .workspace-tabs.mod-top-right-space .workspace-tab-header-container {
  padding-right: calc(var(--size-4-2) + var(--frame-right-space));
}
```

`--size-4-2` is `8px`.

Windows/Linux also paint a `::after` (and `::before` on the left) **no-drag** strip of `width: var(--frame-right-space)` / `frame-left-space` so clicks on caption buttons do not drag the window.

### 7.1 What 80px is

macOS traffic lights sit in a reserved well. When the ribbon is visible, Obsidian subtracts `--ribbon-width` because the ribbon itself occupies the left edge and its `::before` cap (height `--header-height`, width `--ribbon-width`) is painted with titlebar material. Hidden ribbon → subtract nothing → full 80px well on the leftmost tab strip.

### 7.2 This repo's safe-left token

```css
--suite-macos-traffic-gap: 16px;   /* air after the green light; do not kiss it */
--suite-macos-ribbon-compensation: 0px;
--suite-macos-safe-left: 0px;      /* default: Linux/Windows */

/* macOS, not fullscreen, not popout: */
--suite-macos-safe-left: calc(
  var(--frame-left-space, 80px) +
  var(--suite-macos-ribbon-compensation) +
  var(--suite-macos-traffic-gap)
);
```

Applied as:

```css
.workspace-tabs.mod-top-left-space > .workspace-tab-header-container {
  padding-left: var(--suite-macos-safe-left);
}
```

Fullscreen / popout: `padding-left: var(--suite-edge-gap)` only (`6px`).

On a healthy macOS hidden-ribbon window:

`safe-left = (80 - 0) + 0 + 16 = 96px`

That 96px is also what the Linux traffic-light **snippet** forces so we can QA on this VM (see §15).

### 7.3 Right padding

Native `padding-right: 8px + --frame-right-space` leaves a **dead 126px+ margin** on macOS if a theme does not beat it (`--frame-right-space` is 0 on macOS, but other native rules still add 38px for the fixed right toggle). This repo:

- Everyone: `padding-right: var(--suite-edge-gap)` on `.mod-top-right-space`.
- Windows/Linux hidden-frameless: `padding-right: calc(var(--frame-right-space, 0px) + var(--suite-edge-gap))` so caption buttons keep a no-drag well.

There is a **redundant** `.mod-macos { padding-right: edge-gap }` rule that repeats the general rule. Harmless leftover; do not "fix" it mid-geometry unless you are doing a dedicated cleanup.

### 7.4 Ribbon cap

```css
.workspace-ribbon.mod-left::before {
  /* native: titlebar-colored square, header-height × ribbon-width */
}
```

This repo paints only that cap with `--suite-chrome-bg` so the traffic-light well matches the titlebar. The vertical ribbon body stays `--suite-ribbon-bg` (sidebar material). Do not paint the whole ribbon with chrome.

---

## 8. The ribbon-width trap (the bug that looks like a padding bug)

Native:

```css
body {
  --ribbon-width: 44px;
}
body:not(.show-ribbon) {
  --ribbon-width: 0px;
}
```

`--frame-left-space` is `80px - var(--ribbon-width)`. Hidden ribbon is supposed to produce an 80px well.

This repo (and most polished themes) set `--ribbon-width: 42px` on the **same `body.theme-dark` / `body:is(...)` selector that holds the whole palette**.

Specificity:

| Selector | Width | Wins when ribbon hidden? |
| --- | --- | --- |
| `body:not(.show-ribbon)` | 0 | No |
| `body.theme-dark:not(.is-mobile)` | 42 | **Yes** |

So a hidden ribbon still subtracts 42px and `--frame-left-space` becomes ~38px. Buttons look "a bit close to the lights" rather than obviously broken. Easy to miss. Easy to "fix" by adding more magic padding, which then looks wrong when the ribbon is shown.

**Required reset, more specific than the theme assignment:**

```css
body.theme-dark:not(.is-mobile):not(.show-ribbon) {
  --ribbon-width: 0px;
}
/* XP / Vista: */
body:is(.theme-dark, .theme-light):not(.is-mobile):not(.show-ribbon) {
  --ribbon-width: 0px;
}
```

### 8.1 Plugin hide-ribbon classes

Some snippets/plugins add `.hider-ribbon` or `.hide-ribbon` and `display: none` the ribbon **without** removing `show-ribbon` or zeroing `--ribbon-width`. Then `--frame-left-space` is still `80 - 42`. This repo adds the missing width back as padding:

```css
body.mod-macos…:is(.hider-ribbon, .hide-ribbon) {
  --suite-macos-ribbon-compensation: var(--ribbon-width, 42px);
}
```

And, if the ribbon node is actually present and expanded, a `:has()` rule zeros that compensation:

```css
@supports selector(body:has(.workspace-ribbon.mod-left)) {
  body.mod-macos…:has(.workspace-ribbon.mod-left:not(.is-collapsed)) {
    --suite-macos-ribbon-compensation: 0px;
  }
}
```

Do not delete these because they look speculative. They are the difference between "works in a stock vault" and "breaks the moment someone uses Hider."

---

## 9. New-tab placement (browser tab-strip metaphor)

Wanted order on the **root** row:

```text
[ left toggle if dock closed ] [ tab ] [ tab ] [ + ] [ ~~~~ spacer ~~~~ ] [ ☰ ] [ right toggle if dock closed ]
```

The `+` sits immediately after the current tab titles, the way Chrome/Safari do it. It must **not** sit after the spacer (far right) and must **not** sit in the optical middle of the window.

### 9.1 Why it went wrong

Native inner is already `flex: 0 1 auto`. An earlier version of these themes set the inner to `flex: 1 1 auto` so it ate the row. The `+` is the next sibling, so it landed after a growing tab strip — visually "in the middle" or "far right" depending on tab count.

The geometry chapter still has a **general** rule that sets inner to `flex: 1 1 auto` (shared with sidedocks). The **root override** that follows is the actual fix:

```css
.workspace-split.mod-root
  .workspace-tabs.mod-top
  > .workspace-tab-header-container
  > .workspace-tab-header-container-inner {
  order: 0;
  flex: 0 1 auto;
  width: max-content;
  min-width: 0;
  max-width: calc(100% - (var(--suite-control-size) + var(--suite-chrome-gap)) * 3);
}
```

`max-width` reserves room for `+`, ☰, and one toggle so a pile of document tabs cannot shove those controls off the right edge.

Then explicit `order`:

| Child | `order` |
| --- | ---: |
| left toggle (only on root `.mod-top-left-space`, i.e. left dock closed) | `-2` |
| inner (tabs) | `0` |
| new-tab | `1` |
| spacer | `2` |
| tab-list | `3` |
| right toggle | `4` |

Do not dock `+` after the spacer. Do not give the inner `flex-grow: 1` on the root row.

### 9.2 Closed left sidebar

When the left dock is closed, the left toggle joins the **root** row, and that row also becomes `.mod-top-left-space` (it now owns the traffic-light padding). `order: -2` parks the toggle at the far left, after the safe padding, without changing tab/`+` geometry.

---

## 10. Icon color: inheritance, `--icon-color-focused`, and the 1.4:1 bug

### 10.1 Native token roles

From `app.css` defaults and the official Icons reference:

| Token | Native default | What actually uses it |
| --- | --- | --- |
| `--icon-color` | `var(--text-muted)` | Idle Lucide glyphs. `.workspace-tab-header-inner .workspace-tab-header-inner-icon { color: var(--icon-color) }` |
| `--icon-color-hover` | `var(--text-muted)` | Hover. |
| `--icon-color-active` | `var(--text-accent)` | **Pressed / `is-active` clickable-icon.** Not the thing that paints a selected sidedock tab. |
| `--icon-color-focused` | `var(--text-normal)` | **Selected sidedock tab icons.** Also `:active` on those icons. |
| `--icon-opacity` | `0.85` | Idle fade. This repo forces `1`. |

Lucide SVGs use `currentColor`. Setting `color` on the button or icon wrapper is what you want. `fill:` on the SVG is usually the wrong fight.

### 10.2 The leak

`--icon-color` is assigned on `body` to `--suite-icon` / `--suite-sidebar-icon` — pane colors. On XP that is `#3f5680` / `#3d5a86`; on Vista `#3f6576`. Fine on cream Explorer. On Luna `#1769dc` chrome that is about **1.4:1**.

Two later assignments make it worse:

1. `.mod-left-split` / `.mod-right-split` reset `--icon-color` to `--suite-sidebar-icon` for the **file list**. That custom property inherits into the **same split's titlebar** unless you re-pin it on the header.
2. A global `.clickable-icon:hover { color: var(--suite-icon-hover) }` exists for in-pane ghost buttons. `--suite-icon-hover` is a dark blue. Chrome hover rules must be **more specific** or hovered + / ☰ / toggles go dark on blue.

`--icon-color-active` does **not** save you. Active Files/Search/Bookmarks tiles use `--icon-color-focused`.

### 10.3 The pin (do all of these)

On the titlebar container:

```css
.workspace-tabs.mod-top > .workspace-tab-header-container {
  --icon-color: var(--suite-control-text);
  --icon-color-hover: var(--suite-control-hover-text);
  --icon-color-active: var(--suite-control-text);
  --icon-color-focused: var(--suite-side-tab-active-text);
}
```

On each sidedock tile (and again on `.is-active`):

```css
.workspace-tab-header {
  --icon-color: var(--suite-control-text);
  --icon-color-hover: var(--suite-control-hover-text);
  --icon-color-focused: var(--suite-side-tab-active-text);
  color: var(--suite-control-text);
}
.workspace-tab-header.is-active {
  --icon-color: var(--suite-side-tab-active-text);
  color: var(--suite-side-tab-active-text);
}
```

On the glyph itself:

```css
:is(.workspace-tab-header-inner-icon, .workspace-tab-header-inner-icon svg) {
  color: var(--icon-color);
  filter: var(--suite-control-icon-filter, none);
}
```

And `color` + the same `filter` on chrome `.clickable-icon` squares.

`--suite-control-icon-filter` is a `drop-shadow(...)` on XP (Luna punch) and a stronger glass shadow on Vista. Aqua / Noir can leave it unset (`none`).

### 10.4 What not to bleach

`.nav-header` under the chrome — the row with "sort" / "new note" / "collapse" inside the file explorer — is **not** the titlebar. On XP/Vista it is dark icons on a light toolbar. If you "fix unreadability" by making every icon in `.mod-left-split` white, you will break that row.

View-header icons on the notepad (reading/live-preview/more) are also pane icons, not chrome.

### 10.5 Status bar

XP / Vista / Organizer paint a saturated status bar. The same leak applies. They pin `--icon-color*` on `.status-bar`. Aqua / Noir status bars already match pane luminance and only set `color` / background.

### 10.6 Measured contrast after the pin (1.13.7, this VM)

WCAG-ish simple contrast, sampled from screenshots:

| Surface | Pair | Ratio |
| --- | --- | --- |
| XP idle chrome glyph | `#ffffff` on `#1769dc` | ~5.1:1 |
| Vista idle chrome glyph | `#f4fbff` on dark glass | ~8.4:1 |
| XP/Vista active side tile | dark ink on cream/cyan | ~7–8:1 |
| Pre-fix XP chrome glyph | `#3d5a86` on `#1769dc` | ~1.4:1 |

If you invent a new saturated chrome, **sample pixels**. Do not trust "it looks like the control text token is white." Inheritance will lie.

### 10.7 Native active sidedock background

```css
.mod-left-split .workspace-tab-header-container .workspace-tab-header.is-active {
  background-color: var(--background-modifier-hover);
}
```

On XP, `--background-modifier-hover` is the yellow notepad hover (`#f0cf55`). If you forget to override `.is-active` background to `--suite-side-tab-active-bg`, the selected Files tile becomes a yellow pad on a blue titlebar.

---

## 11. Light client, dark Settings, and `color-scheme`

XP / Vista / Organizer force a light client in both Appearance schemes (`color-scheme: light`, paper editor, cream Explorer). That created a second class of bugs that Aqua / Noir never saw:

- **Settings / community / vertical tabs.** Core paints `.vertical-tab-content` with `--background-primary`. If you mapped `--background-primary` to a dark editor (the original XP experiment) or if some pane still inherits a dark token, labels become dark-on-dark. The notebook chapter re-maps `--background-primary` / `--text-*` / `--icon-color` on `.vertical-tab-content` and `.horizontal-tab-content` to panel cream.
- **`.workspace { background }` is assigned twice** on XP/Vista: once to `--suite-editor-bg` in SURFACES, then overwritten to `--suite-desk-bg` in NOTEBOOK. The first assignment is leftover. Harmless; the second is the wallpaper you see around the notepad.
- **Do not use `body.theme-dark` alone** for a light-client theme. Users who leave Appearance on Dark would get a half-themed mutant (stock dark panes + your chrome, or nothing).

Aqua / Noir are allowed to be dark-only. If someone switches the base scheme to Light, stock light Obsidian is correct.

---

## 12. Geometry tokens (copy these)

Defined at the top of DESKTOP CHROME GEOMETRY:

```css
--suite-header-height: 40px;     /* maps to --header-height; native titlebar-height is 30px */
--suite-control-size: 30px;      /* +, ☰, sidebar toggles */
--suite-side-tab-size: 28px;     /* Files / Search / Bookmarks tiles */
--suite-icon-size: 17px;         /* Lucide box inside the 30/28 controls */
--suite-chrome-gap: 4px;
--suite-edge-gap: 6px;
--suite-macos-traffic-gap: 16px;
--suite-macos-ribbon-compensation: 0px;
--suite-macos-safe-left: 0px;
--suite-left-chrome-min: calc(
  (var(--suite-side-tab-size) + 2px) * 3 +
  var(--suite-control-size) +
  var(--suite-edge-gap) +
  8px
);
```

Native `--header-height` is consumed by the ribbon `::before` cap and the tab container. If you change `--suite-header-height`, the ribbon cap and the tab strip stay aligned.

---

## 13. How this repo beats native positioning

When a native rule uses `position: absolute` / `fixed`, `inset`, or `transform`, a theme `margin` will not win. The geometry chapter therefore **resets the fight** on chrome controls:

```css
position: relative;
inset: auto;
left: auto; top: auto; right: auto;
transform: none;
isolation: isolate;
content: none; /* on ::before / ::after */
```

If a new Obsidian build starts teleporting a button again, inspect computed `position` and `inset` before adding more padding.

Also reset `box-sizing: border-box` everywhere in that row. Native padding + our 30px width otherwise overflows the 40px header.

---

## 14. Known leftover cruft (do not "clean" mid-feature)

A CSS audit after PR #4 found the chrome **clean enough**. These leftovers are real but unused or redundant. Leave them unless you are doing a dedicated tidy PR:

| Leftover | Where | Notes |
| --- | --- | --- |
| `--suite-paper-alt` | XP + Vista palette | Never referenced. |
| `--suite-start-green`, `--suite-start-border` | Vista palette | Unused on Vista. XP **does** use them for the left-ribbon first icon (Start orb). |
| `.workspace { background: var(--suite-editor-bg) }` | XP + Vista SURFACES | Immediately overwritten by the notebook chapter's `--suite-desk-bg`. |
| Duplicate macOS `padding-right: var(--suite-edge-gap)` | All four geometry chapters | Same value as the platform-agnostic rule above it. |

Zero `!important` in every theme. Do not introduce one to win a specificity fight; lengthen the selector instead. The only `!important` we used while testing was in the **vault-only** Linux traffic-light snippet, which is not in this repo.

---

## 15. Previewing on this Cloud VM (Linux pretending to be macOS)

The VM is `mod-linux`. `--frame-left-space` is `0`. You cannot QA traffic lights with theme CSS alone.

### 15.1 Scripts

| Script | What it does |
| --- | --- |
| `.cursor/install.sh` | Installs Obsidian 1.13.7, clones official docs to `~/obsidian-docs`, runs vault-setup. |
| `.cursor/vault-setup.sh` | Symlinks every theme folder into `~/ObsidianVault/.obsidian/themes/`, seeds notes, writes `appearance.json`, registers the vault in `~/.config/obsidian/obsidian.json`. |
| `.cursor/run-obsidian.sh` | Calls vault-setup, then `obsidian --no-sandbox --disable-gpu` on `DISPLAY=:1`. |

Vault-setup sets `cssTheme` to the **first theme folder it finds** (glob order; currently **Aqua 2000**). Relaunching via `run-obsidian.sh` therefore **resets the active theme**. After a relaunch, switch back in Appearance. Prefer `Ctrl+R` for CSS iteration.

Symlinks mean you edit the repo file, not a copy under the vault. Confirm with `ls -l ~/ObsidianVault/.obsidian/themes/`.

### 15.2 Vault Appearance we used for chrome QA

`~/ObsidianVault/.obsidian/appearance.json` (vault-local, not in git):

```json
{
  "theme": "obsidian",
  "baseFontSize": 16,
  "cssTheme": "Windows XP Luna",
  "enabledCssSnippets": ["macos-traffic-sim"],
  "showRibbon": false
}
```

`theme: "obsidian"` is the **base** dark scheme. XP/Vista still look light because of their body guard. Aqua/Noir need that dark base.

### 15.3 The traffic-light snippet (vault-only)

`~/ObsidianVault/.obsidian/snippets/macos-traffic-sim.css` is **not in the repo**. It exists only on this VM. Recreate it if the machine is clean:

```css
/* Selectors must match theme body guards or the theme's
   --suite-macos-safe-left: 0px wins. */
body:is(.theme-dark, .theme-light):not(.is-mobile),
body.theme-dark:not(.is-mobile) {
  --suite-macos-safe-left: 96px;
}

body:not(.is-mobile)
  .workspace-tabs.mod-top-left-space
  > .workspace-tab-header-container {
  position: relative;
  padding-left: var(--suite-macos-safe-left, 96px) !important;
}

body:not(.is-mobile)
  .workspace-tabs.mod-top-left-space
  > .workspace-tab-header-container::after {
  content: "";
  position: absolute;
  left: 10px;
  top: 50%;
  width: 58px;
  height: 14px;
  transform: translateY(-50%);
  background:
    radial-gradient(circle closest-side, #ff5f57 92%, transparent 94%) 0 1px / 12px 12px no-repeat,
    radial-gradient(circle closest-side, #febc2e 92%, transparent 94%) 23px 1px / 12px 12px no-repeat,
    radial-gradient(circle closest-side, #28c840 92%, transparent 94%) 46px 1px / 12px 12px no-repeat;
  pointer-events: none;
  z-index: 30;
}
```

Why `!important` here and nowhere in the themes: the snippet must beat the theme's `padding-left: var(--suite-macos-safe-left)` when that token is still `0px` on Linux. Matching the body-guard selectors for the **token** is the cleaner half; `!important` on padding is the belt.

Geometry of the fake lights, for screenshot assertions:

- Circles are 12px.
- Group starts at `left: 10px`.
- Green light occupies roughly x = 56–68 inside the header, i.e. ends around **x = 70–80**.
- First chrome control should start **~50px after the green** (the 16px traffic gap plus tile padding). If a Files icon or ☰ overlaps x ≈ 70, the well is wrong.

Enable the snippet in Appearance → CSS snippets. `vault-setup.sh` does **not** currently write `enabledCssSnippets` or `showRibbon`; those were set by hand during chrome work.

### 15.4 Reload vs relaunch

| Action | Use |
| --- | --- |
| `Ctrl+R` in the Obsidian window | CSS / snippet iteration. Keeps `cssTheme`, workspace widths, snippet enablement. |
| Appearance → Themes dropdown | Switch among the repo themes. |
| `.cursor/run-obsidian.sh` | Only if Obsidian is dead. Re-runs vault-setup and may reset `cssTheme` to Aqua 2000. |

Do not `pkill -f obsidian`. If you must restart, kill the specific PID from the `obsidian` terminal.

### 15.5 Extracting native CSS

```bash
# already extracted on this VM:
# /tmp/obsidian-css/app.css

python3 - <<'PY'
import os, subprocess, tempfile
asar = "/opt/Obsidian/resources/obsidian.asar"
# npx asar extract also works if asar is installed
print(os.path.exists("/tmp/obsidian-css/app.css"))
PY
```

In a running Obsidian: `Ctrl+Shift+I` → Sources → `obsidian.md` → `app.css`. Search `"  --ribbon-"` (two spaces) to find **definitions** rather than uses.

### 15.6 Screenshot captions lie

Image-description / alt-text models repeatedly hallucinated the **old** bugs after they were fixed: an extra chevron, `+` on the far right, dark glyphs on blue chrome. **Trust pixel samples and computed styles**, not the caption. Sample `--icon-color` on the header and the RGB of a glyph pixel.

### 15.7 Checklist for a new theme's first preview

1. Theme selected; snippet on; ribbon off.
2. Left dock **open**, dragged to its minimum: three icon tiles + collapse control fully visible, no overlap with the green light (or the left edge on stock Linux).
3. Left dock **closed**: left toggle sits after the well; document tabs follow; `+` is immediately after the last title; spacer; ☰; right toggle.
4. Right dock open and closed: no extra + / ☰ clones in the dock header.
5. Hover chrome buttons: glyphs stay light on saturated chrome.
6. Active Files/Search/Bookmarks: dark ink on the depressed tile, not a yellow pad and not a white-on-white tile.
7. File-explorer `.nav-header` icons still dark-on-light (XP/Vista) or correct pane contrast (Aqua/Noir).
8. Settings → Appearance: labels readable (especially XP/Vista).
9. Status bar icons readable (especially XP/Vista).
10. Toggle Appearance light/dark: Aqua/Noir go inert on light; XP/Vista stay notepad-like on both.
11. Toggle ribbon on: well shrinks; ribbon cap uses chrome material; buttons do not jump into a double-wide hole.

---

## 16. Debugging recipe (when chrome "just looks wrong")

Work this list before rewriting geometry.

1. **Which strip has `mod-top-left-space`?** Open vs closed left dock moves it. Padding the left split while the dock is closed does nothing for the lights.
2. **Computed `--ribbon-width` on `body`.** Hidden ribbon must be `0px`. If it is `42px`, you lost the `:not(.show-ribbon)` reset.
3. **Computed `--frame-left-space`.** macOS hidden ribbon: `80px`. macOS shown ribbon: `80 - ribbon-width`. Linux: `0`.
4. **Computed `--suite-macos-safe-left`.** Linux theme default `0`. Snippet should force `96px` for fake-light QA. If it stays `0`, the snippet selectors lost the specificity war.
5. **`display` on sidedock `.workspace-tab-header-tab-list`.** Must be `none`. If `flex`, you un-hid the clone; that clone is what sits under the lights.
6. **`flex-grow` on root `.workspace-tab-header-container-inner`.** Must be `0`. If `1`, the `+` is not next to the last title.
7. **Computed `--icon-color` on the header container and on `.workspace-tab-header.is-active`.** Header idle should be `--suite-control-text`. Active tile should be `--suite-side-tab-active-text`. If either is `--suite-sidebar-icon`, a split-level reset leaked.
8. **Computed `color` on the SVG.** Lucide follows `currentColor`. A correct token on the container with a global `.clickable-icon:hover { color: dark }` still loses on hover.
9. **`position` on `.sidebar-toggle-button.mod-right`.** If `fixed`, the macOS native rule won; your `inset: auto` reset is missing or less specific.
10. **Did you relaunch instead of reload?** Check `appearance.json` `cssTheme`. Vault-setup may have put you back on Aqua 2000.

---

## 17. Settings, snippets, and Style Settings

- User snippets live in `<vault>/.obsidian/snippets/*.css` and are toggled in Appearance. They load after the theme. That is why the traffic-light simulator can override `--suite-macos-safe-left`.
- Style Settings plugin reads `/* @settings` YAML in `theme.css`. This repo does **not** currently ship a Style Settings block. If you add one, keep chrome geometry out of user-tunable sliders unless you also document the traffic-light math.
- Community theme submission: no network calls, folder name = manifest name, screenshot, `minAppVersion`. See `~/obsidian-docs/developer-docs/en/Themes/App themes/Submit your theme.md`.

---

## 18. Drag regions, popouts, stacked tabs

Things we hit or narrowly avoided:

- Top spacer and the top header container are `-webkit-app-region: drag` so users can move a frameless window. Buttons must stay `no-drag` (native `.clickable-icon` already sets this; do not override it).
- Popout windows: `body.is-popout-window`. macOS gives them a flat 80px left well and no ribbon. This repo excludes them from `--suite-macos-safe-left` and uses `--suite-edge-gap`.
- Stacked tabs (`.workspace-tabs.mod-stacked`) have a different header layout. We did not restyle that path beyond what the variable map does. If a new theme cares about stacked tabs, inspect `.workspace .mod-root .workspace-tabs.mod-stacked` in `app.css` (~7057) before copying the top-row flex order onto it.
- Graph, canvas, backlinks, outgoing links, file view: XP/Vista notebook chapter forces paper background + ink on those root panes so they do not flash a dark `--background-primary`.

---

## 19. Appendix A — native CSS you will re-read

All line numbers from the 1.13.7 `app.css` extract on this VM. They will drift.

| Topic | Approx. lines | What to look at |
| --- | --- | --- |
| Icon tokens | 2348–2368 | `--icon-color*` defaults, `--icon-opacity: 0.85` |
| `--size-4-2` | 2657 | `8px` |
| `--tab-curve` | 2738 | `6px` |
| Frame / titlebar essay | 4025–4182 | `--frame-*-space`, hidden-frameless padding, no-drag strips |
| Ribbon + hidden reset | 4510–4532 | `::before` cap, `body:not(.show-ribbon) { --ribbon-width: 0px }` |
| Tab inner / curves | 6642–6784 | Container flex, inner `flex: 0 1 auto`, hide markdown icons, curves |
| Spacer / drag / native hide of + | 6859–6898 | Why clones exist, `-4px` new-tab margin |
| Sidedock tabs | 6941–6988 | `padding: 1px 0 7px`, `--icon-color-focused`, `--background-modifier-hover` |
| macOS fixed right toggle | 7172–7182 | `position: fixed`, `padding-right: 38px` |

---

## 20. Appendix B — selector cheatsheet

Replace `BODY` with the family guard.

```text
BODY
BODY:not(.show-ribbon)
BODY.mod-macos:not(.is-fullscreen):not(.is-popout-window)
BODY.mod-macos:is(.hider-ribbon, .hide-ribbon)
BODY:not(.mod-macos).is-hidden-frameless

BODY .workspace-tabs.mod-top > .workspace-tab-header-container
BODY .workspace-tabs.mod-top-left-space > .workspace-tab-header-container
BODY .workspace-tabs.mod-top-right-space > .workspace-tab-header-container

BODY .workspace-split.mod-root .workspace-tabs.mod-top > .workspace-tab-header-container > .workspace-tab-header-container-inner
BODY .workspace-split.mod-root .workspace-tabs.mod-top > .workspace-tab-header-container > .workspace-tab-header-new-tab
BODY .workspace-split.mod-root .workspace-tabs.mod-top-left-space .sidebar-toggle-button.mod-left

BODY .workspace-split:is(.mod-left-split, .mod-right-split) .workspace-tabs.mod-top :is(.workspace-tab-header-new-tab, .workspace-tab-header-tab-list)
BODY .workspace-split:is(.mod-left-split, .mod-right-split):not(.is-sidedock-collapsed) .workspace-tab-header-container-inner > .workspace-tab-header
BODY .workspace-split.mod-left-split:not(.is-sidedock-collapsed)   /* min-width */

BODY .workspace-ribbon.side-dock-ribbon.mod-left::before
BODY .status-bar                                          /* XP/Vista icon pin */
BODY :is(.vertical-tab-content, .horizontal-tab-content)  /* XP/Vista settings */
```

---

## 21. Appendix C — new-theme decision table

| If you want… | Clone | Guard | Also copy |
| --- | --- | --- | --- |
| Dark editor, dark chrome | Vercel Noir or Aqua 2000 | `body.theme-dark:not(.is-mobile)` | Geometry + surfaces. Skip notebook chapter. |
| Dark editor, **saturated** chrome | Aqua 2000, then recolor `--suite-chrome-*` / `--suite-control-text` | same | Pin `--icon-color` on the header even if you think contrast is fine. |
| Light notepad + blue chrome | Windows XP Luna | `body:is(.theme-dark, .theme-light):not(.is-mobile)` | Geometry + notebook/settings chapter + status-bar icon pin. |
| Light notepad + glass chrome | Windows Vista Aero | same | Same as Luna. Do not assume Vista's `--suite-start-green` does anything. |
| Light notepad + burgundy leather | Lotus Organizer | same | Same as Luna, plus rainbow section-tab folders and left-edge brass rings. |
| Light LCD + black hardware | Newton MessagePad | same | Same as Luna, plus bottom silk buttons and a dark view-header icon pin. |
| Light index cards + navy chrome | Windows 3.1 Cardfile | same | Same as Luna, plus a top A–M letter strip. Status bar is gray: pin dark icons. |
| Light olive LCD + charcoal plastic | Palm OS Memo Pad | same | Same as Luna, plus bottom graffiti silk and a dark view-header icon pin. |
| Light editor + light chrome | Start from Luna, flatten `--suite-chrome-*` toward `--suite-panel-bg` | same | You can ease the icon pin, but keep the sidedock-clone hide and flex order. |

Never start from a blank `theme.css` and re-derive traffic-light math. Copy the geometry chapter first, then paint.

---

## 22. Appendix D — history of the chrome work

Useful if a later diff looks inexplicable.

1. Four period themes shipped as standalone folders with a shared-but-duplicated chrome chapter.
2. Shrinking the left sidebar put Files/Search/Bookmarks (or the tab-list clone) under macOS traffic lights. Root `+` sat after a `flex-grow` tab strip.
3. XP/Vista editors were made light (notepad). Sidebar `--icon-color` then inherited onto the still-blue titlebar. Contrast collapsed to ~1.4:1. Status bar had the same leak.
4. PR #4 (merged as `e94fc7d`) did three things in all four themes:
   - Re-hide sidedock + / tab-list clones.
   - Root flex order `[tabs][+][spacer][list][toggles]`, inner `flex: 0 1 auto`.
   - `--suite-macos-safe-left` + ribbon-width reset + left-dock `min-width`.
   - Pin `--icon-color*` / `color` / optional `drop-shadow` on chrome; XP/Vista also pin the status bar.
5. This document is the write-up of that thread so nobody has to rediscover it from `app.css`.
