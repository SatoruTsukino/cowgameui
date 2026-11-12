--[[
	Building / construction GUI (index.html #pageBuilding, UI_ELEMENTS_MAP §5). Visible while state.mode == "build".

	Top bar:   Exit Build (left) · Parts limit pill with cog (centre) · Grid snap + Wood/Stone counters (right)
	Tools:     Rotate [R] · Paint · Undo [Z] · Redo [Y] · Trash [X], stacked on the right above the action arc
	Catalog:   category tabs joined to a scrolling slot tray, centred between the mobile safe zones (max 680)

	The wireframe's placement boundary and cursor are world-space and belong to the game's placement system,
	so they are not drawn here.

	Fires: ExitBuild, GridSnap, BuildCategory, BuildItem (payload = item name), Rotate, Paint, Undo, Redo, Trash
	State: gridSnap (index into GRID_SNAPS), buildCategory, buildItem; reads buildParts, buildPartsMax, wood, stone
]]

local ContextActionService = game:GetService("ContextActionService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local GRID_SNAPS = { "2 Studs", "4 Studs", "1 Stud", "Free / Off" }
local BAR_HEIGHT = 48
local BAR_BORDER = 5
local TOOL_SIZE = 56
local TOOL_GAP = 10
local DOCK_BOTTOM = 24
local DOCK_MAX_WIDTH = 680
local DOCK_SIDE_CLEARANCE = Theme.Margin + 256 + 16 -- keep clear of the safe zones / action arc
local TAB_HEIGHT = 40
local TRAY_BORDER = 5
local SLOT = Vector2.new(96, 112)

local TOOLS = {
	{ action = "Rotate", glyph = "↻", text = "ROT [R]", key = Enum.KeyCode.R },
	{ action = "Paint", glyph = "◐", text = "PAINT" },
	{ action = "Undo", glyph = "↶", text = "UNDO [Z]", key = Enum.KeyCode.Z },
	{ action = "Redo", glyph = "↷", text = "REDO [Y]", key = Enum.KeyCode.Y },
	{ action = "Trash", glyph = "✕", text = "TRASH [X]", key = Enum.KeyCode.X, danger = true },
}

export type CatalogItem = { name: string, cost: string, glyph: string }
export type Category = { id: string, label: string, items: { CatalogItem } }

-- Demo catalog from the wireframe; pass `options.catalog` to CowHUD.mount to replace it.
local DEFAULT_CATALOG: { Category } = {
	{
		id = "fences",
		label = "Fences & Gates",
		items = {
			{ name = "Rustic Fence", cost = "20 Wood", glyph = "#" },
			{ name = "Picket Gate", cost = "35 Wood", glyph = "⊞" },
			{ name = "Stone Wall", cost = "40 Stone", glyph = "▦" },
		},
	},
	{ id = "barns", label = "Barns & Sheds", items = { { name = "Cozy Shed", cost = "120 Wood", glyph = "⌂" } } },
	{ id = "feeders", label = "Feeders & Troughs", items = { { name = "Hay Bale", cost = "15 Wood", glyph = "≋" } } },
	{ id = "flooring", label = "Paths & Floors", items = { { name = "Clover Bed", cost = "10 Stone", glyph = "✿" } } },
	{ id = "decor", label = "Cozy Decor", items = { { name = "Cozy Lantern", cost = "25 Stone", glyph = "✦" } } },
}

-- Rounded bar segment used by the top bar (h-12 rounded-2xl border-[5px]).
local function barBox(parent: Instance, name: string, props: { [string]: any }?): (GuiObject, Frame)
	local outer, inner = Util.box({
		Name = name,
		Size = UDim2.fromOffset(0, BAR_HEIGHT),
		AutomaticSize = Enum.AutomaticSize.X,
		Radius = 16,
		Border = BAR_BORDER,
		Parent = parent,
	})
	inner.Size = UDim2.new(0, 0, 1, 0)
	Util.paddingEach(inner, 16, 0, 16, 0)
	Util.list(inner, Enum.FillDirection.Horizontal, 8, { VerticalAlignment = Enum.VerticalAlignment.Center })
	if props then
		for key, value in props do
			(outer :: any)[key] = value
		end
	end
	return outer, inner
end

-- Same bar segment, but clickable with the standard spring.
local function barButton(parent: Instance, name: string, order: number, onActivated: () -> ()): (ImageButton, Frame)
	local slot, visual = Util.button({
		Name = name,
		Size = UDim2.fromOffset(0, BAR_HEIGHT),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = order,
		Parent = parent,
	}, { HoverScale = 1.05, OnActivated = onActivated })
	visual.AutomaticSize = Enum.AutomaticSize.X
	visual.Size = UDim2.fromOffset(0, BAR_HEIGHT)
	local _, inner = barBox(visual, "Face")
	return slot, inner
end

local function text(parent: Instance, value: string, size: number, order: number, color: Theme.Token?): TextLabel
	return Util.label({ Text = value, TextSize = size, TextColor3 = color or C.Text, LayoutOrder = order, Parent = parent })
end

local function topBar(layer: Instance, ctx)
	local state = ctx.state

	-- Left: Exit Build
	local left = Util.frame({ Name = "BuildLeft", AutomaticSize = Enum.AutomaticSize.XY, Parent = layer })
	local _, exitFace = barButton(left, "ExitBuild", 1, function()
		state:set("mode", "normal")
	end)
	text(exitFace, "✕", 14, 1)
	text(exitFace, "EXIT BUILD", 12, 2)

	-- Centre: parts limit
	local centre, centreFace = barBox(layer, "PartsLimit", { AnchorPoint = Vector2.new(0.5, 0) })
	local _, cog = Util.box({ Size = UDim2.fromOffset(28, 28), Radius = 8, Border = 2, Fill = C.Screen, LayoutOrder = 1, Parent = centreFace })
	Util.label({ Text = "⚙", TextSize = 16, Size = UDim2.fromScale(1, 1), Parent = cog })
	local partsLabel = text(centreFace, "", 12, 2)
	local function updateParts()
		partsLabel.Text = string.format("PARTS: %d / %d", state:get("buildParts") or 0, state:get("buildPartsMax") or 0)
	end
	state:observe("buildParts", updateParts)
	state:observe("buildPartsMax", updateParts)

	-- Right: grid snap + resources
	local right = Util.frame({ Name = "BuildRight", AnchorPoint = Vector2.new(1, 0), AutomaticSize = Enum.AutomaticSize.XY, Parent = layer })
	Util.list(right, Enum.FillDirection.Horizontal, 12, { VerticalAlignment = Enum.VerticalAlignment.Center })

	local _, snapFace = barButton(right, "GridSnap", 1, function()
		state:set("gridSnap", (state:get("gridSnap") or 1) % #GRID_SNAPS + 1)
		ctx.fire("GridSnap", GRID_SNAPS[state:get("gridSnap")])
	end)
	text(snapFace, "▦", 14, 1, C.Accent)
	local snapLabel = text(snapFace, "", 11, 2)
	state:observe("gridSnap", function(index)
		snapLabel.Text = "GRID: " .. string.upper(GRID_SNAPS[index or 1])
	end)

	local resources, resourceFace = barBox(right, "Resources")
	resources.LayoutOrder = 2
	text(resourceFace, "≡", 14, 1)
	local woodLabel = text(resourceFace, "", 12, 2)
	Util.frame({ Name = "Divider", Size = UDim2.fromOffset(2, 20), BackgroundColor3 = C.Subtle, LayoutOrder = 3, Parent = resourceFace })
	text(resourceFace, "⬟", 14, 4)
	local stoneLabel = text(resourceFace, "", 12, 5)
	state:observe("wood", function(value)
		woodLabel.Text = Util.formatNumber(value or 0)
	end)
	state:observe("stone", function(value)
		stoneLabel.Text = Util.formatNumber(value or 0)
	end)

	return left, centre, right
end

local function toolStack(layer: Instance, ctx)
	-- Layout sets the height to the room above the right safe zone; the list wraps into more columns if short.
	local stack = Util.frame({ Name = "BuildTools", AnchorPoint = Vector2.new(1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = layer })
	Util.list(stack, Enum.FillDirection.Vertical, TOOL_GAP, { Wraps = true, HorizontalAlignment = Enum.HorizontalAlignment.Right })
	for index, tool in TOOLS do
		local color = if tool.danger then C.Danger else C.Text
		local _, visual = Util.button({ Name = tool.action, Size = UDim2.fromOffset(TOOL_SIZE, TOOL_SIZE), LayoutOrder = index, Parent = stack }, {
			OnActivated = function()
				ctx.fire(tool.action)
			end,
		})
		local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = 16, Border = BAR_BORDER, Parent = visual })
		Util.label({ Text = tool.glyph, TextSize = 20, TextColor3 = color, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 26), Parent = face })
		Util.label({ Text = tool.text, TextSize = 9, TextColor3 = color, Position = UDim2.new(0, 0, 1, -16), Size = UDim2.new(1, 0, 0, 14), Parent = face })
	end
	return stack
end

-- Tab shape: rounded top, square bottom (rounded-t-xl rounded-b-none), border on three sides.
local function tab(parent: Instance, ctx, category: Category, order: number)
	local state = ctx.state
	local holder = Util.frame({ Name = category.id, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, TAB_HEIGHT), LayoutOrder = order, Parent = parent })
	local slot, visual = Util.button({
		Name = "Tab",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, TAB_HEIGHT),
		Parent = holder,
	}, {
		HoverScale = 1,
		OnActivated = function()
			state:set("buildCategory", category.id)
			ctx.fire("BuildCategory", category.id)
		end,
	})
	visual.AutomaticSize = Enum.AutomaticSize.X

	local border = Util.shape({ Name = "Border", Radius = 12, Corners = { BL = 0, BR = 0 }, Parent = visual })
	local fill = Util.shape({ Name = "Fill", Radius = 8, Corners = { BL = 0, BR = 0 }, Parent = visual })
	local label = Util.label({ Text = string.upper(category.label), TextSize = 11, ZIndex = 2, Parent = visual })
	Util.paddingEach(label, 14, 0, 14, 0)
	label.Size = UDim2.fromScale(0, 1)
	label.AutomaticSize = Enum.AutomaticSize.X

	local function paint(container: Frame, token)
		for _, piece in container:GetChildren() do
			Theme.paint(piece, "BackgroundColor3", token)
		end
	end

	state:observe("buildCategory", function(active)
		local on = active == category.id
		local b = if on then TRAY_BORDER else 4
		-- Active tab reaches down over the tray's top border (-mb-[5px]) so the two read as one shape.
		slot.Size = UDim2.fromOffset(0, if on then TAB_HEIGHT else TAB_HEIGHT - TRAY_BORDER - 4)
		slot.Position = UDim2.new(0, 0, 1, if on then 0 else -TRAY_BORDER)
		fill.Position = UDim2.fromOffset(b, b)
		fill.Size = UDim2.new(1, -2 * b, 1, -b) -- no bottom border (border-b-0)
		paint(border, if on then C.Border else C.Fill)
		paint(fill, if on then C.Card else C.Subtle)
		Theme.paint(label, "TextColor3", if on then C.Text else C.Accent)
	end)
