-- Design tokens mirrored from index.html: colour presets (DESIGN_SYSTEM_AND_SPEC §4), font, scale, motion.
--
-- Colours are role tokens, not values. Pass `Theme.Color.<Role>` to any Util.new-built property and the
-- instance is tracked, so `Theme.applyPreset` recolours the live HUD. For direct assignment use `Theme.paint`.
--
-- Roles (wireframe gray it replaces):
--   Card (white)  Screen (100)  Subtle (200)  Fill (300)  Border (400)  Accent (500)  Text (600)  Danger
-- Preset values are the WCAG-checked palette from .planning/phases/05-legibility-ergonomics (T1):
-- Text ≥ 4.5:1 on Card/Screen/Fill, Accent ≥ 4.5:1 on Card, Border ≥ 3:1 on Card/Screen.

local Theme = {}

export type Token = { __token: string }

local ROLES = { "Card", "Screen", "Subtle", "Fill", "Border", "Accent", "Text", "Danger" }

Theme.PresetOrder = { "Mono", "Meadow", "Sunrise", "Lavender", "Sky" }

local function preset(card, screen, subtle, fill, border, accent, text)
	return {
		Card = Color3.fromHex(card),
		Screen = Color3.fromHex(screen),
		Subtle = Color3.fromHex(subtle),
		Fill = Color3.fromHex(fill),
		Border = Color3.fromHex(border),
		Accent = Color3.fromHex(accent),
		Text = Color3.fromHex(text),
		Danger = Color3.fromHex("#dc2626"),
	}
end

Theme.Presets = {
	Mono = preset("#ffffff", "#f3f4f6", "#e5e7eb", "#d1d5db", "#6b7280", "#4b5563", "#4b5563"),
	Meadow = preset("#f7fdf9", "#ecfdf5", "#dcfce7", "#86efac", "#16a34a", "#15803d", "#166534"),
	Sunrise = preset("#fffdf5", "#fef3c7", "#fef3c7", "#fde68a", "#c76b06", "#b45309", "#78350f"),
	Lavender = preset("#faf5ff", "#f3e8ff", "#f3e8ff", "#e9d5ff", "#a855f7", "#9333ea", "#581c87"),
	Sky = preset("#f0f9ff", "#e0f2fe", "#e0f2fe", "#bae6fd", "#0284c7", "#0369a1", "#075985"),
}

Theme.Color = {} :: { [string]: Token }
for _, role in ROLES do
	Theme.Color[role] = table.freeze({ __token = role })
end

local active = Theme.Presets.Mono
Theme.presetName = "Mono"

-- instance -> { [property] = role }; weak keys so destroyed HUD pieces are collected.
local tracked = setmetatable({}, { __mode = "k" })

function Theme.isToken(value: any): boolean
	return type(value) == "table" and value.__token ~= nil
end

function Theme.resolve(token: Token): Color3
	return active[token.__token]
end

function Theme.paint(instance: Instance, property: string, token: Token)
	local props = tracked[instance]
	if not props then
		props = {}
		tracked[instance] = props
	end
	props[property] = token.__token;
	(instance :: any)[property] = active[token.__token]
end

function Theme.applyPreset(name: string)
	local palette = Theme.Presets[name]
	if not palette or palette == active then
		return
	end
	active = palette
	Theme.presetName = name
	for instance, props in tracked do
		for property, role in props do
			(instance :: any)[property] = palette[role]
		end
	end
end

Theme.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Heavy)

-- Virtual canvas: everything is authored in 720p pixels, then scaled by viewport height.
-- MinScale keeps 9-10px labels legible on short phone screens (the virtual canvas grows instead).
Theme.Scale = {
	ReferenceHeight = 720,
	MinScale = 0.6,
	MaxScale = 4,
}

Theme.Margin = 32 -- Tailwind `top-8` / `left-8`
Theme.ClusterGap = 16 -- minimum breathing room between top clusters and the bulletin
Theme.SidebarOffset = 160 -- sidebars start this far below the top-left cluster (HTML: top-48 - top-8)
Theme.TopRowHeight = 56 -- calories pill / settings height, centred on the core topbar buttons
Theme.TopRowMinY = 12 -- closest the topbar row may sit to the screen top
Theme.MinTouchTarget = 44 -- rendered px (Apple HIG 44pt); hit areas grow to this, visuals keep spec size

--[[
	Motion modes (Settings → Motion; defaults to the player's Roblox Reduced Motion setting):
	  Full     spring overshoot from `.hud-spring` + hover grow
	  Reduced  short linear fades, no overshoot, no hover grow
	  Off      instant changes
	Components read `Theme.Tween.*` and `Theme.hoverAllowed()` at call time, so switching applies immediately.
]]
Theme.MotionOrder = { "Full", "Reduced", "Off" }
Theme.motion = "Full"

local MOTION = {
	Full = {
		-- Approximates cubic-bezier(0.34, 1.56, 0.64, 1) from `.hud-spring`.
		Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	},
	Reduced = {
		Spring = TweenInfo.new(0.12, Enum.EasingStyle.Linear),
		Fade = TweenInfo.new(0.12, Enum.EasingStyle.Linear),
		Quick = TweenInfo.new(0.1, Enum.EasingStyle.Linear),
	},
	Off = {
		Spring = TweenInfo.new(0),
		Fade = TweenInfo.new(0),
		Quick = TweenInfo.new(0),
	},
}

Theme.Tween = table.clone(MOTION.Full)

function Theme.setMotion(mode: string)
	local infos = MOTION[mode]
	if not infos then
		return
	end
	Theme.motion = mode
	for key, info in infos do
		Theme.Tween[key] = info
	end
end

function Theme.hoverAllowed(): boolean
	return Theme.motion == "Full"
end

return Theme
