-- Top-centre town bulletin: full card (cycle, world event, boost chip) or compact pill.
-- Collapses to the pill only in compact mode (the player's choice); Layout moves the card when space is tight.

local TweenService = game:GetService("TweenService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

local EDGE_ROOM = 8 -- CanvasGroup clips its children; leave room for the pill's notification dot

return function(parent: Instance, ctx)
	local state = ctx.state

	local wrapper: CanvasGroup = Util.gui("CanvasGroup", {
		Name = "Bulletin",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, Theme.Margin - EDGE_ROOM),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 3,
		Parent = parent,
	})
	Util.padding(wrapper, EDGE_ROOM, EDGE_ROOM)
	Util.list(wrapper, Enum.FillDirection.Vertical, 0, { HorizontalAlignment = Enum.HorizontalAlignment.Center })
	local wrapperScale = Util.new("UIScale", { Parent = wrapper })

	---------------------------------------------------------------- full card
	local full = Util.frame({ Name = "Full", AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, Parent = wrapper })
	Util.list(full, Enum.FillDirection.Vertical, -6, { HorizontalAlignment = Enum.HorizontalAlignment.Center })

	local _, card = Util.box({
		Name = "Card",
		AutomaticSize = Enum.AutomaticSize.XY,
		Radius = 32,
		Border = 6,
		Padding = { 16, 10 },
		LayoutOrder = 1,
		ZIndex = 1,
		Parent = full,
	})
	Util.list(card, Enum.FillDirection.Horizontal, 12, { VerticalAlignment = Enum.VerticalAlignment.Center })

	-- Cycle
	local cycle = Util.frame({ Name = "Cycle", AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, Parent = card })
	Util.list(cycle, Enum.FillDirection.Horizontal, 8, { VerticalAlignment = Enum.VerticalAlignment.Center })
	local _, iconFace = Util.box({ Size = UDim2.fromOffset(32, 32), Radius = "full", Border = 4, Fill = C.Screen, LayoutOrder = 1, Parent = cycle })
	Util.sunIcon(iconFace, 16, C.Accent)
	local cycleText = Util.frame({ AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 2, Parent = cycle })
	Util.list(cycleText, Enum.FillDirection.Vertical, 2)
	Util.label({ Text = "CYCLE", TextSize = 9, TextColor3 = C.Accent, LayoutOrder = 1, Parent = cycleText })
	local cycleLabel = Util.label({
		Size = UDim2.fromOffset(90, 16), -- fixed so the card doesn't jitter as digits change
		TextSize = 12,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = cycleText,
	})

	-- Divider (border-r-4 gray-200)
	local divider = Util.frame({ Name = "Divider", Size = UDim2.fromOffset(4, 36), BackgroundColor3 = C.Subtle, LayoutOrder = 2, Parent = card })
	Util.corner(divider, 2)

	-- World event
	local event = Util.frame({ Name = "Event", Size = UDim2.fromOffset(155, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, Parent = card })
	Util.list(event, Enum.FillDirection.Vertical, 4)
	local header = Util.frame({ Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1, Parent = event })
	Util.paddingEach(header, 4, 0, 4, 0)
	Util.label({ Text = "WORLD EVENT", TextSize = 9, TextColor3 = C.Accent, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
	local eventTimer = Util.label({ TextSize = 10, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Right, Parent = header })

	local _, eventTrack = Util.box({
		Size = UDim2.new(1, 0, 0, 24),
		Radius = "full",
		Border = 4,
		BorderColor = C.Fill,
		Fill = C.Screen,
		Padding = { 2, 2 },
		LayoutOrder = 2,
		Parent = event,
	})
	local eventFill = Util.frame({ Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.Fill, Parent = eventTrack })
	Util.corner(eventFill, "full")
	local eventName = Util.label({ TextSize = 10, TextColor3 = C.Text, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = eventTrack })

	-- Boost chip (-mt-1.5, border-4 gray-500)
	local boost, boostFace = Util.box({
		Name = "Boost",
		AutomaticSize = Enum.AutomaticSize.XY,
		Radius = 12,
		Border = 4,
		BorderColor = C.Accent,
		Fill = C.Screen,
		Padding = { 16, 4 },
		LayoutOrder = 2,
		ZIndex = 2,
		Parent = full,
	})
	Util.list(boostFace, Enum.FillDirection.Horizontal, 8, { VerticalAlignment = Enum.VerticalAlignment.Center })
	local dot = Util.frame({ Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.Accent, LayoutOrder = 1, Parent = boostFace })
	Util.corner(dot, "full")
	local boostLabel = Util.label({ TextSize = 10, TextColor3 = C.Text, LayoutOrder = 2, Parent = boostFace })

	---------------------------------------------------------------- compact pill
	local compact, compactVisual = Util.button({ Name = "Compact", Size = UDim2.fromOffset(124, 60), LayoutOrder = 2, Parent = wrapper }, {
		HoverScale = 1.05,
		OnActivated = function()
			ctx.trigger("Bulletin")
		end,
	})
	local _, pill = Util.box({ Size = UDim2.fromScale(1, 1), Radius = "full", Border = 6, Padding = { 10, 0 }, Parent = compactVisual })
	Util.list(pill, Enum.FillDirection.Horizontal, 10, {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	local _, miniIcon = Util.box({ Size = UDim2.fromOffset(28, 28), Radius = "full", Border = 4, Fill = C.Screen, LayoutOrder = 1, Parent = pill })
	Util.sunIcon(miniIcon, 14, C.Accent)
	local compactTime = Util.label({ TextSize = 12, TextColor3 = C.Text, LayoutOrder = 2, Parent = pill })
	Util.box({
		Name = "Dot",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 6, 0, -6),
		Size = UDim2.fromOffset(20, 20),
		Radius = "full",
		Border = 4,
		BorderColor = C.Card,
		Fill = C.Accent,
		ZIndex = 3,
		Parent = compactVisual,
	})

	---------------------------------------------------------------- bindings
	local function refreshLayout()
		local collapsed = state:get("compact")
		full.Visible = not collapsed
		compact.Visible = collapsed
	end
	state:observe("compact", refreshLayout)

	local fadeTween: Tween? = nil
	state:observe("bulletinVisible", function(visible)
		if fadeTween then
			fadeTween:Cancel()
		end
		if visible then
			wrapper.Visible = true
		end
		TweenService:Create(wrapperScale, Theme.Tween.Spring, { Scale = if visible then 1 else 0.9 }):Play()
		local tween = TweenService:Create(wrapper, Theme.Tween.Fade, { GroupTransparency = if visible then 0 else 1 })
		tween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed and not state:get("bulletinVisible") then
				wrapper.Visible = false -- stop invisible buttons from eating clicks
			end
		end)
		fadeTween = tween
		tween:Play()
	end)

	local function refreshCycle()
		local timeLeft = Util.clock(state:get("cycleTimeLeft") or 0)
		cycleLabel.Text = string.upper(tostring(state:get("cyclePhase") or "DAY")) .. " • " .. timeLeft
		compactTime.Text = timeLeft
	end
	state:observe("cyclePhase", refreshCycle)
	state:observe("cycleTimeLeft", refreshCycle)

	local function refreshEvent()
		local name = state:get("eventName")
		if name then
			eventName.Text = string.upper(name)
			eventTimer.Text = Util.duration(state:get("eventTimeLeft") or 0)
			eventFill.Size = UDim2.fromScale(math.clamp(state:get("eventProgress") or 0, 0, 1), 1)
		else
			eventName.Text = "CALM SKIES"
			eventTimer.Text = "--"
			eventFill.Size = UDim2.fromScale(0, 1)
		end
	end
	state:observe("eventName", refreshEvent)
	state:observe("eventTimeLeft", refreshEvent)
	state:observe("eventProgress", refreshEvent)

	local function refreshBoost()
		local label, timeLeft = state:get("boostLabel"), state:get("boostTimeLeft") or 0
		boost.Visible = label ~= nil and timeLeft > 0
		if label then
			boostLabel.Text = string.upper(label) .. " • " .. Util.clock(timeLeft)
		end
	end
	state:observe("boostLabel", refreshBoost)
	state:observe("boostTimeLeft", refreshBoost)

	return {
		wrapper = wrapper,
		scale = wrapperScale,
		full = full,
		-- Places the visible card's top edge at `y` (virtual px), compensating for the clip padding.
		setTop = function(y: number)
			wrapper.Position = UDim2.new(0.5, 0, 0, y - EDGE_ROOM)
		end,
	}
end