end

local function catalogSlot(parent: Instance, ctx, item: CatalogItem, order: number)
	local state = ctx.state
	local _, visual = Util.button({ Name = item.name, Size = UDim2.fromOffset(SLOT.X, SLOT.Y), LayoutOrder = order, Parent = parent }, {
		HoverScale = 1.05,
		OnActivated = function()
			state:set("buildItem", item.name)
			ctx.fire("BuildItem", item.name)
		end,
	})
	local outer, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = 16, Border = 4, Parent = visual })
	Util.padding(face, 6, 8)
	Util.list(face, Enum.FillDirection.Vertical, 4, {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	Util.label({ Text = string.upper(item.name), TextSize = 10, TextWrapped = true, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1, Parent = face })
	local _, icon = Util.box({ Size = UDim2.fromOffset(48, 40), Radius = 8, Border = 2, BorderColor = C.Fill, Fill = C.Screen, LayoutOrder = 2, Parent = face })
	Util.label({ Text = item.glyph, TextSize = 20, Size = UDim2.fromScale(1, 1), Parent = icon })
	local chip = Util.frame({ Name = "Cost", AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), BackgroundColor3 = C.Subtle, LayoutOrder = 3, Parent = face })
	Util.corner(chip, 6)
	Util.paddingEach(chip, 8, 0, 8, 0)
	Util.label({ Text = string.upper(item.cost), TextSize = 10, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X, Parent = chip })

	return state:observe("buildItem", function(selected)
		local on = selected == item.name
		Theme.paint(outer, "BackgroundColor3", if on then C.Accent else C.Fill)
		Theme.paint(face, "BackgroundColor3", if on then C.Screen else C.Card)
	end)
end

local function catalogDock(layer: Instance, ctx, catalog: { Category })
	local state = ctx.state
	local trayHeight = SLOT.Y + 2 * 14 + 2 * TRAY_BORDER

	local dock = Util.frame({
		Name = "CatalogDock",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -DOCK_BOTTOM),
		Size = UDim2.new(1, -2 * DOCK_SIDE_CLEARANCE, 0, trayHeight + TAB_HEIGHT - TRAY_BORDER),
		Parent = layer,
	})
	Util.new("UISizeConstraint", { MaxSize = Vector2.new(DOCK_MAX_WIDTH, math.huge), Parent = dock })

	-- Tray: rounded-t-xl rounded-b-[2rem], built as a border shape with an inset fill shape.
	local tray = Util.frame({ Name = "Tray", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, trayHeight), Parent = dock })
	Util.shape({ Name = "Border", Color = C.Border, Radius = 12, Corners = { BL = 32, BR = 32 }, Parent = tray })
	local trayFill = Util.shape({
		Name = "Fill",
		Color = C.Card,
		Radius = 12 - TRAY_BORDER,
		Corners = { BL = 32 - TRAY_BORDER, BR = 32 - TRAY_BORDER },
		Position = UDim2.fromOffset(TRAY_BORDER, TRAY_BORDER),
		Size = UDim2.new(1, -2 * TRAY_BORDER, 1, -2 * TRAY_BORDER),
		Parent = tray,
	})

	local slots = Util.gui("ScrollingFrame", {
		Name = "Slots",
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -32, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.Border,
		ZIndex = 2,
		Parent = trayFill,
	})
	Util.list(slots, Enum.FillDirection.Horizontal, 12, { VerticalAlignment = Enum.VerticalAlignment.Center })

	-- Tabs sit above the tray (ZIndex) so the active tab's fill covers the tray's top border.
	local tabs = Util.gui("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -32, 0, TAB_HEIGHT),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ZIndex = 3,
		Parent = dock,
	})
	Util.list(tabs, Enum.FillDirection.Horizontal, 6, { VerticalAlignment = Enum.VerticalAlignment.Bottom })
	for index, category in catalog do
		tab(tabs, ctx, category, index)
	end

	local slotCleanup: { () -> () } = {}
	state:observe("buildCategory", function(id)
		for _, disconnect in slotCleanup do
			disconnect()
		end
		table.clear(slotCleanup)
		for _, child in slots:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		for _, category in catalog do
			if category.id == id then
				for index, item in category.items do
					table.insert(slotCleanup, catalogSlot(slots, ctx, item, index))
				end
			end
		end
		slots.CanvasPosition = Vector2.zero
	end)
	return dock
