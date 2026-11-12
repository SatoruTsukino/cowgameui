-- Top-right cluster: calories pill + upgrades tab, cowbell settings button, compact "•••" menu.

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local CALORIES_INSET = 52 -- (px-5 + border-6) * 2
local CALORIES_MIN_WIDTH = 120
-- Upgrades tab hugs the pill: only 20px of it shows below the calories border (HTML -mt-2 h-8, tightened).
local UPGRADES_HEIGHT = 30
local UPGRADES_TOP = 56 - 10
local UPGRADES_INSET = 40 -- (px-4 + border-4) * 2

--[[
	Cowbell button (.shape-cowbell: border-radius 35% 35% 15% 15% / 50% 50% 20% 20%, border-6, w-14 h-14) with the
	loop on top (-top-2 w-4 h-3 border-4 rounded-t-full). UICorner has no elliptical radii, so the domed top uses
	24px corners (between the CSS 19.6px × 28px ellipse axes) and the flared bottom 9px.
	Wrapped in pt-1 like the wireframe so the loop clears the top row.
]]
local function cowbell(parent: Instance, name: string, caption: string, order: number, onActivated: (GuiObject) -> ()): GuiObject
	local wrapper = Util.frame({ Name = name, Size = UDim2.fromOffset(56, 60), LayoutOrder = order, Parent = parent })
	Util.paddingEach(wrapper, 0, 4, 0, 0)
	local _, bell = Util.button({ Name = "Bell", Size = UDim2.fromOffset(56, 56), Parent = wrapper }, {
		OnActivated = onActivated,
	})
	local loop = Util.frame({
		Name = "Loop",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -4),
		Size = UDim2.fromOffset(8, 12),
		ZIndex = 1,
		Parent = bell,
	})
	Util.corner(loop, 4)
	Util.new("UIStroke", { Color = C.Border, Thickness = 4, Parent = loop })
	Util.shape({ Name = "Border", Color = C.Border, Radius = 24, Corners = { BL = 9, BR = 9 }, ZIndex = 2, Parent = bell })
	Util.shape({
		Name = "Fill",
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 1, -12),
		Color = C.Card,
		Radius = 18,
		Corners = { BL = 3, BR = 3 },
		ZIndex = 3,
		Parent = bell,
	})
	Util.label({ Text = caption, TextSize = 9, Position = UDim2.fromOffset(0, 4), Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = bell })
	return wrapper
end

return function(parent: Instance, ctx)
	local state = ctx.state

	local cluster = Util.frame({
		Name = "TopRight",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -Theme.Margin, 0, Theme.Margin),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 2,
		Parent = parent,
	})
	Util.list(cluster, Enum.FillDirection.Horizontal, 16)

	-- Economy column (flex-col items-center): pill with the upgrades tab tucked 8px underneath (-mt-2).
	-- Positioned explicitly instead of with a negative list gap so the tab always docks flush to the pill.
	local economy = Util.frame({ Name = "Economy", Size = UDim2.fromOffset(CALORIES_MIN_WIDTH, UPGRADES_TOP + UPGRADES_HEIGHT), LayoutOrder = 1, Parent = cluster })

	-- Calories pill (h-14, px-5, rounded-[1.5rem], border-6). Width is set explicitly from measured text bounds:
	-- AutomaticSize can't be used here because the scale-sized visual inside the slot feeds back into it and grows unbounded.
	local calories, caloriesVisual = Util.button({
		Name = "Calories",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(CALORIES_MIN_WIDTH, 56),
		ZIndex = 2,
		Parent = economy,
	}, {
		HoverScale = 1.05,
		OnActivated = function()
			ctx.trigger("Calories")
		end,
	})
	local _, caloriesFace = Util.box({ Size = UDim2.fromScale(1, 1), Radius = 24, Border = 6, Parent = caloriesVisual })
	local caloriesLabel = Util.label({ TextSize = 12, Size = UDim2.fromScale(1, 1), Parent = caloriesFace })

	-- Upgrades tab (h-8, rounded-b-xl, border-4 without top, gray-200)
	local upgrades, upgradesVisual = Util.button({
		Name = "Upgrades",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, UPGRADES_TOP),
		Size = UDim2.fromOffset(112, UPGRADES_HEIGHT),
		ZIndex = 1,
		Parent = economy,
	}, {
		HoverScale = 1,
		HitAlign = Vector2.new(0.5, 0), -- grow the touch area downward, away from the Calories pill
		OnActivated = function()
			ctx.trigger("Upgrades")
		end,
	})
	Util.shape({ Name = "Border", Color = C.Border, Radius = 12, Corners = { TL = 0, TR = 0 }, Parent = upgradesVisual })
	Util.shape({
		Name = "Fill",
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -8, 1, -4),
		Color = C.Subtle,
		Radius = 8,
		Corners = { TL = 0, TR = 0 },
		ZIndex = 2,
		Parent = upgradesVisual,
	})
	local upgradesLabel = Util.label({
		Text = "UPGRADES ⬆",
		TextSize = 9,
		Size = UDim2.fromScale(1, 1),
		TextYAlignment = Enum.TextYAlignment.Bottom,
		ZIndex = 3,
		Parent = upgradesVisual,
	})
	Util.paddingEach(upgradesLabel, 0, 0, 0, 6)

	-- Settings (standard) and the unified MENU (compact) share the cowbell from the wireframe.
	local standard = cowbell(cluster, "Settings", "SET", 2, function()
		ctx.trigger("Settings")
	end)
	local more = cowbell(cluster, "More", "MENU", 3, function(slot)
		ctx.toggleMenu(slot, "below", { "Settings", "Herd", "Trade" })
	end)

	state:observe("compact", function(compact)
		upgrades.Visible = not compact
		economy.Size = UDim2.fromOffset(economy.Size.X.Offset, if compact then 56 else UPGRADES_TOP + UPGRADES_HEIGHT)
		standard.Visible = not compact
		more.Visible = compact
	end)
	Util.fitWidth(upgrades, "UPGRADES ⬆", 9, UPGRADES_INSET)
	local function sizeEconomy()
		local height = if state:get("compact") then 56 else UPGRADES_TOP + UPGRADES_HEIGHT
		economy.Size = UDim2.fromOffset(math.max(calories.Size.X.Offset, upgrades.Size.X.Offset), height)
	end
	calories:GetPropertyChangedSignal("Size"):Connect(sizeEconomy)
	upgrades:GetPropertyChangedSignal("Size"):Connect(sizeEconomy)

	state:observe("calories", function(value)
		local text = "CALORIES: " .. Util.formatNumber(tonumber(value) or 0)
		caloriesLabel.Text = text
		Util.fitWidth(calories, text, 12, CALORIES_INSET, CALORIES_MIN_WIDTH)
	end)

	return cluster
end
