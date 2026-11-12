-- Bottom row: the centred Area Actions placeholder (bottom-14, w-1/3, max-w-sm).
-- The wireframe's mobile safe zones are previews of Roblox's own thumbstick and Jump, so they are not drawn here.
-- Roblox has no dashed UIStroke, so the dashed border from the wireframe is a solid stroke.

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local BOTTOM = 56 -- bottom-14

return function(parent: Instance, ctx)
	local area, areaVisual = Util.button({
		Name = "AreaActions",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -BOTTOM),
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
		BackgroundColor3 = C.Card,
		BackgroundTransparency = 0.2,
		Parent = areaVisual,
	})
	Util.corner(face, 18)
	Util.new("UIStroke", { Color = C.Border, Thickness = 6, Parent = face })
	Util.label({ Text = "AREA ACTIONS (WIP)", TextSize = 14, TextColor3 = C.Accent, Size = UDim2.fromScale(1, 1), Parent = face })
end
