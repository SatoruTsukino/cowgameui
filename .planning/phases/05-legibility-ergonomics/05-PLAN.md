# Phase 5: Legibility, accessibility and ergonomics pass

**Status:** Planned, waiting for review. No code changes until this plan is approved.
**Scope:** `index.html` (reference prototype) and `roblox/src/shared/CowHUD` (shipping port). The two must stay in step (PROJECT R1/R2).

## Goal
Every button, label, menu and panel is readable and easy to tap at every supported aspect ratio and resolution, and sits where a hand (touch) or the eye (desktop) expects it.

## Design constraints (from `DESIGN_SYSTEM_AND_SPEC.md` + `UI_ELEMENTS_MAP.md`)
Every change in this phase must keep these. If a fix would break one, it's flagged here rather than worked around.
- **C1 Chunky wireframe hierarchy** (Spec §1.1): keep the 4–6px strokes and 16–40px radii. Legibility fixes grow invisible hit areas and padding, not the art. Concentric radius maths (Spec §2B) holds after any resize.
- **C2 Unibar clearance** (Spec §1.2, §2A): only `#topLeftVitals` moves for CoreGui (top-8 → top-16). The bulletin and top-right stay at top-4. Phone profiles must not push the top-centre or top-right down.
- **C3 Radial arc thumb controls** (Spec §1.3, §2C; Map §4F): Jump stays centred in `#safeZoneRight`, with satellites on R=92 at fixed angles: Sprint 190°, Moo 135°, Emote 80°, Kick 235°, plus the Emote flyout mini-arc. Profiles scale the cluster as one unit and never rearrange it.
- **C4 Virtual 720p canvas** (Spec §1.4, §5B; PROJECT R2): anchor to edges and the centre, so wider screens gain space and nothing stretches. Profiles change the scale clamp and layout, not the coordinate model.
- **C5 Global safe zones overlay both pages** (Map §4F): the Pasture and Building GUIs both have to clear them. The Building utility stack stays "strictly above the right safe zone", and the catalog dock stays "centred strictly between the mobile safe zones" (Map §5).
- **C6 Theme tokens** (Spec §4): contrast fixes edit the token values per preset and never hardcode colours in components.
- **C7 Spring motion** (Spec §5C): the existing `hud-spring` and `Back` easing stay. Add a reduced-motion option (accessibility) that swaps them for a linear fade.

## Audit findings (current state)

### F1. Text is too small on phones
- In the HTML, text sizes are used this often: `text-[7px]` ×5, `text-[8px]` ×7, `text-[9px]` ×29, `text-[10px]` ×17, `text-[11px]` ×14, `text-xs` (12px) ×22.
- The Roblox port uses TextSize 9 (×5), 10 (×9), 12 (×7) and 14 (×5).
- Rendered size = virtual size × scale. On an iPhone 14 in landscape (390pt tall), scale is 0.54, clamped up to `MinScale = 0.6`. That makes 9px text render at **5.4pt** and 7px text at **4.2pt**. Apple's HIG minimum is 11pt, and around 12pt is comfortable for game HUDs.
- The HTML `resizeUI()` has **no clamp at all**, so the prototype draws text even smaller than the port.

### F2. Touch targets are below the minimum on phones
- The minimum is 44pt (Apple HIG) or 48dp (Material).
- At scale 0.6: the 56px satellites, cowbell and `•••` render at 33.6pt ❌. The 64px sidebar buttons render at 38.4pt ❌. Only the 80px Jump (48pt) passes.
- Small inline controls (the 24px HERD badge, the 26px rebirth chip, the 32px upgrades tab) render at about 14–19pt ❌.

### F3. The layout cannot fit when we scale up for phones
- To pass the 44pt floor, phones need a scale of about 0.79. That leaves a virtual canvas only about **494px tall**.
- The right sidebar starts at y=128. The bottom safe zone takes 256 + 32 = 288px. Together they leave about 78px, so the stacked herd and trade buttons (64px each plus a gap) collide with the action cluster.
- Raising `MinScale` alone is therefore not enough. Short screens need their own layout profile.

