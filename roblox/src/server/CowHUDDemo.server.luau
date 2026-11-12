-- ServerScriptService/CowHUDDemo (Script): drives every HUD value so the test place looks alive.
-- Replace with real game systems; the HUD only reads the attributes documented in CowHUD/Bindings.

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")

local CYCLE_PHASE_SECONDS = 165 -- "DAY • 02:45"
local CALM_SECONDS = 30
local EVENTS = {
	{ name = "Clover Bloom", duration = 560 },
	{ name = "Golden Hay", duration = 300 },
	{ name = "Moo Moon", duration = 420 },
}
local TICK_SECONDS = 2
local CALORIES_PER_TICK = 10
local GRAZING_PER_TICK = 0.02
local BOOST_SECONDS = 90

local function now(): number
	return Workspace:GetServerTimeNow()
end

-- Day / night cycle
task.spawn(function()
	local phase = "DAY"
	while true do
		Workspace:SetAttribute("CyclePhase", phase)
		Workspace:SetAttribute("CycleEndsAt", now() + CYCLE_PHASE_SECONDS)
		task.wait(CYCLE_PHASE_SECONDS)
		phase = if phase == "DAY" then "NIGHT" else "DAY"
	end
end)

-- Rotating world events with a calm gap between them
task.spawn(function()
	local index = 1
	while true do
		local event = EVENTS[index]
		Workspace:SetAttribute("EventName", event.name)
		Workspace:SetAttribute("EventDuration", event.duration)
		Workspace:SetAttribute("EventEndsAt", now() + event.duration)
		task.wait(event.duration)

		Workspace:SetAttribute("EventName", nil)
		Workspace:SetAttribute("EventEndsAt", nil)
		task.wait(CALM_SECONDS)
		index = index % #EVENTS + 1
	end
end)

local function onPlayerAdded(player: Player)
	player:SetAttribute("Calories", 1500)
	player:SetAttribute("Rebirth", 2)
	player:SetAttribute("GrazingArea", "Clover Meadow")
	player:SetAttribute("GrazingProgress", 0.68)
	player:SetAttribute("BoostLabel", "2x Calories")
	player:SetAttribute("BoostEndsAt", now() + BOOST_SECONDS)
	player:SetAttribute("Wood", 450)
	player:SetAttribute("Stone", 320)
	player:SetAttribute("BuildParts", 34)
	player:SetAttribute("BuildPartsMax", 50)
end

-- Test command: "/boost" starts a fresh 90s boost; "/boost 30" sets the length in seconds.
-- Created on the server so the attributes replicate and the doubled calories apply.
local boostCommand = Instance.new("TextChatCommand")
boostCommand.Name = "CowHUDDemoBoost"
boostCommand.PrimaryAlias = "/boost"
boostCommand.Triggered:Connect(function(source: TextSource, text: string)
	local player = Players:GetPlayerByUserId(source.UserId)
	if not player then
		return
	end
	local seconds = math.clamp(tonumber(text:match("^%S+%s+(%d+)")) or BOOST_SECONDS, 1, 3600)
	player:SetAttribute("BoostLabel", "2x Calories")
	player:SetAttribute("BoostEndsAt", now() + seconds)
end)
boostCommand.Parent = TextChatService

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

-- Grazing: earn calories (doubled while boosted), fill the meadow bar; a full bar grants a bonus.
while true do
	task.wait(TICK_SECONDS)
	for _, player in Players:GetPlayers() do
		local boosted = (player:GetAttribute("BoostEndsAt") or 0) > now()
		if not boosted and player:GetAttribute("BoostLabel") then
			player:SetAttribute("BoostLabel", nil)
		end

		local calories = (player:GetAttribute("Calories") or 0) + CALORIES_PER_TICK * (if boosted then 2 else 1)
		local progress = (player:GetAttribute("GrazingProgress") or 0) + GRAZING_PER_TICK
		if progress >= 1 then
			progress = 0
			calories += 100
		end
		player:SetAttribute("Calories", calories)
		player:SetAttribute("GrazingProgress", progress)
	end
end
