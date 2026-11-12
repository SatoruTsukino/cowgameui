--[[
	Positions the top row around Roblox's core topbar buttons and guards the bulletin against collisions.

	GuiService.TopbarInset is the free strip between the left and right core buttons (screen px):
	  Min.X = right edge of the left core buttons, Max.X = left edge of the right core buttons, Max.Y = topbar bottom.
	- Top-right cluster + bulletin share the topbar row; top-right stops short of any right-side core buttons.
	- Top-left drops below the topbar when left core buttons occupy its corner (sidebars follow it).
	- The bulletin collapses to its pill when the full card would overlap a neighbour (narrow aspect ratios).
]]

local GuiService = game:GetService("GuiService")

local Theme = require(script.Parent.Theme)

local Layout = {}

export type Refs = {
	topLeft: GuiObject,
	topRight: GuiObject,
	bulletin: { full: GuiObject, scale: UIScale, setTop: (number) -> () },
	leftSidebar: GuiObject,
	rightSidebar: GuiObject,
	-- Build mode top bar + tools reuse the same row and top-bar clearance as the pasture HUD.
	building: { left: GuiObject, centre: GuiObject, right: GuiObject, tools: GuiObject },
}

local BUILD_BAR_HEIGHT = 48 -- h-12
local BUILD_TOOLS_GAP = 24
local RIGHT_SAFE_ZONE = Theme.Margin + 256 + 16 -- build tools stay strictly above the right safe zone (C5)

function Layout.attach(root: GuiObject, scaler, state, refs: Refs)
	local fullWidth = 0 -- last measured full-card width (virtual px), kept while the card is hidden
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
		refs.bulletin.setTop(rowY)

		local leftBlocked = leftCoreEdge > Theme.Margin
		local topLeftY = if leftBlocked then math.max(Theme.Margin, barBottom + Theme.ClusterGap) else rowY
		refs.topLeft.Position = UDim2.fromOffset(Theme.Margin, topLeftY)

		local barY = rowY + (Theme.TopRowHeight - BUILD_BAR_HEIGHT) / 2
		local building = refs.building
		building.left.Position = UDim2.fromOffset(Theme.Margin, if leftBlocked then topLeftY else barY)
		building.centre.Position = UDim2.fromOffset(virtualWidth / 2, barY)
		building.right.Position = UDim2.fromOffset(topRightX, barY)
		local toolsY = barY + BUILD_BAR_HEIGHT + BUILD_TOOLS_GAP
		building.tools.Position = UDim2.fromOffset(topRightX, toolsY)
		building.tools.Size = UDim2.fromOffset(0, math.max(56, scaler.virtualSize.Y - toolsY - RIGHT_SAFE_ZONE))

		local sidebarY = topLeftY + Theme.SidebarOffset
		refs.leftSidebar.Position = UDim2.fromOffset(Theme.Margin, sidebarY)
		refs.rightSidebar.Position = UDim2.new(1, -Theme.Margin, 0, sidebarY)

		-- Bulletin collision guard
		local full = refs.bulletin.full
		if full.Visible and full.AbsoluteSize.X > 0 then
			fullWidth = full.AbsoluteSize.X / (scale * refs.bulletin.scale.Scale)
		end
		local leftLimit = math.max(Theme.Margin + refs.topLeft.AbsoluteSize.X / scale, leftCoreEdge) + Theme.ClusterGap
		local rightLimit = topRightX - refs.topRight.AbsoluteSize.X / scale - Theme.ClusterGap
		local centre, half = virtualWidth / 2, fullWidth / 2
		state:set("bulletinCrowded", centre - half < leftLimit or centre + half > rightLimit)
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
		refs.bulletin.full:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule),
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
