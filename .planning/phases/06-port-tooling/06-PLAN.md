# Phase 6: Port tooling (HTML → Roblox)

Goal: make the HTML wireframe cheaper to port to and keep in sync with the Roblox `CowHUD` port, by removing hand-copied values and hand-traced data. Approved 2026-11-12. Order: T1 → T2 → T3 → T4, one commit each.

## T1: Shared tokens file
- `tokens.json` (repo root): palette (8 roles × 5 presets), scale config, catalog deck budget, vital-bar widths, phone size pairs.
- `tools/gen-tokens.mjs` (node, no deps) writes `roblox/src/shared/CowHUD/Tokens.luau` (pure data, deep-frozen) and rewrites only the marked `tokens:root`, `tokens:phone` and `tokens:js` regions in `index.html`. `--check` exits 1 when either output is stale.
- `Theme.luau`, `CatalogMetrics.luau`, `Layout.luau` and `tools/test-catalog-metrics.luau` read `Tokens`. `CatalogMetrics` stays free of Roblox APIs (it requires `./Tokens` when `script` is absent).
- HTML preset keys become the Roblox names (`Mono`, `Meadow`, `Sunrise`, `Lavender`, `Sky`), including `?theme=`.
- Parity fix (decision 1): HTML presets gain the `Subtle` role (`--theme-fill-subtle` per preset) and a `Danger` role (`--theme-danger`). The trash tool uses it, as in Roblox `Building.luau`.
- Verify: `gen-tokens --check`, `verify-hud.mjs`, `test-catalog-metrics.luau`, `rojo build`; Studio theme switch (human).

## T2: `data-rbx` element mapping
- `data-rbx="Component/Name"` on each HTML element that has a Luau instance (top-level groups plus named interactive parts).
- `verify-hud.mjs` checks every `data-rbx` leaf exists as a `Name = "…"` in `Components/*.luau`.
- `UI_ELEMENTS_MAP.md` (decision 2): line-number refs are replaced by `data-rbx` / `#id` keys.

## T3: SVG → icon data generator (superseded: Build HUD is text only; generator, Icons and IconData removed)
- `data-icon="name"` on HTML SVGs; `tools/gen-icons.mjs` flattens paths and shapes into polylines and dots, and writes `IconData.luau`.
- `Icons.luau` draws from `IconData`; its public API is unchanged. Filled arbitrary polygons are out of scope and reported.
- One-off preview of generated vs hand-traced icons (scratchpad, not committed); Studio icon pass (human).

## T4: Palette check
- `tools/check-palette.mjs` reads `tokens.json`. It makes the phase-5 WCAG audit permanent (text ≥ 4.5:1 on Card/Screen/Fill, Accent ≥ 4.5:1 on Card, Border ≥ 3:1 on Card/Screen).
- Adds colour-blind simulation (protanopia, deuteranopia, tritanopia; Machado 2009, full severity). Pairs Fill/Subtle, Border/Card, Accent/Fill and Danger/Text must keep CIEDE2000 ΔE ≥ 10 after simulation.
- Failures are reported before any colour change.

## T4 results (2026-11-12): 19 failures, no colours changed yet
Normal-vision contrast passes for every preset (matches phase 5). Failures:
- Fill/Subtle ΔE below 10 in Mono (4.3), Lavender (7.2) and Sky (7.6) even with normal vision, and in Sunrise under deuteranopia (9.8) and tritanopia (6.9). This pair separates the selected and idle catalog cost chip.
- Meadow under protanopia: Border/Card 2.97:1 and Border/Screen 2.93:1 (min 3), and Danger/Text ΔE 2.7. The red trash tool and the green text look nearly the same.
- Sunrise under protanopia: Danger/Text ΔE 8.7. Under deuteranopia: Accent/Card 4.40:1 (min 4.5).

## T5: Colour fixes (approved 2026-11-12)
Smallest ΔE changes that pass every check, plus a new rule: Danger ≥ 4.5:1 on Card (the TRASH label is text).
- All presets: Danger `#dc2626` → `#be123c`.
- Mono: Fill `#d1d5db` → `#bdc3cb`, Subtle `#e5e7eb` → `#eceef1`, Text and Accent `#4b5563` → `#47505d`. The cheaper fix, Subtle `#fcfcfd`, was rejected because it is nearly the same as the white Card.
- Meadow: Border `#16a34a` → `#159f48`.
- Sunrise: Fill `#fde68a` → `#fcde67`, Accent `#b45309` → `#af5109`.
- Lavender: Fill `#e9d5ff` → `#dcbcff`. Sky: Fill `#bae6fd` → `#97d9fc`.
- Result: `tools/check-palette.mjs` passes for all 5 presets × 4 vision modes.
