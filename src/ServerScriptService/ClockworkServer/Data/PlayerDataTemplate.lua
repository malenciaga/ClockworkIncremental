--!strict

local BalanceConfig = require(script.Parent.BalanceConfig)

export type CurrencyData = {
	[string]: number,
}

export type ProductionEntry = {
	PerSecond: number,
}

export type PlayerData = {
	SchemaVersion: number,
	Currencies: CurrencyData,
	Upgrades: {
		[string]: number,
	},
	Production: {
		[string]: ProductionEntry,
	},
	Metadata: {
		CreatedAt: number,
		LastSeenAt: number,
	},
}

local PlayerDataTemplate = {}
local defaultUpgradeLevels = BalanceConfig.CreateDefaultUpgradeLevels()

local TEMPLATE: PlayerData = {
	SchemaVersion = 2,
	Currencies = {
		Ticks = 0,
	},
	Upgrades = defaultUpgradeLevels,
	Production = {
		Ticks = {
			PerSecond = BalanceConfig.CalculateProduction("Ticks", defaultUpgradeLevels),
		},
	},
	Metadata = {
		CreatedAt = 0,
		LastSeenAt = 0,
	},
}

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, childValue in value do
		copy[deepCopy(key)] = deepCopy(childValue)
	end

	return copy
end

function PlayerDataTemplate.Create(): PlayerData
	local data: PlayerData = deepCopy(TEMPLATE)
	local now = os.time()
	data.Metadata.CreatedAt = now
	data.Metadata.LastSeenAt = now

	return data
end

return PlayerDataTemplate
