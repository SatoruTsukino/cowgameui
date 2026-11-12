-- Instance factory + reusable visual primitives for the HUD.

local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local C = Theme.Color

local Util = {}

local function merge(defaults: { [string]: any }, props: { [string]: any }?)
	local merged = table.clone(defaults)
	if props then
		for key, value in props do
			merged[key] = value
		end
	end
	return merged
end

-- Instance.new with a props table; `Parent` is applied last so properties are set before replication.
function Util.new(className: string, props: { [string]: any }?): any
	local instance = Instance.new(className)
	local parent = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			elseif Theme.isToken(value) then
				Theme.paint(instance, key, value)
			else
				(instance :: any)[key] = value
			end
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

-- GuiObject with sane defaults: no legacy border, transparent unless a colour is given, blank buttons.
function Util.gui(className: string, props: { [string]: any }?): any
	local defaults: { [string]: any } = {
		BorderSizePixel = 0,
		BackgroundTransparency = if props and props.BackgroundColor3 then 0 else 1,
	}
	if className == "ImageButton" then
		defaults.Image = ""
		defaults.AutoButtonColor = false
	elseif className == "TextButton" then
		defaults.Text = ""
		defaults.AutoButtonColor = false
	end
	return Util.new(className, merge(defaults, props))
end

function Util.frame(props: { [string]: any }?): Frame
	return Util.gui("Frame", props)
end

-- radius: pixels, or "full" for pill/circle.
function Util.corner(parent: Instance, radius: number | string)
	return Util.new("UICorner", {
		CornerRadius = if radius == "full" then UDim.new(1, 0) else UDim.new(0, radius :: number),
		Parent = parent,
	})
end

function Util.padding(parent: Instance, x: number, y: number)
	return Util.paddingEach(parent, x, y, x, y)
end

function Util.paddingEach(parent: Instance, left: number, top: number, right: number, bottom: number)
	return Util.new("UIPadding", {
		PaddingLeft = UDim.new(0, left),
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		Parent = parent,
	})
end

