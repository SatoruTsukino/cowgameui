# T11: Catalog deck scales with resolution and aspect ratio (Roblox)

**Status:** Implemented: T11 in Roblox and in the `index.html` preview, plus T11b (tab peek). Local commit, not pushed.
**Scope:** `roblox/src/shared/CowHUD/Components/Building.luau` (catalog dock only), `roblox/src/shared/CowHUD/Layout.luau` (one call), and one new pure module `roblox/src/shared/CowHUD/CatalogMetrics.luau`. `index.html` is the reference and doesn't change.

## Problem (Studio screenshots, 2026-11-12)
| Device | Virtual canvas | Deck height incl. `bottom-6` | Share of screen height |
|---|---|---|---|
| iPhone 14 landscape (844×390) | 1125×520 (scale 0.75) | 57 − 5 + 166 + 24 = **242** | **47%** |
| iPad (1180×820) | 1036×720 | 47 − 5 + 150 + 24 = 216 | 30% |
| 1080p desktop | 1280×720 | 216 | 30% |

On phones the deck reaches almost to the middle of the screen. Two things cause it:
- **Phone sizes:** the T5 "grow boxes on phones" sizes (slot 120×128, two-line tab labels at 36px) keep the text at 11pt but stack vertically.
- **Fixed rule:** the deck is one fixed design chosen once at mount (`Theme.phone`). It never looks at how much room the screen actually has.

`index.html` renders the same 19.5:9 deck at about 37% of the canvas, so matching the wireframe 1:1 doesn't fix it. The fix is to make the Roblox deck respond to the available height, while keeping the wireframe's look and the legibility floor.

## Approach: height budget, two deck densities
1. **Budget.** The deck, including its bottom margin, may use at most `DECK_BUDGET = 0.35` of the virtual canvas height. Desktop and iPad use 30% in Roblox and 33% in the HTML, so they stay Full; phones use 47–51%, so they go Compact. (The preview showed 0.30 would flip the HTML desktop deck to Compact.)
2. **Choosing a density.** Each `Layout.apply()` runs on resize, scale change and topbar change. It computes the full deck's height for the current text scale. If that height is over budget, it switches the deck to **Compact**; otherwise the deck stays **Full**. Rotating a device or resizing the Studio emulator switches density live, with no rejoin.
3. **Full** is the deck as it is today: wireframe sizes and phone growth for two-line labels.
4. **Compact** keeps the wireframe's visual language (the same tray shape, tab shape, colours and name/icon/cost order) but trades height for width:

   | Part | Full (today) | Compact |
   |---|---|---|
   | Tab labels | 2 lines, 5 tabs share the width (Flex Fill) | 1 line; each tab is as wide as its label (`Util.fitWidth`); the strip scrolls sideways if all five don't fit and is centred when they do |
   | Active tab | 5 + 8 + lines + 8 | 5 + 6 + 18 + 6 = **35** |
   | Slot | 96×112 (120×128 on phones), name on 2 lines | name on 1 line; each slot is as wide as its name (min 112, `Util.fitWidth`) × **98** tall |
   | Slot icon box | 48×40, glyph 24 | 40×32, glyph 20 |
   | Tray padding (py) | 14 (`py-3.5`) | 8 |
   | Bottom margin | 24 (`bottom-6`) | 12 |

   Compact on iPhone 14 is 35 − 5 + (98 + 16 + 10) + 12 = **166**, which is **32%** of the screen instead of 47%. That is about 57pt less height. Text still renders at 11pt or more, because sizes come from `Util.textSize`, as they do everywhere else.
5. **Width** keeps today's rules:
   - `max-w-[680px]`;
   - side clearance of 256 on touch screens for the native thumbstick and Jump button, or `Theme.Margin` on other screens;
   - slots scroll inside the tray.
6. **Sizes are computed, not hard-coded per device.** A pure function, `CatalogMetrics.deck(virtualSize, textSize, compact)`, returns tab, slot, tray and margin sizes.
   - It has no Roblox dependencies, so a plain `luau` script can test it.
   - `Building.luau` reads it when it builds tabs and slots and again when the density changes. Slots are already rebuilt on every category change, so a density change reuses that path.
   - The Full deck uses the same numbers as today's `Theme.size` values (`SlotWidth`/`SlotHeight`/`SlotName`/`TabLines`), so the Full deck doesn't change.

## Catalog tab "peek" parity (T11b) — approved, implemented
Your uncommitted `index.html` adds `.catalog-tab` peek-and-pop. Inactive tabs sit 5px lower, tucked behind the tray's top border; the active tab sits on top. On hover a tab lifts 2px.
- **Port to Roblox:** inactive tabs drop 5px behind the tray.
- **Hover:** the 2px lift happens only when `Theme.hoverAllowed()` (motion Full) and never on touch.
- **Effect on height:** none.

## Not changing
- Tool column, top bar, `index.html`, the Full deck's look, and the touch clearance width.
- The docs: `DESIGN_SYSTEM_AND_SPEC.md` and `README.md` have your uncommitted edits, so I won't touch them. After this lands I can add a "Catalog deck — Compact" row to Spec §3 if you want.

## Verification
1. `luau-compile` on every changed file, and `rojo build`.
2. Run `luau` on a scratch test of `CatalogMetrics` across this matrix:
   - 1080p, 1440p, ultrawide 3440×1440, iPad 1180×820, iPad mini 1133×744, 4:3 1024×768, iPhone 14 844×390, iPhone SE 667×375, and a short desktop window 1280×420.
   - For each, it asserts that the deck height is within the 35% budget, the width fits the available width, and every label's text size reaches the floor (12/11pt rendered).
   - It prints a table of results.
3. **Studio (you):** screenshots in build mode on iPhone 14, iPad and 1080p. On iPhone 14 the deck should be compact and around a third of the height or less; on iPad and 1080p it should be unchanged. Switch tabs and scroll the slots. Resize the emulator once to see the density switch live.
4. The work goes into one local commit, and I won't push until you've reviewed it.

## Preview results (index.html, 2026-11-12)
| Preset | Density | Deck height / canvas |
|---|---|---|
| 16:9, 21:9, 4:3 | Full | 235 / 720 (33%) |
| 19.5:9 phone, before (`?deck=full`) | Full | 51% |
| 19.5:9 phone, after | Compact | 169 / 520 (33%) |

`node tools/verify-hud.mjs` passes on all 8 checks (4 presets × 2 pages), so no overlaps and every label reaches the text floor.

The T11b label fix is in both versions. An inactive tab's bottom 10px sits behind the tray, so its label is centred in the visible part instead of losing the bottom of the second line, which happened in the first peek version.

## Roblox results (`luau tools/test-catalog-metrics.luau`)
| Device | Deck | Height / canvas |
|---|---|---|
| 1080p, 1440p, 3440×1440 | Full | 216 / 720 (30%) |
| iPad 1180×820 | Full | 218 / 720 (30%) |
| iPad mini, 4:3 1024×768 | Full | 224 / 720 (31%) |
| iPhone 14 | Compact | 168 / 520 (32%), down from 242 (47%) |
| iPhone SE | Compact | 168 / 500 (34%) |
| 1280×420 window | Compact | 183 / 700 (26%) |

`Theme.size` no longer has `SlotWidth`/`SlotHeight`/`SlotName`/`TabLines`. `CatalogMetrics` now works out those sizes from the rendered text, so the Full deck is identical on 1080p and phones. Where the legibility floor raises the text to 10px (iPad, iPad mini, 4:3), the slot widens from 96 to 100.
