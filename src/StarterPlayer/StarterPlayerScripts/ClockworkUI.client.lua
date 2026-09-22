--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local clockwork = ReplicatedStorage:WaitForChild("Clockwork")
local shared = clockwork:WaitForChild("Shared")
local remotes = clockwork:WaitForChild("Remotes")
local NumberFormatter = require(shared:WaitForChild("NumberFormatter"))
local economySnapshot = remotes:WaitForChild("EconomySnapshot") :: RemoteEvent
local purchaseUpgrade = remotes:WaitForChild("PurchaseUpgrade") :: RemoteEvent

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClockworkUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "TicksPanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.fromScale(0.5, 0.04)
panel.Size = UDim2.fromOffset(360, 112)
panel.BackgroundColor3 = Color3.fromRGB(29, 24, 19)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(184, 137, 65)
stroke.Thickness = 2
stroke.Transparency = 0.15
stroke.Parent = panel

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 38, 27)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 21, 18)),
})
gradient.Rotation = 90
gradient.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 20)
padding.PaddingRight = UDim.new(0, 20)
padding.PaddingTop = UDim.new(0, 14)
padding.PaddingBottom = UDim.new(0, 14)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "TicksValue"
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "0 Ticks"
title.TextColor3 = Color3.fromRGB(244, 208, 128)
title.TextScaled = true
title.Parent = panel

local titleConstraint = Instance.new("UITextSizeConstraint")
titleConstraint.MaxTextSize = 34
titleConstraint.MinTextSize = 18
titleConstraint.Parent = title

local rate = Instance.new("TextLabel")
rate.Name = "TicksPerSecond"
rate.LayoutOrder = 2
rate.Size = UDim2.new(1, 0, 0, 28)
rate.BackgroundTransparency = 1
rate.Font = Enum.Font.GothamMedium
rate.Text = "+0 Ticks / second"
rate.TextColor3 = Color3.fromRGB(196, 181, 151)
rate.TextSize = 18
rate.Parent = panel

local upgradePanel = Instance.new("Frame")
upgradePanel.Name = "StrongerSpringPanel"
upgradePanel.AnchorPoint = Vector2.new(0.5, 0)
upgradePanel.Position = UDim2.new(0.5, 0, 0.04, 126)
upgradePanel.Size = UDim2.fromOffset(360, 190)
upgradePanel.BackgroundColor3 = Color3.fromRGB(29, 24, 19)
upgradePanel.BorderSizePixel = 0
upgradePanel.Parent = screenGui

local upgradeCorner = Instance.new("UICorner")
upgradeCorner.CornerRadius = UDim.new(0, 12)
upgradeCorner.Parent = upgradePanel

local upgradeStroke = Instance.new("UIStroke")
upgradeStroke.Color = Color3.fromRGB(184, 137, 65)
upgradeStroke.Thickness = 2
upgradeStroke.Transparency = 0.15
upgradeStroke.Parent = upgradePanel

local upgradePadding = Instance.new("UIPadding")
upgradePadding.PaddingLeft = UDim.new(0, 20)
upgradePadding.PaddingRight = UDim.new(0, 20)
upgradePadding.PaddingTop = UDim.new(0, 14)
upgradePadding.PaddingBottom = UDim.new(0, 14)
upgradePadding.Parent = upgradePanel

local upgradeLayout = Instance.new("UIListLayout")
upgradeLayout.FillDirection = Enum.FillDirection.Vertical
upgradeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
upgradeLayout.SortOrder = Enum.SortOrder.LayoutOrder
upgradeLayout.Padding = UDim.new(0, 5)
upgradeLayout.Parent = upgradePanel

local upgradeTitle = Instance.new("TextLabel")
upgradeTitle.Name = "UpgradeName"
upgradeTitle.LayoutOrder = 1
upgradeTitle.Size = UDim2.new(1, 0, 0, 28)
upgradeTitle.BackgroundTransparency = 1
upgradeTitle.Font = Enum.Font.GothamBold
upgradeTitle.Text = "Stronger Spring"
upgradeTitle.TextColor3 = Color3.fromRGB(244, 208, 128)
upgradeTitle.TextSize = 22
upgradeTitle.Parent = upgradePanel

