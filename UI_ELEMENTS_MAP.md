# Cozy Cow Game UI - Elements Line Map & Reference

> **Source File:** [`index.html`](file:///Users/jsph/cowgameui/index.html)  
> **Resolution Model:** Virtual 720p Canvas (`virtualHeight = 720`, dynamic `virtualWidth = 720 * aspect_ratio`) scaled into `.game-screen`.

---

## 1. Global Setup & Dynamic Theme System ([L1-L113](file:///Users/jsph/cowgameui/index.html#L1-L113))

| Line Range | Selector / Token | Purpose & Functionality |
| :--- | :--- | :--- |
| [`L9`](file:///Users/jsph/cowgameui/index.html#L9) | `@import Nunito` | Google Fonts import (`Nunito:wght@700;800;900`). |
| [`L11-L22`](file:///Users/jsph/cowgameui/index.html#L11-L22) | `body` | Centered flex column layout, gray background (`#e5e7eb`), overflow prevention. |
| [`L24-L33`](file:///Users/jsph/cowgameui/index.html#L24-L33) | `.game-screen` | Radial dot grid viewport with dynamic `--theme-screen-bg` and `--theme-grid-dot`. |
| [`L35-L38`](file:///Users/jsph/cowgameui/index.html#L35-L38) | `.ui-element` | Disables text selection (`user-select: none`). |
| [`L40-L42`](file:///Users/jsph/cowgameui/index.html#L40-L42) | `.hud-spring` | Cubic-bezier transition (`0.34, 1.56, 0.64, 1`) for bouncy HUD animations. |
| [`L45-L51`](file:///Users/jsph/cowgameui/index.html#L45-L51) | `.shape-leaf` | Custom asymmetric border-radius for quest bar: TL `2.5rem`, BR `2.5rem`, TR/BL `0.5rem`. |
| [`L53-L58`](file:///Users/jsph/cowgameui/index.html#L53-L58) | `.shape-leaf-inner` | Concentric inset radius for fill bar: TL/BR `1.875rem` (30px), TR/BL `0` (sharp). |
| [`L60-L62`](file:///Users/jsph/cowgameui/index.html#L60-L62) | `.shape-cowbell` | Downward-flared border-radius for settings button: `35% 35% 15% 15% / 50% 50% 20% 20%`. |
| [`L64-L66`](file:///Users/jsph/cowgameui/index.html#L64-L66) | `.aspect-*` | Preset aspect ratio CSS utility classes (`21/9`, `4/3`, `19.5/9`). |
| [`L68-L112`](file:///Users/jsph/cowgameui/index.html#L68-L112) | Dynamic Theme CSS | `:root` custom properties and `.game-screen` scoped overrides for Cards, Borders, Fills, Accents, and Text. |

---

## 1.5. Top Page Navigation Tabs ([L116-L125](file:///Users/jsph/cowgameui/index.html#L116-L125))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L116`](file:///Users/jsph/cowgameui/index.html#L116) | `#pageTabsContainer` | Top view switcher dock. Controls active ScreenGui page via `switchPage(pageId)`. |
| [`L117-L119`](file:///Users/jsph/cowgameui/index.html#L117-L119) | `#tabBtnPasture` | Tab button: switches to `#pagePasture` (Main Game HUD). |
| [`L120-L124`](file:///Users/jsph/cowgameui/index.html#L120-L124) | `#tabBtnBuilding` | Tab button: switches to `#pageBuilding` (Building & Construction GUI). |

---

## 2. Dev Controls Bar & Theme Customizer Drawer ([L127-L225](file:///Users/jsph/cowgameui/index.html#L127-L225))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L128-L157`](file:///Users/jsph/cowgameui/index.html#L128-L157) | Controls Bar | ScreenGui Controls top card wrapper. |
| [`L134-L139`](file:///Users/jsph/cowgameui/index.html#L134-L139) | `#aspectRatioSelect` | Dropdown: switches aspect ratio (`16:9`, `21:9`, `19.5:9`, `4:3`) & triggers `resizeUI()`. |
| [`L141-L143`](file:///Users/jsph/cowgameui/index.html#L141-L143) | `#btnCompact` | Toggle Button: switches Compact Mode (`toggleCompactMode()`). |
| [`L144-L146`](file:///Users/jsph/cowgameui/index.html#L144-L146) | `#btnBulletin` | Toggle Button: hides/shows Town Bulletin (`toggleBulletin()`). |
| [`L147-L149`](file:///Users/jsph/cowgameui/index.html#L147-L149) | `#btnSafeZones` | Toggle Button: displays mobile thumbstick & radial action cluster (`toggleSafeZones()`). |
| [`L150-L152`](file:///Users/jsph/cowgameui/index.html#L150-L152) | `#btnCoreGui` | Toggle Button: displays native Roblox CoreGui top bar (`toggleCoreGui()`). |
| [`L153-L155`](file:///Users/jsph/cowgameui/index.html#L153-L155) | `#btnTheme` | Toggle Button: expands/collapses theme color customizer drawer (`toggleThemeDrawer()`). |
| [`L159-L224`](file:///Users/jsph/cowgameui/index.html#L159-L224) | `#themeDrawer` | Palette bar: 5 presets (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`) + 6 live `<input type="color">` pickers (`Cards`, `Borders`, `Fills`, `Accents`, `Text`, `Canvas`). |

---

## 3. Game Screen & Scaler Root ([L227-L233](file:///Users/jsph/cowgameui/index.html#L227-L233))

| Line Range | Element ID / Selector | Purpose & Dimensions |
| :--- | :--- | :--- |
| [`L228`](file:///Users/jsph/cowgameui/index.html#L228) | `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| [`L231`](file:///Users/jsph/cowgameui/index.html#L231) | `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. Houses `#pagePasture` and `#pageBuilding`. |

---

## 4. Page 1: Pasture ScreenGui ([L233-L456](file:///Users/jsph/cowgameui/index.html#L233-L456))

### A. Roblox CoreGui Overlay Mockup ([L236-L261](file:///Users/jsph/cowgameui/index.html#L236-L261))
Positioned at `absolute top-4 left-6 pointer-events-none z-30 opacity-90 transition-opacity`.
- `#robloxCoreGui`: Top-Left Unibar with Roblox Hexagon, Hamburger menu (`≡`), and Chat with unread badge. Shifts `#topLeftVitals` to `top-16` when active.

### B. Top-Left: Player Vitals & Quest ([L264-L296](file:///Users/jsph/cowgameui/index.html#L264-L296))
- Cow Profile Box (`w-28 h-28`), Rebirth chip, `#profileHerdBadge`, `.shape-leaf` Grazing Quest bar (`68%`), Stamina/HP bar (`HP 100`).

### C. Top-Right: Economy & Settings ([L299-L325](file:///Users/jsph/cowgameui/index.html#L299-L325))
- Calories Pill (`h-14 px-5`), Upgrades tab, `#topRightStandard` (Persistent cowbell Settings with `SET`), `#topRightCompact` (Persistent cowbell Menu with `MENU` in Compact Mode).

### D. Top-Center: Town Bulletin ([L328-L375](file:///Users/jsph/cowgameui/index.html#L328-L375))
- `#townBulletinWrapper`: Elevated to `top-4`. `#bulletinFull` (Cycle timer + World Event bar + 2x Calories boost chip) and `#bulletinCompact`.

### E. Sidebars ([L378-L415](file:///Users/jsph/cowgameui/index.html#L378-L415))
- `#leftSidebar`: Inventory + Closet (`top-48`) or single `BAG` button.
- `#rightSidebar`: 2-button vertical stack (`top-32`, gap `4`):
  1. `#sidebarHerd`: Herd button (`HERD`).
  2. `#sidebarTrade`: Trade button (`TRADE`).

### F. Mobile Action Cluster & Safe Zones ([L438-L495](file:///Users/jsph/cowgameui/index.html#L438-L495))
- `#safeZoneLeft`: Mobile thumbstick (`w-48 h-48`).
- `#safeZoneRight`: Mobile action cluster (`w-64 h-64`). Centered `#btnMobileJump` (`80px`), Radial Arc satellites ($D=56\text{px}$, $R=92\text{px}$):
  - Sprint ($190^\circ$, `#btnMobileSprint`)
  - Moo ($135^\circ$, `#btnMobileMoo`)
  - Emote ($80^\circ$, `#btnMobileEmote` with `onclick="toggleEmoteRadial()"`)
  - Emote Flyout (`#mobileEmoteFlyout`): Mini-arc above Emote button with 3 quick emotes (Heart, Cheer/Sparkles, Snooze)
  - Kick ($235^\circ$, `#btnMobileKick` at `left-[47px] bottom-[25px]`)

---

## 5. Page 2: Building & Construction GUI ([L500-L716](file:///Users/jsph/cowgameui/index.html#L500-L716))

| Line Range | Element ID / Selector | Description & Functionality |
| :--- | :--- | :--- |
| [`L500`](file:///Users/jsph/cowgameui/index.html#L500) | `#pageBuilding` | Root wrapper for Construction Mode wireframe. Toggled via `switchPage('building')`. |
| [`L503-L563`](file:///Users/jsph/cowgameui/index.html#L503-L563) | Building Top Bar | Top HUD: Exit Build button (`[✕] Exit Build`), center title chip (`CONSTRUCTION MODE • Tier 2`), grid snap button (`#btnGridSnap`), and dual Wood (`450`) & Stone (`320`) side-by-side SVG counters (Calorie counter removed). |
| [`L565-L578`](file:///Users/jsph/cowgameui/index.html#L565-L578) | Placement Boundary | Dashed building boundary ring with central animated `Placement Cursor` target. |
| [`L580-L622`](file:///Users/jsph/cowgameui/index.html#L580-L622) | Right Utility Tools | Vertical action stack: Rotate (`ROT [R]`), Paint (`PAINT`), Undo (`UNDO [Z]`), Redo (`REDO [Y]`), Demolish (`TRASH [X]`). |
| [`L624-L701`](file:///Users/jsph/cowgameui/index.html#L624-L701) | Bottom Catalog Dock | Category tabs (`Fences`, `Barns`, `Feeders`, `Paths`, `Decor`) + horizontal scrollable prop tray with 6 slot cards (Rustic Fence: 20 Wood, Picket Gate: 35 Wood, Hay Bale: 15 Wood, Stone Wall: 40 Stone, Cozy Lantern: 25 Stone, Clover Bed: 10 Stone), all 100% SVG vectorized. |

---

## 6. JavaScript Engine ([L721-L990](file:///Users/jsph/cowgameui/index.html#L721-L990))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L722-L728`](file:///Users/jsph/cowgameui/index.html#L722-L728) | Runtime State Flags | `activePage`, `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible`, `isThemeDrawerOpen`, `isEmoteRadialOpen`. |
| [`L730-L750`](file:///Users/jsph/cowgameui/index.html#L730-L750) | `switchPage(pageId)` | Switches view between `#pagePasture` and `#pageBuilding` and updates tab pills. |
| [`L752-L758`](file:///Users/jsph/cowgameui/index.html#L752-L758) | `toggleEmoteRadial()` | Toggles visibility of `#mobileEmoteFlyout` mini-arc. |
| [`L760-L765`](file:///Users/jsph/cowgameui/index.html#L760-L765) | `cycleGridSnap()` | Cycles grid snap setting (`2 Studs`, `4 Studs`, `1 Stud`, `Free / Off`). |
| [`L767-L778`](file:///Users/jsph/cowgameui/index.html#L767-L778) | `filterBuildCategory(cat)` | Highlights active category tab in building catalog dock. |
| [`L780-L821`](file:///Users/jsph/cowgameui/index.html#L780-L821) | `THEME_PRESETS` | Palette presets: `monochrome`, `meadow`, `sunrise`, `lavender`, `sky`. |
| [`L823-L842`](file:///Users/jsph/cowgameui/index.html#L823-L842) | `updateThemeProp(prop, val)` | Injects CSS variables into `.game-screen` with cascade overrides. |
| [`L844-L858`](file:///Users/jsph/cowgameui/index.html#L844-L858) | `applyThemePreset(key)` | Applies palette preset and syncs native `<input type="color">` pickers. |
| [`L860-L862`](file:///Users/jsph/cowgameui/index.html#L860-L862) | `resetTheme()` | Reverts to Default Monochrome wireframe palette. |
| [`L864-L869`](file:///Users/jsph/cowgameui/index.html#L864-L869) | `toggleThemeDrawer()` | Shows/hides `#themeDrawer` palette panel. |
| [`L871-L878`](file:///Users/jsph/cowgameui/index.html#L871-L878) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L880-L905`](file:///Users/jsph/cowgameui/index.html#L880-L905) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L907-L916`](file:///Users/jsph/cowgameui/index.html#L907-L916) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L918-L923`](file:///Users/jsph/cowgameui/index.html#L918-L923) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` thumbstick and `#safeZoneRight` radial action cluster. |
| [`L925-L939`](file:///Users/jsph/cowgameui/index.html#L925-L939) | `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| [`L941-L951`](file:///Users/jsph/cowgameui/index.html#L941-L951) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L953-L973`](file:///Users/jsph/cowgameui/index.html#L953-L973) | `resizeUI()` | Derives `virtualWidth` and scales `#ui-container` to virtual 720p resolution. |
| [`L975-L990`](file:///Users/jsph/cowgameui/index.html#L975-L990) | `ResizeObserver` & init | Listens to `.game-screen` size changes and parses URL query params (`page`, `safezones`, `coregui`, `compact`, `theme`). |
