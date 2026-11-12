# CowHUD — Roblox port of `index.html` (V4 wireframe)

## Goal
Turn the HTML/Tailwind HUD wireframe into a working Roblox `ScreenGui` you can drop into a test place.
It has to scale with resolution and aspect ratio the same way the web preview does.

## Requirements
| ID | Requirement |
| :-- | :-- |
| R1 | Every HUD element in the HTML is present, with matching virtual-px sizes, borders and radii: profile, grazing leaf bar, HP pill, calories + upgrades tab, cowbell settings, bulletin (full + compact), sidebars, safe zones, area actions. |
| R2 | Scaling uses a virtual 720p canvas: `scale = viewportHeight / 720` (clamped), `virtualWidth = viewportWidth / scale`. Elements are anchored to edges/centre, so wider screens add space instead of stretching. |
| R3 | The HUD respects device safe areas and the Roblox top bar (`ScreenInsets.CoreUISafeInsets`). |
| R4 | Compact Mode, World Bulletin and Mobile Safe Zones toggles behave as in the HTML, and can be changed in-game from the Settings panel. |
| R5 | When the screen is too narrow, the bulletin collapses itself to the compact pill so it never overlaps the top-left or top-right clusters (e.g. on 4:3). |
| R6 | Every button works: hover/press spring, and it fires `ActionTriggered(action)`. Merged buttons (`•••`, `BAG`) open dropdown menus. Non-settings actions open placeholder panels. |
| R7 | Live data comes from attributes (server writes, client reads), the humanoid's health and server-synced timers. A demo server script drives every value. |
| R8 | Code is split into small modules and laid out for Rojo, with manual Studio placement documented. |

## Out of scope
- Final art and icons (the wireframe is grayscale).
- Dashed borders: Roblox has no dashed `UIStroke`, so these use a solid stroke.
- Real inventory/trade/herd systems. The panels are placeholders.

## Key decisions
- **Borders:** drawn as layered frames (border colour on the outer frame, fill on an inner frame inset by the border width). This matches CSS `border-box` sizing and scales with `UIScale`, unlike `UIStroke`, which draws outside the frame.
- **Asymmetric radii** (leaf, cowbell, tab): built from a base `UICorner` plus quadrant patches, each patch with its own radius.
- **Minimum scale 0.6**, so 10px text stays readable on phones (a 390pt-tall landscape phone would otherwise drop to 0.54).
