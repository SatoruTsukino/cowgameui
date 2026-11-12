--[[
	Positions the top row around Roblox's core topbar buttons and guards the bulletin against collisions.

	GuiService.TopbarInset is the free strip between the left and right core buttons (screen px):
	  Min.X = right edge of the left core buttons, Max.X = left edge of the right core buttons, Max.Y = topbar bottom.
	- Top-right cluster + bulletin share the topbar row; top-right stops short of any right-side core buttons.
	- Top-left drops below the topbar when left core buttons occupy its corner (sidebars follow it).
	- Right sidebar (Herd, Trade) hangs 112px below the top row (HTML: top-32 vs the top-right's top-4).
	- The bulletin never collapses on its own (compact is only ever the player's choice). It stays in the top row,
	  centred when it can be, slid sideways to clear the core buttons and the top-right cluster otherwise; when it
	  would sit over the vitals, the vitals (and left sidebar) move down below it instead.
]]

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)

local Layout = {}

export type Refs = {
	topLeft: GuiObject,
	vitals: GuiObject, -- grazing + HP column inside topLeft
	topRight: GuiObject,
	bulletin: { wrapper: GuiObject, scale: UIScale, edgeRoom: number, setPosition: (number, number) -> () },
	leftSidebar: GuiObject,
	rightSidebar: GuiObject,
	-- Build mode top bar + tools reuse the same row and top-bar clearance as the pasture HUD.
	building: { left: GuiObject, centre: GuiObject, right: GuiObject, tools: GuiObject },
}

local BUILD_BAR_HEIGHT = 48 -- h-12

-- Vital bars: full 208px on 16:9-and-wider canvases at full height, down to 160px on narrow (4:3, 960 wide)
-- or short (phones, ~520 tall) canvases; linear in between, whichever constraint is tighter.
local VITALS_MAX, VITALS_MIN = 208, 160
local function vitalsWidth(virtualSize: Vector2): number
	local byWidth = math.clamp((virtualSize.X - 960) / (1280 - 960), 0, 1)
	local byHeight = math.clamp((virtualSize.Y - 520) / (720 - 520), 0, 1)
	return math.round(VITALS_MIN + (VITALS_MAX - VITALS_MIN) * math.min(byWidth, byHeight))
end
local BUILD_TOOLS_GAP_TOP = 16 -- HTML: tools at top-20, bar ends at top-4 + h-12
local RIGHT_SIDEBAR_DROP = 112 -- HTML: #rightSidebar top-32 minus #topRightHud top-4
local ACTION_ARC_RESERVE = Theme.Margin + 256 + 16 -- touch: build tools stay above the mobile action arc

function Layout.attach(root: GuiObject, scaler, refs: Refs)
	local pending = false

	local function apply()
		pending = false
		local scale = scaler.scale
		local virtualWidth = scaler.virtualSize.X
		if virtualWidth <= 0 then
			return
		end

		-- Core topbar in virtual px relative to root (root top == screen top under DeviceSafeInsets).
		local inset = GuiService.TopbarInset
		local rootX = root.AbsolutePosition.X
		local barTop = inset.Min.Y / scale
		local barBottom = inset.Max.Y / scale
		local leftCoreEdge = (inset.Min.X - rootX) / scale
		local rightCoreEdge = (inset.Max.X - rootX) / scale

		-- Topbar row: centre the 56px top-row controls on the core buttons, never closer than TopRowMinY to the edge.
		local rowY = math.max(Theme.TopRowMinY, (barTop + barBottom - Theme.TopRowHeight) / 2)
		local topRightX = math.min(virtualWidth - Theme.Margin, rightCoreEdge - Theme.ClusterGap)
		refs.topRight.Position = UDim2.fromOffset(topRightX, rowY)
		refs.vitals.Size = UDim2.fromOffset(vitalsWidth(scaler.virtualSize), refs.vitals.Size.Y.Offset)

		-- Bulletin: top row, centred if possible, otherwise slid to fit between the core buttons and the top-right.
		local bulletin = refs.bulletin
		local wrapper = bulletin.wrapper
		local animScale = math.max(bulletin.scale.Scale, 0.01)
		local bulletinSize = wrapper.AbsoluteSize / (scale * animScale) - Vector2.one * 2 * bulletin.edgeRoom
		local leftBound = math.max(Theme.Margin, leftCoreEdge + Theme.ClusterGap)
		local rightBound = topRightX - refs.topRight.AbsoluteSize.X / scale - Theme.ClusterGap
		local half = bulletinSize.X / 2
		local bulletinX = math.clamp(virtualWidth / 2, leftBound + half, math.max(leftBound + half, rightBound - half))
		bulletin.setPosition(bulletinX, rowY)

		-- Top-left: below the core buttons when they occupy its corner, and below the bulletin when it sits above.
		local leftBlocked = leftCoreEdge > Theme.Margin
		local topLeftY = if leftBlocked then math.max(Theme.Margin, barBottom + Theme.ClusterGap) else rowY
		local topLeftRight = Theme.Margin + refs.topLeft.AbsoluteSize.X / scale
		if wrapper.Visible and bulletinX - half < topLeftRight then
			topLeftY = math.max(topLeftY, rowY + bulletinSize.Y + Theme.ClusterGap)
		end
		refs.topLeft.Position = UDim2.fromOffset(Theme.Margin, topLeftY)

		local barY = rowY + (Theme.TopRowHeight - BUILD_BAR_HEIGHT) / 2
		local building = refs.building
		building.left.Position = UDim2.fromOffset(Theme.Margin, if leftBlocked then math.max(Theme.Margin, barBottom + Theme.ClusterGap) else barY)
		building.centre.Position = UDim2.fromOffset(virtualWidth / 2, barY)
		building.right.Position = UDim2.fromOffset(topRightX, barY)
		local toolsY = barY + BUILD_BAR_HEIGHT + BUILD_TOOLS_GAP_TOP
		local toolsReserve = if UserInputService.TouchEnabled then ACTION_ARC_RESERVE else Theme.Margin
		building.tools.Position = UDim2.fromOffset(topRightX, toolsY)
		building.tools.Size = UDim2.fromOffset(0, math.max(56, scaler.virtualSize.Y - toolsY - toolsReserve))

		refs.leftSidebar.Position = UDim2.fromOffset(Theme.Margin, topLeftY + Theme.SidebarOffset)
		refs.rightSidebar.Position = UDim2.new(1, -Theme.Margin, 0, rowY + RIGHT_SIDEBAR_DROP)
	end

	local function schedule()
		if not pending then
			pending = true
			task.defer(apply)
		end
	end

	local connections = {
		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(schedule),
		refs.topLeft:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule),
		refs.topRight:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule),
		refs.bulletin.wrapper:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule),
		refs.bulletin.wrapper:GetPropertyChangedSignal("Visible"):Connect(schedule),
	}

	return {
		schedule = schedule,
		destroy = function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end,
	}
end

return Layout
