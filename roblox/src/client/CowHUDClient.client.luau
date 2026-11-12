-- StarterPlayerScripts/CowHUDClient (LocalScript): mounts the HUD for the local player.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CowHUD = require(ReplicatedStorage:WaitForChild("CowHUD"))

-- The HUD draws its own HP bar.
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local hud = CowHUD.mount(Players.LocalPlayer, { placeholderPanels = true })

hud.ActionTriggered:Connect(function(action: string)
	print("[CowHUD] action:", action)
end)
