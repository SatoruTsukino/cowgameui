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

### C. Top-Right: Economy & Settings ([L299-L319](file:///Users/jsph/cowgameui/index.html#L299-L319))
- Calories Pill (`h-14 px-5`), Upgrades tab, `#topRightStandard` (Settings cowbell), `#topRightCompact` (`•••` menu).

### D. Top-Center: Town Bulletin ([L322-L368](file:///Users/jsph/cowgameui/index.html#L322-L368))
- `#townBulletinWrapper`: Elevated to `top-4`. `#bulletinFull` (Cycle timer + World Event bar + 2x Calories boost chip) and `#bulletinCompact`.

### E. Sidebars ([L371-L400](file:///Users/jsph/cowgameui/index.html#L371-L400))
- `#leftSidebar`: Inventory + Closet (`top-48`) or single `BAG` button.
- `#rightSidebar`: Herd + Trade (`top-32`).

### F. Mobile Action Cluster & Safe Zones ([L403-L446](file:///Users/jsph/cowgameui/index.html#L403-L446))
- `#safeZoneLeft`: Mobile thumbstick (`w-48 h-48`).
- `#safeZoneRight`: Mobile action cluster (`w-64 h-64`). Centered `#btnMobileJump` (`80px`), Radial Arc satellites ($D=56\text{px}$, $R=92\text{px}$): Sprint ($190^\circ$), Moo ($135^\circ$), Emote ($80^\circ$).

---

## 5. Page 2: Building & Construction GUI ([L458-L650](file:///Users/jsph/cowgameui/index.html#L458-L650))

| Line Range | Element ID / Selector | Description & Functionality |
| :--- | :--- | :--- |
| [`L458`](file:///Users/jsph/cowgameui/index.html#L458) | `#pageBuilding` | Root wrapper for Construction Mode wireframe. Toggled via `switchPage('building')`. |
| [`L461-L508`](file:///Users/jsph/cowgameui/index.html#L461-L508) | Building Top Bar | Top HUD: Exit Build button (`[✕] Exit Build`), center title chip (`CONSTRUCTION MODE • Tier 2`), grid snap button (`#btnGridSnap`), and resource budget (`🪵 450 • 🌾 1,500`). |
| [`L510-L523`](file:///Users/jsph/cowgameui/index.html#L510-L523) | Placement Boundary | Dashed building boundary ring with central animated `Placement Cursor` target. |
| [`L525-L567`](file:///Users/jsph/cowgameui/index.html#L525-L567) | Right Utility Tools | Vertical action stack: Rotate (`ROT [R]`), Paint (`PAINT`), Undo (`UNDO [Z]`), Redo (`REDO [Y]`), Demolish (`TRASH [X]`). |
| [`L569-L648`](file:///Users/jsph/cowgameui/index.html#L569-L648) | Bottom Catalog Dock | Category tabs (`Fences`, `Barns`, `Feeders`, `Paths`, `Decor`) + horizontal scrollable prop tray with 6 slot cards (Rustic Fence, Picket Gate, Hay Bale, Stone Wall, Cozy Lantern, Clover Bed). |

---

## 6. JavaScript Engine ([L652-L915](file:///Users/jsph/cowgameui/index.html#L652-L915))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L653-L657`](file:///Users/jsph/cowgameui/index.html#L653-L657) | Runtime State Flags | `activePage`, `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible`, `isThemeDrawerOpen`. |
| [`L659-L681`](file:///Users/jsph/cowgameui/index.html#L659-L681) | `switchPage(pageId)` | Switches view between `#pagePasture` and `#pageBuilding` and updates tab pills. |
| [`L683-L686`](file:///Users/jsph/cowgameui/index.html#L683-L686) | `cycleGridSnap()` | Cycles grid snap setting (`2 Studs`, `4 Studs`, `1 Stud`, `Free / Off`). |
| [`L688-L699`](file:///Users/jsph/cowgameui/index.html#L688-L699) | `filterBuildCategory(cat)` | Highlights active category tab in building catalog dock. |
| [`L701-L742`](file:///Users/jsph/cowgameui/index.html#L701-L742) | `THEME_PRESETS` | Palette presets: `monochrome`, `meadow`, `sunrise`, `lavender`, `sky`. |
| [`L744-L763`](file:///Users/jsph/cowgameui/index.html#L744-L763) | `updateThemeProp(prop, val)` | Injects CSS variables into `.game-screen` with cascade overrides. |
| [`L765-L779`](file:///Users/jsph/cowgameui/index.html#L765-L779) | `applyThemePreset(key)` | Applies palette preset and syncs native `<input type="color">` pickers. |
| [`L781-L783`](file:///Users/jsph/cowgameui/index.html#L781-L783) | `resetTheme()` | Reverts to Default Monochrome wireframe palette. |
| [`L785-L790`](file:///Users/jsph/cowgameui/index.html#L785-L790) | `toggleThemeDrawer()` | Shows/hides `#themeDrawer` palette panel. |
| [`L792-L799`](file:///Users/jsph/cowgameui/index.html#L792-L799) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L801-L826`](file:///Users/jsph/cowgameui/index.html#L801-L826) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar*`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L828-L837`](file:///Users/jsph/cowgameui/index.html#L828-L837) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L839-L844`](file:///Users/jsph/cowgameui/index.html#L839-L844) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` thumbstick and `#safeZoneRight` radial action cluster. |
| [`L846-L860`](file:///Users/jsph/cowgameui/index.html#L846-L860) | `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| [`L862-L872`](file:///Users/jsph/cowgameui/index.html#L862-L872) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L874-L894`](file:///Users/jsph/cowgameui/index.html#L874-L894) | `resizeUI()` | Derives `virtualWidth` and scales `#ui-container` to virtual 720p resolution. |
| [`L896-L913`](file:///Users/jsph/cowgameui/index.html#L896-L913) | `ResizeObserver` & init | Listens to `.game-screen` size changes and parses URL query params (`page`, `safezones`, `coregui`, `compact`, `theme`). |
