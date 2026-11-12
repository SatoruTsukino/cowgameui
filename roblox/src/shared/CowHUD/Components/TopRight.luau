-- Top-right cluster: calories pill + upgrades tab, cowbell settings button, compact "•••" menu.

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local CALORIES_INSET = 52 -- (px-5 + border-6) * 2
local CALORIES_MIN_WIDTH = 120
local UPGRADES_TOP = 56 - 8 -- h-14 pill, -mt-2 tab
local UPGRADES_INSET = 40 -- (px-4 + border-4) * 2

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
	local economy = Util.frame({ Name = "Economy", Size = UDim2.fromOffset(CALORIES_MIN_WIDTH, UPGRADES_TOP + 32), LayoutOrder = 1, Parent = cluster })

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
		Size = UDim2.fromOffset(112, 32),
		ZIndex = 1,
		Parent = economy,
	}, {
		HoverScale = 1,
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
	Util.paddingEach(upgradesLabel, 0, 0, 0, 8)

	-- Settings: downward-flared cowbell with a loop on top (pt-1 wrapper).
	local standard = Util.frame({ Name = "Standard", AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 2, Parent = cluster })
	Util.paddingEach(standard, 0, 4, 0, 0)
	local _, bell = Util.button({ Name = "Settings", Size = UDim2.fromOffset(56, 56), Parent = standard }, {
		OnActivated = function()
			ctx.trigger("Settings")
		end,
	})
	local loop = Util.frame({
		Name = "Loop",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -4),
		Size = UDim2.fromOffset(8, 10),
		ZIndex = 1,
		Parent = bell,
	})
	Util.corner(loop, 4)
	Util.new("UIStroke", { Color = C.Border, Thickness = 4, Parent = loop })
	Util.shape({ Name = "Border", Color = C.Border, Radius = 22, Corners = { BL = 9, BR = 9 }, ZIndex = 2, Parent = bell })
	Util.shape({
		Name = "Fill",
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 1, -12),
		Color = C.Card,
		Radius = 16,
		Corners = { BL = 3, BR = 3 },
		ZIndex = 3,
		Parent = bell,
	})
	Util.label({ Text = "SET", TextSize = 9, Position = UDim2.fromOffset(0, 4), Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = bell })

	-- Compact: unified menu (Settings + Herd + Trade)
	local more = Util.iconButton({
		Name = "More",
		Size = UDim2.fromOffset(56, 56),
		Radius = 16,
		Text = "•••",
		TextSize = 14,
		TextColor3 = C.Text,
		LayoutOrder = 3,
		Parent = cluster,
		OnActivated = function(slot)
			ctx.toggleMenu(slot, "below", { "Settings", "Herd", "Trade" })
		end,
	})

	state:observe("compact", function(compact)
		upgrades.Visible = not compact
		economy.Size = UDim2.fromOffset(economy.Size.X.Offset, if compact then 56 else UPGRADES_TOP + 32)
		standard.Visible = not compact
		more.Visible = compact
	end)
	Util.fitWidth(upgrades, "UPGRADES ⬆", 9, UPGRADES_INSET)
	local function sizeEconomy()
		local height = if state:get("compact") then 56 else UPGRADES_TOP + 32
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
