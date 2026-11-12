--[[
	Building / construction GUI (index.html #pageBuilding, UI_ELEMENTS_MAP §5). Visible while state.mode == "build".
	Sizes follow the wireframe's Tailwind classes 1:1 in virtual px.

	Top bar (top-4, h-12, rounded-2xl, border-[5px]):
	  left    Exit Build button (px-5, ✕ + "EXIT BUILD")
	  centre  Parts limit pill (px-5, gap-2.5, cog chip w-7 rounded-lg border-2 bg-gray-100)
	  right   Grid snap button (px-4) · Wood | Stone counter (px-4, gap-3), gap-3
	Tools (right-8 top-20, gap-2.5): w-14 h-14 rounded-2xl border-[5px]; ROT [R] · PAINT · UNDO [Z] · REDO [Y] · TRASH [X]
	Catalog (bottom-6, max-w-[680px]): tabs joined to the tray (-mb-[5px]); tray px-5 py-3.5 border-[5px]
	  rounded-t-xl rounded-b-[2rem]; slots w-24 h-28 rounded-2xl border-4. When that deck would take more than
	  CatalogMetrics.Budget of the screen height (phones), it is rebuilt Compact: one-line tabs that scroll and
	  landscape slots (index.html .deck-compact). Layout calls `setDeck` on every resize.

	Spring buttons get explicit widths from measured text (Util.fitWidth), never AutomaticSize.
	The wireframe's placement boundary and cursor are world-space and belong to the game's placement system.
	Icons are the wireframe's SVGs traced with Frames (Icons.luau): Nunito has no symbol glyphs and emoji
	don't fit the wireframe look.

	Fires: GridSnap (payload = label), BuildCategory (id), BuildItem (name), Rotate, Paint, Undo, Redo, Trash.
	Exit Build sets state.mode = "normal" (init fires ExitBuild).
	State: gridSnap, buildCategory, buildItem; reads buildParts, buildPartsMax, wood, stone.
]]

local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local Icons = require(CowHUD.Icons)
local CatalogMetrics = require(CowHUD.CatalogMetrics)
local C = Theme.Color

local GRID_SNAPS = { "2 Studs", "4 Studs", "1 Stud", "Free / Off" }

local BAR_HEIGHT = 48 -- h-12
local BAR_BORDER = 5
local BAR_RADIUS = 16 -- rounded-2xl
local ICON = 16 -- w-4 h-4

local TOOL_SIZE = 56 -- w-14; Theme.size("Tool") when built (64 on phones)
local TOOL_GAP = 10 -- gap-2.5

-- Catalog deck. Heights and slot sizes come from CatalogMetrics (Full or Compact, per the height budget).
local DOCK_MAX_WIDTH = 680
local DOCK_PADDING = 8 -- px-2
local DOCK_TOUCH_CLEARANCE = 256 -- touch: keep clear of Roblox's native thumbstick and Jump (the arc is hidden here)
local TAB_GAP = 6 -- gap-1.5
local TAB_PAD_X = 8 -- px-3.5 minus the border, so two-line labels fit when five tabs share 680px
local TAB_COMPACT_INSET = 2 * (14 + 5) -- compact tabs fit their one-line label: px-3.5 + border-[5px]
local TAB_TEXT = 10
local TAB_PEEK = 5 -- .catalog-tab translateY(5px)
local TAB_LIFT = 2 -- .catalog-tab:hover translateY(-2px)
local TAB_CLIP_HEADROOM = 8
local TRAY_BORDER = CatalogMetrics.TrayBorder
local TRAY_PAD_X = 20 -- px-5
local SLOT_GAP = 12 -- gap-3
local SLOT_TEXT = 9

local TOOLS = {
	{ action = "Rotate", icon = "rotate", text = "ROT [R]", key = Enum.KeyCode.R },
	{ action = "Paint", icon = "paint", text = "PAINT" },
	{ action = "Undo", icon = "undo", text = "UNDO [Z]", key = Enum.KeyCode.Z },
	{ action = "Redo", icon = "redo", text = "REDO [Y]", key = Enum.KeyCode.Y },
	{ action = "Trash", icon = "trash", text = "TRASH [X]", key = Enum.KeyCode.X, danger = true },
}

export type CatalogItem = { name: string, cost: string, icon: string } -- icon: a key in Icons.luau
export type Category = { id: string, label: string, items: { CatalogItem } }

-- The wireframe's catalog; pass `options.catalog` to CowHUD.mount to replace it.
local DEFAULT_CATALOG: { Category } = {
	{
		id = "fences",
		label = "Fences & Gates",
		items = {
			{ name = "Rustic Fence", cost = "20 Wood", icon = "fence" },
			{ name = "Picket Gate", cost = "35 Wood", icon = "gate" },
			{ name = "Hay Bale", cost = "15 Wood", icon = "hay" },
			{ name = "Stone Wall", cost = "40 Stone", icon = "wall" },
			{ name = "Cozy Lantern", cost = "25 Stone", icon = "lantern" },
			{ name = "Clover Bed", cost = "10 Stone", icon = "clover" },
		},
	},
	{ id = "barns", label = "Barns & Sheds", items = {} },
	{ id = "feeders", label = "Feeders & Troughs", items = {} },
	{ id = "flooring", label = "Paths & Floors", items = {} },
	{ id = "decor", label = "Cozy Decor", items = {} },
}

local function text(parent: Instance, value: string, size: number, order: number, color: Theme.Token?): TextLabel
	return Util.label({ Text = value, TextSize = size, TextColor3 = color or C.Text, LayoutOrder = order, Parent = parent })
end

-- Horizontal, centred content row inside a bar face.
local function row(face: Instance, gap: number)
	Util.list(face, Enum.FillDirection.Horizontal, gap, {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
end

-- Static bar segment (not a button), so AutomaticSize is safe: h-12 rounded-2xl border-[5px], padding `padX`.
local function barBox(parent: Instance, name: string, padX: number, gap: number, props: { [string]: any }?): (Frame, Frame)
	local outer, inner = Util.box({
		Name = name,
		Size = UDim2.fromOffset(0, BAR_HEIGHT),
		AutomaticSize = Enum.AutomaticSize.X,
		Radius = BAR_RADIUS,
		Border = BAR_BORDER,
		Parent = parent,
	})
	inner.Size = UDim2.new(0, 0, 1, 0)
	Util.paddingEach(inner, padX, 0, padX, 0)
	Util.list(inner, Enum.FillDirection.Horizontal, gap, { VerticalAlignment = Enum.VerticalAlignment.Center })
	for key, value in props or {} do
		(outer :: any)[key] = value
	end
	return outer, inner
end

-- Bar button: fixed height; callers size the width from measured text with Util.fitWidth.
local function barButton(parent: Instance, name: string, order: number, onActivated: () -> ()): (ImageButton, Frame)
	local slot, visual = Util.button({
		Name = name,
		Size = UDim2.fromOffset(BAR_HEIGHT * 2, BAR_HEIGHT),
		LayoutOrder = order,
		Parent = parent,
	}, { HoverScale = 1.05, OnActivated = onActivated })
	local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = BAR_RADIUS, Border = BAR_BORDER, Parent = visual })
	return slot, face
end

local function topBar(layer: Instance, ctx)
	local state = ctx.state

	-- Left: Exit Build (px-5, gap-2)
	local exit, exitFace = barButton(layer, "ExitBuild", 1, function()
		state:set("mode", "normal")
	end)
	row(exitFace, 8)
	Icons.slot("close", exitFace, ICON, C.Text, 1)
	text(exitFace, "EXIT BUILD", 12, 2)
	Util.fitWidth(exit, "EXIT BUILD", 12, 2 * (20 + BAR_BORDER) + ICON + 8)

	-- Centre: parts limit (px-5, gap-2.5)
	local centre, centreFace = barBox(layer, "PartsLimit", 20, 10, { AnchorPoint = Vector2.new(0.5, 0) })
	local _, cog = Util.box({ Size = UDim2.fromOffset(28, 28), Radius = 8, Border = 2, Fill = C.Screen, LayoutOrder = 1, Parent = centreFace })
	Icons.draw("cog", cog, ICON, C.Text)
	local partsLabel = text(centreFace, "", 12, 2)
	local function updateParts()
		partsLabel.Text = string.format("PARTS: %d / %d", state:get("buildParts") or 0, state:get("buildPartsMax") or 0)
	end
	state:observe("buildParts", updateParts)
	state:observe("buildPartsMax", updateParts)

	-- Right: grid snap + resources (gap-3)
	local right = Util.frame({ Name = "BuildRight", AnchorPoint = Vector2.new(1, 0), AutomaticSize = Enum.AutomaticSize.XY, Parent = layer })
	Util.list(right, Enum.FillDirection.Horizontal, 12, { VerticalAlignment = Enum.VerticalAlignment.Center })

	local snap, snapFace = barButton(right, "GridSnap", 1, function()
		state:set("gridSnap", (state:get("gridSnap") or 1) % #GRID_SNAPS + 1)
		ctx.fire("GridSnap", GRID_SNAPS[state:get("gridSnap")])
	end)
	row(snapFace, 8)
	Icons.slot("grid", snapFace, ICON, C.Accent, 1)
	local snapLabel = text(snapFace, "", 10, 2)
	state:observe("gridSnap", function(index)
		snapLabel.Text = "GRID: " .. string.upper(GRID_SNAPS[index or 1])
		Util.fitWidth(snap, snapLabel.Text, 10, 2 * (16 + BAR_BORDER) + ICON + 8)
	end)

	local resources, resourceFace = barBox(right, "Resources", 16, 12)
	resources.LayoutOrder = 2
	local function counter(order: number, icon: string): TextLabel
		local group = Util.frame({ AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = order, Parent = resourceFace })
		Util.list(group, Enum.FillDirection.Horizontal, 6, { VerticalAlignment = Enum.VerticalAlignment.Center })
		Icons.slot(icon, group, ICON, C.Text, 1)
		return text(group, "", 11, 2)
	end
	local woodLabel = counter(1, "wood")
	Util.frame({ Name = "Divider", Size = UDim2.fromOffset(2, 20), BackgroundColor3 = C.Subtle, LayoutOrder = 2, Parent = resourceFace })
	local stoneLabel = counter(3, "stone")
	state:observe("wood", function(value)
		woodLabel.Text = Util.formatNumber(value or 0)
	end)
	state:observe("stone", function(value)
		stoneLabel.Text = Util.formatNumber(value or 0)
	end)

	return exit, centre, right
end

local function toolStack(layer: Instance, ctx)
	-- Layout sets the height (room above the action arc on touch); the list wraps into a second column if short.
	local stack = Util.frame({ Name = "BuildTools", AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(TOOL_SIZE, 0), Parent = layer })
	Util.list(stack, Enum.FillDirection.Vertical, TOOL_GAP, { Wraps = true, HorizontalAlignment = Enum.HorizontalAlignment.Right })
	local function fitColumns()
		local perColumn = math.max(1, math.floor((stack.Size.Y.Offset + TOOL_GAP) / (TOOL_SIZE + TOOL_GAP)))
		local columns = math.ceil(#TOOLS / perColumn)
		stack.Size = UDim2.fromOffset(columns * TOOL_SIZE + (columns - 1) * TOOL_GAP, stack.Size.Y.Offset)
	end
	stack:GetPropertyChangedSignal("Size"):Connect(fitColumns) -- converges: the second pass sets the same size

	for index, tool in TOOLS do
		local color = if tool.danger then C.Danger else C.Text
		local _, visual = Util.button({ Name = tool.action, Size = UDim2.fromOffset(TOOL_SIZE, TOOL_SIZE), LayoutOrder = index, Parent = stack }, {
			OnActivated = function()
				ctx.fire(tool.action)
			end,
		})
		local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = 16, Border = BAR_BORDER, Parent = visual })
		local iconBox = Util.frame({ Name = "IconBox", Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 22), Parent = face })
		Icons.draw(tool.icon, iconBox, 20, color)
		local caption = Util.label({
			Text = tool.text,
			TextSize = 9,
			TextColor3 = if tool.danger then C.Danger else C.Accent,
			Position = UDim2.new(0, 0, 1, -15),
			Size = UDim2.new(1, 0, 0, 12),
			Parent = face,
		})
		-- Keyboard hints ("[R]") only make sense with a keyboard; touch screens show the bare tool name.
		local function updateCaption()
			caption.Text = if UserInputService.TouchEnabled then (tool.text:gsub(" %[.%]$", "")) else tool.text
		end
		UserInputService.LastInputTypeChanged:Connect(updateCaption)
		updateCaption()
	end
	return stack
