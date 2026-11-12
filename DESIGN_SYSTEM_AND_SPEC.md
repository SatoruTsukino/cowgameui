# Cozy Cow ScreenGui - Production Design System & Shipping Specification

> **Repository:** `cowgameui`  
> **Source Prototype:** [`index.html`](file:///Users/jsph/cowgameui/index.html)  
> **Component Index:** [`UI_ELEMENTS_MAP.md`](file:///Users/jsph/cowgameui/UI_ELEMENTS_MAP.md)  
> **Engine Target:** Roblox Engine (Luau / `ScreenGui` / `CanvasGroup`)  
> **Virtual Canvas Reference:** $720\text{p}$ Base Resolution ($H = 720\text{px}$, $W = 720 \times \text{Aspect Ratio}$)

---

## 1. Executive Summary & Design Philosophy

The Cozy Cow UI is designed to combine the charming, chunky aesthetics of cozy sandbox titles with mobile touch ergonomics and modern Roblox platform constraints.

### Key Tenets
1. **Chunky Wireframe Hierarchy**: High-contrast, friendly rounded geometry ($4-6\text{px}$ strokes, $16-40\text{px}$ corner radii) ensures instant readability across low-end mobile devices and high-DPI desktop screens.
2. **Platform Native Respect (Unibar Clearance)**: Roblox's modern top bar (Unibar) resides strictly in the top-left ($0-44\text{px}$). Rather than depressing the entire top HUD across the screen, the interface decouples top-left vitals from top-center and top-right elements, reclaiming valuable headroom.
3. **Ergonomic Arc-Based Touch Controls**: Thumb movements follow radial arcs. The mobile action cluster centers the high-frequency `Jump` anchor and places secondary actions (`Sprint`, `Moo`, `Emote`) in a natural upward swipe arc with zero hand repositioning.
4. **Resolution-Agnostic Scaling**: Layout math is anchored to a virtual 720p coordinate space scaled proportionally via root transform, preventing element clipping across 16:9, 21:9, 19.5:9, and 4:3 viewports.

---

## 2. Spatial Topology & Layout Design Choices

### A. Roblox CoreGui Unibar Accommodating Header
- **Problem**: Default Roblox CoreGui places `[Logo] [≡] [💬3]` at top-left. Dropping the whole HUD to `top-16` ($64\text{px}$) wasted vertical space across the center and right screen areas.
- **Solution**: Decoupled `#topLeftVitals` from `#topRightHud`.
  - `#topLeftVitals`: Sits at `top-8` ($32\text{px}$) normally. When CoreGui is active, dynamic spring transitions shift it down to `top-16` ($64\text{px}$).
  - `#townBulletinWrapper` & `#topRightHud`: Permanently elevated to `top-4` ($16\text{px}$) because modern Roblox has no native CoreGui in the center or top-right.
  - `#rightSidebar`: Elevated to `top-32` ($128\text{px}$), filling the upper-right quadrant and eliminating bottom-screen crowding.

### B. Concentric Leaf Quest Progress Bar Math
- **Problem**: When progress fill bars have arbitrary radii inside rounded containers, corners visually clash or leave awkward gaps.
- **Math Formula**:
  $$\text{Radius}_{inner} = \max(0, \text{Radius}_{outer} - \text{BorderThickness} - \text{Padding})$$
- **Implementation**:
  - Outer `.shape-leaf`: $B = 6\text{px}$, $P = 4\text{px}$ (`p-1`).
    - Top-Left & Bottom-Right: $R_{outer} = 2.5\text{rem} = 40\text{px}$.
      $$R_{inner} = 40\text{px} - 6\text{px} - 4\text{px} = 30\text{px} = 1.875\text{rem}$$
    - Top-Right & Bottom-Left: $R_{outer} = 0.5\text{rem} = 8\text{px}$.
      $$R_{inner} = \max(0, 8\text{px} - 6\text{px} - 4\text{px}) = 0\text{px} \text{ (True Sharp Corner)}$$
- **Result**: `.shape-leaf-inner` has concentric $30\text{px}$ smooth curves on TL/BR and pristine $0\text{px}$ sharp corners on TR/BL.

### C. Mobile Radial Action Cluster & Graze Removal
- **Graze Removal**: In-game grazing is proximity-activated or triggered via context interaction; a permanent dedicated graze button created visual clutter.
- **Centered Jump Anchor**: Centered inside a $256\text{px} \times 256\text{px}$ safe zone (`#safeZoneRight`) at $(128\text{px}, 128\text{px})$.
- **Radial Satellite Placement ($R = 92\text{px}$ from Jump Center)**:
  - Satellites enlarged from $48\text{px}$ to $56\text{px}$ (`w-14 h-14`) for effortless finger targeting.
  - **Sprint (Bottom / West, $\theta \approx 190^\circ$)**: Nearest to thumb rest position. Quickest access for simultaneous sprint + jump.
  - **Moo (Middle / North-West, $\theta = 135^\circ$)**: $45^\circ$ diagonal angle.
  - **Emote (Top / North, $\theta \approx 80^\circ$)**: Top of thumb reach arc.
- **Clearance Math**:
  - Distance from Jump: $92\text{px} - (40\text{px} + 28\text{px}) = 24\text{px}$ finger clearance.
  - Gap between Satellites: $2 \times 92 \times \sin(27.5^\circ) - 56\text{px} \approx 28.9\text{px}$ gap.
  - Prevents accidental multi-button presses.

---

## 3. UI Element Sizing & Styling Tokens

All dimensions are in virtual 720p coordinate units ($1\text{px} \to 1$ Roblox offset pixel at 720p).

### Layout Components

| Component | Dimensions ($W \times H$) | Border Stroke | Corner Radius | Position Anchor |
| :--- | :--- | :--- | :--- | :--- |
| **Cow Profile Squircle** | $88\text{px} \times 88\text{px}$ | $6\text{px}$ | $26\text{px}$ | `top-8, left-8` |
| **Rebirth Chip** | Auto $\times 26\text{px}$ | $4\text{px}$ | $12\text{px}$ (`0.75rem`) | Bottom of profile card |
| **+HERD Badge** | Auto $\times 24\text{px}$ | $4\text{px}$ | $9999\text{px}$ (Pill) | Top-right of profile card |
| **Grazing Quest Leaf** | $208\text{px} \times 32\text{px}$ | $5\text{px}$ | Asymmetric (round / $6\text{px}$) | Top vitals row |
| **Stamina / HP Pill** | $208\text{px} \times 32\text{px}$ | $5\text{px}$ | $9999\text{px}$ (Pill) | Top vitals row |
| **Town Bulletin (Full)** | $430\text{px} \times 64\text{px}$ | $6\text{px}$ | $32\text{px}$ (`2rem`) | `top-4, center` |
| **Town Bulletin (Compact)** | $96\text{px} \times 44\text{px}$ | $6\text{px}$ | $9999\text{px}$ (Pill) | `top-4, center` |
| **Calories Pill** | $160\text{px} \times 56\text{px}$ | $6\text{px}$ | $24\text{px}$ (`1.5rem`) | `top-4, right-8` |
| **Upgrades Tab** | $110\text{px} \times 32\text{px}$ | $4\text{px}$ (no top) | Bottom $12\text{px}$ | Docked under Calories |
| **Settings Cowbell** | $56\text{px} \times 56\text{px}$ | $6\text{px}$ | Bell flare ($35\%/15\%$) | Top-right standard |
| **Unified Menu (`•••`)** | $56\text{px} \times 56\text{px}$ | $6\text{px}$ | $16\text{px}$ (`1rem`) | Top-right compact |
| **Inventory Button** | $64\text{px} \times 72\text{px}$ | $6\text{px}$ | $12\text{px}$ | Left sidebar |
| **Closet Button** | $64\text{px} \times 64\text{px}$ | $6\text{px}$ | $16\text{px}$ | Left sidebar |
| **Unified Bag Button** | $64\text{px} \times 72\text{px}$ | $6\text{px}$ | $12\text{px}$ | Left compact sidebar |
| **Herd Button** | $64\text{px} \times 64\text{px}$ | $6\text{px}$ | $13\text{px}$ (Dual layer) | Right sidebar |
| **Trade Button** | $64\text{px} \times 64\text{px}$ | $6\text{px}$ | $16\text{px}$ | Right sidebar |
| **Mobile Thumbstick Pad** | $192\text{px} \times 192\text{px}$ | $4\text{px}$ dashed | $9999\text{px}$ (Circle) | `bottom-8, left-8` |
| **Mobile Action Safe Zone** | $256\text{px} \times 256\text{px}$ | $4\text{px}$ dashed | $56\text{px}$ (`3.5rem`) | `bottom-8, right-8` |
| **Mobile Jump Button** | $80\text{px} \times 80\text{px}$ | $6\text{px}$ | $9999\text{px}$ (Circle) | Center of safe zone |
| **Mobile Radial Satellites** | $56\text{px} \times 56\text{px}$ | $5\text{px}$ | $9999\text{px}$ (Circle) | $R = 92\text{px}$ from Jump |

---

## 4. Theme System & Color Palettes

The UI uses dynamic CSS custom properties mapped across all structural elements:

| Token | Default Mono | Cozy Meadow | Golden Sunrise | Lavender Dusk | Sky Pasture |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `--theme-card-bg` | `#ffffff` | `#f7fdf9` | `#fffdf5` | `#faf5ff` | `#f0f9ff` |
| `--theme-border` | `#9ca3af` | `#4ade80` | `#f59e0b` | `#c084fc` | `#38bdf8` |
| `--theme-fill-primary` | `#d1d5db` | `#86efac` | `#fde68a` | `#e9d5ff` | `#bae6fd` |
| `--theme-accent` | `#6b7280` | `#16a34a` | `#d97706` | `#9333ea` | `#0284c7` |
| `--theme-text-main` | `#6b7280` | `#166534` | `#78350f` | `#581c87` | `#075985` |
| `--theme-screen-bg` | `#f3f4f6` | `#ecfdf5` | `#fef3c7` | `#f3e8ff` | `#e0f2fe` |

---

## 5. Roblox Luau Engine Porting Guide

When implementing these wireframe elements in Roblox Studio (`rbxm` / Rojo):

### A. Root Hierarchy
```
ScreenGui (ResetOnSpawn = false, ZIndexBehavior = Sibling, IgnoreGuiInset = true)
└── RootCanvas (Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1)
    ├── UIScale (Controlled by viewport scaling script)
    ├── TopLeftVitals (Frame, AnchorPoint = Vector2.new(0, 0))
    ├── TopRightHud (Frame, AnchorPoint = Vector2.new(1, 0))
    ├── TownBulletin (Frame, AnchorPoint = Vector2.new(0.5, 0))
    ├── LeftSidebar (Frame, AnchorPoint = Vector2.new(0, 0))
    ├── RightSidebar (Frame, AnchorPoint = Vector2.new(1, 0))
    └── MobileControls (Frame, AnchorPoint = Vector2.new(0, 1))
```

### B. Proportional Scaling Math (720p Reference)
```lua
local camera = workspace.CurrentCamera
local rootCanvas = script.Parent.RootCanvas
local uiScale = rootCanvas.UIScale

local VIRTUAL_HEIGHT = 720

local function updateScale()
    local viewportSize = camera.ViewportSize
    local scale = viewportSize.Y / VIRTUAL_HEIGHT
    uiScale.Scale = scale
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
updateScale()
```

### C. Roblox Spring Animation (HUD Springs)
To match the web CSS spring (`cubic-bezier(0.34, 1.56, 0.64, 1)`):
```lua
local TweenService = game:GetService("TweenService")
local springInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function springTo(guiObject, properties)
    local tween = TweenService:Create(guiObject, springInfo, properties)
    tween:Play()
end
```

### D. Asymmetric Leaf Shape in Roblox
Since Roblox `UICorner` applies uniform radius to all four corners, the `.shape-leaf` should be constructed via:
1. **Option A (Recommended)**: 9-slice `ImageLabel` asset export from the vector prototype.
2. **Option B (Native CanvasGroup Composition)**: 2 overlapping frames with corner radii clipped inside a `CanvasGroup`.

