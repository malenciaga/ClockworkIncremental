--!strict

local Players = game:GetService("Players")

local BalanceConfig = require(script.Parent.Parent.Data.BalanceConfig)
local PlayerDataService = require(script.Parent.PlayerDataService)

type UpgradeSnapshot = {
	DisplayName: string,
	Description: string,
	Level: number,
	Cost: number,
	CostCurrency: string,
}

type EconomySnapshot = {
	Currencies: { [string]: number },
	PerSecond: { [string]: number },
	Upgrades: { [string]: UpgradeSnapshot },
}

local EconomyService = {}
local snapshotRemote: RemoteEvent? = nil

local function assertFiniteNonNegative(value: number, label: string)
	assert(value == value and value < math.huge and value >= 0, label .. " must be a finite, non-negative number")
end

function EconomyService.Init(remote: RemoteEvent)
	snapshotRemote = remote
end

function EconomyService.GetBalance(player: Player, currencyName: string): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end

	return profile.Currencies[currencyName] or 0
end

function EconomyService.Add(player: Player, currencyName: string, amount: number): number
	assertFiniteNonNegative(amount, "Currency amount")

	local profile = PlayerDataService.GetProfile(player)
	assert(profile, "Cannot change currency before the player's profile is loaded")

	local newBalance = (profile.Currencies[currencyName] or 0) + amount
	assertFiniteNonNegative(newBalance, "Currency balance")
	profile.Currencies[currencyName] = newBalance

	return newBalance
end

function EconomyService.TrySpend(player: Player, currencyName: string, amount: number): boolean
	assertFiniteNonNegative(amount, "Currency cost")

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false
	end

	local currentBalance = profile.Currencies[currencyName] or 0
	if currentBalance < amount then
		return false
	end

	profile.Currencies[currencyName] = currentBalance - amount
	return true
end

function EconomyService.GetPerSecond(player: Player, currencyName: string): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return 0
	end

	local production = profile.Production[currencyName]
	return if production then production.PerSecond else 0
end

function EconomyService.SetPerSecond(player: Player, currencyName: string, amount: number)
	assertFiniteNonNegative(amount, "Production rate")

	local profile = PlayerDataService.GetProfile(player)
	assert(profile, "Cannot change production before the player's profile is loaded")

	profile.Production[currencyName] = {
		PerSecond = amount,
	}
end

function EconomyService.GetSnapshot(player: Player): EconomySnapshot?
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return nil
	end

	local snapshot: EconomySnapshot = {
		Currencies = {},
		PerSecond = {},
		Upgrades = {},
	}

	for currencyName, balance in profile.Currencies do
		snapshot.Currencies[currencyName] = balance
	end

	for currencyName, production in profile.Production do
		snapshot.PerSecond[currencyName] = production.PerSecond
	end

	for upgradeId, level in profile.Upgrades do
		local definition = BalanceConfig.GetUpgrade(upgradeId)
		local cost = BalanceConfig.GetUpgradeCost(upgradeId, level)
		if definition and cost then
			snapshot.Upgrades[upgradeId] = {
				DisplayName = definition.DisplayName,
				Description = definition.Description,
				Level = level,
				Cost = cost,
				CostCurrency = definition.CostCurrency,
			}
		end
	end

	return snapshot
end

function EconomyService.Publish(player: Player)
	local remote = snapshotRemote
	local snapshot = EconomyService.GetSnapshot(player)

	if remote and snapshot and player.Parent == Players then
		remote:FireClient(player, snapshot)
	end
end

return EconomyService
