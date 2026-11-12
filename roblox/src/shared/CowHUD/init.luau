--[[
	CowHUD: Roblox port of the Cozy Cow HUD wireframe (index.html V4).

	local hud = CowHUD.mount(Players.LocalPlayer, { placeholderPanels = true })
	hud.ActionTriggered:Connect(function(action: string) ... end)
	hud.State:set("compact", true)
	hud:Destroy()

	ActionTriggered(action, payload?) actions:
	  HUD:       Profile, Herd, Calories, Upgrades, Settings, Inventory, Closet, Trade, Bulletin, AreaActions
	  Mobile:    Emote, Moo, Sprint, Kick, EmoteHeart, EmoteCheer, EmoteSnooze
	  Mode:      EnterBuild, ExitBuild (whenever state.mode changes: Exit Build button, /build, /normal)
	  Building:  GridSnap, BuildCategory, BuildItem, Rotate, Paint, Undo, Redo, Trash (see Components/Building)
	State keys: mode ("normal" | "build"), compact, bulletinVisible, theme, motion (UI)
	            + data keys fed by Bindings (see Bindings.luau)
]]

local GuiService = game:GetService("GuiService")

local Theme = require(script.Theme)
local Util = require(script.Util)
local State = require(script.State)
local Scaler = require(script.Scaler)
local Bindings = require(script.Bindings)
local Layout = require(script.Layout)
local Commands = require(script.Commands)

local Components = script.Components
local TopLeft = require(Components.TopLeft)
local TopRight = require(Components.TopRight)
local Bulletin = require(Components.Bulletin)
local Sidebars = require(Components.Sidebars)
local Bottom = require(Components.Bottom)
local Overlays = require(Components.Overlays)
local ActionCluster = require(Components.ActionCluster)
local Building = require(Components.Building)

local DEFAULT_STATE = {
	-- UI
	mode = "normal", -- "normal" (pasture HUD) | "build" (construction GUI)
	theme = "Mono", -- Theme.PresetOrder
	motion = "Full", -- Theme.MotionOrder; mount() defaults it from the player's Reduced Motion setting
	emoteFlyout = false,
	gridSnap = 1,
	compact = false,
	bulletinVisible = true,
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
	buildParts = 0,
	buildPartsMax = 0,
	wood = 0,
	stone = 0,
}

export type Options = {
	-- Open a "Coming soon" panel for actions without a built-in panel (default true).
	placeholderPanels: boolean?,
	-- Build catalog categories (default: the wireframe's demo catalog). See Components/Building.
	catalog: { Building.Category }?,
}

local CowHUD = {}

function CowHUD.mount(player: Player, options: Options?)
	local opts = options or {}
	local initial = table.clone(DEFAULT_STATE)
	if GuiService.ReducedMotionEnabled then
		initial.motion = "Reduced"
	end
	local state = State.new(initial)
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
		return if scaler then scaler.scale else 1 -- components may measure before the scaler attaches
	end

	-- Gameplay actions: fire without opening a panel.
	function ctx.fire(action: string, payload: any?)
		actionEvent:Fire(action, payload)
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

	-- Theme and motion apply before anything is built, then live on change.
	state:observe("theme", Theme.applyPreset)
	state:observe("motion", Theme.setMotion)

	local hudLayer = Util.frame({ Name = "HUD", Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = root })
	local topLeft = TopLeft(hudLayer, ctx)
	local topRight = TopRight(hudLayer, ctx)
	local bulletin = Bulletin(hudLayer, ctx)
	local sidebars = Sidebars(hudLayer, ctx)
	Bottom(hudLayer, ctx)
	local building = Building(root, ctx, opts.catalog)
	-- Global across both modes (UI_ELEMENTS_MAP §4F), above the page layers.
	ActionCluster(root, ctx)
	Overlays(root, ctx)

	local lastMode = state:get("mode")
	state:observe("mode", function(mode)
		hudLayer.Visible = mode ~= "build"
		state:set("menu", nil)
		state:set("panel", nil)
		if mode ~= lastMode then
			lastMode = mode
			actionEvent:Fire(if mode == "build" then "EnterBuild" else "ExitBuild")
		end
	end)

	local layout
	scaler = Scaler.attach(screenGui, root, Theme.Scale, function(current)
		Util.setTextScale(current.scale)
		state:set("menu", nil) -- menu positions are computed once; drop them on resize
		if layout then
			layout.schedule()
		end
	end)
	layout = Layout.attach(root, scaler, {
		topLeft = topLeft,
		topRight = topRight,
		bulletin = bulletin,
		leftSidebar = sidebars.left,
		rightSidebar = sidebars.right,
		building = building,
	})
	layout.schedule()

	local stopBindings = Bindings.start(player, state)
	local stopCommands = Commands.start(state)

	screenGui.Parent = player:WaitForChild("PlayerGui")

	local hud = {
		State = state,
		ActionTriggered = actionEvent.Event,
		ScreenGui = screenGui,
	}

	function hud.Destroy(_self)
		stopBindings()
		stopCommands()
		building.destroy()
		scaler.connection:Disconnect()
		layout.destroy()
		screenGui:Destroy()
		actionEvent:Destroy()
	end

	return hud
end

return CowHUD
