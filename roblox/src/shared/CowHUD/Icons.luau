--[[
	Line icons traced from the wireframe's 24×24 SVGs (stroke-2, round caps), drawn with plain Frames so they
	scale crisply with the HUD's UIScale (no image assets, no emoji, no glyphs missing from Nunito).

	Icons.draw(name, parent, size, color, weight?) -> Frame
	  name    one of the keys in ICONS
	  size    icon box in virtual px (w-4 = 16, w-5 = 20, w-6 = 24)
	  color   Theme token (live re-theming) or Color3
	  weight  stroke width in SVG units (default 2.25)
]]

local CowHUD = script.Parent
local Theme = require(CowHUD.Theme)
local Util = require(CowHUD.Util)

local Icons = {}

type Pen = {
	line: (number, number, number, number) -> (),
	poly: ({ number }, boolean?) -> (),
	rect: (number, number, number, number) -> (),
	ring: (number, number, number, number?) -> (),
	dot: (number, number, number) -> (),
}

local ICONS: { [string]: (Pen) -> () } = {
	close = function(p)
		p.line(6, 6, 18, 18)
		p.line(18, 6, 6, 18)
	end,
	cog = function(p)
		p.ring(12, 12, 6.5, 12)
		p.ring(12, 12, 2.5, 8)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			p.line(12 + math.cos(a) * 7.5, 12 + math.sin(a) * 7.5, 12 + math.cos(a) * 10, 12 + math.sin(a) * 10)
		end
	end,
	grid = function(p)
		p.rect(3, 3, 7, 7)
		p.rect(14, 3, 7, 7)
		p.rect(14, 14, 7, 7)
		p.rect(3, 14, 7, 7)
	end,
	wood = function(p) -- M4 7h16 M4 12h16 M4 17h16
		p.line(4, 7, 20, 7)
		p.line(4, 12, 20, 12)
		p.line(4, 17, 20, 17)
	end,
	stone = function(p) -- polygon 12 2, 2 8.5, 4 19, 12 22, 20 19, 22 8.5
		p.poly({ 12, 2, 2, 8.5, 4, 19, 12, 22, 20, 19, 22, 8.5 }, true)
	end,
	rotate = function(p) -- circular arrows
		p.poly({ 19, 9.5, 17.3, 6.7, 14.6, 5, 11.5, 4.5, 8.5, 5.3, 6, 7.3, 4.6, 10 })
		p.poly({ 19, 4.5, 19, 9.5, 14, 9.5 })
		p.poly({ 5, 14.5, 6.7, 17.3, 9.4, 19, 12.5, 19.5, 15.5, 18.7, 18, 16.7, 19.4, 14 })
		p.poly({ 5, 19.5, 5, 14.5, 10, 14.5 })
	end,
	paint = function(p) -- paint drop / bottle
		p.poly({ 7, 21, 4.2, 19.8, 3, 17, 3.8, 13.6, 7, 9.5, 7, 9, 8, 7.3, 10, 7.3, 11, 9, 11, 9.5, 14.2, 13.6, 15, 17, 13.8, 19.8, 11, 21 }, true)
	end,
	undo = function(p) -- M3 10h10a5 5 0 015 5v2 M3 10l4-4 M3 10l4 4
		p.poly({ 3, 10, 13, 10, 15.5, 10.7, 17.3, 12.5, 18, 15, 18, 17 })
		p.line(3, 10, 7, 6)
		p.line(3, 10, 7, 14)
	end,
	redo = function(p)
		p.poly({ 21, 10, 11, 10, 8.5, 10.7, 6.7, 12.5, 6, 15, 6, 17 })
		p.line(21, 10, 17, 6)
		p.line(21, 10, 17, 14)
	end,
	trash = function(p)
		p.line(4, 7, 20, 7)
		p.poly({ 5, 7, 6, 19.5, 7.5, 21, 16.5, 21, 18, 19.5, 19, 7 })
		p.poly({ 9, 7, 9, 4, 10, 3, 14, 3, 15, 4, 15, 7 })
		p.line(10, 11, 10, 17)
		p.line(14, 11, 14, 17)
	end,
	fence = function(p) -- M6 3v18 M18 3v18 M3 8h18 M3 16h18
		p.line(6, 3, 6, 21)
		p.line(18, 3, 18, 21)
		p.line(3, 8, 21, 8)
		p.line(3, 16, 21, 16)
	end,
	gate = function(p)
		p.line(4, 4, 4, 20)
		p.line(20, 4, 20, 20)
		p.line(4, 7, 20, 7)
		p.line(4, 17, 20, 17)
		p.line(8, 4, 8, 20)
		p.line(16, 4, 16, 20)
		p.line(4, 17, 20, 7)
	end,
	hay = function(p) -- ellipse end + body + band
		p.ring(8, 12, 4, 10, 7)
		p.poly({ 8, 5, 16, 5, 18.8, 7, 20, 12, 18.8, 17, 16, 19, 8, 19 })
		p.line(14, 5, 14, 19)
	end,
	wall = function(p)
		p.rect(3, 5, 18, 14)
		p.line(3, 12, 21, 12)
		p.line(9, 5, 9, 12)
		p.line(15, 5, 15, 12)
		p.line(6, 12, 6, 19)
		p.line(12, 12, 12, 19)
		p.line(18, 12, 18, 19)
	end,
	lantern = function(p) -- M9 3h6 M12 3v3 M7 9h10l-2 9H9L7 9z M7 9l5-3 5 3 M9 21h6
		p.line(9, 3, 15, 3)
		p.line(12, 3, 12, 6)
		p.poly({ 7, 9, 17, 9, 15, 18, 9, 18 }, true)
		p.poly({ 7, 9, 12, 6, 17, 9 })
		p.line(9, 21, 15, 21)
	end,
	clover = function(p)
		p.dot(9, 9, 3)
		p.dot(15, 9, 3)
		p.dot(9, 15, 3)
		p.dot(15, 15, 3)
		p.line(12, 14, 12, 21)
	end,
}

