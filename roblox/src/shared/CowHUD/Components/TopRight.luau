-- Top-right cluster: calories pill + upgrades tab, cowbell settings button, compact "•••" menu.

local TextService = game:GetService("TextService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local CALORIES_INSET = 52 -- (px-5 + border-6) * 2
local CALORIES_MIN_WIDTH = 120

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

	-- Economy column: pill with the upgrades tab tucked 8px underneath (-mt-2).
	local economy = Util.frame({ Name = "Economy", AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, Parent = cluster })
	Util.list(economy, Enum.FillDirection.Vertical, -8, { HorizontalAlignment = Enum.HorizontalAlignment.Center })

	-- Calories pill (h-14, px-5, rounded-[1.5rem], border-6). Width is set explicitly from measured text bounds:
	-- AutomaticSize can't be used here because the scale-sized visual inside the slot feeds back into it and grows unbounded.
	local calories, caloriesVisual = Util.button({
		Name = "Calories",
		Size = UDim2.fromOffset(CALORIES_MIN_WIDTH, 56),
		LayoutOrder = 1,
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
		Size = UDim2.fromOffset(112, 32),
		LayoutOrder = 2,
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
		standard.Visible = not compact
		more.Visible = compact
	end)
	local measureToken = 0
	state:observe("calories", function(value)
		local text = "CALORIES: " .. Util.formatNumber(tonumber(value) or 0)
		caloriesLabel.Text = text

		measureToken += 1
		local token = measureToken
		task.spawn(function()
			local params = Instance.new("GetTextBoundsParams")
			params.Text = text
			params.Font = Theme.Font
			params.Size = 12
			params.Width = math.huge
			local ok, bounds = pcall(TextService.GetTextBoundsAsync, TextService, params)
			if ok and token == measureToken then
				calories.Size = UDim2.fromOffset(math.max(CALORIES_MIN_WIDTH, math.ceil(bounds.X) + CALORIES_INSET), 56)
			end
		end)
	end)

	return cluster
end
