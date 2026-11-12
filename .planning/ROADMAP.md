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

## Phase 5 — Legibility, accessibility, ergonomics 📝 (plan awaiting review)
See `phases/05-legibility-ergonomics/05-PLAN.md`.
- [ ] T0a theme tokens (Roblox) · T0b radial cluster (Roblox) · T0c building GUI port · T0d settings toggles
- [x] T1 contrast audit
- [ ] T2 type tokens · T3 hit areas · T4 device profiles
- [ ] T5 phone layout · T5b building phone layout · T5c kick arc · T5d reduced motion · T6 tablet thumb band · T7 overlap/size verify · T8 contrast fixes · T9 docs
