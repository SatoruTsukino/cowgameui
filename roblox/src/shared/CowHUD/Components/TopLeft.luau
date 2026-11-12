-- Top-left cluster: cow profile (+ herd badge, rebirth chip), grazing leaf bar, HP pill.

local TweenService = game:GetService("TweenService")

local CowHUD = script.Parent.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)
local C = Theme.Color

return function(parent: Instance, ctx)
	local state = ctx.state

	local cluster = Util.frame({
		Name = "TopLeft",
		Position = UDim2.fromOffset(Theme.Margin, Theme.Margin),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 2,
		Parent = parent,
	})
	Util.list(cluster, Enum.FillDirection.Horizontal, 12)

	-- Compact vitals (phase 5): profile 88 (was w-28 112), bars 208×32 (was w-64 h-10), so the cluster takes
	-- ~35% less of the screen; its height matches the label + two bars exactly.
	-- Cow profile (88×88, rounded 26, border-6)
	local _, profile = Util.button({ Name = "Profile", Size = UDim2.fromOffset(88, 88), LayoutOrder = 1, Parent = cluster }, {
		HoverScale = 1.05,
		OnActivated = function()
			ctx.trigger("Profile")
		end,
	})
	local _, face = Util.box({ Size = UDim2.fromScale(1, 1), Radius = 26, Border = 6, Parent = profile })
	Util.label({ Text = "COW", TextSize = 16, Size = UDim2.fromScale(1, 1), Parent = face })

	-- "+ HERD" badge (-top-3 -right-3), shown in compact mode where the right sidebar is hidden.
	local herdBadge, badgeVisual = Util.button({
		Name = "HerdBadge",
		Size = UDim2.fromOffset(80, 28),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 12, 0, -12),
		ZIndex = 3,
		Parent = profile,
	}, {
		OnActivated = function()
			ctx.trigger("Herd")
		end,
	})
	local _, badgeFace = Util.box({
		Size = UDim2.fromScale(1, 1),
		Radius = "full",
		Border = 4,
		BorderColor = C.Card,
		Fill = C.Text,
		Parent = badgeVisual,
	})
	Util.label({ Text = "+ HERD", TextSize = 10, TextColor3 = C.Card, Size = UDim2.fromScale(1, 1), Parent = badgeFace })

	-- Rebirth chip (-bottom-3.5, centred)
	local _, chipFace = Util.box({
		Name = "RebirthChip",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 12),
		AutomaticSize = Enum.AutomaticSize.XY,
		Radius = 12,
		Border = 4,
		BorderColor = C.Card,
		Fill = C.Border,
		Padding = { 12, 4 },
		ZIndex = 3,
		Parent = profile,
	})
	local rebirthLabel = Util.label({ TextSize = 10, TextColor3 = C.Card, Parent = chipFace })

	-- Vitals column (208 wide, gap-2; Layout narrows it to 160 on small canvases)
	local vitals = Util.frame({
		Name = "Vitals",
		Size = UDim2.fromOffset(208, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = cluster,
	})
	Util.list(vitals, Enum.FillDirection.Vertical, 8)

	local grazing = Util.frame({
		Name = "Grazing",
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = vitals,
	})
	Util.list(grazing, Enum.FillDirection.Vertical, 2)

	local areaLabel = Util.label({
		Size = UDim2.new(1, 0, 0, 14),
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 1,
		Parent = grazing,
	})
	Util.paddingEach(areaLabel, 4, 0, 4, 0)

	-- Leaf bar: border-5, TL/BR fully round, TR/BL 6; 3px gap; fill keeps TL/BR round, TR/BL sharp.
	local leaf = Util.frame({ Name = "GrazingBar", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 2, Parent = grazing })
	Util.shape({ Name = "Border", Color = C.Border, Radius = 16, Corners = { TR = 6, BL = 6 }, Parent = leaf })
	local track = Util.shape({
		Name = "Track",
		Size = UDim2.new(1, -10, 1, -10),
		Position = UDim2.fromOffset(5, 5),
		Color = C.Card,
		Radius = 11,
		Corners = { TR = 1, BL = 1 },
		Parent = leaf,
	})
	local fillArea = Util.frame({
		Name = "FillArea",
		Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.fromOffset(3, 3),
		ZIndex = 2,
		Parent = track,
	})
	local leafFill = Util.shape({
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		Color = C.Fill,
		Radius = 8,
		Corners = { TR = 0, BL = 0 },
		Parent = fillArea,
	})
	local leafLabel = Util.label({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -12, 1, 0),
		TextSize = 12,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = track,
	})

	-- HP pill (border-5 gray-500, p-[3px])
	local _, hpTrack = Util.box({
		Name = "HealthBar",
		Size = UDim2.new(1, 0, 0, 32),
		Radius = "full",
		Border = 5,
		BorderColor = C.Accent,
		Padding = { 3, 3 },
		LayoutOrder = 2,
		Parent = vitals,
	})
	local hpFill = Util.frame({ Name = "Fill", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.Fill, Parent = hpTrack })
	Util.corner(hpFill, "full")
	local hpLabel = Util.label({
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -8, 1, 0),
		TextSize = 10,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = hpTrack,
	})

	-- Bindings
	state:observe("compact", function(compact)
		herdBadge.Visible = compact
	end)
	state:observe("rebirth", function(rebirth)
		rebirthLabel.Text = "REBIRTH " .. tostring(rebirth)
	end)
	state:observe("grazingArea", function(area)
		areaLabel.Text = "GRAZING: " .. string.upper(tostring(area))
	end)
	state:observe("grazingProgress", function(progress)
		local p = math.clamp(tonumber(progress) or 0, 0, 1)
		TweenService:Create(leafFill, Theme.Tween.Quick, { Size = UDim2.fromScale(p, 1) }):Play()
		leafLabel.Text = string.format("%d%%", math.round(p * 100))
	end)

	local function refreshHealth()
		local hp, maxHp = state:get("hp") or 0, state:get("maxHp") or 100
		local p = if maxHp > 0 then math.clamp(hp / maxHp, 0, 1) else 0
		TweenService:Create(hpFill, Theme.Tween.Quick, { Size = UDim2.fromScale(p, 1) }):Play()
		hpLabel.Text = "HP " .. tostring(math.ceil(hp))
	end
	state:observe("hp", refreshHealth)
	state:observe("maxHp", refreshHealth)

	return cluster, vitals
end
