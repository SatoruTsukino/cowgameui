--[[
	Feeds live game data into HUD state. The server writes attributes; the HUD only reads them.

	Player attributes:     Calories, Rebirth, GrazingArea, GrazingProgress (0-1), BoostLabel, BoostEndsAt,
	                       Wood, Stone, BuildParts, BuildPartsMax (build mode)
	Workspace attributes:  CyclePhase ("DAY"/"NIGHT"), CycleEndsAt, EventName, EventEndsAt, EventDuration
	*EndsAt values are Workspace:GetServerTimeNow() timestamps, so countdowns stay in sync across clients.
	HP comes straight from the character's Humanoid.
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TIMER_INTERVAL = 0.2

-- attribute -> { state key, may be cleared (nil) }
local PLAYER_ATTRIBUTES = {
	Calories = { "calories", false },
	Rebirth = { "rebirth", false },
	GrazingArea = { "grazingArea", false },
	GrazingProgress = { "grazingProgress", false },
	BoostLabel = { "boostLabel", true },
	Wood = { "wood", false },
	Stone = { "stone", false },
	BuildParts = { "buildParts", false },
	BuildPartsMax = { "buildPartsMax", false },
}
local WORLD_ATTRIBUTES = {
	CyclePhase = { "cyclePhase", false },
	EventName = { "eventName", true },
}

local Bindings = {}

local function mirrorAttributes(instance: Instance, map, state, connections)
	for attribute, spec in map do
		local key, optional = spec[1], spec[2]
		local function sync()
			local value = instance:GetAttribute(attribute)
			if value ~= nil or optional then
				state:set(key, value)
			end
		end
		sync()
		table.insert(connections, instance:GetAttributeChangedSignal(attribute):Connect(sync))
	end
end

local function bindHumanoid(player: Player, state, connections)
	local humanoidConnections = {}

	local function onCharacter(character: Model)
		for _, connection in humanoidConnections do
			connection:Disconnect()
		end
		table.clear(humanoidConnections)

		local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
		if not humanoid or player.Character ~= character then
			return
		end
		local function sync()
			state:set("maxHp", humanoid.MaxHealth)
			state:set("hp", humanoid.Health)
		end
		sync()
		table.insert(humanoidConnections, humanoid.HealthChanged:Connect(sync))
		table.insert(humanoidConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(sync))
	end

	table.insert(connections, player.CharacterAdded:Connect(onCharacter))
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
	return humanoidConnections
end

local function bindTimers(player: Player, state, connections)
	local elapsed = TIMER_INTERVAL
	table.insert(
		connections,
		RunService.Heartbeat:Connect(function(dt)
			elapsed += dt
			if elapsed < TIMER_INTERVAL then
				return
			end
			elapsed = 0

			local now = Workspace:GetServerTimeNow()
			local function remaining(endsAt: any): number
				return if typeof(endsAt) == "number" then math.max(0, endsAt - now) else 0
			end

			state:set("cycleTimeLeft", math.ceil(remaining(Workspace:GetAttribute("CycleEndsAt"))))

			local eventLeft = remaining(Workspace:GetAttribute("EventEndsAt"))
			local duration = Workspace:GetAttribute("EventDuration")
			state:set("eventTimeLeft", math.ceil(eventLeft))
			state:set("eventProgress", if typeof(duration) == "number" and duration > 0 then 1 - eventLeft / duration else 0)

			state:set("boostTimeLeft", math.ceil(remaining(player:GetAttribute("BoostEndsAt"))))
		end)
	)
end

-- Returns a cleanup function.
function Bindings.start(player: Player, state): () -> ()
	local connections = {}
	mirrorAttributes(player, PLAYER_ATTRIBUTES, state, connections)
	mirrorAttributes(Workspace, WORLD_ATTRIBUTES, state, connections)
	local humanoidConnections = bindHumanoid(player, state, connections)
	bindTimers(player, state, connections)

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, connection in humanoidConnections do
			connection:Disconnect()
		end
	end
end

return Bindings
