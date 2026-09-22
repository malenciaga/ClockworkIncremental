--!strict

local Players = game:GetService("Players")

local EconomyService = require(script.Parent.EconomyService)

local TickService = {}
local running = false

local function awardOneSecond(player: Player)
	local ticksPerSecond = EconomyService.GetPerSecond(player, "Ticks")
	if ticksPerSecond <= 0 then
		return
	end

	EconomyService.Add(player, "Ticks", ticksPerSecond)
	EconomyService.Publish(player)
end

function TickService.Start()
	if running then
		return
	end

	running = true
	task.spawn(function()
		while running do
			task.wait(1)

			for _, player in Players:GetPlayers() do
				awardOneSecond(player)
			end
		end
	end)
end

function TickService.Stop()
	running = false
end

return TickService
