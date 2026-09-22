--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clockwork = ReplicatedStorage:WaitForChild("Clockwork")
local remotes = clockwork:WaitForChild("Remotes")
local economySnapshot = remotes:WaitForChild("EconomySnapshot") :: RemoteEvent
local purchaseUpgrade = remotes:WaitForChild("PurchaseUpgrade") :: RemoteEvent

local services = script.Parent:WaitForChild("Services")
local PlayerDataService = require(services:WaitForChild("PlayerDataService"))
local EconomyService = require(services:WaitForChild("EconomyService"))
local TickService = require(services:WaitForChild("TickService"))
local UpgradeService = require(services:WaitForChild("UpgradeService"))

local lastSnapshotRequest: { [Player]: number } = {}

EconomyService.Init(economySnapshot)

local function onPlayerAdded(player: Player)
	PlayerDataService.LoadPlayer(player)
	EconomyService.Publish(player)
end

local function onPlayerRemoving(player: Player)
	lastSnapshotRequest[player] = nil
	PlayerDataService.RemovePlayer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- The client may ask for a fresh snapshot, but it cannot submit balances or rates.
-- Requests are throttled to keep this endpoint cheap if a client abuses it.
economySnapshot.OnServerEvent:Connect(function(player: Player)
	local now = os.clock()
	local lastRequest = lastSnapshotRequest[player] or -math.huge
	if now - lastRequest < 1 then
		return
	end

	lastSnapshotRequest[player] = now
	EconomyService.Publish(player)
end)

purchaseUpgrade.OnServerEvent:Connect(function(player: Player, upgradeId: any)
	UpgradeService.TryPurchase(player, upgradeId)
end)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

TickService.Start()

game:BindToClose(function()
	TickService.Stop()
	PlayerDataService.RemoveAllPlayers()
end)
