--[[
	Mobile action arc (DESIGN_SYSTEM_AND_SPEC §2C): Emote, Moo, Sprint and Kick satellites orbiting Roblox's
	native touch Jump button. The wireframe's Jump and thumbstick are placeholders for the native controls,
	so this module never draws a Jump; it finds PlayerGui.TouchGui…JumpButton and centres the arc on it.

	Geometry (virtual px): radius = jumpHalf + 24 (finger clearance) + 28 (satellite half), as in the spec
	(92 = 40 + 24 + 28 for the 80px wireframe Jump). Angles are measured counter-clockwise from east, evenly
	spread over 60°–200° so the arc stays on screen beside Roblox's bottom-right Jump on small phones while 44pt
	hit areas keep ≥ 8px apart (verified for 360–1440px tall screens). If the arc would still cross a screen edge
	(large scales), the whole arc shifts inward so its spacing is kept.

	Shown on touch devices only, and hidden in build mode. Tapping Emote swaps Moo/Sprint/Kick for three quick emotes in the same slots.
	Fires: Emote (toggles the quick emotes), Moo, Sprint, Kick, EmoteHeart, EmoteCheer, EmoteSnooze.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)

local SATELLITE = 56 -- set from Theme.size("Satellite") when the arc is built (64 on phones)
local SATELLITE_BORDER = 5
local CLEARANCE = 24
local FLYOUT_BUTTON = 48 -- quick emotes: w-10 in the wireframe, raised so the glyphs read at phone scale

local ARC_START, ARC_END = 60, 200

-- Top of the thumb arc to the bottom: Emote (opens quick emotes) · Moo · Sprint (nearest the thumb rest) · Kick
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
local function satellite(parent: Instance, ctx, spec): (ImageButton, TextLabel)
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
	local caption = Util.label({ Text = spec.text, TextSize = 10, Size = UDim2.fromScale(1, 1), Parent = face })
	return slot, caption
end

return function(parent: Instance, ctx)
	SATELLITE = Theme.size("Satellite")
	local state = ctx.state
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local arc = Util.frame({ Name = "ActionArc", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = parent })

	local slots = {}
	local emoteCaption
	for _, spec in SATELLITES do
		local slot, caption = satellite(arc, ctx, spec)
		slots[spec.action] = slot
		if spec.action == "Emote" then
			emoteCaption = caption
		end
	end

	-- Quick emotes: tapping Emote swaps Moo/Sprint/Kick for the three emotes in the same arc slots, so each
	-- emote sits one thumb-step from Emote with the arc's verified spacing; tapping Emote again (or an emote) closes.
	local emoteSlots = {}
	for index, spec in EMOTES do
		local slot, visual = Util.button({
			Name = spec.action,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(FLYOUT_BUTTON, FLYOUT_BUTTON),
			Visible = false,
			Parent = arc,
		}, {
			OnActivated = function()
				state:set("emoteFlyout", false)
				ctx.fire(spec.action)
			end,
		})
		visual.Size = UDim2.fromOffset(FLYOUT_BUTTON, FLYOUT_BUTTON)
		local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = "full", Border = 4, Parent = visual })
		Util.label({ Text = spec.glyph, TextSize = 20, Size = UDim2.fromScale(1, 1), Parent = face })
		emoteSlots[index] = slot
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

		-- Quick emote i takes the slot of satellite i + 1 (Moo, Sprint, Kick).
		for index, slot in emoteSlots do
			slot.Size = UDim2.fromOffset(hit, hit)
			slot.Position = slots[SATELLITES[index + 1].action].Position
		end
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

	-- Touch only (desktop/console use keys and buttons), and never in build mode.
	local function updateVisible()
		arc.Visible = UserInputService.TouchEnabled and state:get("mode") ~= "build"
		if not arc.Visible then
			state:set("emoteFlyout", false)
		end
	end
	UserInputService.LastInputTypeChanged:Connect(updateVisible)
	state:observe("mode", updateVisible)

	state:observe("emoteFlyout", function(open)
		open = open == true
		for index, slot in emoteSlots do
			slots[SATELLITES[index + 1].action].Visible = not open
			slot.Visible = open
		end
		emoteCaption.Text = if open then "BACK" else "EMOTE"
	end)

	return arc
end
