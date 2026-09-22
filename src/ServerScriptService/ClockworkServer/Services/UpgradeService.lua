--!strict

local Players = game:GetService("Players")

local BalanceConfig = require(script.Parent.Parent.Data.BalanceConfig)
local EconomyService = require(script.Parent.EconomyService)
local PlayerDataService = require(script.Parent.PlayerDataService)

local UpgradeService = {}

function UpgradeService.TryPurchase(player: Player, upgradeId: any): boolean
	if player.Parent ~= Players or type(upgradeId) ~= "string" then
		return false
	end

	local definition = BalanceConfig.GetUpgrade(upgradeId)
	if not definition then
		return false
	end

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false
	end

	local currentLevel = profile.Upgrades[upgradeId]
	if type(currentLevel) ~= "number" then
		return false
	end

	local cost = BalanceConfig.GetUpgradeCost(upgradeId, currentLevel)
	if not cost or not EconomyService.TrySpend(player, definition.CostCurrency, cost) then
		return false
	end

	profile.Upgrades[upgradeId] = currentLevel + 1

	local productionRate = BalanceConfig.CalculateProduction(definition.ProductionCurrency, profile.Upgrades)
	EconomyService.SetPerSecond(player, definition.ProductionCurrency, productionRate)
	EconomyService.Publish(player)

	return true
end

return UpgradeService
