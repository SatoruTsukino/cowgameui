# Cozy Cow Game UI - Elements Map & Reference

> **Source File:** [`index.html`](index.html)
> **Lookup:** entries are keyed by `data-rbx` path, `#id`, selector or function name, not by line number. Search `index.html` for the key (e.g. `data-rbx="TopLeft/Profile"`). Line numbers are not kept here because every edit made them stale.
> **Roblox mapping:** `data-rbx="A/B/C"` names the matching instance chain in the Roblox port (`roblox/src/shared/CowHUD`). `node tools/verify-hud.mjs` fails when a path segment has no Luau instance.
> **Verification:** `node tools/verify-hud.mjs` also checks every preset × page for overlaps and text below 11pt/12pt (phase 5, T7).
> **Tokens:** palette, scale, deck budget, vital-bar widths and phone sizes come from `tokens.json` (`node tools/gen-tokens.mjs`; see the `tokens:*` regions).
> **Resolution Model:** Virtual 720p Canvas (`virtualHeight = 720`, dynamic `virtualWidth = 720 * aspect_ratio`) scaled into `.game-screen`.

---

## 1. Global Setup & Dynamic Theme System (`<style>`)

| Selector / Token | Purpose & Functionality |
| :--- | :--- |
| `@import Nunito` | Google Fonts import (`Nunito:wght@700;800;900`). |
| `body` | Centered flex column layout, gray background (`#e5e7eb`), overflow prevention. |
| `.game-screen` | Radial dot grid viewport with dynamic `--theme-screen-bg` and `--theme-grid-dot`. |
| `.ui-element` | Disables text selection (`user-select: none`). |
| `.hud-spring` | Cubic-bezier transition (`0.34, 1.56, 0.64, 1`) for bouncy HUD animations. |
| Touch / phone / narrow preset CSS | Touch presets hide keyboard hints (`.key-hint`). Phone preset (`.aspect-19-5-9`): safe zones placed like Roblox's native controls, `ps-*` boxes grow so labels reach 11pt (generated `tokens:phone` region, Roblox `Theme.size` parity), letter-spacing normal, build tools wrap, catalog dock clears both thumb zones. Responsive bulletin rules collapse `#bulletinDaytime` on mobile/narrow resolutions and center `#bulletinBoostCard` under the shortened pill. |
| Reduced motion | `prefers-reduced-motion`: short linear fades, no hover/press scaling or pulsing (Roblox Settings → Motion parity). |
| `.shape-leaf` | Custom asymmetric border-radius for quest bar: TL `2.5rem`, BR `2.5rem`, TR/BL `0.5rem`. |
| `.shape-leaf-inner` | Concentric inset radius for fill bar: TL/BR `1.875rem` (30px), TR/BL `0` (sharp). |
| `.shape-cowbell` | Downward-flared border-radius for settings button: `35% 35% 15% 15% / 50% 50% 20% 20%`. |
| `.aspect-*` | Preset aspect ratio CSS utility classes (`21/9`, `4/3`, `19.5/9`). |
| `tokens:root` region | Generated `:root` custom properties (Mono preset): card, screen, subtle, fill, border, accent, text, danger. |
| Dynamic Theme CSS | `.game-screen` derived roles and the gray-class → role overrides for Cards, Borders, Fills, Accents, and Text. `.stroke-danger` / `.text-danger` use the Danger role (trash tool). |

---

## 1.5. Top Page Navigation Tabs

| Element ID | Purpose & Triggers |
| :--- | :--- |
| `#pageTabsContainer` | Top view switcher dock. Controls active ScreenGui page via `switchPage(pageId)`. |
| `#tabBtnPasture` | Tab button: switches to `#pagePasture` (Main Game HUD). |
| `#tabBtnBuilding` | Tab button: switches to `#pageBuilding` (Building & Construction GUI). |

---

## 2. Dev Controls Bar & Theme Customizer Drawer

