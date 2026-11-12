-- Design tokens mirrored from index.html (Tailwind gray scale, Nunito Black).

local Theme = {}

Theme.Color = {
	White = Color3.fromHex("#ffffff"),
	Gray100 = Color3.fromHex("#f3f4f6"),
	Gray200 = Color3.fromHex("#e5e7eb"),
	Gray300 = Color3.fromHex("#d1d5db"),
	Gray400 = Color3.fromHex("#9ca3af"),
	Gray500 = Color3.fromHex("#6b7280"),
	Gray600 = Color3.fromHex("#4b5563"),
}

Theme.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Heavy)

-- Virtual canvas: everything is authored in 720p pixels, then scaled by viewport height.
-- MinScale keeps 9-10px labels legible on short phone screens (the virtual canvas grows instead).
Theme.Scale = {
	ReferenceHeight = 720,
	MinScale = 0.6,
	MaxScale = 4,
}

Theme.Margin = 32 -- Tailwind `top-8` / `left-8`
Theme.ClusterGap = 16 -- minimum breathing room between top clusters and the bulletin
Theme.SidebarOffset = 160 -- sidebars start this far below the top-left cluster (HTML: top-48 - top-8)
Theme.TopRowHeight = 56 -- calories pill / settings height, centred on the core topbar buttons
Theme.TopRowMinY = 12 -- closest the topbar row may sit to the screen top

Theme.Tween = {
	-- Approximates cubic-bezier(0.34, 1.56, 0.64, 1) from `.hud-spring`.
	Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

return Theme
