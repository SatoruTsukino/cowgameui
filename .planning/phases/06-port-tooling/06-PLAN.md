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

## T3: SVG → icon data generator
- `data-icon="name"` on HTML SVGs; `tools/gen-icons.mjs` flattens paths and shapes into polylines and dots, and writes `IconData.luau`.
- `Icons.luau` draws from `IconData`; its public API is unchanged. Filled arbitrary polygons are out of scope and reported.
- One-off preview of generated vs hand-traced icons (scratchpad, not committed); Studio icon pass (human).

## T4: Palette check
- `tools/check-palette.mjs` reads `tokens.json`. It makes the phase-5 WCAG audit permanent (text ≥ 4.5:1 on Card/Screen/Fill, Accent ≥ 4.5:1 on Card, Border ≥ 3:1 on Card/Screen).
- Adds colour-blind simulation (protanopia, deuteranopia, tritanopia; Machado 2009, full severity). Pairs Fill/Subtle, Border/Card, Accent/Fill and Danger/Text must keep CIEDE2000 ΔE ≥ 10 after simulation.
- Failures are reported before any colour change.