end

-- Category tab: rounded-t-xl, square bottom, border on three sides (border-b-0).
-- Peek-and-pop (index.html `.catalog-tab`): inactive tabs sit TAB_PEEK px lower, tucked behind the tray, and the
-- active tab sits on top of it. With a mouse, hovering lifts a tab TAB_LIFT px above its resting line (Full motion only).
-- Returns the disconnect for its state observer.
local function tab(parent: Instance, ctx, category: Category, order: number, m: CatalogMetrics.Metrics): () -> ()
	local state = ctx.state
	local label = string.upper(category.label)

	-- Full: tabs share the tray width (Flex Fill on the row), so the holder's width comes from the list layout.
	-- Compact: each tab fits its one-line label. The holder's bottom sits TRAY_BORDER px inside the tray (-mb-[5px]).
	local holder = Util.frame({ Name = category.id, Size = UDim2.fromOffset(0, m.tabActive), LayoutOrder = order, Parent = parent })
	if m.compact then
		Util.fitWidth(holder, label, TAB_TEXT, TAB_COMPACT_INSET)
	end
	-- Sibling ZIndex can't draw one tab under the tray and another over it, so inactive tabs are clipped at the
	-- tray's top edge instead: it looks the same as tucking them behind. The headroom leaves space for the
	-- hover lift and the grown touch hit area.
	local clip = Util.frame({
		Name = "Clip",
		Position = UDim2.fromOffset(0, -TAB_CLIP_HEADROOM),
		Size = UDim2.new(1, 0, 1, TAB_CLIP_HEADROOM - TRAY_BORDER),
		Parent = holder,
	})
	local slot, visual = Util.button({
		Name = "Tab",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, TRAY_BORDER),
		Size = UDim2.new(1, 0, 0, m.tabActive),
		Parent = clip,
	}, {
		HoverScale = 1,
		OnActivated = function()
			state:set("buildCategory", category.id)
			ctx.fire("BuildCategory", category.id)
		end,
	})

	local border = Util.shape({ Name = "Border", Radius = 12, Corners = { BL = 0, BR = 0 }, Parent = visual })
	local fill = Util.shape({ Name = "Fill", Radius = 7, Corners = { BL = 0, BR = 0 }, Parent = visual })
	local caption = Util.label({
		Text = label,
		TextSize = TAB_TEXT,
		TextWrapped = true,
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(1, -2 * TAB_PAD_X, 1, 0),
		ZIndex = 2,
		Parent = visual,
	})

	local function paint(container: Frame, token)
		for _, piece in container:GetChildren() do
			if piece:IsA("GuiObject") then
				Theme.paint(piece, "BackgroundColor3", token)
			end
		end
	end

	local on, hovered = false, false
	local function lift()
		local up = 0
		if hovered and Theme.hoverAllowed() and not UserInputService.TouchEnabled then
			up = if on then TAB_LIFT else TAB_PEEK + TAB_LIFT
		end
		TweenService:Create(visual, Theme.Tween.Spring, { Position = UDim2.new(0.5, 0, 0.5, -up) }):Play()
	end
	local hit = slot:FindFirstChild("Hit") :: GuiButton
	hit.MouseEnter:Connect(function()
		hovered = true
		lift()
	end)
	hit.MouseLeave:Connect(function()
		hovered = false
		lift()
	end)

	return state:observe("buildCategory", function(active)
		on = active == category.id
		local b = if on then TRAY_BORDER else 4
		local height = if on then m.tabActive else m.tabInactive
		-- Active: bottom TRAY_BORDER px inside the tray, drawn over it; its fill covers the tray's top border, so
		-- tab and tray read as one shape. Inactive: TAB_PEEK px further down, so only `height - TRAY_BORDER -
		-- TAB_PEEK` shows above the tray.
		local hidden = if on then 0 else TRAY_BORDER + TAB_PEEK
		clip.ClipsDescendants = not on
		slot.Size = UDim2.new(1, 0, 0, height)
		slot.Position = UDim2.new(0, 0, 1, if on then TRAY_BORDER else TRAY_BORDER + TAB_PEEK)
		fill.Position = UDim2.fromOffset(b, b)
		fill.Size = UDim2.new(1, -2 * b, 1, -b)
		-- The label is centred in the visible part, so the peek never clips it (index.html: pt 1 / pb 11).
		caption.Position = UDim2.new(0.5, 0, 0, b)
		caption.Size = UDim2.new(1, -2 * TAB_PAD_X, 0, height - hidden - b)
		lift()
		paint(border, if on then C.Border else C.Fill)
		paint(fill, if on then C.Card else C.Subtle)
		Theme.paint(caption, "TextColor3", if on then C.Text else C.Accent)
	end)
