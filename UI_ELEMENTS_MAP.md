# Cozy Cow Game UI - Elements Line Map & Reference

> **Source File:** [`index.html`](file:///Users/jsph/cowgameui/index.html)  
> **Verification:** `node tools/verify-hud.mjs` checks every preset × page for overlaps and text below 11pt/12pt (phase 5, T7).
> **Resolution Model:** Virtual 720p Canvas (`virtualHeight = 720`, dynamic `virtualWidth = 720 * aspect_ratio`) scaled into `.game-screen`.

---

## 1. Global Setup & Dynamic Theme System ([L1-L209](file:///Users/jsph/cowgameui/index.html#L1-L209))

| Line Range | Selector / Token | Purpose & Functionality |
| :--- | :--- | :--- |
| [`L9`](file:///Users/jsph/cowgameui/index.html#L9) | `@import Nunito` | Google Fonts import (`Nunito:wght@700;800;900`). |
| [`L11-L22`](file:///Users/jsph/cowgameui/index.html#L11-L22) | `body` | Centered flex column layout, gray background (`#e5e7eb`), overflow prevention. |
| [`L24-L33`](file:///Users/jsph/cowgameui/index.html#L24-L33) | `.game-screen` | Radial dot grid viewport with dynamic `--theme-screen-bg` and `--theme-grid-dot`. |
| [`L35-L38`](file:///Users/jsph/cowgameui/index.html#L35-L38) | `.ui-element` | Disables text selection (`user-select: none`). |
| [`L40-L42`](file:///Users/jsph/cowgameui/index.html#L40-L42) | `.hud-spring` | Cubic-bezier transition (`0.34, 1.56, 0.64, 1`) for bouncy HUD animations. |
| [`L44-L121`](file:///Users/jsph/cowgameui/index.html#L44-L121) | Touch / phone / narrow preset CSS | Touch presets hide keyboard hints (`.key-hint`). Phone preset (`.aspect-19-5-9`): safe zones placed like Roblox's native controls, `ps-*` boxes grow so labels reach 11pt (Roblox `Theme.size` parity), letter-spacing normal, build tools wrap, catalog dock clears both thumb zones. Responsive bulletin rules collapse `#bulletinDaytime` on mobile/narrow resolutions and center `#bulletinBoostCard` under the shortened pill. |
| [`L123-L132`](file:///Users/jsph/cowgameui/index.html#L123-L132) | Reduced motion | `prefers-reduced-motion`: short linear fades, no hover/press scaling or pulsing (Roblox Settings → Motion parity). |
| [`L134-L141`](file:///Users/jsph/cowgameui/index.html#L134-L141) | `.shape-leaf` | Custom asymmetric border-radius for quest bar: TL `2.5rem`, BR `2.5rem`, TR/BL `0.5rem`. |
| [`L143-L148`](file:///Users/jsph/cowgameui/index.html#L143-L148) | `.shape-leaf-inner` | Concentric inset radius for fill bar: TL/BR `1.875rem` (30px), TR/BL `0` (sharp). |
| [`L150-L152`](file:///Users/jsph/cowgameui/index.html#L150-L152) | `.shape-cowbell` | Downward-flared border-radius for settings button: `35% 35% 15% 15% / 50% 50% 20% 20%`. |
| [`L154-L157`](file:///Users/jsph/cowgameui/index.html#L154-L157) | `.aspect-*` | Preset aspect ratio CSS utility classes (`21/9`, `4/3`, `19.5/9`). |
| [`L158-L209`](file:///Users/jsph/cowgameui/index.html#L158-L209) | Dynamic Theme CSS | `:root` custom properties and `.game-screen` scoped overrides for Cards, Borders, Fills, Accents, and Text. |

---

## 1.5. Top Page Navigation Tabs ([L212-L227](file:///Users/jsph/cowgameui/index.html#L212-L227))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L213`](file:///Users/jsph/cowgameui/index.html#L213) | `#pageTabsContainer` | Top view switcher dock. Controls active ScreenGui page via `switchPage(pageId)`. |
| [`L214-L219`](file:///Users/jsph/cowgameui/index.html#L214-L219) | `#tabBtnPasture` | Tab button: switches to `#pagePasture` (Main Game HUD). |
| [`L220-L226`](file:///Users/jsph/cowgameui/index.html#L220-L226) | `#tabBtnBuilding` | Tab button: switches to `#pageBuilding` (Building & Construction GUI). |

---

## 2. Dev Controls Bar & Theme Customizer Drawer ([L229-L328](file:///Users/jsph/cowgameui/index.html#L229-L328))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L229-L261`](file:///Users/jsph/cowgameui/index.html#L229-L261) | Controls Bar | ScreenGui Controls top card wrapper. |
| [`L237-L242`](file:///Users/jsph/cowgameui/index.html#L237-L242) | `#aspectRatioSelect` | Dropdown: switches aspect ratio (`16:9`, `21:9`, `19.5:9`, `4:3`) & triggers `resizeUI()`. |
| [`L244-L246`](file:///Users/jsph/cowgameui/index.html#L244-L246) | `#btnCompact` | Toggle Button: switches Compact Mode (`toggleCompactMode()`). |
| [`L247-L249`](file:///Users/jsph/cowgameui/index.html#L247-L249) | `#btnBulletin` | Toggle Button: hides/shows Town Bulletin (`toggleBulletin()`). |
| [`L250-L252`](file:///Users/jsph/cowgameui/index.html#L250-L252) | `#btnSafeZones` | Toggle Button: displays mobile thumbstick & radial action cluster (`toggleSafeZones()`). |
| [`L253-L255`](file:///Users/jsph/cowgameui/index.html#L253-L255) | `#btnCoreGui` | Toggle Button: displays native Roblox CoreGui top bar (`toggleCoreGui()`). |
| [`L256-L258`](file:///Users/jsph/cowgameui/index.html#L256-L258) | `#btnTheme` | Toggle Button: expands/collapses theme color customizer drawer (`toggleThemeDrawer()`). |
| [`L263-L328`](file:///Users/jsph/cowgameui/index.html#L263-L328) | `#themeDrawer` | Palette bar: 5 presets (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`) + 6 live `<input type="color">` pickers (`Cards`, `Borders`, `Fills`, `Accents`, `Text`, `Canvas`). |

---

## 3. Game Screen & Scaler Root ([L330-L335](file:///Users/jsph/cowgameui/index.html#L330-L335))

| Line Range | Element ID / Selector | Purpose & Dimensions |
| :--- | :--- | :--- |
| [`L24`](file:///Users/jsph/cowgameui/index.html#L24) | `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| [`L333`](file:///Users/jsph/cowgameui/index.html#L333) | `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. Houses `#pagePasture` and `#pageBuilding`. |

---

## 4. Page 1: Pasture ScreenGui ([L336-L516](file:///Users/jsph/cowgameui/index.html#L336-L516))

### A. Roblox CoreGui Overlay Mockup ([L339-L364](file:///Users/jsph/cowgameui/index.html#L339-L364))
Positioned at `absolute top-4 left-6 pointer-events-none z-30 opacity-90 transition-opacity`.
- `#robloxCoreGui`: Top-Left Unibar with Roblox Hexagon, Hamburger menu (`≡`), and Chat with unread badge. Shifts `#topLeftVitals` to `top-16` when active.

### B. Top-Left: Player Vitals & Quest ([L367-L400](file:///Users/jsph/cowgameui/index.html#L367-L400))
- Cow Profile Box (`w-[88px] h-[88px]`), Rebirth chip, `#profileHerdBadge`, `.shape-leaf` Grazing Quest bar (`68%`), Stamina/HP bar (`HP 100`).

### C. Top-Right: Economy & Settings ([L402-L426](file:///Users/jsph/cowgameui/index.html#L402-L426))
- Calories Pill (`h-14 px-5`), Upgrades tab, `#topRightStandard` (Persistent cowbell Settings with `SET`), `#topRightCompact` (Persistent cowbell Menu with `MENU` in Compact Mode).

### D. Top-Center: Town Bulletin ([L428-L475](file:///Users/jsph/cowgameui/index.html#L428-L475))
- `#townBulletinWrapper`: Elevated to `top-4`. Houses `#bulletinFull` (pill `#bulletinCard` + boost chip `#bulletinBoostCard`) and `#bulletinCompact`.
- `#bulletinCard`: Pill containing daytime cycle `#bulletinDaytime` (sun icon, cycle timer) and world event progress `#eventColumn`.
- Responsive behavior: On mobile (`.aspect-19-5-9`), tablet (`.aspect-4-3`), and narrow resolutions (`.narrow-screen` / `virtualWidth < 1150` / screen width < 900px), `#bulletinDaytime` collapses with `display: none !important`. The pill shrinks to a minimum width floor of $216\text{px}$ (event column min-width $180\text{px}$) with reduced vertical padding ($8\text{px}$), and `#bulletinBoostCard` remains centered underneath.

### E. Sidebars ([L477-L508](file:///Users/jsph/cowgameui/index.html#L477-L508))
- `#leftSidebar`: Inventory + Closet (`top-48`) or single `BAG` button.
- `#rightSidebar`: 2-button vertical stack (`top-32`, gap `4`):
  1. `#sidebarHerd`: Herd button (`HERD`).
  2. `#sidebarTrade`: Trade button (`TRADE`).

### F. Mobile Action Cluster & Safe Zones ([L728-L800](file:///Users/jsph/cowgameui/index.html#L728-L800))
- Global in `#ui-container` (`z-30`): Overlays across both Pasture and Building GUIs without obstruction.
- `#safeZoneLeft`: Mobile thumbstick (`w-48 h-48`).
- `#safeZoneRight`: Mobile action cluster (`w-64 h-64`). Centered `#btnMobileJump` (`80px`, placeholder for Roblox's native Jump), Radial Arc satellites ($D=56\text{px}$, $68\text{px}$ on the phone preset; $R=92\text{px}$), evenly spread $60^\circ \to 200^\circ$ counter-clockwise from east:
  - Emote ($60^\circ$, `#btnMobileEmote` with `onclick="toggleEmoteRadial()"`)
  - Moo ($106.7^\circ$, `#btnMobileMoo`)
  - Sprint ($153.3^\circ$, `#btnMobileSprint`)
  - Kick ($200^\circ$, `#btnMobileKick`)
  - Quick emotes (`.mobile-quick-emote`): Heart, Cheer, Snooze take over the Moo / Sprint / Kick slots while open; Emote reads BACK. Hidden with the rest of the arc on the building page.

---

## 5. Page 2: Building & Construction GUI ([L519-L726](file:///Users/jsph/cowgameui/index.html#L519-L726))

| Line Range | Element ID / Selector | Description & Functionality |
| :--- | :--- | :--- |
| [`L519`](file:///Users/jsph/cowgameui/index.html#L519) | `#pageBuilding` | Root wrapper for Construction Mode wireframe. Toggled via `switchPage('building')`. |
| [`L521-L573`](file:///Users/jsph/cowgameui/index.html#L521-L573) | Building Top Bar | Top HUD: Exit Build button (`[✕] Exit Build`), centered Object/Parts Limit pill (`Parts: 34 / 50`) with Cog icon (`absolute left-1/2 -translate-x-1/2`), grid snap button (`#btnGridSnap`), and dual Wood (`450`) & Stone (`320`) side-by-side SVG counters. |
| [`L575-L587`](file:///Users/jsph/cowgameui/index.html#L575-L587) | Placement Boundary | Dashed building boundary ring with central animated `Placement Cursor` target. |
| [`L589-L630`](file:///Users/jsph/cowgameui/index.html#L589-L630) | Right Utility Tools | Vertical action stack (`top-20`, gap-2.5): Rotate (`ROT [R]`), Paint (`PAINT`), Undo (`UNDO [Z]`), Redo (`REDO [Y]`), Demolish (`TRASH [X]`). Kept strictly above right safe zone. |
| [`L632-L724`](file:///Users/jsph/cowgameui/index.html#L632-L724) | Bottom Catalog Dock | Connected category tabs (`rounded-t-xl rounded-b-none`, `-mb-[5px]`) + seamless horizontal prop tray (`rounded-b-[2rem] rounded-t-xl`, `border-[5px]`) with 6 slot cards (Rustic Fence, Picket Gate, Hay Bale, Stone Wall, Cozy Lantern, Clover Bed). Constrained to `max-w-[680px]` centered strictly between mobile safe zones. |

---

## 6. JavaScript Engine ([L804-L1156](file:///Users/jsph/cowgameui/index.html#L804-L1156))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L805-L813`](file:///Users/jsph/cowgameui/index.html#L805-L813) | Runtime State Flags | `activePage`, `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible`, `isThemeDrawerOpen`, `isEmoteRadialOpen`. |
| [`L813-L833`](file:///Users/jsph/cowgameui/index.html#L813-L833) | `switchPage(pageId)` | Switches view between `#pagePasture` and `#pageBuilding` and updates tab pills. |
| [`L840-L862`](file:///Users/jsph/cowgameui/index.html#L840-L862) | `setEmoteRadial(open)` / `toggleEmoteRadial()` / `setActionArcVisible(visible)` | Emote swaps Moo / Sprint / Kick for the three quick emotes in the same arc slots (Emote reads BACK); the arc hides on the building page. |
| [`L862-L867`](file:///Users/jsph/cowgameui/index.html#L862-L867) | `cycleGridSnap()` | Cycles grid snap setting (`2 Studs`, `4 Studs`, `1 Stud`, `Free / Off`). |
| [`L867-L878`](file:///Users/jsph/cowgameui/index.html#L867-L878) | `filterBuildCategory(cat)` | Highlights active category tab in building catalog dock. |
| [`L880-L921`](file:///Users/jsph/cowgameui/index.html#L880-L921) | `THEME_PRESETS` | Palette presets: `monochrome`, `meadow`, `sunrise`, `lavender`, `sky`. |
| [`L923-L942`](file:///Users/jsph/cowgameui/index.html#L923-L942) | `updateThemeProp(prop, val)` | Injects CSS variables into `.game-screen` with cascade overrides. |
| [`L944-L958`](file:///Users/jsph/cowgameui/index.html#L944-L958) | `applyThemePreset(key)` | Applies palette preset and syncs native `<input type="color">` pickers. |
| [`L960-L962`](file:///Users/jsph/cowgameui/index.html#L960-L962) | `resetTheme()` | Reverts to Default Monochrome wireframe palette. |
| [`L964-L969`](file:///Users/jsph/cowgameui/index.html#L964-L969) | `toggleThemeDrawer()` | Shows/hides `#themeDrawer` palette panel. |
| [`L971-L978`](file:///Users/jsph/cowgameui/index.html#L971-L978) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L980-L1005`](file:///Users/jsph/cowgameui/index.html#L980-L1005) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L1007-L1016`](file:///Users/jsph/cowgameui/index.html#L1007-L1016) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L1018-L1023`](file:///Users/jsph/cowgameui/index.html#L1018-L1023) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` thumbstick and `#safeZoneRight` radial action cluster. |
| [`L1025-L1039`](file:///Users/jsph/cowgameui/index.html#L1025-L1039) | `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| [`L1041-L1051`](file:///Users/jsph/cowgameui/index.html#L1041-L1051) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L1055-L1098`](file:///Users/jsph/cowgameui/index.html#L1055-L1098) | `DEVICE_HUD_SCALE` / `fitText()` | Each preset simulates a device's Roblox HUD scale (desktop 1.5, ultrawide 2, iPad 1.14, phone 0.75 on a 520px canvas). `fitText` applies the Roblox legibility floor: 11pt captions / 12pt labels, shrink-to-fit in fixed boxes. |
| [`L1099-L1134`](file:///Users/jsph/cowgameui/index.html#L1099-L1134) | `resizeUI()` | Sizes `#ui-container` to the preset's virtual canvas (720 tall; 520 on the phone preset), sets vital-bar width, toggles `.narrow-screen` for town bulletin adaptation, then runs `fitText`. |
| [`L1136-L1156`](file:///Users/jsph/cowgameui/index.html#L1136-L1156) | `ResizeObserver` & init | Listens to `.game-screen` size changes and parses URL query params (`page`, `safezones`, `coregui`, `compact`, `theme`). |
