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
   └─ Components         (Folder)
      ├─ TopLeft         (ModuleScript)
      ├─ TopRight        (ModuleScript)
      ├─ Bulletin        (ModuleScript)
      ├─ Sidebars        (ModuleScript)
      ├─ Bottom          (ModuleScript)
      └─ Overlays        (ModuleScript)
ServerScriptService
└─ CowHUDDemo            (Script)        ← src/server/CowHUDDemo.server.luau
StarterPlayer/StarterPlayerScripts
└─ CowHUDClient          (LocalScript)   ← src/client/CowHUDClient.client.luau
```

## Scaling model
- Every element is authored in **virtual 720p pixels**, the same numbers as the Tailwind classes (`w-28` → 112).
- `Scaler` sets `scale = clamp(screenHeight / 720, 0.6, 4)` on a `UIScale` and sizes the root to `screen / scale`. Height always maps to about 720 virtual px, and width follows the aspect ratio (16:9 → 1280, 21:9 → 1680, 4:3 → 960).
- Elements are anchored to the edges and centre, so ultrawide screens get more space in the middle instead of stretched UI.
- `ScreenInsets = DeviceSafeInsets` keeps the HUD clear of device notches. The HUD shares the top bar row with Roblox's own buttons: `Layout.luau` reads `GuiService.TopbarInset` so the top-right cluster and bulletin sit in that row next to the core buttons, and the top-left cluster (with the sidebars) moves down below the left core buttons.
- **Aspect guard:** if the full bulletin would overlap the corner clusters (for example on 4:3), it collapses to the compact pill on its own.
- Change `Theme.Scale.MinScale` if phone text feels too small or too large.

## Using it from game code
```lua
local hud = CowHUD.mount(player, { placeholderPanels = false }) -- false = no "Coming soon" panels
hud.ActionTriggered:Connect(function(action) --[[ open your own UI ]] end)
hud.State:set("compact", true)
```
- **Actions:** `Profile Herd Calories Upgrades Settings Inventory Closet Trade Bulletin AreaActions`
- **UI state:** `compact`, `bulletinVisible`, `safeZones`. All three can also be toggled in-game from the **Settings** (cowbell) panel.
- **Data contract:** documented at the top of `Bindings.luau`. The server sets attributes on `Player` and `Workspace`. HP is read from the `Humanoid`.

## Known differences from the HTML
- Dashed borders (safe zones, area actions) are solid strokes, because Roblox has no dashed `UIStroke`.
- No drop shadows.
- The font is Nunito Heavy (`Theme.Font`). Roblox has no letter-spacing, so `tracking-widest` is dropped.
