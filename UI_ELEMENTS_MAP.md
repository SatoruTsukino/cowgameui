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

## 2. Dev Controls Bar & Theme Customizer Drawer ([L116-L214](file:///Users/jsph/cowgameui/index.html#L116-L214))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L117-L148`](file:///Users/jsph/cowgameui/index.html#L117-L148) | Controls Bar | ScreenGui Controls top card wrapper. |
| [`L123-L128`](file:///Users/jsph/cowgameui/index.html#L123-L128) | `#aspectRatioSelect` | Dropdown: switches aspect ratio (`16:9`, `21:9`, `19.5:9`, `4:3`) & triggers `resizeUI()`. |
| [`L130-L132`](file:///Users/jsph/cowgameui/index.html#L130-L132) | `#btnCompact` | Toggle Button: switches Compact Mode (`toggleCompactMode()`). |
| [`L133-L135`](file:///Users/jsph/cowgameui/index.html#L133-L135) | `#btnBulletin` | Toggle Button: hides/shows Town Bulletin (`toggleBulletin()`). |
| [`L136-L138`](file:///Users/jsph/cowgameui/index.html#L136-L138) | `#btnSafeZones` | Toggle Button: displays mobile thumbstick & radial action cluster (`toggleSafeZones()`). |
| [`L139-L141`](file:///Users/jsph/cowgameui/index.html#L139-L141) | `#btnCoreGui` | Toggle Button: displays native Roblox CoreGui top bar (`toggleCoreGui()`). |
| [`L142-L144`](file:///Users/jsph/cowgameui/index.html#L142-L144) | `#btnTheme` | Toggle Button: expands/collapses theme color customizer drawer (`toggleThemeDrawer()`). |
| [`L148-L213`](file:///Users/jsph/cowgameui/index.html#L148-L213) | `#themeDrawer` | Palette bar: 5 presets (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`) + 6 live `<input type="color">` pickers (`Cards`, `Borders`, `Fills`, `Accents`, `Text`, `Canvas`). |

---

## 3. Game Screen & Scaler Root ([L216-L222](file:///Users/jsph/cowgameui/index.html#L216-L222))

| Line Range | Element ID / Selector | Purpose & Dimensions |
| :--- | :--- | :--- |
| [`L216`](file:///Users/jsph/cowgameui/index.html#L216) | `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| [`L219`](file:///Users/jsph/cowgameui/index.html#L219) | `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. |

---

## 3.5. Roblox CoreGui Overlay Mockup ([L225-L250](file:///Users/jsph/cowgameui/index.html#L225-L250))

Positioned at `absolute top-4 left-6 pointer-events-none z-30 opacity-90 transition-opacity`.

| Line Range | Selector | Description |
| :--- | :--- | :--- |
| [`L225`](file:///Users/jsph/cowgameui/index.html#L225) | `#robloxCoreGui` | Top bar mockup toggled via `toggleCoreGui()`. Shifts `#topLeftVitals` between `top-8` and `top-16` when active. |
| [`L227-L249`](file:///Users/jsph/cowgameui/index.html#L227-L249) | Top-Left Unibar | Dark pill (`bg-black/75`) containing Roblox Hexagon, Hamburger menu (`≡`), and Chat with unread badge. |

---

## 4. Top HUD Elements (Decoupled Top-Left & Top-Right)

### A. Top-Left: Player Vitals & Quest ([L253-L285](file:///Users/jsph/cowgameui/index.html#L253-L285))
Positioned at `absolute top-8 left-8 flex items-start gap-4 pointer-events-auto shrink-0 z-20 hud-spring`. Shifted to `top-16` when Roblox CoreGui is toggled ON.

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L255-L265`](file:///Users/jsph/cowgameui/index.html#L255-L265) | Cow Profile Box | `w-28 h-28` rounded squircle card (`rounded-[2rem] border-[6px] border-gray-400`). |
| [`L258-L260`](file:///Users/jsph/cowgameui/index.html#L258-L260) | `#profileHerdBadge` | `+ HERD` badge: `-top-3 -right-3`. Hidden by default; displayed when Compact Mode = ON. |
| [`L262-L264`](file:///Users/jsph/cowgameui/index.html#L262-L264) | Rebirth Chip | Rebirth level chip docked to bottom: `-bottom-3.5 left-1/2 -translate-x-1/2`. |
| [`L270-L276`](file:///Users/jsph/cowgameui/index.html#L270-L276) | Grazing Quest Bar | `w-64 h-10` `.shape-leaf` progress bar with `p-1` (4px gap) + inner `.shape-leaf-inner` fill (`68%`). |
| [`L279-L283`](file:///Users/jsph/cowgameui/index.html#L279-L283) | HP / Stamina Pill | `w-full h-10 rounded-full border-[6px] border-gray-500` inner progress pill (`HP 100`). |

### B. Top-Right: Economy & Settings ([L288-L308](file:///Users/jsph/cowgameui/index.html#L288-L308))
Positioned at `absolute top-4 right-8 flex items-start gap-4 pointer-events-auto shrink-0 z-20 hud-spring` (Elevated to reclaim headroom).

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L289-L296`](file:///Users/jsph/cowgameui/index.html#L289-L296) | Calories Pill & Tab | `h-14 px-5` rounded pill (`Calories: 1,500`) with docked `#upgradesPill` underneath. |
| [`L293-L295`](file:///Users/jsph/cowgameui/index.html#L293-L295) | `#upgradesPill` | `h-8 px-4 -mt-2 rounded-b-xl` Upgrades button tab. Hidden when Compact Mode = ON. |
| [`L298-L303`](file:///Users/jsph/cowgameui/index.html#L298-L303) | `#topRightStandard` | Standard container for Settings (`w-14 h-14` `.shape-cowbell`). Hidden in Compact Mode. |
| [`L305-L307`](file:///Users/jsph/cowgameui/index.html#L305-L307) | `#topRightCompact` | `w-14 h-14` overflow menu button (`•••`). Unified action hub for Settings + Herd + Trade when Compact Mode = ON. |

---

## 5. Top-Center: Town Bulletin ([L311-L355](file:///Users/jsph/cowgameui/index.html#L311-L355))

Positioned at `absolute top-4 left-1/2 -translate-x-1/2 flex flex-col items-center pointer-events-auto z-20` (Elevated to reclaim headroom).

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L311`](file:///Users/jsph/cowgameui/index.html#L311) | `#townBulletinWrapper` | Main parent wrapper; toggles opacity/scale via `toggleBulletin()`. |
| [`L312-L345`](file:///Users/jsph/cowgameui/index.html#L312-L345) | `#bulletinFull` | Expanded Bulletin card: Cycle timer (Day/Night icon + `DAY • 02:45`), World Event progress bar (`Clover Bloom 55%`), and 2x Calories boost chip. Hidden in Compact Mode. |
| [`L347-L354`](file:///Users/jsph/cowgameui/index.html#L347-L354) | `#bulletinCompact` | Collapsed mini-pill (`w-7` icon + `02:45` text + notification dot). Displayed in Compact Mode. |

---

## 6. Sidebars ([L358-L387](file:///Users/jsph/cowgameui/index.html#L358-L387))

### A. Left Sidebar: Inventory & Wardrobe ([L358-L373](file:///Users/jsph/cowgameui/index.html#L358-L373))
Positioned at `absolute left-8 top-48 flex flex-col gap-4 pointer-events-auto z-10`.
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L359-L367`](file:///Users/jsph/cowgameui/index.html#L359-L367) | `#leftSidebarStandard` | Standard 2-button stack: Inventory (`w-16 h-[4.5rem]` with backpack flap) + Closet (`w-16 h-16` squircle). Hidden in Compact Mode. |
| [`L369-L372`](file:///Users/jsph/cowgameui/index.html#L369-L372) | `#leftSidebarCompact` | Single unified `BAG` button (`w-16 h-[4.5rem]`). Displayed when Compact Mode = ON. |

### B. Right Sidebar: Social & Trade ([L375-L387](file:///Users/jsph/cowgameui/index.html#L375-L387))
Positioned at `absolute right-8 top-32 flex flex-col items-end gap-4 pointer-events-auto z-10 hud-spring` (Elevated to reclaim headroom).
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L375-L387`](file:///Users/jsph/cowgameui/index.html#L375-L387) | `#rightSidebar` | 2-button stack: Herd (`w-16 h-16` overlapping dual boxes) + Trade (`w-16 h-16` squircle). Entire container hidden in Compact Mode (actions absorb into Top-Right `#topRightCompact`). |

---

## 7. Bottom Safe Zones & Mobile Action Cluster ([L389-L440](file:///Users/jsph/cowgameui/index.html#L389-L440))

Toggled together via `#btnSafeZones` (`toggleSafeZones()`). Redundant Graze button removed.

| Line Range | Element ID / Selector | Description & Radial Geometry |
| :--- | :--- | :--- |
| [`L390-L395`](file:///Users/jsph/cowgameui/index.html#L390-L395) | `#safeZoneLeft` | `w-48 h-48` mobile thumbstick touch zone with inner base (`w-20`) and nub. |
| [`L397-L433`](file:///Users/jsph/cowgameui/index.html#L397-L433) | `#safeZoneRight` | Mobile action cluster root container (`w-64 h-64`) positioned at `bottom-8 right-8`. |
| [`L402-L408`](file:///Users/jsph/cowgameui/index.html#L402-L408) | `#btnMobileJump` | **Anchor:** Centered `w-20 h-20` rounded-full Jump button with bold up-arrow. Center at `(128, 128)` in safe zone. |
| [`L411-L417`](file:///Users/jsph/cowgameui/index.html#L411-L417) | `#btnMobileSprint` | **Bottom of Arc ($\theta \approx 190^\circ$):** Enlarged `w-14 h-14` (56px) Sprint button (`SPRINT`). Located at `left-2.5 top-[116px]` ($R=92\text{px}$). |
| [`L419-L425`](file:///Users/jsph/cowgameui/index.html#L419-L425) | `#btnMobileMoo` | **Middle of Arc ($\theta = 135^\circ$):** Enlarged `w-14 h-14` (56px) Moo button (`MOO`). Located at `left-[35px] top-[35px]` ($R=92\text{px}$). |
| [`L427-L433`](file:///Users/jsph/cowgameui/index.html#L427-L433) | `#btnMobileEmote` | **Top of Arc ($\theta \approx 80^\circ$):** Enlarged `w-14 h-14` (56px) Emote button (`EMOTE`). Located at `left-[116px] top-2.5` ($R=92\text{px}$). |
| [`L435-L440`](file:///Users/jsph/cowgameui/index.html#L435-L440) | Bottom-Center Area Actions | `w-1/3 max-w-sm` dashed squircle (`Area Actions (WIP)`). Reserved for context-sensitive prompts. |

---

## 8. JavaScript Engine ([L445-L655](file:///Users/jsph/cowgameui/index.html#L445-L655))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L446-L450`](file:///Users/jsph/cowgameui/index.html#L446-L450) | `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible`, `isThemeDrawerOpen` | Runtime UI boolean state flags. |
| [`L452-L493`](file:///Users/jsph/cowgameui/index.html#L452-L493) | `THEME_PRESETS` | Dictionary of 5 color schemes: `monochrome`, `meadow`, `sunrise`, `lavender`, `sky`. |
| [`L495-L514`](file:///Users/jsph/cowgameui/index.html#L495-L514) | `updateThemeProp(prop, val)` | Dynamically injects CSS custom properties into `.game-screen` with cascade updates. |
| [`L516-L530`](file:///Users/jsph/cowgameui/index.html#L516-L530) | `applyThemePreset(presetKey)` | Applies palette preset and syncs native `<input type="color">` pickers. |
| [`L532-L534`](file:///Users/jsph/cowgameui/index.html#L532-L534) | `resetTheme()` | Reverts to Default Monochrome wireframe palette. |
| [`L536-L541`](file:///Users/jsph/cowgameui/index.html#L536-L541) | `toggleThemeDrawer()` | Shows/hides `#themeDrawer` palette panel. |
| [`L543-L550`](file:///Users/jsph/cowgameui/index.html#L543-L550) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L552-L577`](file:///Users/jsph/cowgameui/index.html#L552-L577) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar*`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L579-L588`](file:///Users/jsph/cowgameui/index.html#L579-L588) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L590-L595`](file:///Users/jsph/cowgameui/index.html#L590-L595) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` thumbstick and `#safeZoneRight` radial action cluster. |
| [`L597-L611`](file:///Users/jsph/cowgameui/index.html#L597-L611) | `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| [`L613-L623`](file:///Users/jsph/cowgameui/index.html#L613-L623) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L625-L645`](file:///Users/jsph/cowgameui/index.html#L625-L645) | `resizeUI()` | Derives `virtualWidth` and scales `#ui-container` to virtual 720p resolution. |
| [`L647-L654`](file:///Users/jsph/cowgameui/index.html#L647-L654) | `ResizeObserver` & init | Listens to `.game-screen` size changes and runs initial `resizeUI()` on `DOMContentLoaded`. |
