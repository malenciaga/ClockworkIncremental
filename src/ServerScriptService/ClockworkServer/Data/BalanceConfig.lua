--!strict

export type UpgradeDefinition = {
	DisplayName: string,
	Description: string,
	CostCurrency: string,
	BaseCost: number,
	CostMultiplier: number,
	ProductionCurrency: string,
	FlatProductionPerLevel: number?,
	ProductionMultiplierPerLevel: number?,
}

local BalanceConfig = {}

local BASE_PRODUCTION: { [string]: number } = {
	Ticks = 1,
}

local UPGRADES: { [string]: UpgradeDefinition } = {
	StrongerSpring = {
		DisplayName = "Stronger Spring",
		Description = "+1 Tick/sec per level",
		CostCurrency = "Ticks",
		BaseCost = 10,
		CostMultiplier = 1.5,
		ProductionCurrency = "Ticks",
		FlatProductionPerLevel = 1,
	},
	PrecisionGears = {
		DisplayName = "Precision Gears",
		Description = "x1.25 Tick production per level",
		CostCurrency = "Ticks",
		BaseCost = 50,
		CostMultiplier = 1.75,
		ProductionCurrency = "Ticks",
		ProductionMultiplierPerLevel = 1.25,
	},
}

function BalanceConfig.GetUpgrade(upgradeId: string): UpgradeDefinition?
	return UPGRADES[upgradeId]
end

-- Centralized exponential formula: baseCost * multiplier ^ currentLevel.
-- Change BaseCost or CostMultiplier above to rebalance an upgrade.
function BalanceConfig.GetUpgradeCost(upgradeId: string, currentLevel: number): number?
	local definition = UPGRADES[upgradeId]
	if not definition then
		return nil
	end

	return math.floor(definition.BaseCost * (definition.CostMultiplier ^ currentLevel) + 0.5)
end

function BalanceConfig.CreateDefaultUpgradeLevels(): { [string]: number }
	local levels = {}
	for upgradeId in UPGRADES do
		levels[upgradeId] = 0
	end

	return levels
end

function BalanceConfig.CalculateProduction(currencyName: string, upgradeLevels: { [string]: number }): number
	local flatProduction = BASE_PRODUCTION[currencyName] or 0
	local productionMultiplier = 1

	for upgradeId, level in upgradeLevels do
		local definition = UPGRADES[upgradeId]
		if definition and definition.ProductionCurrency == currencyName then
			if definition.FlatProductionPerLevel then
				flatProduction += level * definition.FlatProductionPerLevel
			end

			if definition.ProductionMultiplierPerLevel then
				productionMultiplier *= definition.ProductionMultiplierPerLevel ^ level
			end
		end
	end

	return flatProduction * productionMultiplier
end

return BalanceConfig
