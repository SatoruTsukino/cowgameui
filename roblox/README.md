# CowHUD: Roblox port of `index.html`

A working `ScreenGui` version of the V4 wireframe. It scales with resolution and aspect ratio.

## Install

### Option A: Rojo
```sh
cd roblox
rojo serve            # then press Connect in the Rojo Studio plugin
# or
rojo build -o CowHUD.rbxlx
```

### Option B: Manual (Studio)
Create these scripts and paste in each file's contents. **The names must match exactly.**

```
ReplicatedStorage
└─ CowHUD                (ModuleScript)  ← src/shared/CowHUD/init.luau
   ├─ Theme              (ModuleScript)  ← Theme.luau
   ├─ Util               (ModuleScript)  ← Util.luau
   ├─ State              (ModuleScript)  ← State.luau
   ├─ Scaler             (ModuleScript)  ← Scaler.luau
   ├─ Bindings           (ModuleScript)  ← Bindings.luau
   ├─ Layout             (ModuleScript)  ← Layout.luau
   ├─ Commands           (ModuleScript)  ← Commands.luau
   ├─ Icons              (ModuleScript)  ← Icons.luau
   └─ Components         (Folder)
      ├─ TopLeft         (ModuleScript)
      ├─ TopRight        (ModuleScript)
      ├─ Bulletin        (ModuleScript)
      ├─ Sidebars        (ModuleScript)
      ├─ Bottom          (ModuleScript)
      ├─ ActionCluster   (ModuleScript)
      ├─ Building        (ModuleScript)
      └─ Overlays        (ModuleScript)
ServerScriptService
└─ CowHUDDemo            (Script)        ← src/server/CowHUDDemo.server.luau
StarterPlayer/StarterPlayerScripts
└─ CowHUDClient          (LocalScript)   ← src/client/CowHUDClient.client.luau
```

## Scaling model
- Every element is authored in **virtual 720p pixels**, the same numbers as the Tailwind classes (`w-28` → 112).
- `Scaler` sets `scale = clamp(screenHeight / 720, minScale, 4)` on a `UIScale` and sizes the root to `screen / scale`. `minScale` is 0.75 on touch devices and 0.6 elsewhere. Height maps to about 720 virtual px (480–520 on phones, so controls render big enough to tap), and width follows the aspect ratio (16:9 → 1280, 21:9 → 1680, 4:3 → 960).
- Elements are anchored to the edges and centre, so ultrawide screens get more space in the middle instead of stretched UI.
- `ScreenInsets = DeviceSafeInsets` keeps the HUD clear of device notches. The HUD shares the top bar row with Roblox's own buttons: `Layout.luau` reads `GuiService.TopbarInset` so the top-right cluster and bulletin sit in that row next to the core buttons, and the top-left cluster (with the sidebars) moves down below the left core buttons.
- **Bulletin:** a single 56px row (☀ cycle · event bar · countdown) with the same text sizes as the wireframe. It never switches to compact on its own, because Compact Mode is only ever the player's choice. It always stays in the top row: centred when possible, otherwise slid sideways to clear the core buttons and the top-right cluster. If it ends up above the vitals, the vitals and the left sidebar move down below it.
- **Legibility floor:** labels render at no less than 12pt (11pt for captions under 12px) at any scale. On phones, text grows past its wireframe size: auto-sized boxes grow with it, and fixed boxes grow only as far as the text still fits.
- Change `Theme.Scale.TouchMinScale` (touch) or `MinScale` (desktop) if text feels too small or too large.

