--[[
	Mobile action arc (DESIGN_SYSTEM_AND_SPEC §2C): Emote, Moo, Sprint and Kick satellites orbiting Roblox's
	native touch Jump button. The wireframe's Jump and thumbstick are placeholders for the native controls,
	so this module never draws a Jump; it finds PlayerGui.TouchGui…JumpButton and centres the arc on it.

	Geometry (virtual px): radius = jumpHalf + 24 (finger clearance) + 28 (satellite half), as in the spec
	(92 = 40 + 24 + 28 for the 80px wireframe Jump). Angles are measured counter-clockwise from east, evenly
	spread over 60°–200° so the arc stays on screen beside Roblox's bottom-right Jump on small phones while 44pt
	hit areas keep ≥ 8px apart (verified for 360–1440px tall screens). If the arc would still cross a screen edge
	(large scales), the whole arc shifts inward so its spacing is kept.

	Shown on touch devices, or anywhere while the "Mobile Safe Zones" preview toggle is on.
	Fires: Emote (toggles the flyout), Moo, Sprint, Kick, EmoteHeart, EmoteCheer, EmoteSnooze.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)

local SATELLITE = 56
local SATELLITE_BORDER = 5
local CLEARANCE = 24
local FLYOUT_BUTTON = 40
local FLYOUT_GAP = 8

local ARC_START, ARC_END = 60, 200

-- Top of the thumb arc to the bottom: Emote (with flyout) · Moo · Sprint (nearest the thumb rest) · Kick
local SATELLITES = {
	{ action = "Emote", text = "EMOTE" },
	{ action = "Moo", text = "MOO" },
	{ action = "Sprint", text = "SPRINT" },
	{ action = "Kick", text = "KICK" },
}
for index, spec in SATELLITES do
	spec.angle = ARC_START + (index - 1) * (ARC_END - ARC_START) / (#SATELLITES - 1)
end

local EMOTES = {
	{ action = "EmoteHeart", glyph = "❤" },
	{ action = "EmoteCheer", glyph = "✨" },
	{ action = "EmoteSnooze", glyph = "💤" },
}

-- Roblox TouchJumpController layout, used until (or when) the native button isn't available, e.g. on desktop.
local function fallbackJump(screen: Vector2): (Vector2, number)
	local small = math.min(screen.X, screen.Y) <= 500
	local size = if small then 70 else 120
	local offset = if small then Vector2.new(95, 90) else Vector2.new(170, 210)
	return Vector2.new(screen.X - offset.X + size / 2, screen.Y - offset.Y + size / 2), size
end

local function findJumpButton(playerGui: Instance): GuiObject?
	local touchGui = playerGui:FindFirstChild("TouchGui")
	local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local jump = frame and frame:FindFirstChild("JumpButton")
	return if jump and jump:IsA("GuiObject") then jump else nil
end

-- Round button with a caption; the slot grows to the minimum touch target, the visual keeps its size.
local function satellite(parent: Instance, ctx, spec): ImageButton
	local slot, visual = Util.button({
		Name = spec.action,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(SATELLITE, SATELLITE),
		Parent = parent,
	}, {
		OnActivated = function()
			if spec.action == "Emote" then
				ctx.state:toggle("emoteFlyout")
			end
			ctx.fire(spec.action)
		end,
	})
	visual.Size = UDim2.fromOffset(SATELLITE, SATELLITE)
	local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = "full", Border = SATELLITE_BORDER, Parent = visual })
	Util.label({ Text = spec.text, TextSize = 10, Size = UDim2.fromScale(1, 1), Parent = face })
	return slot
end

