# T10: Boost chip as a tab (Roblox parity)

**Status:** Implemented (local commit, not pushed). Also adds the `/boost [seconds]` demo command.
**Scope:** `roblox/src/shared/CowHUD/Components/Bulletin.luau` (the boost chip only) and the size table in `DESIGN_SYSTEM_AND_SPEC.md` §3. `index.html` is the reference and doesn't change.

## Reference (index.html)
```html
<div class="-mt-1.5 px-4 py-1 rounded-b-2xl rounded-t-lg border-4 border-gray-500 bg-gray-100 shadow-md flex items-center gap-2">
  <span class="w-2 h-2 rounded-full bg-gray-500"></span>
  <span class="text-[10px] ...">2x Calories • 01:30</span>
</div>
```
The chip is a tab hanging from the bulletin. Its top corners are small (8px) and its bottom corners large (16px), with a 4px darker border. It overlaps the card's bottom edge by 6px and is painted over it.

## Today (Roblox)
`Util.box` with a uniform 12px radius. On a chip about 28px tall, that reads as a rounded pill, not a tab.

## Changes
1. **Shape:** build the border and fill with `Util.shape` (per-corner radii), like the Upgrades tab and the catalog tray.
   - **Border:** `C.Accent`, base radius 16, `Corners = { TL = 8, TR = 8 }`.
   - **Fill:** inset by 4px, `C.Screen`, base radius 12, `Corners = { TL = 4, TR = 4 }`. These are the inner radii from the concentric formula in Spec §2B (outer radius minus border).
2. **Sizing:** the content stays auto-sized exactly as today. The 16/4 padding plus the 4px border, the 8px dot, the 8px gap and the 10px label all live in a `Content` frame. That keeps the legibility floor and the live timer text working.
   - The tab shape sits behind `Content`. It is sized from `Content.AbsoluteSize ÷ (HUD scale × bulletin spring scale)` whenever that changes.
   - **Why:** shapes need an explicit size, and an auto-sized parent with scale-sized children can grow but never shrink back when the label gets shorter.
3. **Position:** unchanged. The list gap stays −6 (`-mt-1.5`), and the chip stays above the card in ZIndex, so its top border is drawn over the card's bottom border as in the HTML.
4. **No drop shadow:** this is the existing known difference from the HTML.

**Alternative rejected:** a single 16px-radius box tucked behind the card is simpler, but it hides the 8px top corners that make the shape read as a tab.

## Docs
- Add a "Boost Tab" row to Spec §3: auto width × about 28px, 4px border, 8px top and 16px bottom radius, docked under the bulletin with a 6px overlap.

## Proof
- `luau-compile` on every file, and `rojo build`.
- Studio screenshots of desktop 1080p and iPhone 14 while a boost is active. In the demo, a boost lasts 90s after joining.

## Out of scope
- `index.html`, the compact bulletin pill, and the Upgrades tab.
