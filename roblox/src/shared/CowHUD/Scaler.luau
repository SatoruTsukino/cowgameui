-- Resolution / aspect-ratio scaling (port of resizeUI() in index.html).
--
-- The root frame is sized to a virtual canvas whose height is ~720px and whose width follows the
-- real aspect ratio, then a UIScale maps it onto the screen. Children are authored in virtual px and
-- anchored with Scale positions, so ultrawide screens gain space at the edges and nothing stretches.

local UserInputService = game:GetService("UserInputService")

local Scaler = {}

export type Scaler = {
	scale: number,
	virtualSize: Vector2,
	connection: RBXScriptConnection,
}

function Scaler.attach(screenGui: ScreenGui, root: GuiObject, config, onChanged: ((Scaler) -> ())?): Scaler
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = root

	local scaler = { scale = 1, virtualSize = Vector2.zero } :: any

	local function update()
		local screen = screenGui.AbsoluteSize -- already excludes safe-area / top bar insets
		if screen.X <= 0 or screen.Y <= 0 then
			return
		end
		local minScale = if UserInputService.TouchEnabled then config.TouchMinScale else config.MinScale
		local scale = math.clamp(screen.Y / config.ReferenceHeight, minScale, config.MaxScale)
		scaler.scale = scale
		scaler.virtualSize = screen / scale
		uiScale.Scale = scale
		root.Size = UDim2.fromOffset(scaler.virtualSize.X, scaler.virtualSize.Y)
		if onChanged then
			onChanged(scaler)
		end
	end

	scaler.connection = screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	update()
	return scaler
end

return Scaler