return function(parent: Instance, ctx)
	local state = ctx.state
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local arc = Util.frame({ Name = "ActionArc", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = parent })

	local slots = {}
	for _, spec in SATELLITES do
		slots[spec.action] = satellite(arc, ctx, spec)
	end

	-- Emote flyout: a row of quick emotes above the Emote satellite, right-aligned so it never leaves the screen.
	local flyout = Util.frame({
		Name = "EmoteFlyout",
		AnchorPoint = Vector2.new(1, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, FLYOUT_BUTTON),
		Visible = false,
		Parent = arc,
	})
	Util.list(flyout, Enum.FillDirection.Horizontal, FLYOUT_GAP)
	local flyoutSlots = {}
	for index, spec in EMOTES do
		local slot, visual = Util.button({
			Name = spec.action,
			Size = UDim2.fromOffset(FLYOUT_BUTTON, FLYOUT_BUTTON),
			LayoutOrder = index,
			Parent = flyout,
		}, {
			OnActivated = function()
				state:set("emoteFlyout", false)
				ctx.fire(spec.action)
			end,
		})
		visual.Size = UDim2.fromOffset(FLYOUT_BUTTON, FLYOUT_BUTTON)
		local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = "full", Border = 4, Parent = visual })
		Util.label({ Text = spec.glyph, TextSize = 18, Size = UDim2.fromScale(1, 1), Parent = face })
		table.insert(flyoutSlots, slot)
	end

	local jumpButton: GuiObject? = nil
	local jumpConnections: { RBXScriptConnection } = {}

	local function place()
		local scale = ctx.getScale()
		local root = arc.Parent :: GuiObject
		local rootOrigin = root.AbsolutePosition
		local screen = workspace.CurrentCamera.ViewportSize

		local centre, size
		if jumpButton and jumpButton.AbsoluteSize.X > 0 then
			centre, size = jumpButton.AbsolutePosition + jumpButton.AbsoluteSize / 2, jumpButton.AbsoluteSize.X
		else
			centre, size = fallbackJump(screen)
		end
		-- Both are screen-space AbsolutePositions, so the native button's own insets don't matter.
		local virtualCentre = (centre - rootOrigin) / scale
		local radius = size / 2 / scale + CLEARANCE + SATELLITE / 2

		local hit = math.max(SATELLITE, Theme.MinTouchTarget / scale)
		local bounds = arc.AbsoluteSize / scale
		local points = {}
		local shift = Vector2.zero
		for index, spec in SATELLITES do
			local theta = math.rad(spec.angle)
			local point = virtualCentre + Vector2.new(math.cos(theta), -math.sin(theta)) * radius
			points[index] = point
			shift = shift:Max(point + Vector2.one * hit / 2 - bounds)
		end
		for index, spec in SATELLITES do
			local point = points[index] - shift
			local slot = slots[spec.action]
			slot.Size = UDim2.fromOffset(hit, hit)
			slot.Position = UDim2.fromOffset(point.X, point.Y)
		end

		local flyoutHit = math.max(FLYOUT_BUTTON, Theme.MinTouchTarget / scale)
		for _, slot in flyoutSlots do
			slot.Size = UDim2.fromOffset(flyoutHit, flyoutHit)
		end
		flyout.Size = UDim2.fromOffset(0, flyoutHit)
		local emote = slots.Emote.Position
		flyout.Position = UDim2.fromOffset(emote.X.Offset + SATELLITE / 2, emote.Y.Offset - SATELLITE / 2 - FLYOUT_GAP)
	end

	local function bindJump()
		for _, connection in jumpConnections do
			connection:Disconnect()
		end
		table.clear(jumpConnections)
		jumpButton = findJumpButton(playerGui)
		if jumpButton then
			table.insert(jumpConnections, jumpButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(place))
			table.insert(jumpConnections, jumpButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(place))
			table.insert(jumpConnections, jumpButton.AncestryChanged:Connect(bindJump))
		end
		place()
	end

	-- The PlayerModule builds TouchGui lazily (and rebuilds it when the input type changes).
	playerGui.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "JumpButton" then
			task.defer(bindJump)
		end
	end)
	arc:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
	bindJump()

	local function updateVisible()
		arc.Visible = UserInputService.TouchEnabled or state:get("safeZones")
	end
	UserInputService.LastInputTypeChanged:Connect(updateVisible)
	state:observe("safeZones", updateVisible)

	state:observe("emoteFlyout", function(open)
		flyout.Visible = open == true
	end)

	return arc
end