end

-- Slot: name, icon box, cost chip (rounded-2xl border-4). Full: portrait w-24 h-28, name on two lines.
-- Compact: landscape, name on one line, as wide as the name needs.
local function catalogSlot(parent: Instance, ctx, item: CatalogItem, order: number, m: CatalogMetrics.Metrics): () -> ()
	local state = ctx.state
	local itemName = string.upper(item.name)
	local button, visual = Util.button({ Name = item.name, Size = UDim2.fromOffset(m.slotWidth, m.slotHeight), LayoutOrder = order, Parent = parent }, {
		HoverScale = 1.05,
		OnActivated = function()
			state:set("buildItem", item.name)
			ctx.fire("BuildItem", item.name)
		end,
	})
	if m.compact then
		Util.fitWidth(button, itemName, SLOT_TEXT, 2 * (4 + m.slotPad.x), m.slotWidth)
	end
	local outer, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = 16, Border = 4, Parent = visual })
	Util.padding(face, m.slotPad.x, m.slotPad.y) -- p-2 inside border-4 (compact: 6px 10px)
	Util.list(face, Enum.FillDirection.Vertical, m.slotGap, {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	local name = Util.label({
		Text = itemName,
		TextSize = SLOT_TEXT,
		TextWrapped = not m.compact,
		Size = UDim2.new(1, 0, 0, m.slotName),
		LayoutOrder = 1,
		Parent = face,
	})
	local iconBorder, icon = Util.box({ Size = UDim2.fromOffset(m.icon.w, m.icon.h), Radius = 8, Border = 2, LayoutOrder = 2, Parent = face })
	local glyph = Icons.draw(item.icon, icon, m.icon.glyph, C.Accent)
	local chip = Util.frame({ Name = "Cost", Size = UDim2.fromOffset(m.slotWidth - 20, m.chip), LayoutOrder = 3, Parent = face })
	Util.corner(chip, 6)
	local cost = Util.label({ Text = string.upper(item.cost), TextSize = SLOT_TEXT, Size = UDim2.fromScale(1, 1), Parent = chip })
	Util.fitWidth(chip, cost.Text, SLOT_TEXT, 16) -- px-2

	return state:observe("buildItem", function(selected)
		local on = selected == item.name
		-- Selected: border-gray-500 bg-gray-100, chip bg-gray-300; others: border-gray-300 bg-white, chip bg-gray-200.
		Theme.paint(outer, "BackgroundColor3", if on then C.Accent else C.Fill)
		Theme.paint(face, "BackgroundColor3", if on then C.Screen else C.Card)
		Theme.paint(iconBorder, "BackgroundColor3", if on then C.Border else C.Fill)
		Theme.paint(icon, "BackgroundColor3", if on then C.Card else C.Screen)
		Theme.paint(chip, "BackgroundColor3", if on then C.Fill else C.Subtle)
		Theme.paint(name, "TextColor3", if on then C.Text else C.Accent)
		Icons.paint(glyph, if on then C.Text else C.Accent)
		Theme.paint(cost, "TextColor3", C.Text)
	end)
end

-- Builds the deck for metrics `m`. Returns a destroy function (the deck is rebuilt when its density changes).
local function catalogDock(layer: Instance, ctx, catalog: { Category }, m: CatalogMetrics.Metrics): () -> ()
	local state = ctx.state
	local cleanup: { () -> () } = {}
	local dock = Util.frame({
		Name = "CatalogDock",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -m.bottom),
		Parent = layer,
	})
	-- TouchEnabled can settle after mount (Studio emulator), so the clearance follows the input type.
	local function updateWidth()
		local sideClearance = if UserInputService.TouchEnabled then DOCK_TOUCH_CLEARANCE else Theme.Margin
		dock.Size = UDim2.new(1, -2 * sideClearance, 0, m.height)
	end
	local inputChanged = UserInputService.LastInputTypeChanged:Connect(updateWidth)
	table.insert(cleanup, function()
		inputChanged:Disconnect()
	end)
	updateWidth()
	Util.new("UISizeConstraint", { MaxSize = Vector2.new(DOCK_MAX_WIDTH, math.huge), Parent = dock })
	Util.paddingEach(dock, DOCK_PADDING, 0, DOCK_PADDING, 0)

	-- Tray: rounded-t-xl (12) rounded-b-[2rem] (32), as a border shape with an inset fill shape.
	local tray = Util.frame({ Name = "Tray", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, m.trayHeight), Parent = dock })
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
		Position = UDim2.fromOffset(TRAY_PAD_X, 0),
		Size = UDim2.new(1, -2 * TRAY_PAD_X, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ZIndex = 2,
		Parent = trayFill,
	})
	Util.list(slots, Enum.FillDirection.Horizontal, SLOT_GAP, { VerticalAlignment = Enum.VerticalAlignment.Center })
	local empty = Util.label({
		Text = "NOTHING HERE YET",
		TextSize = 12,
		TextColor3 = C.Accent,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 3,
		Parent = trayFill,
	})

	-- Tabs row (items-end) above the tray; the active tab overlaps the tray's top border.
	-- Full: the tabs share the tray width. Compact: one-line tabs, centred, scrolling sideways when they don't fit;
	-- the strip reaches TAB_CLIP_HEADROOM above the tabs so its clipping leaves room for the hover lift.
	local tabs
	if m.compact then
		tabs = Util.gui("ScrollingFrame", {
			Name = "Tabs",
			Position = UDim2.fromOffset(0, -TAB_CLIP_HEADROOM),
			Size = UDim2.new(1, 0, 0, m.tabActive + TAB_CLIP_HEADROOM),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			ScrollingDirection = Enum.ScrollingDirection.X,
			ScrollBarThickness = 0,
			ZIndex = 3,
			Parent = dock,
		})
		Util.list(tabs, Enum.FillDirection.Horizontal, TAB_GAP, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		})
	else
		tabs = Util.frame({ Name = "Tabs", Size = UDim2.new(1, 0, 0, m.tabActive), ZIndex = 3, Parent = dock })
		Util.list(tabs, Enum.FillDirection.Horizontal, TAB_GAP, {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		})
	end
	for index, category in catalog do
		table.insert(cleanup, tab(tabs, ctx, category, index, m))
	end

	local slotCleanup: { () -> () } = {}
	local function clearSlots()
		for _, disconnect in slotCleanup do
			disconnect()
		end
		table.clear(slotCleanup)
	end
	table.insert(cleanup, clearSlots)
	table.insert(cleanup, state:observe("buildCategory", function(id)
		clearSlots()
		for _, child in slots:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local count = 0
		for _, category in catalog do
			if category.id == id then
				for index, item in category.items do
					table.insert(slotCleanup, catalogSlot(slots, ctx, item, index, m))
					count += 1
				end
			end
		end
		empty.Visible = count == 0
		slots.CanvasPosition = Vector2.zero
	end))

	return function()
		for _, fn in cleanup do
			fn()
		end
		dock:Destroy()
	end