### F3b. The Building page and the radial cluster also break on phones
- **Utility stack:** 5 buttons (ROT, PAINT, UNDO, REDO, TRASH) starting at top-20 (80) need about 80 + 5×66 = 410px. On a 494px canvas, the space above the right safe zone is only about 206px. This breaks C5.
- **Catalog dock:** the room between the safe zones on a phone is about 1068 − (224 + 288) = 556px, which is narrower than the dock's `max-w-[680px]`. This breaks C5.
- **Kick vs Sprint:** they are 45° apart, so the chord is 2·92·sin(22.5°) = 70.4px. That leaves a 14.4px visual gap, which is tighter than the spec's 28.9px. A 44pt hit area at scale 0.6 is a 73px virtual diameter, so the hit areas **overlap by about 2.6px**. The spec's §2C gap maths was written before Kick existed and is out of date.
- **Other satellite pairs:** Sprint/Moo (55°) and Moo/Emote (55°) still have about 12px of hit clearance at 73px, which is OK. Jump to satellite: 92 − (40 + 36.5) = 15.5px, which is OK.

### F4. Contrast (to verify with a calculator in T1)
- The Default Mono `--theme-text-main #6b7280` on the `#f3f4f6` screen background is about 4.4:1, which is just under WCAG AA (4.5:1) for small text.
- The accent `#6b7280` on the fill `#d1d5db` is about 3.3:1, which fails for text.
- The other four presets still need checking.

### F5. Ergonomic placement
- Primary touch actions (Jump, Sprint, Moo, Emote) already sit in the bottom-right thumb arc ✅.
- Sidebar buttons (INV, closet, BAG, herd, trade) sit mid-height at the screen edges. That spot is fine on landscape phones, but it is a stretch for thumbs on 4:3 tablets, which are held lower.
- On 21:9, the top-centre bulletin and the edge clusters sit far apart. That is acceptable, but the HUD should stay inside a maximum content width so the eye doesn't travel to the bezel.
- The cowbell (settings) and `•••` sit in the top-right, which is fine because they are low-frequency.

## Approach

