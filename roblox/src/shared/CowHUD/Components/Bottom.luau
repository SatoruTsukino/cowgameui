-- Bottom row: mobile safe-zone overlays (non-interactive) and the centred Area Actions placeholder.
-- Roblox has no dashed UIStroke, so the dashed borders from the wireframe are solid strokes here.

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local ZONE_BORDER = 4

-- UIStroke draws outside the frame, so shrink by the stroke width to keep the CSS outer size.
local function safeZone(parent: Instance, name: string, anchorX: number, size: Vector2, radius: number | string, text: string)
	local offsetX = if anchorX == 0 then Theme.Margin + ZONE_BORDER else -(Theme.Margin + ZONE_BORDER)
	local zone = Util.frame({
		Name = name,
		AnchorPoint = Vector2.new(anchorX, 1),
		Position = UDim2.new(anchorX, offsetX, 1, -(Theme.Margin + ZONE_BORDER)),
		Size = UDim2.fromOffset(size.X - ZONE_BORDER * 2, size.Y - ZONE_BORDER * 2),
		BackgroundColor3 = C.Gray300,
		BackgroundTransparency = 0.7,
		Parent = parent,
	})
	Util.corner(zone, radius)
	Util.new("UIStroke", { Color = C.Gray400, Thickness = ZONE_BORDER, Parent = zone })
	Util.label({ Text = text, TextSize = 10, Size = UDim2.fromScale(1, 1), Parent = zone })
	return zone
end

return function(parent: Instance, ctx)
	local state = ctx.state

	local leftZone = safeZone(parent, "SafeZoneLeft", 0, Vector2.new(192, 192), "full", "THUMBSTICK")
	local rightZone = safeZone(parent, "SafeZoneRight", 1, Vector2.new(224, 192), 40 - ZONE_BORDER, "JUMP / INTERACT")

	-- Area actions: w-1/3 max-w-sm, bottom-8, centred
	local area, areaVisual = Util.button({
		Name = "AreaActions",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -Theme.Margin),
		Size = UDim2.new(1 / 3, 0, 0, 56),
		ZIndex = 1,
		Parent = parent,
	}, {
		HoverScale = 1.05,
		OnActivated = function()
			ctx.trigger("AreaActions")
		end,
	})
	Util.new("UISizeConstraint", { MaxSize = Vector2.new(384, math.huge), Parent = area })
	local face = Util.frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -12, 1, -12),
		BackgroundColor3 = C.White,
		BackgroundTransparency = 0.2,
		Parent = areaVisual,
	})
	Util.corner(face, 18)
	Util.new("UIStroke", { Color = C.Gray400, Thickness = 6, Parent = face })
	Util.label({ Text = "AREA ACTIONS (WIP)", TextSize = 14, Size = UDim2.fromScale(1, 1), Parent = face })

	state:observe("safeZones", function(visible)
		leftZone.Visible = visible
		rightZone.Visible = visible
	end)
end