end

return function(parent: Instance, ctx, catalog: { Category }?)
	TOOL_SIZE = Theme.size("Tool")
	local state = ctx.state
	local categories = catalog or DEFAULT_CATALOG
	if state:get("buildCategory") == nil and categories[1] then
		state:set("buildCategory", categories[1].id)
	end
	if state:get("buildItem") == nil and categories[1] and categories[1].items[1] then
		state:set("buildItem", categories[1].items[1].name)
	end

	local layer = Util.frame({ Name = "Building", Size = UDim2.fromScale(1, 1), ZIndex = 1, Visible = false, Parent = parent })
	local left, centre, right = topBar(layer, ctx)
	local tools = toolStack(layer, ctx)
	-- Deck density follows the canvas (Layout calls setDeck on every resize); rebuilt only when its sizes change.
	local deckKey, destroyDeck
	local function setDeck(virtualHeight: number)
		local m = CatalogMetrics.choose(virtualHeight, Util.textSize(TAB_TEXT), Util.textSize(SLOT_TEXT))
		local key = string.format("%s/%d/%d/%d", tostring(m.compact), m.tabActive, m.slotWidth, m.slotHeight)
		if key == deckKey then
			return
		end
		deckKey = key
		if destroyDeck then
			destroyDeck()
		end
		destroyDeck = catalogDock(layer, ctx, categories, m)
	end
	setDeck(Theme.Scale.ReferenceHeight)

	-- Keyboard shortcuts shown on the tool captions, bound only while building.
	local BIND_NAME = "CowHUDBuildTools"
	local actions, keyCodes = {}, {}
	for _, tool in TOOLS do
		if tool.key then
			actions[tool.key] = tool.action
			table.insert(keyCodes, tool.key)
		end
	end
	local function onKey(_, inputState: Enum.UserInputState, input: InputObject)
		if inputState == Enum.UserInputState.Begin then
			ctx.fire(actions[input.KeyCode])
		end
		return Enum.ContextActionResult.Pass
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
		setDeck = setDeck,
		destroy = function()
			ContextActionService:UnbindAction(BIND_NAME)
			destroyDeck()
		end,
	}
end