1. **Device profiles instead of a single scale.** Pick a profile from the viewport, never from the user agent:
   | Profile | Trigger (virtual canvas at the profile's scale) | Behaviour |
   | :-- | :-- | :-- |
   | `desktop` | mouse/keyboard input, height ≥ 600pt | current layout, scale = H/720 |
   | `tablet` | touch input, aspect ≤ 1.6 | current layout, sidebars moved lower into the thumb band |
   | `phone` | touch input, height < 600pt | scale floor raised to meet 44pt targets; compact mode on by default; safe zones resized; sidebars become a single column above the thumbstick zone |
   - Roblox: decide touch vs desktop with `UserInputService.TouchEnabled` and `PreferredInput`. The HTML gets a preview dropdown, next to the existing aspect selector, to force a profile.
2. **Type scale tokens.** Replace the 8 ad-hoc sizes with 4 tokens: `caption 11`, `label 12`, `body 14`, `title 18` (virtual px), and enforce a **minimum rendered size of 11pt**: `TextSize = max(token, 11 / scale)`. This lives in one helper (`Theme.text(token)` / a CSS `clamp` var), not in each component.
3. **Hit-area tokens.** Each interactive element gets an invisible hit frame of at least 44pt rendered (`max(visual, 44 / scale)`). The visual size can stay chunky-small. Badges and chips that act as buttons get padding, not bigger art.
4. **Contrast-checked themes.** Darken `text-main` and `accent` wherever a preset fails AA 4.5:1 for text, or 3:1 for UI borders and icons.
5. **Max content width.** Cap the HUD at 21:9 equivalent (virtual width ≤ 1680). Beyond that, centre it with gutters.

## Tasks

| ID | Task | Files | Done when |
| :-- | :-- | :-- | :-- |
| T1 | Contrast audit script: compute ratios for all 5 presets × (text/bg, text/fill, border/bg) | scratch script → results table in this doc | table filled in; failing pairs listed |
| T2 | Type tokens + min-rendered-size helper | `Theme.luau`, `Util.luau`; `index.html` `:root` vars + `resizeUI` | no raw `TextSize =` or `text-[Npx]` left outside tokens |
| T3 | Hit-area helper wrapping `Util.button`; HTML `.hit` pseudo-element | `Util.luau`, `index.html` | every interactive element ≥ 44pt rendered at scale 0.6–0.8 |
| T4 | Profile detection + `Layout` per profile; HTML profile selector and scale clamp parity | `Scaler.luau`, `Layout.luau`, `init.luau`, `index.html` | profile switches live on resize/input change |
| T5 | Phone layout: compact on by default, sidebar column, resized safe zones; no overlaps at a 494px virtual height | `Sidebars.luau`, `Bottom.luau`, `TopLeft.luau`, `index.html` | overlap check passes (T7) |
| T5b | Building page phone layout: utility stack becomes a 2-column grid or a horizontal row above the right safe zone; catalog dock width = `min(680, gap between safe zones − 16)` with a scrolling tray | `index.html` (`#pageBuilding`); Roblox only if the Building GUI is ported | no overlap with the safe zones at a 494px height (C5) |
| T5c | Radial arc fix for Kick: change the angle (e.g. Kick 245°, Sprint 185°) or make the hit areas wedge-shaped; update Spec §2C gap maths for 4 satellites | `index.html`, `Bottom.luau`, `DESIGN_SYSTEM_AND_SPEC.md` | all satellite hit areas are ≥ 8px apart at scale 0.6 (C3) |
| T5d | Reduced-motion toggle in Settings | `index.html`, `Overlays.luau`, `Theme.luau` | springs become linear fades when it is on (C7) |
| T6 | Tablet thumb band: sidebars anchored to the lower 60% | `Layout.luau`, `index.html` | visual check on 4:3 |
| T7 | Overlap/size verification: script that iterates a device matrix and asserts no rect overlaps, text ≥ 11pt, targets ≥ 44pt | HTML: headless check via the `?profile=` URL param; Roblox: Studio command-bar snippet | passes for the whole matrix |
| T8 | Theme contrast fixes from T1 | `Theme.luau`, `index.html`, `DESIGN_SYSTEM_AND_SPEC.md` §4 | all pairs pass AA |
| T9 | Docs: update the spec tables and `UI_ELEMENTS_MAP.md` | docs | sizes in the docs match the code |

**Order:** T0a → T0b → T0c → T0d → T1 ✅ → T2 → T3 → T4 → T5 / T5b / T5c / T6 (in parallel) → T5d → T8 → T7 → T9.

## Device matrix (verification)
| Device | Viewport (pt) | Aspect | Profile |
| :-- | :-- | :-- | :-- |
| 1080p desktop | 1920×1080 | 16:9 | desktop |
| 1440p ultrawide | 3440×1440 | 21:9 | desktop |
| 768p laptop | 1366×768 | 16:9 | desktop |
| iPhone SE (landscape) | 667×375 | 16:9 | phone |
| iPhone 14 (landscape) | 844×390 | 19.5:9 | phone |
| Android mid-range | 800×360 | 20:9 | phone |
| iPad 10th gen | 1180×820 | ~1.44 | tablet |
| iPad mini | 1133×744 | ~1.52 | tablet |

## Decisions (2026-11-11 review)
| # | Decision | Effect on the plan |
| :-- | :-- | :-- |
| D1 | Compact mode on phones is **off by default** (the player can turn it on) | T5 must fit the **non-compact** layout at a 494px virtual height: INV, closet, herd and trade all visible without overlap. |
| D2 | Text floor: **12pt rendered for labels and buttons, 11pt for captions only** (badges, timers, chip subtext) | This follows Spec §1.1, "instant readability across low-end mobile". The extra room is found by T5 removing duplicated labels, not by shrinking the art. |
| D3 | **Grow only the invisible hit areas.** Visible art stays at spec size | Follows C1. Hit size = `max(visual, 44pt / scale)`. Neighbouring hit areas are clipped at the midpoint between them so they never overlap. |
| D4 | **Move the satellite angles** for Kick | T5c updates Spec §2C. |
| D5 | **Port the Building GUI** to Roblox | New task T0c. |
| D6 | **Change the preset colours** | T8 uses the T1 palette below. |
| D7 | **Apply the design philosophy to Roblox** wherever it's missing | New tasks T0a–T0d (parity), which run before the legibility work. |

## Roblox parity gaps (D7 audit)
| Spec item | Roblox today | Gap |
| :-- | :-- | :-- |
| C2 Unibar clearance | `Layout.luau` uses `GuiService.TopbarInset` and only the top-left drops | ✅ already done, and more precise than the HTML |
| C3 Radial arc cluster | `Bottom.luau` draws placeholder safe zones only. The right zone is 224×192 with a "JUMP / INTERACT" label, and the HTML has 256×256 | ❌ no Jump, Sprint, Moo, Emote, Kick or Emote flyout |
| C5 Building GUI | not present | ❌ |
| C6 Theme presets | `Theme.Color` is the grey scale only, with no presets and no tokens | ❌ |
| C7 Reduced motion | not present | ❌ (new in this phase for both builds) |
| §3 sizing tokens | text sizes are hardcoded (9/10/12/14/18/20) in each component | replaced by T2 |

New tasks (these come first in the order):
| ID | Task | Files |
| :-- | :-- | :-- |
| T0a | Theme tokens and the 5 presets in Roblox (`cardBg`, `border`, `fill`, `accent`, `text`, `screenBg`), with a live `Theme.apply(preset)` and a preset picker in Settings | `Theme.luau`, all components (swap `Gray*` for the tokens), `Overlays.luau` |
| T0b | Radial action cluster in Roblox: a 256×256 right zone, an 80px Jump, 56px satellites on R=92, and the Emote flyout. Hide the default `TouchGui` jump button so it isn't duplicated | new `Components/ActionCluster.luau`, `Bottom.luau`, `Bindings.luau` |
| T0c | Building GUI port: top bar, utility stack, catalog dock, placement cursor (a placeholder), and the page switch | new `Components/Building/*.luau`, `init.luau`, `State.luau` |
| T0d | Settings: reduced-motion and theme toggles, shared with T5d | `Overlays.luau` |

## T1 results — contrast (WCAG 2.2: text 4.5:1, UI borders and icons 3:1)
Script: `/private/tmp/claude-501/-Users-jsph-cowgameui/c1988756-da6d-412a-b925-2ec339f0899e/scratchpad/contrast.py`

**Current:**
| Preset | text/card | text/screen | text/fill | accent/card | accent/fill | border/card | border/screen |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| mono | 4.83 | 4.39 ❌ | 3.28 ❌ | 4.83 | 3.28 | 2.54 ❌ | 2.31 ❌ |
| meadow | 6.92 | 6.77 | 5.08 | 3.20 ❌ | 2.35 ❌ | 1.69 ❌ | 1.65 ❌ |
| sunrise | 8.91 | 8.15 | 7.28 | 3.13 ❌ | 2.56 ❌ | 2.11 ❌ | 1.93 ❌ |
| lavender | 10.14 | 9.22 | 7.99 | 5.02 | 3.95 | 2.46 ❌ | 2.24 ❌ |
| sky | 7.09 | 6.59 | 5.70 | 3.84 ❌ | 3.09 | 2.01 ❌ | 1.87 ❌ |

**Proposed changes for T8 (one Tailwind step darker; hue unchanged):**
| Preset | text | accent | border |
| :-- | :-- | :-- | :-- |
| mono | `#6b7280` → `#4b5563` | `#6b7280` → `#4b5563` | `#9ca3af` → `#6b7280` |
| meadow | — | `#16a34a` → `#15803d` | `#4ade80` → `#16a34a` |
| sunrise | — | `#d97706` → `#b45309` | `#f59e0b` → `#c76b06` (custom) |
| lavender | — | — | `#c084fc` → `#a855f7` |
| sky | — | `#0284c7` → `#0369a1` | `#38bdf8` → `#0284c7` |

**After the changes, every pair passes.** The lowest results are border/screen at 3.13 (meadow) and 3.41 (sunrise), and accent/fill at 3.57 (meadow).

**Look-and-feel cost:** borders get noticeably darker, especially Mono (from light grey to mid grey). The wireframe reads more "inked", but the chunky 4–6px strokes are kept. Dashed safe-zone outlines are decorative and stay as they are (they are exempt from 1.4.11).

## Parity review (2026-11-11), applied to T0
- **Jump and thumbstick** in the HTML are placeholders for Roblox's native touch controls. Roblox only adds the action arc (Emote, Moo, Sprint, Kick, plus the flyout) around the native JumpButton. The arc angles are spread evenly from 60° to 200°. That keeps 44pt hit areas ≥ 8.4px apart on 360–390px-tall phones, and the arc on screen from 360px to 1440px tall (scratch test `run.luau`).
- **Unibar clearance** needs no new work; the Building top bar reuses `Layout`.
- Added Roblox chat commands `/build` and `/normal`.
- Added reduced-motion options: Full, Reduced and Off, defaulting from `GuiService.ReducedMotionEnabled`.
- **Colour presets** live in Settings and use the T1 palette. That means T8 is done for Roblox; the HTML still needs it.
- **T5b (partly done):** the Building tools wrap into columns above the right safe zone, and the catalog dock is `min(680, width − 2·304)` with a tray that scrolls.

## Studio review round 1 (2026-11-11)
- **Themes:** the theme registry held Instances in a weak table, and Roblox can collect an Instance's Lua wrapper while the Instance is still alive. The registry is now strong, and entries are removed on `Destroying`.
- **Herd and Trade** now sit at `rowY + 112` (HTML top-32 vs top-4), independent of the top-left cluster.
- **Calories and Upgrades:** the tab is positioned explicitly, 8px under the pill, and both widths are measured from their text.
- **Compact is never forced (D1 hardened):** `bulletinCrowded` is removed. When the bulletin doesn't fit, it moves below the clusters at full size. This replaces PROJECT R5.
- **Mobile safe zones** are removed from Roblox (the setting and the outlines).
- **Touch scale floor** is now 0.75: phones get a 480–520px virtual canvas, and 56px controls render at 42pt or more. The arc check passes with tap areas at least 14.6px apart.
- **Quick emotes** reuse the Moo, Sprint and Kick arc slots while open.
- **Building GUI** is rebuilt. Button widths are measured from text (`AutomaticSize` inside spring buttons grew without limit), tabs share the tray width with two-line labels, and the 6-slot fences catalog matches the HTML.

## Original open questions (answered in D1–D6)
1. **Phone compact default:** should compact mode be forced on phones (merged BAG / `•••`), or only defaulted so players can turn it off?
2. **Minimum text size:** is an 11pt floor OK? Going to 12pt is more comfortable but costs more layout room.
3. **Visual vs hit size:** keep the chunky look by growing only the invisible hit areas (recommended), or grow the visible buttons too?
4. **Kick placement (T5c):** move the satellite angles (this changes Spec §2C), or keep the angles and clip the hit areas into wedges?
5. **Building GUI in Roblox:** it isn't ported yet. Should this phase cover it only in the HTML, or port it too?
6. **Theme colour changes:** may T8 change preset colours (mainly the Default Mono greys), or should failing pairs only get a text outline or shadow?

## Risks
- Roblox `AbsoluteSize` on mobile is in DPI-independent points. Verify this in the Studio emulator during T4, because the 44pt maths depends on it.
- An 11pt text floor at scale 0.6 means a virtual size of 18px. Long labels (bulletin, panels) may truncate, so T7 must also check `TextFits`.
- Phase 4 (the Studio verification) is still open. This phase adds to that human checklist rather than replacing it.

## Process
- Work on branch `phase-5-legibility`. One commit per task, nothing pushed. Wait for review after T1 (the numbers) and again before any push.