end

return function(parent: Instance, ctx, catalog: { Category }?)
	local state = ctx.state
	local categories = catalog or DEFAULT_CATALOG
	if state:get("buildCategory") == nil and categories[1] then
		state:set("buildCategory", categories[1].id)
	end

	local layer = Util.frame({ Name = "Building", Size = UDim2.fromScale(1, 1), ZIndex = 1, Visible = false, Parent = parent })
	local left, centre, right = topBar(layer, ctx)
	local tools = toolStack(layer, ctx)
	catalogDock(layer, ctx, categories)

	-- Keyboard shortcuts shown on the tool captions, bound only while building.
	local BIND_NAME = "CowHUDBuildTools"
	local keys = {}
	for _, tool in TOOLS do
		if tool.key then
			keys[tool.key] = tool.action
		end
	end
	local function onKey(_, inputState: Enum.UserInputState, input: InputObject)
		if inputState == Enum.UserInputState.Begin then
			ctx.fire(keys[input.KeyCode])
		end
		return Enum.ContextActionResult.Pass
	end

	local keyCodes = {}
	for key in keys do
		table.insert(keyCodes, key)
	end
	state:observe("mode", function(mode)
		local building = mode == "build"
		layer.Visible = building
		if building then
			ContextActionService:BindAction(BIND_NAME, onKey, false, table.unpack(keyCodes))
		else
			ContextActionService:UnbindAction(BIND_NAME)
		end
	end)

	return {
		layer = layer,
		left = left,
		centre = centre,
		right = right,
		tools = tools,
		destroy = function()
			ContextActionService:UnbindAction(BIND_NAME)
		end,
	}
end