function Icons.draw(name: string, parent: Instance, size: number, color: any, weight: number?): Frame
	local unit = size / 24
	local thickness = (weight or 2.25) * unit
	local icon = Util.frame({
		Name = "Icon",
		Size = UDim2.fromOffset(size, size),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 2,
		Parent = parent,
	})

	local pen = {} :: Pen
	function pen.line(x1, y1, x2, y2)
		local dx, dy = (x2 - x1) * unit, (y2 - y1) * unit
		local length = math.sqrt(dx * dx + dy * dy)
		local stroke = Util.frame({
			Size = UDim2.fromOffset(length + thickness, thickness), -- + thickness: round caps overlap at joints
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((x1 + x2) / 2 * unit, (y1 + y2) / 2 * unit),
			Rotation = math.deg(math.atan2(dy, dx)),
			BackgroundColor3 = color,
			Parent = icon,
		})
		Util.corner(stroke, "full")
	end
	function pen.poly(points, closed)
		local count = #points // 2
		for i = 1, count - 1 do
			pen.line(points[2 * i - 1], points[2 * i], points[2 * i + 1], points[2 * i + 2])
		end
		if closed then
			pen.line(points[2 * count - 1], points[2 * count], points[1], points[2])
		end
	end
	function pen.rect(x, y, w, h)
		pen.poly({ x, y, x + w, y, x + w, y + h, x, y + h }, true)
	end
	function pen.ring(cx, cy, rx, segments, ry)
		local n = segments or 12
		local points = {}
		for i = 0, n - 1 do
			local a = 2 * math.pi * i / n
			table.insert(points, cx + math.cos(a) * rx)
			table.insert(points, cy + math.sin(a) * (ry or rx))
		end
		pen.poly(points, true)
	end
	function pen.dot(cx, cy, r)
		local dot = Util.frame({
			Size = UDim2.fromOffset(2 * r * unit, 2 * r * unit),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx * unit, cy * unit),
			BackgroundColor3 = color,
			Parent = icon,
		})
		Util.corner(dot, "full")
	end

	local drawIcon = ICONS[name]
	assert(drawIcon, "unknown icon " .. name)
	drawIcon(pen)
	return icon
end

-- Re-colours a drawn icon (e.g. selected vs idle catalog slot) with a Theme token.
function Icons.paint(icon: Frame, color: Theme.Token)
	for _, stroke in icon:GetChildren() do
		if stroke:IsA("GuiObject") then
			Theme.paint(stroke, "BackgroundColor3", color)
		end
	end
end

-- Fixed-size, list-friendly slot holding an icon (for UIListLayout rows).
function Icons.slot(name: string, parent: Instance, size: number, color: any, order: number?): Frame
	local holder = Util.frame({ Name = name, Size = UDim2.fromOffset(size, size), LayoutOrder = order, Parent = parent })
	Icons.draw(name, holder, size, color)
	return holder
end

return Icons
