-- Left sidebar (Inventory backpack + Closet, merged into BAG in compact mode)
-- and right sidebar (Herd + Trade, hidden in compact mode; their actions move to the top-right menu).

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

-- Backpack-shaped button (w-16 h-[4.5rem]) with a flap hanging from the top edge.
local function backpackButton(props)
	local slot, _, face, label = Util.iconButton({
		Name = props.Name,
		Size = UDim2.fromOffset(64, 72),
		Radius = 12,
		Text = props.Text,
		LayoutOrder = props.LayoutOrder,
		Parent = props.Parent,
		OnActivated = props.OnActivated,
	})
	label.TextYAlignment = Enum.TextYAlignment.Bottom
	Util.paddingEach(label, 0, 0, 0, 6)

	Util.shape({
		Name = "FlapBorder",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(32, 16),
		Color = C.Gray400,
		Radius = 6,
		Corners = { TL = 0, TR = 0 },
		ZIndex = 1,
		Parent = face,
	})
	Util.shape({
		Name = "Flap",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(24, 12),
		Color = C.Gray100,
		Radius = 2,
		Corners = { TL = 0, TR = 0 },
		ZIndex = 2,
		Parent = face,
	})
	return slot
end

return function(parent: Instance, ctx)
	local state = ctx.state

	---------------------------------------------------------------- left
	local left = Util.frame({
		Name = "LeftSidebar",
		Position = UDim2.fromOffset(Theme.Margin, Theme.Margin + Theme.SidebarOffset),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 1,
		Parent = parent,
	})
	Util.list(left, Enum.FillDirection.Vertical, 16)

	local standard = Util.frame({ Name = "Standard", AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, Parent = left })
	Util.list(standard, Enum.FillDirection.Vertical, 16)
	backpackButton({
		Name = "Inventory",
		Text = "INV",
		LayoutOrder = 1,
		Parent = standard,
		OnActivated = function()
			ctx.trigger("Inventory")
		end,
	})
	Util.iconButton({
		Name = "Closet",
		Size = UDim2.fromOffset(64, 64),
		Radius = 16,
		Text = "CLOSET",
		LayoutOrder = 2,
		Parent = standard,
		OnActivated = function()
			ctx.trigger("Closet")
		end,
	})

	local bag = backpackButton({
		Name = "Bag",
		Text = "BAG",
		LayoutOrder = 2,
		Parent = left,
		OnActivated = function(slot)
			ctx.toggleMenu(slot, "right", { "Inventory", "Closet" })
		end,
	})

	---------------------------------------------------------------- right
	local right = Util.frame({
		Name = "RightSidebar",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -Theme.Margin, 0, Theme.Margin + Theme.SidebarOffset),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 1,
		Parent = parent,
	})
	Util.list(right, Enum.FillDirection.Vertical, 16, { HorizontalAlignment = Enum.HorizontalAlignment.Right })

	-- Herd: two overlapping rounded squares
	local _, herd = Util.button({ Name = "Herd", Size = UDim2.fromOffset(64, 64), LayoutOrder = 1, Parent = right }, {
		OnActivated = function()
			ctx.trigger("Herd")
		end,
	})
	Util.box({
		Name = "Back",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(48, 48),
		Radius = 13,
		Border = 6,
		Fill = C.Gray200,
		ZIndex = 1,
		Parent = herd,
	})
	local _, front = Util.box({
		Name = "Front",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromOffset(48, 48),
		Radius = 13,
		Border = 6,
		ZIndex = 2,
		Parent = herd,
	})
	Util.label({ Text = "HERD", TextSize = 9, Size = UDim2.fromScale(1, 1), Parent = front })

	Util.iconButton({
		Name = "Trade",
		Size = UDim2.fromOffset(64, 64),
		Radius = 16,
		Text = "TRADE",
		TextSize = 10,
		LayoutOrder = 2,
		Parent = right,
		OnActivated = function()
			ctx.trigger("Trade")
		end,
	})

	state:observe("compact", function(compact)
		standard.Visible = not compact
		bag.Visible = compact
		right.Visible = not compact
	end)

	return { left = left, right = right }
end