## Using it from game code
```lua
local hud = CowHUD.mount(player, { placeholderPanels = false }) -- false = no "Coming soon" panels
hud.ActionTriggered:Connect(function(action) --[[ open your own UI ]] end)
hud.State:set("compact", true)
```
- **Actions:** `Profile Herd Calories Upgrades Settings Inventory Closet Trade Bulletin AreaActions`, mobile `Emote Moo Sprint Kick EmoteHeart EmoteCheer EmoteSnooze`, mode `EnterBuild ExitBuild`, and building `GridSnap BuildCategory BuildItem Rotate Paint Undo Redo Trash`. Some actions also pass a second `payload` argument.
- **UI state:** `mode`, `compact`, `bulletinVisible`, `theme`, `motion`. All of them except `mode` can also be changed in-game from the **Settings** (cowbell) panel.
- **Data contract:** documented at the top of `Bindings.luau`. The server sets attributes on `Player` and `Workspace`. HP is read from the `Humanoid`.

## Build mode
- **Chat commands:** type `/build` (or `/buildmode`) to switch the HUD to the Building GUI, and `/normal` (or `/exitbuild`) to switch back. The **Exit Build** button does the same thing. The commands are created on the client by `Commands.luau`, so they only react to the local player and the text never shows in chat. They need `TextChatService`, which is the default chat for new places.
- **From code:** `hud.State:set("mode", "build")` or `hud.State:set("mode", "normal")`. Every mode change fires `ActionTriggered("EnterBuild")` or `ActionTriggered("ExitBuild")`.
- **Building GUI:** a top bar (Exit Build, a parts-limit pill, grid snap, wood and stone counters), a tool stack (ROT [R], PAINT, UNDO [Z], REDO [Y], TRASH [X]; the keys are bound only while building), and a catalog dock. The catalog dock has category tabs and a tray of slots that scrolls. Its tool actions fire through `ActionTriggered(action, payload)`. Replace the demo catalog with `CowHUD.mount(player, { catalog = { { id, label, items = { { name, cost, glyph } } } } })`.
- **Data:** the `Wood`, `Stone`, `BuildParts` and `BuildPartsMax` player attributes.

## Demo commands
- `/boost` starts a fresh 90-second "2x Calories" boost, and `/boost 30` sets the length in seconds. It's created by the demo server script, so it goes away when you replace the demo with real game systems.
- The wireframe's placement boundary and cursor are not drawn. They are world-space and belong to the game's placement system.

## Mobile action arc
- The wireframe's thumbstick and Jump are placeholders for Roblox's own touch controls, so the HUD never draws a Jump. `ActionCluster.luau` finds `PlayerGui.TouchGui.TouchControlFrame.JumpButton` and places Emote, Moo, Sprint and Kick on an arc around it, evenly spaced from 60° to 200°. The radius is half the jump size + 24 + 28.
- Each satellite's hit area grows to 44pt while the visible button stays 56px.
- **Quick emotes:** tapping Emote swaps Moo, Sprint and Kick for the three quick emotes (`EmoteHeart`, `EmoteCheer`, `EmoteSnooze`) in the same arc slots, one thumb-step from Emote, and Emote's label changes to BACK. Tapping an emote or BACK restores the arc.
- The arc shows on touch devices only and is hidden in build mode. The wireframe's safe-zone outlines are not drawn in Roblox.

## Settings
The cowbell panel has toggles for Compact Mode and World Bulletin. It also has:
- **Color Theme:** Mono, Meadow, Sunrise, Lavender or Sky (state `theme`). The palette is WCAG-checked: text is at least 4.5:1 and borders at least 3:1. Colours are role tokens (`Theme.Color.Card`, `Border`, `Text`, …), so switching presets recolours the live HUD.
- **Motion:** Full, Reduced or Off (state `motion`). It starts at Reduced when the player has Roblox's Reduced Motion setting on. Reduced removes spring overshoot and hover growth. Off makes changes instant.

## Known differences from the HTML
- Dashed borders (area actions) are solid strokes, because Roblox has no dashed `UIStroke`.
- Mobile safe zones are not drawn. They only preview Roblox's native thumbstick and Jump.
- Icons are the wireframe's SVGs traced with Frames (`Icons.luau`), because Roblox can't render SVG and Nunito has no symbol glyphs. They scale with the HUD and follow the theme.
- No drop shadows.
- The font is Nunito Heavy (`Theme.Font`). Roblox has no letter-spacing, so `tracking-widest` is dropped.
