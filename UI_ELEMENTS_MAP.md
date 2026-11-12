# Cozy Cow Game UI - Elements Line Map & Reference

> **Source File:** [`index.html`](file:///Users/jsph/cowgameui/index.html)  
> **Resolution Model:** Virtual 720p Canvas (`virtualHeight = 720`, dynamic `virtualWidth = 720 * aspect_ratio`) scaled into `.game-screen`.

---

## 1. Global Setup & Custom Styles ([L1-L60](file:///Users/jsph/cowgameui/index.html#L1-L60))

| Line Range | Selector / Token | Purpose & Functionality |
| :--- | :--- | :--- |
| [`L9`](file:///Users/jsph/cowgameui/index.html#L9) | `@import Nunito` | Google Fonts import (`Nunito:wght@700;800;900`). |
| [`L11-L22`](file:///Users/jsph/cowgameui/index.html#L11-L22) | `body` | Centered flex column layout, gray background (`#e5e7eb`), overflow prevention. |
| [`L24-L33`](file:///Users/jsph/cowgameui/index.html#L24-L33) | `.game-screen` | Radial dot grid viewport (`#d1d5db 2px`), max-bounds (`max-w-[90vw]`, `max-h-[75vh]`). |
| [`L35-L38`](file:///Users/jsph/cowgameui/index.html#L35-L38) | `.ui-element` | Disables text selection (`user-select: none`). |
| [`L40-L42`](file:///Users/jsph/cowgameui/index.html#L40-L42) | `.hud-spring` | Cubic-bezier transition (`0.34, 1.56, 0.64, 1`) for bouncy HUD animations. |
| [`L45-L51`](file:///Users/jsph/cowgameui/index.html#L45-L51) | `.shape-leaf` | Custom asymmetric border-radius for quest bar: TL `2.5rem`, BR `2.5rem`, TR/BL `0.5rem`. |
| [`L53-L58`](file:///Users/jsph/cowgameui/index.html#L53-L58) | `.shape-leaf-inner` | Concentric inset radius for fill bar: TL/BR `1.875rem` (30px), TR/BL `0` (sharp). |
| [`L60-L62`](file:///Users/jsph/cowgameui/index.html#L60-L62) | `.shape-cowbell` | Downward-flared border-radius for settings button: `35% 35% 15% 15% / 50% 50% 20% 20%`. |
| [`L64-L66`](file:///Users/jsph/cowgameui/index.html#L64-L66) | `.aspect-*` | Preset aspect ratio CSS utility classes (`21/9`, `4/3`, `19.5/9`). |

---

## 2. Dev & Preview Controls Bar ([L64-L88](file:///Users/jsph/cowgameui/index.html#L64-L88))

| Line Range | Element ID / Selector | Purpose & Triggers |
| :--- | :--- | :--- |
| [`L65-L69`](file:///Users/jsph/cowgameui/index.html#L65-L69) | Header Container | ScreenGui Controls top card wrapper. |
| [`L71-L76`](file:///Users/jsph/cowgameui/index.html#L71-L76) | `#aspectRatioSelect` | Dropdown: switches aspect ratio class (`aspect-video`, `aspect-21-9`, `aspect-19-5-9`, `aspect-4-3`) & triggers continuous `resizeUI()`. |
| [`L78-L80`](file:///Users/jsph/cowgameui/index.html#L78-L80) | `#btnCompact` | Toggle Button: switches Compact Mode (`toggleCompactMode()`). |
| [`L81-L83`](file:///Users/jsph/cowgameui/index.html#L81-L83) | `#btnBulletin` | Toggle Button: hides/shows Town Bulletin (`toggleBulletin()`). |
| [`L84-L86`](file:///Users/jsph/cowgameui/index.html#L84-L86) | `#btnSafeZones` | Toggle Button: displays mobile thumbstick & action safe zones (`toggleSafeZones()`). |
| [`L87-L89`](file:///Users/jsph/cowgameui/index.html#L87-L89) | `#btnCoreGui` | Toggle Button: displays native Roblox CoreGui top bar & safe insets (`toggleCoreGui()`). |

---

## 3. Game Screen & Scaler Root ([L90-L95](file:///Users/jsph/cowgameui/index.html#L90-L95))

| Line Range | Element ID / Selector | Purpose & Dimensions |
| :--- | :--- | :--- |
| [`L91`](file:///Users/jsph/cowgameui/index.html#L91) | `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| [`L94`](file:///Users/jsph/cowgameui/index.html#L94) | `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. |

---

## 3.5. Roblox CoreGui Overlay Mockup ([L107-L132](file:///Users/jsph/cowgameui/index.html#L107-L132))

Positioned at `absolute top-4 left-6 pointer-events-none z-30 opacity-90 transition-opacity`.

| Line Range | Selector | Description |
| :--- | :--- | :--- |
| [`L107`](file:///Users/jsph/cowgameui/index.html#L107) | `#robloxCoreGui` | Top bar mockup toggled via `toggleCoreGui()`. Shifts `#topLeftVitals` between `top-8` and `top-16` when active. |
| [`L109-L131`](file:///Users/jsph/cowgameui/index.html#L109-L131) | Top-Left Unibar | Dark pill (`bg-black/75`) containing Roblox Hexagon, Hamburger menu (`≡`), and Chat with unread badge. |

---

## 4. Top HUD Elements (Decoupled Top-Left & Top-Right)

### A. Top-Left: Player Vitals & Quest ([L135-L167](file:///Users/jsph/cowgameui/index.html#L135-L167))
Positioned at `absolute top-8 left-8 flex items-start gap-4 pointer-events-auto shrink-0 z-20 hud-spring`. Shifted to `top-16` when Roblox CoreGui is toggled ON.

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L137-L147`](file:///Users/jsph/cowgameui/index.html#L137-L147) | Cow Profile Box | `w-28 h-28` rounded squircle card (`rounded-[2rem] border-[6px] border-gray-400`). |
| [`L140-L142`](file:///Users/jsph/cowgameui/index.html#L140-L142) | `#profileHerdBadge` | `+ HERD` badge: `-top-3 -right-3`. Hidden by default; displayed when Compact Mode = ON. |
| [`L144-L146`](file:///Users/jsph/cowgameui/index.html#L144-L146) | Rebirth Chip | Rebirth level chip docked to bottom: `-bottom-3.5 left-1/2 -translate-x-1/2`. |
| [`L152-L158`](file:///Users/jsph/cowgameui/index.html#L152-L158) | Grazing Quest Bar | `w-64 h-10` `.shape-leaf` progress bar with `p-1` (4px gap) + inner `.shape-leaf-inner` fill (`68%`). |
| [`L161-L165`](file:///Users/jsph/cowgameui/index.html#L161-L165) | HP / Stamina Pill | `w-full h-10 rounded-full border-[6px] border-gray-500` inner progress pill (`HP 100`). |

### B. Top-Right: Economy & Settings ([L170-L190](file:///Users/jsph/cowgameui/index.html#L170-L190))
Positioned at `absolute top-4 right-8 flex items-start gap-4 pointer-events-auto shrink-0 z-20 hud-spring` (Elevated to reclaim headroom).

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L171-L178`](file:///Users/jsph/cowgameui/index.html#L171-L178) | Calories Pill & Tab | `h-14 px-5` rounded pill (`Calories: 1,500`) with docked `#upgradesPill` underneath. |
| [`L175-L177`](file:///Users/jsph/cowgameui/index.html#L175-L177) | `#upgradesPill` | `h-8 px-4 -mt-2 rounded-b-xl` Upgrades button tab. Hidden when Compact Mode = ON. |
| [`L180-L185`](file:///Users/jsph/cowgameui/index.html#L180-L185) | `#topRightStandard` | Standard container for Settings (`w-14 h-14` `.shape-cowbell`). Hidden in Compact Mode. |
| [`L187-L189`](file:///Users/jsph/cowgameui/index.html#L187-L189) | `#topRightCompact` | `w-14 h-14` overflow menu button (`•••`). Unified action hub for Settings + Herd + Trade when Compact Mode = ON. |

---

## 5. Top-Center: Town Bulletin ([L193-L239](file:///Users/jsph/cowgameui/index.html#L193-L239))

Positioned at `absolute top-4 left-1/2 -translate-x-1/2 flex flex-col items-center pointer-events-auto z-20` (Elevated to reclaim headroom).

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L193`](file:///Users/jsph/cowgameui/index.html#L193) | `#townBulletinWrapper` | Main parent wrapper; toggles opacity/scale via `toggleBulletin()`. |
| [`L194-L227`](file:///Users/jsph/cowgameui/index.html#L194-L227) | `#bulletinFull` | Expanded Bulletin card: Cycle timer (Day/Night icon + `DAY • 02:45`), World Event progress bar (`Clover Bloom 55%`), and 2x Calories boost chip. Hidden in Compact Mode. |
| [`L229-L238`](file:///Users/jsph/cowgameui/index.html#L229-L238) | `#bulletinCompact` | Collapsed mini-pill (`w-7` icon + `02:45` text + notification dot). Displayed in Compact Mode. |

---

## 6. Sidebars ([L242-L271](file:///Users/jsph/cowgameui/index.html#L242-L271))

### A. Left Sidebar: Inventory & Wardrobe ([L242-L257](file:///Users/jsph/cowgameui/index.html#L242-L257))
Positioned at `absolute left-8 top-48 flex flex-col gap-4 pointer-events-auto z-10`.
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L243-L251`](file:///Users/jsph/cowgameui/index.html#L243-L251) | `#leftSidebarStandard` | Standard 2-button stack: Inventory (`w-16 h-[4.5rem]` with backpack flap) + Closet (`w-16 h-16` squircle). Hidden in Compact Mode. |
| [`L253-L256`](file:///Users/jsph/cowgameui/index.html#L253-L256) | `#leftSidebarCompact` | Single unified `BAG` button (`w-16 h-[4.5rem]`). Displayed when Compact Mode = ON. |

### B. Right Sidebar: Social & Trade ([L259-L271](file:///Users/jsph/cowgameui/index.html#L259-L271))
Positioned at `absolute right-8 top-32 flex flex-col items-end gap-4 pointer-events-auto z-10 hud-spring` (Elevated to reclaim headroom).
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L259-L271`](file:///Users/jsph/cowgameui/index.html#L259-L271) | `#rightSidebar` | 2-button stack: Herd (`w-16 h-16` overlapping dual boxes) + Trade (`w-16 h-16` squircle). Entire container hidden in Compact Mode (actions absorb into Top-Right `#topRightCompact`). |

---

## 7. Bottom Safe Zones & WIP Placeholders ([L274-L286](file:///Users/jsph/cowgameui/index.html#L274-L286))

| Line Range | Element ID / Selector | Description & Behavior |
| :--- | :--- | :--- |
| [`L274-L276`](file:///Users/jsph/cowgameui/index.html#L274-L276) | `#safeZoneLeft` | `w-48 h-48 rounded-full border-[4px] border-dashed` circle representing Mobile Thumbstick zone. Toggled via `#btnSafeZones`. |
| [`L277-L279`](file:///Users/jsph/cowgameui/index.html#L277-L279) | `#safeZoneRight` | `w-56 h-48 rounded-[2.5rem] border-[4px] border-dashed` squircle representing Mobile Jump/Interact cluster. Toggled via `#btnSafeZones`. |
| [`L282-L286`](file:///Users/jsph/cowgameui/index.html#L282-L286) | Bottom-Center Area Actions | `w-1/3 max-w-sm` dashed squircle (`Area Actions (WIP)`). Reserved for context-sensitive prompts. |

---

## 8. JavaScript Engine ([L291-L411](file:///Users/jsph/cowgameui/index.html#L291-L411))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L292-L295`](file:///Users/jsph/cowgameui/index.html#L292-L295) | `isCompact`, `isBulletinVisible`, `areSafeZonesVisible`, `isCoreGuiVisible` | Runtime UI boolean state flags. |
| [`L297-L304`](file:///Users/jsph/cowgameui/index.html#L297-L304) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L306-L331`](file:///Users/jsph/cowgameui/index.html#L306-L331) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar*`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L333-L342`](file:///Users/jsph/cowgameui/index.html#L333-L342) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L344-L349`](file:///Users/jsph/cowgameui/index.html#L344-L349) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` and `#safeZoneRight`. |
| [`L351-L365`](file:///Users/jsph/cowgameui/index.html#L351-L365) | `toggleCoreGui()` | Shows/hides `#robloxCoreGui` and shifts `#topLeftVitals` between `top-8` and `top-16`. |
| [`L367-L377`](file:///Users/jsph/cowgameui/index.html#L367-L377) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L379-L399`](file:///Users/jsph/cowgameui/index.html#L379-L399) | `resizeUI()` | Calculates `screen.clientWidth/clientHeight` (border-box safe), derives `virtualWidth`, and scales `#ui-container` to virtual 720p resolution. |
| [`L401-L410`](file:///Users/jsph/cowgameui/index.html#L401-L410) | `ResizeObserver` & init | Listens to `.game-screen` size changes and runs initial `resizeUI()` on `DOMContentLoaded`. |

