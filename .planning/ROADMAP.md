# Roadmap

## Phase 1 — Foundation ✅
- [x] `Theme` — colours, font, scale config, tweens
- [x] `Util` — instance factory, bordered `box`, per-corner `shape`, spring `button`, sun icon, formatters
- [x] `State` — key/value store with `observe`
- [x] `Scaler` — virtual 720p canvas through `UIScale` and the root frame size

## Phase 2 — HUD components ✅
- [x] `TopLeft` — profile, herd badge, rebirth chip, grazing leaf bar, HP pill
- [x] `TopRight` — calories pill (auto width), upgrades tab, cowbell settings, compact `•••`
- [x] `Bulletin` — full card, boost chip, compact pill, show/hide spring, auto-collapse
- [x] `Sidebars` — INV backpack, closet, BAG, herd (stacked squares), trade
- [x] `Bottom` — safe zones, area actions (1/3 width, max 384)
- [x] `Overlays` — dropdown menus, modal panels, Settings toggles

## Phase 3 — Data and wiring ✅
- [x] `Bindings` — player and workspace attributes, humanoid HP, server-time countdowns
- [x] `init` — `CowHUD.mount(player, options)` returns `{ State, ActionTriggered, ScreenGui, Destroy }`
- [x] Client bootstrap and demo server driver
- [x] Rojo `default.project.json` and install README

## Phase 4 — Verify in Studio ⏳ (needs a human)
- [ ] Device emulator: 1920×1080, 2560×1080, iPhone 14 (landscape), iPad (4:3)
- [ ] Bulletin auto-collapses on 4:3 and expands on 16:9
- [ ] Compact toggle merges the sidebars and menus
- [ ] Nunito Heavy renders. If not, swap `Theme.Font`.

## Phase 5 — Legibility, accessibility, ergonomics ✅ (code done; Studio re-check pending)
See `phases/05-legibility-ergonomics/05-PLAN.md`.
- [x] T0a theme tokens + presets (Roblox) · T0b action arc (Roblox) · T0c building GUI + /build /normal · T0d motion + theme settings
- [x] T1 contrast audit · T2 legibility floor (Roblox + HTML) · T3 44pt touch hit areas · T4 device profiles (touch scale floor, phone profile, HTML presets)
- [x] T5 phone layout (bigger boxes) · T5b building phone layout · T5c arc angles · T5d reduced motion · T7 verify-hud.mjs · T8 WCAG palette · T9 docs · T10 boost tab
- [~] T6 tablet thumb band: dropped (current iPad layout approved in Studio)

## Phase 6 — Port tooling ⏳
See `phases/06-port-tooling/06-PLAN.md`.
- [x] T1 shared `tokens.json` + `gen-tokens.mjs`
- [x] T2 `data-rbx` mapping
- [x] T3 SVG → `IconData.luau`
- [ ] T4 palette + colour-blind check
