-- Overlay layer above the HUD: dropdown menus (for merged buttons like ••• and BAG) and modal panels.
-- The Settings panel hosts the in-game versions of the wireframe's preview toggles.

local TweenService = game:GetService("TweenService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local MENU_GAP = 12

local SETTINGS_TOGGLES = {
	{ key = "compact", label = "Compact Mode" },
	{ key = "bulletinVisible", label = "World Bulletin" },
}

-- Converts a HUD element's on-screen rect into virtual (root) coordinates.
local function virtualRect(root: GuiObject, target: GuiObject, scale: number): (Vector2, Vector2)
	return (target.AbsolutePosition - root.AbsolutePosition) / scale, target.AbsoluteSize / scale
end

local function pop(uiScale: UIScale)
	uiScale.Scale = 0.9
	TweenService:Create(uiScale, Theme.Tween.Spring, { Scale = 1 }):Play()
end

-- Pill toggle styled like the wireframe's control buttons (ON = gray-600 fill).
local function toggleRow(parent: Instance, state, spec, order: number): () -> ()
	local row = Util.frame({ Name = spec.key, Size = UDim2.new(1, 0, 0, 48), LayoutOrder = order, Parent = parent })
	Util.label({
		Text = string.upper(spec.label),
		TextSize = 14,
		TextColor3 = C.Text,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local _, visual = Util.button({
		Name = "Toggle",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(96, 40),
		Parent = row,
	}, {
		HoverScale = 1.05,
		OnActivated = function()
			state:toggle(spec.key)
		end,
	})
	local outer, inner = Util.box({ Size = UDim2.fromScale(1, 1), Radius = "full", Border = 4, Parent = visual })
	local text = Util.label({ TextSize = 12, Size = UDim2.fromScale(1, 1), Parent = inner })

	return state:observe(spec.key, function(on)
		Theme.paint(outer, "BackgroundColor3", if on then C.Text else C.Border)
		Theme.paint(inner, "BackgroundColor3", if on then C.Text else C.Screen)
		Theme.paint(text, "TextColor3", if on then C.Card else C.Text)
		text.Text = if on then "ON" else "OFF"
	end)
end

local function rowLabel(row: Instance, text: string)
	Util.label({
		Text = text,
		TextSize = 14,
		TextColor3 = C.Text,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
end

-- Five colour swatches (preset Card fill, Border ring); the active preset gets a Text-coloured outer ring.
local function themeRow(parent: Instance, state, order: number): () -> ()
	local row = Util.frame({ Name = "Theme", Size = UDim2.new(1, 0, 0, 56), LayoutOrder = order, Parent = parent })
	rowLabel(row, "COLOR THEME")
	local swatches = Util.frame({
		Name = "Swatches",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 48),
		Parent = row,
	})
	Util.list(swatches, Enum.FillDirection.Horizontal, 4, { VerticalAlignment = Enum.VerticalAlignment.Center })

	local rings = {}
	for index, name in Theme.PresetOrder do
		local palette = Theme.Presets[name]
		local _, visual = Util.button({ Name = name, Size = UDim2.fromOffset(48, 48), LayoutOrder = index, Parent = swatches }, {
			HoverScale = 1.08,
			OnActivated = function()
				state:set("theme", name)
			end,
		})
		-- Swatches show their own preset, so they take fixed Color3s (untracked) instead of live tokens.
		local ring, face = Util.box({
			Size = UDim2.fromScale(1, 1),
			Radius = "full",
			Border = 4,
			BorderColor = C.Text,
			Fill = palette.Card,
			Parent = visual,
		})
		Util.box({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(28, 28),
			Radius = "full",
			Border = 5,
			BorderColor = palette.Border,
			Fill = palette.Fill,
			Parent = face,
		})
		rings[name] = ring
	end

	return state:observe("theme", function(active)
		for name, ring in rings do
			ring.BackgroundTransparency = if name == active then 0 else 1
		end
	end)
end

-- Cycles Full → Reduced → Off.
local function motionRow(parent: Instance, state, order: number): () -> ()
	local row = Util.frame({ Name = "Motion", Size = UDim2.new(1, 0, 0, 48), LayoutOrder = order, Parent = parent })
	rowLabel(row, "MOTION")
	local _, visual = Util.button({
		Name = "Cycle",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(128, 40),
		Parent = row,
	}, {
		HoverScale = 1.05,
		OnActivated = function()
			local order = Theme.MotionOrder
			local index = table.find(order, state:get("motion")) or 1
			state:set("motion", order[index % #order + 1])
		end,
	})
	local _, inner = Util.box({ Size = UDim2.fromScale(1, 1), Radius = "full", Border = 4, Fill = C.Screen, Parent = visual })
	local text = Util.label({ TextSize = 12, Size = UDim2.fromScale(1, 1), Parent = inner })
	return state:observe("motion", function(mode)
		text.Text = string.upper(mode)
	end)
end

return function(root: GuiObject, ctx)
	local state = ctx.state

	local layer = Util.frame({ Name = "Overlays", Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = root })

	---------------------------------------------------------------- menu
	local menuBackdrop = Util.gui("ImageButton", { Name = "MenuBackdrop", Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 1, Parent = layer })
	menuBackdrop.Activated:Connect(function()
		state:set("menu", nil)
	end)

	local menu, menuFace = Util.box({
		Name = "Menu",
		ClassName = "ImageButton", -- sinks clicks so they don't fall through to the backdrop
		AutomaticSize = Enum.AutomaticSize.XY,
		Radius = 20,
		Border = 6,
		Padding = { 8, 8 },
		Visible = false,
		ZIndex = 2,
		Parent = layer,
	})
	Util.list(menuFace, Enum.FillDirection.Vertical, 6)
	local menuScale = Util.new("UIScale", { Parent = menu })

	state:observe("menu", function(spec)
		for _, child in menuFace:GetChildren() do
			if child:IsA("GuiButton") then
				child:Destroy()
			end
		end
		menuBackdrop.Visible = spec ~= nil
		menu.Visible = spec ~= nil
		if not spec then
			return
		end

		for index, action in spec.items do
			local _, visual = Util.button({ Name = action, Size = UDim2.fromOffset(148, 40), LayoutOrder = index, Parent = menuFace }, {
				HoverScale = 1.04,
				OnActivated = function()
					ctx.trigger(action)
				end,
			})
			local item = Util.frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.Screen, Parent = visual })
			Util.corner(item, 12)
			Util.label({ Text = string.upper(action), TextSize = 12, TextColor3 = C.Text, Size = UDim2.fromScale(1, 1), Parent = item })
		end

		local position, size = virtualRect(root, spec.anchor, ctx.getScale())
		if spec.side == "right" then
			menu.AnchorPoint = Vector2.new(0, 0)
			menu.Position = UDim2.fromOffset(position.X + size.X + MENU_GAP, position.Y)
		else -- "below", right-aligned to the anchor
			menu.AnchorPoint = Vector2.new(1, 0)
			menu.Position = UDim2.fromOffset(position.X + size.X, position.Y + size.Y + MENU_GAP)
		end
		pop(menuScale)
	end)

	---------------------------------------------------------------- panel
	local panelBackdrop = Util.gui("ImageButton", {
		Name = "PanelBackdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = C.Text,
		BackgroundTransparency = 0.6,
		Visible = false,
		ZIndex = 3,
		Parent = layer,
	})
	panelBackdrop.Activated:Connect(function()
		state:set("panel", nil)
	end)

	local panel, panelFace = Util.box({
		Name = "Panel",
		ClassName = "ImageButton",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(480, 440),
		Radius = 32,
		Border = 8,
		BorderColor = C.Accent,
		Padding = { 24, 20 },
		Visible = false,
		ZIndex = 4,
		Parent = layer,
	})
	local panelScale = Util.new("UIScale", { Parent = panel })

	local title = Util.label({
		TextSize = 20,
		TextColor3 = C.Text,
		Size = UDim2.new(1, -48, 0, 40),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panelFace,
	})
	Util.iconButton({
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(40, 40),
		Radius = "full",
		Border = 4,
		Text = "X",
		TextSize = 14,
		TextColor3 = C.Text,
		Parent = panelFace,
		OnActivated = function()
			state:set("panel", nil)
		end,
	})
	local body = Util.frame({ Name = "Body", Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56), Parent = panelFace })

	local bodyCleanup: { () -> () } = {}
	state:observe("panel", function(name)
		for _, disconnect in bodyCleanup do
			disconnect()
		end
		table.clear(bodyCleanup)
		body:ClearAllChildren()

		panelBackdrop.Visible = name ~= nil
		panel.Visible = name ~= nil
		if not name then
			return
		end

		title.Text = string.upper(name)
		if name == "Settings" then
			Util.list(body, Enum.FillDirection.Vertical, 8)
			for index, spec in SETTINGS_TOGGLES do
				table.insert(bodyCleanup, toggleRow(body, state, spec, index))
			end
			table.insert(bodyCleanup, themeRow(body, state, #SETTINGS_TOGGLES + 1))
			table.insert(bodyCleanup, motionRow(body, state, #SETTINGS_TOGGLES + 2))
		else
			Util.label({ Text = "COMING SOON", TextSize = 14, Size = UDim2.fromScale(1, 1), Parent = body })
		end
		pop(panelScale)
	end)
end