-- Negative gaps are allowed (Tailwind `-mt-*` overlaps).
function Util.list(parent: Instance, direction: Enum.FillDirection, gap: number?, extra: { [string]: any }?)
	return Util.new(
		"UIListLayout",
		merge({
			FillDirection = direction,
			Padding = UDim.new(0, gap or 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = parent,
		}, extra)
	)
end

function Util.label(props: { [string]: any }): TextLabel
	return Util.gui(
		"TextLabel",
		merge({
			FontFace = Theme.Font,
			TextColor3 = C.Text,
			TextSize = 12,
			Text = "",
			AutomaticSize = if props.Size then Enum.AutomaticSize.None else Enum.AutomaticSize.XY,
		}, props)
	)
end

--[[
	Bordered box matching CSS border-box sizing (UIStroke draws outside the frame, CSS borders draw inside).
	The outer frame is the border colour; the inner frame is the fill, inset by `Border`. Content goes in the inner frame.

	props: Name, Size, Position, AnchorPoint, ZIndex, LayoutOrder, Parent, Visible, ClassName,
	       Radius (px | "full"), Border, BorderColor, Fill, FillTransparency,
	       AutomaticSize, Padding = { x, y }
]]
function Util.box(props: { [string]: any }): (GuiObject, Frame)
	local border = props.Border or 0
	local auto = props.AutomaticSize or Enum.AutomaticSize.None
	local autoX = auto == Enum.AutomaticSize.X or auto == Enum.AutomaticSize.XY
	local autoY = auto == Enum.AutomaticSize.Y or auto == Enum.AutomaticSize.XY

	local outer = Util.gui(props.ClassName or "Frame", {
		Name = props.Name or "Box",
		Size = props.Size or UDim2.new(),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		AutomaticSize = auto,
		BackgroundColor3 = props.BorderColor or C.Border,
		Parent = props.Parent,
	})
	if props.Radius then
		Util.corner(outer, props.Radius)
	end
	if border > 0 then
		Util.padding(outer, border, border)
	end

	local inner = Util.frame({
		Name = "Inner",
		Size = UDim2.new(if autoX then 0 else 1, 0, if autoY then 0 else 1, 0),
		AutomaticSize = auto,
		BackgroundColor3 = props.Fill or C.Card,
		BackgroundTransparency = props.FillTransparency or 0,
		Parent = outer,
	})
	if props.Radius then
		Util.corner(inner, if props.Radius == "full" then "full" else math.max(props.Radius - border, 0))
	end
	if props.Padding then
		Util.padding(inner, props.Padding[1], props.Padding[2])
	end

	return outer, inner
end

--[[
	Solid shape with per-corner radii (UICorner only supports one radius).
	A base frame carries `Radius`; each entry in `Corners` ({ TL/TR/BL/BR = px }) adds a quadrant patch
	with its own radius. Patches overlap past the centre by their radius so their inner corners stay hidden.

	props: Name, Size, Position, AnchorPoint, ZIndex, Parent, Color, Radius, Corners
]]
local QUADRANT_ANCHORS = {
	TL = Vector2.new(0, 0),
	TR = Vector2.new(1, 0),
	BL = Vector2.new(0, 1),
	BR = Vector2.new(1, 1),
}

function Util.shape(props: { [string]: any }): Frame
	local container = Util.frame({
		Name = props.Name or "Shape",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		Parent = props.Parent,
	})

	local function piece(name: string, size: UDim2, anchor: Vector2, radius: number)
		local frame = Util.frame({
			Name = name,
			Size = size,
			AnchorPoint = anchor,
			Position = UDim2.fromScale(anchor.X, anchor.Y),
			BackgroundColor3 = props.Color,
			Parent = container,
		})
		if radius > 0 then
			Util.corner(frame, radius)
		end
	end

	piece("Base", UDim2.fromScale(1, 1), Vector2.zero, props.Radius or 0)
	for corner, radius in props.Corners or {} do
		piece(corner, UDim2.new(0.5, radius, 0.5, radius), QUADRANT_ANCHORS[corner], radius)
	end
	return container
end

--[[
	Interactive slot: a fixed-size hitbox (`slot`) that holds a centred `visual`, which springs on hover and press.
	Keeping the scale on `visual` leaves layouts untouched (Tailwind `hover:scale-*`).

	opts: HoverScale (default 1.1), OnActivated(slot)
]]
function Util.button(props: { [string]: any }, opts: { [string]: any }?): (ImageButton, Frame)
	opts = opts or {}
	local hoverScale = opts.HoverScale or 1.1

	local slot = Util.gui("ImageButton", props)
	local visual = Util.frame({
		Name = "Visual",
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = slot,
	})
	local scale = Util.new("UIScale", { Parent = visual })

	local hovered = false
	local function springTo(target: number)
		TweenService:Create(scale, Theme.Tween.Spring, { Scale = target }):Play()
	end

	slot.MouseEnter:Connect(function()
		hovered = true
		if Theme.hoverAllowed() then
			springTo(hoverScale)
		end
	end)
	slot.MouseLeave:Connect(function()
		hovered = false
		springTo(1)
	end)
	slot.MouseButton1Down:Connect(function()
		springTo(0.95)
	end)
	slot.MouseButton1Up:Connect(function()
		springTo(if hovered and Theme.hoverAllowed() then hoverScale else 1)
	end)
	slot.Activated:Connect(function(input: InputObject)
		-- Touch never fires MouseLeave reliably; reset so the button doesn't stay enlarged.
		if input.UserInputType == Enum.UserInputType.Touch then
			hovered = false
			springTo(1)
		end
		if opts.OnActivated then
			opts.OnActivated(slot)
		end
	end)

	return slot, visual
end

--[[
	Standard squircle button (white fill, gray-400 border, centred caption).
	props: Name, Size, Position, AnchorPoint, LayoutOrder, ZIndex, Parent, Radius, Border, Text, TextSize,
	       TextColor3, HoverScale, OnActivated
]]
function Util.iconButton(props: { [string]: any }): (ImageButton, Frame, Frame, TextLabel)
	local slot, visual = Util.button({
		Name = props.Name,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		Parent = props.Parent,
	}, { HoverScale = props.HoverScale, OnActivated = props.OnActivated })

	local _, face = Util.box({
		Size = UDim2.fromScale(1, 1),
		Radius = props.Radius,
		Border = props.Border or 6,
		Fill = C.Card,
		Parent = visual,
	})
	local label = Util.label({
		Text = props.Text or "",
		TextSize = props.TextSize or 9,
		TextColor3 = props.TextColor3 or C.Text,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = face,
	})
	return slot, visual, face, label
end

-- Sun glyph from the HTML's 24-unit SVG (ring r=4 + 8 rays), built from frames.
function Util.sunIcon(parent: Instance, size: number, color: Theme.Token): Frame
	local unit = size / 24
	local icon = Util.frame({
		Name = "Sun",
		Size = UDim2.fromOffset(size, size),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 2,
		Parent = parent,
	})

	local ring = Util.frame({
		Name = "Ring",
		Size = UDim2.fromOffset(5 * unit, 5 * unit),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = icon,
	})
	Util.corner(ring, "full")
	Util.new("UIStroke", { Color = color, Thickness = 3 * unit, Parent = ring })

	for i = 0, 7 do
		local angle = math.rad(i * 45)
		local ray = Util.frame({
			Name = "Ray",
			Size = UDim2.fromOffset(3 * unit, 5 * unit),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.sin(angle) * 9 * unit, 0.5, -math.cos(angle) * 9 * unit),
			Rotation = i * 45,
			BackgroundColor3 = color,
			Parent = icon,
		})
		Util.corner(ray, "full")
	end
	return icon
end

--[[
	Sizes `target` to fit `text` at `textSize` (Theme.Font) plus `inset` px, keeping its height.
	For spring buttons (Util.button): AutomaticSize can't be used there because the scale-sized visual inside
	the slot feeds back into it and grows unbounded. Measuring yields, so this runs async; the latest call wins.
]]
local fitTokens = setmetatable({}, { __mode = "k" })
function Util.fitWidth(target: GuiObject, text: string, textSize: number, inset: number, minWidth: number?)
	local token = (fitTokens[target] or 0) + 1
	fitTokens[target] = token
	task.spawn(function()
		local params = Instance.new("GetTextBoundsParams")
		params.Text = text
		params.Font = Theme.Font
		params.Size = textSize
		params.Width = math.huge
		local ok, bounds = pcall(TextService.GetTextBoundsAsync, TextService, params)
		if ok and fitTokens[target] == token then
			local width = math.max(minWidth or 0, math.ceil(bounds.X) + inset)
			target.Size = UDim2.new(0, width, target.Size.Y.Scale, target.Size.Y.Offset)
		end
	end)
end

-- 1500 -> "1,500"
function Util.formatNumber(n: number): string
	local sign = if n < 0 then "-" else ""
	local digits = tostring(math.floor(math.abs(n)))
	local grouped = digits:reverse():gsub("%d%d%d", "%0,"):reverse()
	if grouped:sub(1, 1) == "," then
		grouped = grouped:sub(2)
	end
	return sign .. grouped
end

-- 165 -> "02:45"
function Util.clock(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	return string.format("%02d:%02d", s // 60, s % 60)
end

-- 252 -> "4m 12s"
function Util.duration(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	if s < 60 then
		return string.format("%ds", s)
	end
	return string.format("%dm %ds", s // 60, s % 60)
end

return Util
