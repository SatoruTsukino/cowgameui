# Cozy Cow Game UI - Elements Line Map & Reference

> **Source File:** [`index.html`](file:///Users/jsph/cowgameui/index.html)  
> **Verification:** `node tools/verify-hud.mjs` checks every preset × page for overlaps and text below 11pt/12pt (phase 5, T7).
> **Resolution Model:** Virtual 720p Canvas (`virtualHeight = 720`, dynamic `virtualWidth = 720 * aspect_ratio`) scaled into `.game-screen`.

---

## 1. Global Setup & Dynamic Theme System ([L1-L154](file:///Users/jsph/cowgameui/index.html#L1-L154))

| Line Range | Selector / Token | Purpose & Functionality |
| :--- | :--- | :--- |
| [`L9`](file:///Users/jsph/cowgameui/index.html#L9) | `@import Nunito` | Google Fonts import (`Nunito:wght@700;800;900`). |
| [`L11-L22`](file:///Users/jsph/cowgameui/index.html#L11-L22) | `body` | Centered flex column layout, gray background (`#e5e7eb`), overflow prevention. |
| [`L24-L33`](file:///Users/jsph/cowgameui/index.html#L24-L33) | `.game-screen` | Radial dot grid viewport with dynamic `--theme-screen-bg` and `--theme-grid-dot`. |
| [`L35-L38`](file:///Users/jsph/cowgameui/index.html#L35-L38) | `.ui-element` | Disables text selection (`user-select: none`). |
| [`L40-L42`](file:///Users/jsph/cowgameui/index.html#L40-L42) | `.hud-spring` | Cubic-bezier transition (`0.34, 1.56, 0.64, 1`) for bouncy HUD animations. |
| [`L80-L86`](file:///Users/jsph/cowgameui/index.html#L80-L86) | `.shape-leaf` | Custom asymmetric border-radius for quest bar: TL `2.5rem`, BR `2.5rem`, TR/BL `0.5rem`. |
| [`L88-L93`](file:///Users/jsph/cowgameui/index.html#L88-L93) | `.shape-leaf-inner` | Concentric inset radius for fill bar: TL/BR `1.875rem` (30px), TR/BL `0` (sharp). |
| [`L95-L97`](file:///Users/jsph/cowgameui/index.html#L95-L97) | `.shape-cowbell` | Downward-flared border-radius for settings button: `35% 35% 15% 15% / 50% 50% 20% 20%`. |
| [`L64-L66`](file:///Users/jsph/cowgameui/index.html#L64-L66) | `.aspect-*` | Preset aspect ratio CSS utility classes (`21/9`, `4/3`, `19.5/9`). |
| [`L103-L153`](file:///Users/jsph/cowgameui/index.html#L103-L153) | Dynamic Theme CSS | `:root` custom properties and `.game-screen` scoped overrides for Cards, Borders, Fills, Accents, and Text. |
| [`L44-L65`](file:///Users/jsph/cowgameui/index.html#L44-L65) | Touch / phone preset CSS | Touch presets hide keyboard hints (`.key-hint`). Phone preset (`.aspect-19-5-9`): safe zones placed like Roblox's native controls, `ps-*` boxes grow so labels reach 11pt (Roblox `Theme.size` parity), letter-spacing normal, build tools wrap, catalog dock clears both thumb zones. |
| [`L67-L80`](file:///Users/jsph/cowgameui/index.html#L67-L80) | Reduced motion | `prefers-reduced-motion`: short linear fades, no hover/press scaling or pulsing (Roblox Settings → Motion parity). |

---

## 1.5. Top Page Navigation Tabs ([L157-L172](file:///Users/jsph/cowgameui/index.html#L157-L172))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L158`](file:///Users/jsph/cowgameui/index.html#L158) | `#pageTabsContainer` | Top view switcher dock. Controls active ScreenGui page via `switchPage(pageId)`. |
| [`L159-L161`](file:///Users/jsph/cowgameui/index.html#L159-L161) | `#tabBtnPasture` | Tab button: switches to `#pagePasture` (Main Game HUD). |
| [`L165-L169`](file:///Users/jsph/cowgameui/index.html#L165-L169) | `#tabBtnBuilding` | Tab button: switches to `#pageBuilding` (Building & Construction GUI). |

---

## 2. Dev Controls Bar & Theme Customizer Drawer ([L174-L272](file:///Users/jsph/cowgameui/index.html#L174-L272))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L174-L206`](file:///Users/jsph/cowgameui/index.html#L174-L206) | Controls Bar | ScreenGui Controls top card wrapper. |
| [`L182-L187`](file:///Users/jsph/cowgameui/index.html#L182-L187) | `#aspectRatioSelect` | Dropdown: switches aspect ratio (`16:9`, `21:9`, `19.5:9`, `4:3`) & triggers `resizeUI()`. |
| [`L189-L191`](file:///Users/jsph/cowgameui/index.html#L189-L191) | `#btnCompact` | Toggle Button: switches Compact Mode (`toggleCompactMode()`). |
| [`L192-L194`](file:///Users/jsph/cowgameui/index.html#L192-L194) | `#btnBulletin` | Toggle Button: hides/shows Town Bulletin (`toggleBulletin()`). |
| [`L195-L197`](file:///Users/jsph/cowgameui/index.html#L195-L197) | `#btnSafeZones` | Toggle Button: displays mobile thumbstick & radial action cluster (`toggleSafeZones()`). |
| [`L198-L200`](file:///Users/jsph/cowgameui/index.html#L198-L200) | `#btnCoreGui` | Toggle Button: displays native Roblox CoreGui top bar (`toggleCoreGui()`). |
| [`L201-L203`](file:///Users/jsph/cowgameui/index.html#L201-L203) | `#btnTheme` | Toggle Button: expands/collapses theme color customizer drawer (`toggleThemeDrawer()`). |
| [`L208-L273`](file:///Users/jsph/cowgameui/index.html#L208-L273) | `#themeDrawer` | Palette bar: 5 presets (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`) + 6 live `<input type="color">` pickers (`Cards`, `Borders`, `Fills`, `Accents`, `Text`, `Canvas`). |

---

## 3. Game Screen & Scaler Root ([L274-L280](file:///Users/jsph/cowgameui/index.html#L274-L280))

| Line Range | Element ID / Selector | Purpose & Dimensions |
| :--- | :--- | :--- |
| [`L24`](file:///Users/jsph/cowgameui/index.html#L24) | `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| [`L278`](file:///Users/jsph/cowgameui/index.html#L278) | `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. Houses `#pagePasture` and `#pageBuilding`. |

---

## 4. Page 1: Pasture ScreenGui ([L281-L461](file:///Users/jsph/cowgameui/index.html#L281-L461))

### A. Roblox CoreGui Overlay Mockup ([L284-L309](file:///Users/jsph/cowgameui/index.html#L284-L309))
Positioned at `absolute top-4 left-6 pointer-events-none z-30 opacity-90 transition-opacity`.
- `#robloxCoreGui`: Top-Left Unibar with Roblox Hexagon, Hamburger menu (`≡`), and Chat with unread badge. Shifts `#topLeftVitals` to `top-16` when active.

### B. Top-Left: Player Vitals & Quest ([L311-L344](file:///Users/jsph/cowgameui/index.html#L311-L344))
- Cow Profile Box (`w-[88px] h-[88px]`), Rebirth chip, `#profileHerdBadge`, `.shape-leaf` Grazing Quest bar (`68%`), Stamina/HP bar (`HP 100`).

### C. Top-Right: Economy & Settings ([L346-L370](file:///Users/jsph/cowgameui/index.html#L346-L370))
- Calories Pill (`h-14 px-5`), Upgrades tab, `#topRightStandard` (Persistent cowbell Settings with `SET`), `#topRightCompact` (Persistent cowbell Menu with `MENU` in Compact Mode).

### D. Top-Center: Town Bulletin ([L372-L419](file:///Users/jsph/cowgameui/index.html#L372-L419))
- `#townBulletinWrapper`: Elevated to `top-4`. `#bulletinFull` (Cycle timer + World Event bar + 2x Calories boost chip) and `#bulletinCompact`.

### E. Sidebars ([L421-L452](file:///Users/jsph/cowgameui/index.html#L421-L452))
- `#leftSidebar`: Inventory + Closet (`top-48`) or single `BAG` button.
- `#rightSidebar`: 2-button vertical stack (`top-32`, gap `4`):
  1. `#sidebarHerd`: Herd button (`HERD`).
  2. `#sidebarTrade`: Trade button (`TRADE`).

### F. Mobile Action Cluster & Safe Zones ([L673-L745](file:///Users/jsph/cowgameui/index.html#L673-L745))
- Global in `#ui-container` (`z-30`): Overlays across both Pasture and Building GUIs without obstruction.
- `#safeZoneLeft`: Mobile thumbstick (`w-48 h-48`).
- `#safeZoneRight`: Mobile action cluster (`w-64 h-64`). Centered `#btnMobileJump` (`80px`, placeholder for Roblox's native Jump), Radial Arc satellites ($D=56\text{px}$, $68\text{px}$ on the phone preset; $R=92\text{px}$), evenly spread $60^\circ \to 200^\circ$ counter-clockwise from east:
  - Emote ($60^\circ$, `#btnMobileEmote` with `onclick="toggleEmoteRadial()"`)
  - Moo ($106.7^\circ$, `#btnMobileMoo`)
  - Sprint ($153.3^\circ$, `#btnMobileSprint`)
  - Kick ($200^\circ$, `#btnMobileKick`)
  - Quick emotes (`.mobile-quick-emote`): Heart, Cheer, Snooze take over the Moo / Sprint / Kick slots while open; Emote reads BACK. Hidden with the rest of the arc on the building page.

---

## 5. Page 2: Building & Construction GUI ([L464-L671](file:///Users/jsph/cowgameui/index.html#L464-L671))

| Line Range | Element ID / Selector | Description & Functionality |
| :--- | :--- | :--- |
| [`L464`](file:///Users/jsph/cowgameui/index.html#L464) | `#pageBuilding` | Root wrapper for Construction Mode wireframe. Toggled via `switchPage('building')`. |
| [`L466-L518`](file:///Users/jsph/cowgameui/index.html#L466-L518) | Building Top Bar | Top HUD: Exit Build button (`[✕] Exit Build`), centered Object/Parts Limit pill (`Parts: 34 / 50`) with Cog icon (`absolute left-1/2 -translate-x-1/2`), grid snap button (`#btnGridSnap`), and dual Wood (`450`) & Stone (`320`) side-by-side SVG counters. |
| [`L520-L532`](file:///Users/jsph/cowgameui/index.html#L520-L532) | Placement Boundary | Dashed building boundary ring with central animated `Placement Cursor` target. |
| [`L534-L575`](file:///Users/jsph/cowgameui/index.html#L534-L575) | Right Utility Tools | Vertical action stack (`top-20`, gap-2.5): Rotate (`ROT [R]`), Paint (`PAINT`), Undo (`UNDO [Z]`), Redo (`REDO [Y]`), Demolish (`TRASH [X]`). Kept strictly above right safe zone. |
| [`L577-L669`](file:///Users/jsph/cowgameui/index.html#L577-L669) | Bottom Catalog Dock | Connected category tabs (`rounded-t-xl rounded-b-none`, `-mb-[5px]`) + seamless horizontal prop tray (`rounded-b-[2rem] rounded-t-xl`, `border-[5px]`) with 6 slot cards (Rustic Fence, Picket Gate, Hay Bale, Stone Wall, Cozy Lantern, Clover Bed). Constrained to `max-w-[680px]` centered strictly between mobile safe zones. |

---

## 6. JavaScript Engine ([L749-L1101](file:///Users/jsph/cowgameui/index.html#L749-L1101))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L750-L758`](file:///Users/jsph/cowgameui/index.html#L750-L758) | Runtime State Flags | `activePage`, `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible`, `isThemeDrawerOpen`, `isEmoteRadialOpen`. |
| [`L758-L778`](file:///Users/jsph/cowgameui/index.html#L758-L778) | `switchPage(pageId)` | Switches view between `#pagePasture` and `#pageBuilding` and updates tab pills. |
| [`L785-L807`](file:///Users/jsph/cowgameui/index.html#L785-L807) | `setEmoteRadial(open)` / `toggleEmoteRadial()` / `setActionArcVisible(visible)` | Emote swaps Moo / Sprint / Kick for the three quick emotes in the same arc slots (Emote reads BACK); the arc hides on the building page. |
| [`L807-L812`](file:///Users/jsph/cowgameui/index.html#L807-L812) | `cycleGridSnap()` | Cycles grid snap setting (`2 Studs`, `4 Studs`, `1 Stud`, `Free / Off`). |
| [`L812-L823`](file:///Users/jsph/cowgameui/index.html#L812-L823) | `filterBuildCategory(cat)` | Highlights active category tab in building catalog dock. |
| [`L825-L866`](file:///Users/jsph/cowgameui/index.html#L825-L866) | `THEME_PRESETS` | Palette presets: `monochrome`, `meadow`, `sunrise`, `lavender`, `sky`. |
| [`L868-L887`](file:///Users/jsph/cowgameui/index.html#L868-L887) | `updateThemeProp(prop, val)` | Injects CSS variables into `.game-screen` with cascade overrides. |
| [`L889-L903`](file:///Users/jsph/cowgameui/index.html#L889-L903) | `applyThemePreset(key)` | Applies palette preset and syncs native `<input type="color">` pickers. |
| [`L905-L907`](file:///Users/jsph/cowgameui/index.html#L905-L907) | `resetTheme()` | Reverts to Default Monochrome wireframe palette. |
| [`L909-L914`](file:///Users/jsph/cowgameui/index.html#L909-L914) | `toggleThemeDrawer()` | Shows/hides `#themeDrawer` palette panel. |
| [`L916-L923`](file:///Users/jsph/cowgameui/index.html#L916-L923) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L925-L950`](file:///Users/jsph/cowgameui/index.html#L925-L950) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L952-L961`](file:///Users/jsph/cowgameui/index.html#L952-L961) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L963-L968`](file:///Users/jsph/cowgameui/index.html#L963-L968) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` thumbstick and `#safeZoneRight` radial action cluster. |
| [`L970-L984`](file:///Users/jsph/cowgameui/index.html#L970-L984) | `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| [`L986-L996`](file:///Users/jsph/cowgameui/index.html#L986-L996) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L1000-L1043`](file:///Users/jsph/cowgameui/index.html#L1000-L1043) | `DEVICE_HUD_SCALE` / `fitText()` | Each preset simulates a device's Roblox HUD scale (desktop 1.5, ultrawide 2, iPad 1.14, phone 0.75 on a 520px canvas). `fitText` applies the Roblox legibility floor: 11pt captions / 12pt labels, shrink-to-fit in fixed boxes. |
| [`L1044-L1077`](file:///Users/jsph/cowgameui/index.html#L1044-L1077) | `resizeUI()` | Sizes `#ui-container` to the preset's virtual canvas (720 tall; 520 on the phone preset), sets the vital-bar width (208→160 on narrow or short canvases), then runs `fitText`. |
| [`L1078-L1100`](file:///Users/jsph/cowgameui/index.html#L1078-L1100) | `ResizeObserver` & init | Listens to `.game-screen` size changes and parses URL query params (`page`, `safezones`, `coregui`, `compact`, `theme`). |