Preview-only controls; nothing here is ported to Roblox.

| Element ID / Selector | Purpose & Triggers |
| :--- | :--- |
| Controls Bar | ScreenGui Controls top card wrapper. |
| `#aspectRatioSelect` | Dropdown: switches aspect ratio (`16:9`, `21:9`, `19.5:9`, `4:3`) & triggers `resizeUI()`. |
| `#btnCompact` | Toggle Button: switches Compact Mode (`toggleCompactMode()`). |
| `#btnBulletin` | Toggle Button: hides/shows Town Bulletin (`toggleBulletin()`). |
| `#btnSafeZones` | Toggle Button: displays mobile thumbstick & radial action cluster (`toggleSafeZones()`). |
| `#btnCoreGui` | Toggle Button: displays native Roblox CoreGui top bar (`toggleCoreGui()`). |
| `#btnTheme` | Toggle Button: expands/collapses theme color customizer drawer (`toggleThemeDrawer()`). |
| `#themeDrawer` | Palette bar: 5 presets (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`) + 6 live `<input type="color">` pickers (`Cards`, `Borders`, `Fills`, `Accents`, `Text`, `Canvas`). |

---

## 3. Game Screen & Scaler Root

| Element ID / Selector | Purpose & Dimensions |
| :--- | :--- |
| `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. Houses `#pagePasture` and `#pageBuilding`. Roblox: `Root` + `UIScale` (`Scaler.luau`). |

---

## 4. Page 1: Pasture ScreenGui (`#pagePasture`, `data-rbx="HUD"`)

### A. Roblox CoreGui Overlay Mockup
Positioned at `absolute top-4 left-6 pointer-events-none z-30 opacity-90 transition-opacity`. Not ported (Roblox draws its own).
- `#robloxCoreGui`: Top-Left Unibar with Roblox Hexagon, Hamburger menu (`≡`), and Chat with unread badge. Shifts `#topLeftVitals` to `top-16` when active.

### B–E. HUD groups

| `data-rbx` | HTML key | Description |
| :--- | :--- | :--- |
| `TopLeft` | `#topLeftVitals` | Top-left cluster (`TopLeft.luau`). |
| `TopLeft/Profile` | profile box | Cow Profile Box (`w-[88px] h-[88px]`). |
| `TopLeft/Profile/HerdBadge` | `#profileHerdBadge` | Herd badge, shown in Compact Mode. |
| `TopLeft/Profile/RebirthChip` | rebirth chip | Rebirth chip under the profile. |
| `TopLeft/Vitals` | `#vitalsColumn` | Vital bars column; width 208 → 160px (`tokens.json` `vitals`). |
| `TopLeft/Vitals/Grazing/GrazingBar` | `.shape-leaf` bar | Grazing Quest leaf bar (`68%`). |
| `TopLeft/Vitals/HealthBar` | HP pill | Stamina/HP bar (`HP 100`). |
| `TopRight` | `#topRightHud` | Top-right cluster (`TopRight.luau`). |
| `TopRight/Economy/Calories` | calories pill | Calories Pill (`h-14 px-5`). |
| `TopRight/Economy/Upgrades` | `#upgradesPill` | Upgrades tab tucked under the calories pill. |
| `TopRight/Settings` | cowbell in `#topRightStandard` | Persistent cowbell Settings (`SET`). |
| `TopRight/More` | `#topRightCompact` | Persistent cowbell Menu (`MENU`) in Compact Mode. |
| `Bulletin` | `#townBulletinWrapper` | Town Bulletin wrapper, elevated to `top-4` (`Bulletin.luau`). |
| `Bulletin/Full/Card` | `#bulletinCard` | Pill with daytime cycle `#bulletinDaytime` (sun icon, cycle timer) and world event progress `#eventColumn`. |
| `Bulletin/Full/Boost` | `#bulletinBoostCard` | Boost chip hanging under the pill. |
| `Bulletin/Compact` | `#bulletinCompact` | Compact mini-pill. |
| `LeftSidebar/Standard/Inventory` | `#leftSidebarStandard` backpack | Inventory backpack (`Sidebars.luau`). |
| `LeftSidebar/Standard/Closet` | `#leftSidebarStandard` square | Closet. |
| `LeftSidebar/Bag` | `#leftSidebarCompact` | Single `BAG` button in Compact Mode. |
| `RightSidebar/Herd` | Herd stacked squares | Herd button (`Back` / `Front` squares). |
| `RightSidebar/Trade` | Trade square | Trade button. |
| `AreaActions` | bottom-centre dashed box | Area Actions placeholder (`Bottom.luau`). |

Bulletin responsive behavior: on mobile (`.aspect-19-5-9`), tablet (`.aspect-4-3`), and narrow resolutions (`.narrow-screen` / `virtualWidth < 1150` / screen width < 900px), `#bulletinDaytime` collapses with `display: none !important`. The pill shrinks to a minimum width floor of $216\text{px}$ (event column min-width $155\text{px}$) with reduced vertical padding ($8\text{px}$), and `#bulletinBoostCard` remains centered underneath.

### F. Mobile Action Cluster & Safe Zones
- Global in `#ui-container` (`z-30`): Overlays across both Pasture and Building GUIs without obstruction.
- `#safeZoneLeft`: Mobile thumbstick (`w-48 h-48`). Not ported (Roblox native thumbstick).
- `#safeZoneRight` (`data-rbx="ActionArc"`): Mobile action cluster (`w-64 h-64`). Centered `#btnMobileJump` (`80px`, placeholder for Roblox's native Jump, so it has no `data-rbx`). Radial Arc satellites ($D=56\text{px}$, $68\text{px}$ on the phone preset; $R=92\text{px}$), evenly spread $60^\circ \to 200^\circ$ counter-clockwise from east (`ActionCluster.luau`):

| `data-rbx` | HTML key | Angle |
| :--- | :--- | :--- |
| `ActionArc/Emote` | `#btnMobileEmote` (`toggleEmoteRadial()`) | $60^\circ$ |
| `ActionArc/Moo` | `#btnMobileMoo` | $106.7^\circ$ |
| `ActionArc/Sprint` | `#btnMobileSprint` | $153.3^\circ$ |
| `ActionArc/Kick` | `#btnMobileKick` | $200^\circ$ |
| `ActionArc/EmoteHeart`, `EmoteCheer`, `EmoteSnooze` | `.mobile-quick-emote` | Take over the Moo / Sprint / Kick slots while open; Emote reads BACK. Hidden with the rest of the arc on the building page. |

---

## 5. Page 2: Building & Construction GUI (`#pageBuilding`, `data-rbx="Building"`)

| `data-rbx` | HTML key | Description & Functionality |
| :--- | :--- | :--- |
| `Building` | `#pageBuilding` | Root wrapper for Construction Mode wireframe. Toggled via `switchPage('building')` (`Building.luau`). |
| `Building/ExitBuild` | Exit button | `[✕] Exit Build`. |
| `Building/PartsLimit` | centred pill | Object/Parts Limit pill (`Parts: 34 / 50`) with Cog icon (`absolute left-1/2 -translate-x-1/2`). |
| `Building/BuildRight/GridSnap` | `#btnGridSnap` | Grid snap button (`cycleGridSnap()`). |
| `Building/BuildRight/Resources` | Wood / Stone box | Dual Wood (`450`) & Stone (`320`) side-by-side SVG counters. |
| — | Placement Boundary (`data-verify-skip`) | Dashed building boundary ring with central `Placement Cursor` target. World-space, not ported. |
| `Building/BuildTools` | `#buildTools` | Vertical action stack (`top-20`, gap-2.5), kept strictly above the right safe zone. |
| `Building/BuildTools/Rotate`, `Paint`, `Undo`, `Redo`, `Trash` | tool buttons | `ROT [R]`, `PAINT`, `UNDO [Z]`, `REDO [Y]`, `TRASH [X]` (Danger role). |
| `Building/CatalogDock` | `#catalogDock` | Bottom catalog dock, constrained to `max-w-[680px]` centered strictly between mobile safe zones. |
| `Building/CatalogDock/Tabs` | `#catalogTabsHeader` | Connected category tabs (`rounded-t-xl rounded-b-none`, `-mb-[5px]`). |
| `Building/CatalogDock/Tabs/<id>` | `#catBtn-<id>` | One tab per category id (`fences`, `barns`, `feeders`, `flooring`, `decor`). |
| `Building/CatalogDock/Tray` | `#catalogTray` | Seamless horizontal prop tray (`rounded-b-[2rem] rounded-t-xl`, `border-[5px]`). |
| `Building/CatalogDock/Tray/Slots` | `#catalogSlots` | 6 slot cards (Rustic Fence, Picket Gate, Hay Bale, Stone Wall, Cozy Lantern, Clover Bed). |

---

## 6. JavaScript Engine (`<script>`)

| Function / Variable | Functionality |
| :--- | :--- |
| `TOKENS` (`tokens:js` region) | Generated copy of `tokens.json`: palette, scale, deck, vitals, sizes. |
| Runtime State Flags | `activePage`, `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible`, `isThemeDrawerOpen`, `isEmoteRadialOpen`. |
| `switchPage(pageId)` | Switches view between `#pagePasture` and `#pageBuilding` and updates tab pills. |
| `setEmoteRadial(open)` / `toggleEmoteRadial()` / `setActionArcVisible(visible)` | Emote swaps Moo / Sprint / Kick for the three quick emotes in the same arc slots (Emote reads BACK); the arc hides on the building page. |
| `cycleGridSnap()` | Cycles grid snap setting (`2 Studs`, `4 Studs`, `1 Stud`, `Free / Off`). |
| `filterBuildCategory(cat)` | Highlights active category tab in building catalog dock. |
| `ROLE_VARS` | Palette role (`Card`, `Screen`, `Subtle`, `Fill`, `Border`, `Accent`, `Text`, `Danger`) → CSS variable. |
| `updateThemeProp(prop, val)` | Injects CSS variables into `.game-screen` with cascade overrides. |
| `applyThemePreset(name)` | Applies a `TOKENS.palette` preset (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`) and syncs native `<input type="color">` pickers. |
| `resetTheme()` | Reverts to the first preset (Mono). |
| `toggleThemeDrawer()` | Shows/hides `#themeDrawer` palette panel. |
| `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| `toggleSafeZones()` | Shows / hides `#safeZoneLeft` thumbstick and `#safeZoneRight` radial action cluster. |
| `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| `DEVICE_HUD_SCALE` / `fitText()` | Each preset simulates a device's Roblox HUD scale (desktop 1.5, ultrawide 2, iPad 1.14, phone `TouchMinScale` 0.75 on a 520px canvas). `fitText` applies the Roblox legibility floor: 11pt captions / 12pt labels, shrink-to-fit in fixed boxes. |
| `DECK_BUDGET` / `fitCatalogDeck()` | Catalog deck switches to `.deck-compact` when the full deck exceeds `TOKENS.deck.Budget` of the canvas height (Roblox `CatalogMetrics`). |
| `resizeUI()` | Sizes `#ui-container` to the preset's virtual canvas (720 tall; 520 on the phone preset), sets vital-bar width, toggles `.narrow-screen` for town bulletin adaptation, then runs `fitText`. |
| `ResizeObserver` & init | Listens to `.game-screen` size changes and parses URL query params (`page`, `safezones`, `coregui`, `compact`, `flyout`, `aspect`, `theme`). |
