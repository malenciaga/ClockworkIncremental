--!strict

local Players = game:GetService("Players")

local PlayerDataTemplate = require(script.Parent.Parent.Data.PlayerDataTemplate)

type PlayerData = PlayerDataTemplate.PlayerData

local PlayerDataService = {}
local profiles: { [Player]: PlayerData } = {}

function PlayerDataService.LoadPlayer(player: Player): PlayerData
	local existingProfile = profiles[player]
	if existingProfile then
		return existingProfile
	end

	local profile = PlayerDataTemplate.Create()
	profiles[player] = profile

	return profile
end

function PlayerDataService.GetProfile(player: Player): PlayerData?
	return profiles[player]
end

function PlayerDataService.RemovePlayer(player: Player)
	local profile = profiles[player]
	if profile then
		profile.Metadata.LastSeenAt = os.time()
	end

	profiles[player] = nil
end

function PlayerDataService.RemoveAllPlayers()
	for _, player in Players:GetPlayers() do
		PlayerDataService.RemovePlayer(player)
	end
end

return PlayerDataService
