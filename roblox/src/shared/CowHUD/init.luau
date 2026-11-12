--[[
	CowHUD: Roblox port of the Cozy Cow HUD wireframe (index.html V4).

	local hud = CowHUD.mount(Players.LocalPlayer, { placeholderPanels = true })
	hud.ActionTriggered:Connect(function(action: string) ... end)
	hud.State:set("compact", true)
	hud:Destroy()

	Actions: Profile, Herd, Calories, Upgrades, Settings, Inventory, Closet, Trade, Bulletin, AreaActions
	State keys: compact, bulletinVisible, safeZones (UI) + data keys fed by Bindings (see Bindings.luau)
]]

local Theme = require(script.Theme)
local Util = require(script.Util)
local State = require(script.State)
local Scaler = require(script.Scaler)
local Bindings = require(script.Bindings)
local Layout = require(script.Layout)

local Components = script.Components
local TopLeft = require(Components.TopLeft)
local TopRight = require(Components.TopRight)
local Bulletin = require(Components.Bulletin)
local Sidebars = require(Components.Sidebars)
local Bottom = require(Components.Bottom)
local Overlays = require(Components.Overlays)

local DEFAULT_STATE = {
	-- UI
	compact = false,
	bulletinVisible = true,
	safeZones = false,
	bulletinCrowded = false, -- derived: screen too narrow for the full bulletin
	-- menu = { anchor, side, items } | nil
	-- panel = action name | nil

	-- Data (overwritten by Bindings)
	calories = 0,
	rebirth = 0,
	grazingArea = "Clover Meadow",
	grazingProgress = 0,
	hp = 100,
	maxHp = 100,
	cyclePhase = "DAY",
	cycleTimeLeft = 0,
	eventTimeLeft = 0,
	eventProgress = 0,
	boostTimeLeft = 0,
}

export type Options = {
	-- Open a "Coming soon" panel for actions without a built-in panel (default true).
	placeholderPanels: boolean?,
}

local CowHUD = {}

function CowHUD.mount(player: Player, options: Options?)
	local opts = options or {}
	local state = State.new(DEFAULT_STATE)
	local actionEvent = Instance.new("BindableEvent")

	local screenGui = Util.new("ScreenGui", {
		Name = "CowHUD",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		-- Notch-safe only; the topbar row is shared with core buttons and avoided per-element by Layout.
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	})
	local root = Util.frame({ Name = "Root", Parent = screenGui })

	local ctx = {} :: any
	ctx.state = state

	local scaler
	function ctx.getScale(): number
		return scaler.scale
	end

	function ctx.trigger(action: string)
		state:set("menu", nil)
		actionEvent:Fire(action)
		if action == "Settings" or opts.placeholderPanels ~= false then
			state:set("panel", action)
		end
	end

	function ctx.toggleMenu(anchor: GuiObject, side: string, items: { string })
		local current = state:get("menu")
		if current and current.anchor == anchor then
			state:set("menu", nil)
		else
			state:set("menu", { anchor = anchor, side = side, items = items })
		end
	end

	local hudLayer = Util.frame({ Name = "HUD", Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = root })
	local topLeft = TopLeft(hudLayer, ctx)
	local topRight = TopRight(hudLayer, ctx)
	local bulletin = Bulletin(hudLayer, ctx)
	local sidebars = Sidebars(hudLayer, ctx)
	Bottom(hudLayer, ctx)
	Overlays(root, ctx)

	local layout
	scaler = Scaler.attach(screenGui, root, Theme.Scale, function()
		state:set("menu", nil) -- menu positions are computed once; drop them on resize
		if layout then
			layout.schedule()
		end
	end)
	layout = Layout.attach(root, scaler, state, {
		topLeft = topLeft,
		topRight = topRight,
		bulletin = bulletin,
		leftSidebar = sidebars.left,
		rightSidebar = sidebars.right,
	})
	layout.schedule()

	local stopBindings = Bindings.start(player, state)

	screenGui.Parent = player:WaitForChild("PlayerGui")

	local hud = {
		State = state,
		ActionTriggered = actionEvent.Event,
		ScreenGui = screenGui,
	}

	function hud.Destroy(_self)
		stopBindings()
		scaler.connection:Disconnect()
		layout.destroy()
		screenGui:Destroy()
		actionEvent:Destroy()
	end

	return hud
end

return CowHUD
