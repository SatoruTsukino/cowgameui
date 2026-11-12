--[[
	Chat commands that switch the HUD between normal (pasture) mode and build mode:
	  /build             → mode = "build"   (aliases /buildmode)
	  /normal            → mode = "normal"  (aliases /exitbuild)

	Created on the client, so TextChatService only triggers them for the local player's own messages and
	the text never goes to chat. Requires TextChatService (the default chat for new places).
	Game code reacts through ActionTriggered("EnterBuild" / "ExitBuild"), fired by CowHUD when the mode changes.
]]

local TextChatService = game:GetService("TextChatService")

local Commands = {}

local COMMANDS = {
	{ name = "CowHUDBuild", primary = "/build", secondary = "/buildmode", mode = "build" },
	{ name = "CowHUDNormal", primary = "/normal", secondary = "/exitbuild", mode = "normal" },
}

-- Returns a cleanup function.
function Commands.start(state): () -> ()
	if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
		warn("[CowHUD] /build and /normal need TextChatService; legacy chat is not supported")
		return function() end
	end

	local instances = {}
	for _, spec in COMMANDS do
		local command = Instance.new("TextChatCommand")
		command.Name = spec.name
		command.PrimaryAlias = spec.primary
		command.SecondaryAlias = spec.secondary
		command.Triggered:Connect(function()
			state:set("mode", spec.mode)
		end)
		command.Parent = TextChatService
		table.insert(instances, command)
	end

	return function()
		for _, command in instances do
			command:Destroy()
		end
	end
end

return Commands