local upgradeLevel = Instance.new("TextLabel")
upgradeLevel.Name = "UpgradeLevel"
upgradeLevel.LayoutOrder = 2
upgradeLevel.Size = UDim2.new(1, 0, 0, 20)
upgradeLevel.BackgroundTransparency = 1
upgradeLevel.Font = Enum.Font.GothamMedium
upgradeLevel.Text = "Level --"
upgradeLevel.TextColor3 = Color3.fromRGB(220, 210, 190)
upgradeLevel.TextSize = 17
upgradeLevel.Parent = upgradePanel

local upgradeCost = Instance.new("TextLabel")
upgradeCost.Name = "UpgradeCost"
upgradeCost.LayoutOrder = 3
upgradeCost.Size = UDim2.new(1, 0, 0, 20)
upgradeCost.BackgroundTransparency = 1
upgradeCost.Font = Enum.Font.GothamMedium
upgradeCost.Text = "Cost: --"
upgradeCost.TextColor3 = Color3.fromRGB(220, 210, 190)
upgradeCost.TextSize = 17
upgradeCost.Parent = upgradePanel

local upgradeEffect = Instance.new("TextLabel")
upgradeEffect.Name = "UpgradeEffect"
upgradeEffect.LayoutOrder = 4
upgradeEffect.Size = UDim2.new(1, 0, 0, 20)
upgradeEffect.BackgroundTransparency = 1
upgradeEffect.Font = Enum.Font.Gotham
upgradeEffect.Text = "+1 Tick/sec per level"
upgradeEffect.TextColor3 = Color3.fromRGB(196, 181, 151)
upgradeEffect.TextSize = 15
upgradeEffect.Parent = upgradePanel

local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyButton"
buyButton.LayoutOrder = 5
buyButton.Size = UDim2.new(1, 0, 0, 40)
buyButton.BackgroundColor3 = Color3.fromRGB(139, 91, 38)
buyButton.BorderSizePixel = 0
buyButton.AutoButtonColor = true
buyButton.Font = Enum.Font.GothamBold
buyButton.Text = "BUY"
buyButton.TextColor3 = Color3.fromRGB(255, 239, 202)
buyButton.TextSize = 18
buyButton.Parent = upgradePanel

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 8)
buyCorner.Parent = buyButton

local function renderSnapshot(snapshot: any)
	if type(snapshot) ~= "table" then
		return
	end

	local currencies = snapshot.Currencies
	local perSecond = snapshot.PerSecond
	if type(currencies) ~= "table" or type(perSecond) ~= "table" then
		return
	end

	local ticks = currencies.Ticks
	local ticksPerSecond = perSecond.Ticks
	if type(ticks) ~= "number" or type(ticksPerSecond) ~= "number" then
		return
	end

	title.Text = NumberFormatter.Format(ticks) .. " Ticks"
	rate.Text = "+" .. NumberFormatter.Format(ticksPerSecond) .. " Ticks / second"

	local upgrades = snapshot.Upgrades
	if type(upgrades) ~= "table" then
		return
	end

	local strongerSpring = upgrades.StrongerSpring
	if type(strongerSpring) ~= "table" then
		return
	end

	local level = strongerSpring.Level
	local cost = strongerSpring.Cost
	local displayName = strongerSpring.DisplayName
	local description = strongerSpring.Description
	local costCurrency = strongerSpring.CostCurrency
	if
		type(level) ~= "number"
		or type(cost) ~= "number"
		or type(displayName) ~= "string"
		or type(description) ~= "string"
		or type(costCurrency) ~= "string"
	then
		return
	end

	upgradeTitle.Text = displayName
	upgradeLevel.Text = "Level " .. NumberFormatter.Format(level)
	upgradeCost.Text = "Cost: " .. NumberFormatter.Format(cost) .. " " .. costCurrency
	upgradeEffect.Text = description
end

economySnapshot.OnClientEvent:Connect(renderSnapshot)

buyButton.Activated:Connect(function()
	-- The identifier is only a request. Cost, affordability, and results are server-owned.
	purchaseUpgrade:FireServer("StrongerSpring")
end)

-- This carries no economy values; it only asks the server to resend its truth.
economySnapshot:FireServer()
