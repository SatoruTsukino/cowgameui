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

---

## 3. Game Screen & Scaler Root ([L90-L95](file:///Users/jsph/cowgameui/index.html#L90-L95))

| Line Range | Element ID / Selector | Purpose & Dimensions |
| :--- | :--- | :--- |
| [`L91`](file:///Users/jsph/cowgameui/index.html#L91) | `.game-screen` | Roblox viewport container: `rounded-[3rem]`, `border-[8px] border-gray-500`, `overflow-hidden`. |
| [`L94`](file:///Users/jsph/cowgameui/index.html#L94) | `#ui-container` | Scaler layer: transformed via `scale(${scale})` from `origin-top-left` to match `screen.clientWidth/clientHeight`. |

---

## 4. Top HUD Row ([L97-L156](file:///Users/jsph/cowgameui/index.html#L97-L156))

Positioned at `absolute top-8 left-8 right-8 flex justify-between items-start z-20 pointer-events-none`.

### A. Top-Left: Player Vitals & Quest ([L100-L132](file:///Users/jsph/cowgameui/index.html#L100-L132))
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L102-L112`](file:///Users/jsph/cowgameui/index.html#L102-L112) | Cow Profile Box | `w-28 h-28` rounded squircle card (`rounded-[2rem] border-[6px] border-gray-400`). |
| [`L105-L107`](file:///Users/jsph/cowgameui/index.html#L105-L107) | `#profileHerdBadge` | `+ HERD` badge: `-top-3 -right-3`. Hidden by default; displayed when Compact Mode = ON. |
| [`L109-L111`](file:///Users/jsph/cowgameui/index.html#L109-L111) | Rebirth Chip | Rebirth level chip docked to bottom: `-bottom-3.5 left-1/2 -translate-x-1/2`. |
| [`L122-L131`](file:///Users/jsph/cowgameui/index.html#L122-L131) | Grazing Quest Bar | `w-64 h-10` `.shape-leaf` progress bar with `p-1` (4px gap) + inner `.shape-leaf-inner` fill (`68%`). |
| [`L126-L130`](file:///Users/jsph/cowgameui/index.html#L126-L130) | HP / Stamina Pill | `w-full h-10 rounded-full border-[6px] border-gray-500` inner progress pill (`HP 100`). |

### B. Top-Right: Economy & Settings ([L135-L155](file:///Users/jsph/cowgameui/index.html#L135-L155))
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L136-L143`](file:///Users/jsph/cowgameui/index.html#L136-L143) | Calories Pill & Tab | `h-14 px-5` rounded pill (`Calories: 1,500`) with docked `#upgradesPill` underneath. |
| [`L140-L142`](file:///Users/jsph/cowgameui/index.html#L140-L142) | `#upgradesPill` | `h-8 px-4 -mt-2 rounded-b-xl` Upgrades button tab. Hidden when Compact Mode = ON. |
| [`L145-L150`](file:///Users/jsph/cowgameui/index.html#L145-L150) | `#topRightStandard` | Standard container for Settings (`w-14 h-14` `.shape-cowbell`). Hidden in Compact Mode. |
| [`L158-L161`](file:///Users/jsph/cowgameui/index.html#L158-L161) | `#topRightCompact` | `w-14 h-14` overflow menu button (`•••`). Unified action hub for Settings + Herd + Trade when Compact Mode = ON. |

---

## 5. Top-Center: Town Bulletin ([L158-L205](file:///Users/jsph/cowgameui/index.html#L158-L205))

Positioned at `absolute top-8 left-1/2 -translate-x-1/2 flex flex-col items-center pointer-events-auto z-20`.

| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L159`](file:///Users/jsph/cowgameui/index.html#L159) | `#townBulletinWrapper` | Main parent wrapper; toggles opacity/scale via `toggleBulletin()`. |
| [`L160-L193`](file:///Users/jsph/cowgameui/index.html#L160-L193) | `#bulletinFull` | Expanded Bulletin card: Cycle timer (Day/Night icon + `DAY • 02:45`), World Event progress bar (`Clover Bloom 55%`), and 2x Calories boost chip. Hidden in Compact Mode. |
| [`L194-L204`](file:///Users/jsph/cowgameui/index.html#L194-L204) | `#bulletinCompact` | Collapsed mini-pill (`w-7` icon + `02:45` text + notification dot). Displayed in Compact Mode. |

---

## 6. Sidebars ([L207-L244](file:///Users/jsph/cowgameui/index.html#L207-L244))

Both sidebars align horizontally and vertically at Y-axis `top-48` (`12rem` = `192px`).

### A. Left Sidebar: Inventory & Wardrobe ([L208-L223](file:///Users/jsph/cowgameui/index.html#L208-L223))
Positioned at `absolute left-8 top-48 flex flex-col gap-4 pointer-events-auto z-10`.
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L209-L217`](file:///Users/jsph/cowgameui/index.html#L209-L217) | `#leftSidebarStandard` | Standard 2-button stack: Inventory (`w-16 h-[4.5rem]` with backpack flap) + Closet (`w-16 h-16` squircle). Hidden in Compact Mode. |
| [`L218-L222`](file:///Users/jsph/cowgameui/index.html#L218-L222) | `#leftSidebarCompact` | Single unified `BAG` button (`w-16 h-[4.5rem]`). Displayed when Compact Mode = ON. |

### B. Right Sidebar: Social & Trade ([L225-L242](file:///Users/jsph/cowgameui/index.html#L225-L242))
Positioned at `absolute right-8 top-48 flex flex-col items-end gap-4 pointer-events-auto z-10 hud-spring`.
| Line Range | Element ID / Selector | Description & Reactive States |
| :--- | :--- | :--- |
| [`L225-L242`](file:///Users/jsph/cowgameui/index.html#L225-L242) | `#rightSidebar` | 2-button stack: Herd (`w-16 h-16` overlapping dual boxes) + Trade (`w-16 h-16` squircle). Entire container hidden in Compact Mode (actions absorb into Top-Right `#topRightCompact`). |

---

## 7. Bottom Safe Zones & WIP Placeholders ([L246-L260](file:///Users/jsph/cowgameui/index.html#L246-L260))

| Line Range | Element ID / Selector | Description & Behavior |
| :--- | :--- | :--- |
| [`L247-L249`](file:///Users/jsph/cowgameui/index.html#L247-L249) | `#safeZoneLeft` | `w-48 h-48 rounded-full border-[4px] border-dashed` circle representing Mobile Thumbstick zone. Toggled via `#btnSafeZones`. |
| [`L250-L252`](file:///Users/jsph/cowgameui/index.html#L250-L252) | `#safeZoneRight` | `w-56 h-48 rounded-[2.5rem] border-[4px] border-dashed` squircle representing Mobile Jump/Interact cluster. Toggled via `#btnSafeZones`. |
| [`L254-L259`](file:///Users/jsph/cowgameui/index.html#L254-L259) | Bottom-Center Area Actions | `w-1/3 max-w-sm` dashed squircle (`Area Actions (WIP)`). Reserved for context-sensitive prompts. |

---

## 8. JavaScript Engine ([L263-L365](file:///Users/jsph/cowgameui/index.html#L263-L365))

| Line Range | Function / Variable | Functionality |
| :--- | :--- | :--- |
| [`L264-L266`](file:///Users/jsph/cowgameui/index.html#L264-L266) | `isCompact`, `isBulletinVisible`, `areSafeZonesVisible` | Runtime UI boolean state flags. |
| [`L268-L275`](file:///Users/jsph/cowgameui/index.html#L268-L275) | `setButtonState(btn, label, active)` | Updates control button labels (`ON`/`OFF`) and background pill styling. |
| [`L277-L304`](file:///Users/jsph/cowgameui/index.html#L277-L304) | `toggleCompactMode()` | Toggles `#profileHerdBadge`, `#leftSidebar*`, `#rightSidebar*`, `#topRight*`, `#upgradesPill`, `#bulletin*`. |
| [`L306-L315`](file:///Users/jsph/cowgameui/index.html#L306-L315) | `toggleBulletin()` | Shows / hides `#townBulletinWrapper` with spring transitions. |
| [`L317-L322`](file:///Users/jsph/cowgameui/index.html#L317-L322) | `toggleSafeZones()` | Shows / hides `#safeZoneLeft` and `#safeZoneRight`. |
| [`L324-L334`](file:///Users/jsph/cowgameui/index.html#L324-L334) | `changeAspectRatio(selectElement)` | Swaps `.aspect-*` class on `.game-screen` and runs 500ms smooth polling resize loop. |
| [`L336-L356`](file:///Users/jsph/cowgameui/index.html#L336-L356) | `resizeUI()` | Calculates `screen.clientWidth/clientHeight` (border-box safe), derives `virtualWidth`, and scales `#ui-container` to virtual 720p resolution. |
| [`L358-L364`](file:///Users/jsph/cowgameui/index.html#L358-L364) | `ResizeObserver` & init | Listens to `.game-screen` size changes and runs initial `resizeUI()` on `DOMContentLoaded`. |

