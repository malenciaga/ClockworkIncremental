--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
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
screenGui.Parent = playerGui

local statsPanel = Instance.new("Frame")
statsPanel.Name = "StatsPanel"
statsPanel.AnchorPoint = Vector2.new(0, 0.5)
statsPanel.Position = UDim2.new(0, 12, 0.5, 0)
statsPanel.Size = UDim2.new(0.34, 0, 0, 145)
statsPanel.BackgroundColor3 = Color3.fromRGB(29, 24, 19)
statsPanel.BorderSizePixel = 0
statsPanel.Parent = screenGui

local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(178, 145)
panelConstraint.MaxSize = Vector2.new(214, 145)
panelConstraint.Parent = statsPanel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = statsPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(184, 137, 65)
panelStroke.Thickness = 2
panelStroke.Transparency = 0.1
panelStroke.Parent = statsPanel

local panelPadding = Instance.new("UIPadding")
panelPadding.PaddingLeft = UDim.new(0, 10)
panelPadding.PaddingRight = UDim.new(0, 10)
panelPadding.PaddingTop = UDim.new(0, 8)
panelPadding.PaddingBottom = UDim.new(0, 8)
panelPadding.Parent = statsPanel

local panelLayout = Instance.new("UIListLayout")
panelLayout.FillDirection = Enum.FillDirection.Vertical
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
panelLayout.Padding = UDim.new(0, 3)
panelLayout.Parent = statsPanel

local function createHudText(name: string, order: number, height: number, font: Enum.Font, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.LayoutOrder = order
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.Font = font
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = statsPanel
	return label
end

local ticksValue = createHudText("TicksValue", 1, 33, Enum.Font.GothamBold, Color3.fromRGB(244, 208, 128))
ticksValue.Text = "0 Ticks"
ticksValue.TextScaled = true
local ticksSize = Instance.new("UITextSizeConstraint")
ticksSize.MinTextSize = 15
ticksSize.MaxTextSize = 27
ticksSize.Parent = ticksValue

local ticksRate = createHudText("TicksPerSecond", 2, 21, Enum.Font.GothamMedium, Color3.fromRGB(213, 195, 161))
ticksRate.Text = "+0 Ticks / second"
ticksRate.TextScaled = true
local rateSize = Instance.new("UITextSizeConstraint")
rateSize.MinTextSize = 11
rateSize.MaxTextSize = 15
rateSize.Parent = ticksRate

local divider = Instance.new("Frame")
divider.Name = "BrassRule"
divider.LayoutOrder = 3
divider.Size = UDim2.new(1, 0, 0, 1)
divider.BackgroundColor3 = Color3.fromRGB(128, 82, 38)
divider.BorderSizePixel = 0
divider.Parent = statsPanel

local function createLevelRow(name: string, order: number): TextLabel
	local label = createHudText(name .. "Level", order, 22, Enum.Font.GothamMedium, Color3.fromRGB(231, 218, 190))
	label.Text = name .. "  Lv —"
	label.TextScaled = true
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 11
	constraint.MaxTextSize = 14
	constraint.Parent = label
	return label
end

local springLevel = createLevelRow("Stronger Spring", 4)
local gearsLevel = createLevelRow("Precision Gears", 5)

type UpgradeView = {
	Title: TextLabel,
	Level: TextLabel,
	Cost: TextLabel,
	Effect: TextLabel,
	Button: TextButton,
	ButtonStroke: UIStroke,
	Status: TextLabel,
	Affordable: boolean,
	Hovering: boolean,
	Pressed: boolean,
}

local upgradeViews: { [string]: UpgradeView } = {}

local function updateBuyAppearance(view: UpgradeView)
	local button = view.Button
	button.Active = view.Affordable
	if not view.Affordable then
		button.BackgroundColor3 = Color3.fromRGB(58, 48, 39)
		button.TextColor3 = Color3.fromRGB(164, 147, 121)
		view.ButtonStroke.Color = Color3.fromRGB(117, 91, 61)
		view.Status.TextColor3 = Color3.fromRGB(244, 208, 128)
	elseif view.Pressed then
		button.BackgroundColor3 = Color3.fromRGB(124, 78, 32)
		button.TextColor3 = Color3.fromRGB(255, 240, 205)
		view.ButtonStroke.Color = Color3.fromRGB(203, 157, 83)
		view.Status.TextColor3 = Color3.fromRGB(244, 208, 128)
	elseif view.Hovering then
		button.BackgroundColor3 = Color3.fromRGB(193, 145, 70)
		button.TextColor3 = Color3.fromRGB(29, 24, 19)
		view.ButtonStroke.Color = Color3.fromRGB(244, 208, 128)
		view.Status.TextColor3 = Color3.fromRGB(244, 208, 128)
	else
		button.BackgroundColor3 = Color3.fromRGB(168, 116, 49)
		button.TextColor3 = Color3.fromRGB(255, 240, 205)
		view.ButtonStroke.Color = Color3.fromRGB(203, 157, 83)
		view.Status.TextColor3 = Color3.fromRGB(244, 208, 128)
	end
end

local function createWallText(
	parent: Instance,
	name: string,
	order: number,
	height: number,
	font: Enum.Font,
	textSize: number,
	color: Color3
): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.LayoutOrder = order
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.Font = font
	label.Text = "—"
	label.TextColor3 = color
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createWallView(wall: Model, upgradeId: string)
	local row = wall:WaitForChild(upgradeId .. "Row")
	local display = row:WaitForChild("Display") :: BasePart
	local purchasePlate = row:WaitForChild("PurchasePlate") :: BasePart

	-- PlayerGui ownership keeps each player's levels and costs on their own wall.
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = upgradeId .. "SurfaceGui"
	surfaceGui.Adornee = display
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 70
	surfaceGui.LightInfluence = 0.15
	surfaceGui.AlwaysOnTop = false
	surfaceGui.ResetOnSpawn = false
	surfaceGui.Parent = playerGui

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundTransparency = 1
	content.Parent = surfaceGui

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 24)
	padding.PaddingRight = UDim.new(0, 24)
	padding.PaddingTop = UDim.new(0, 15)
	padding.PaddingBottom = UDim.new(0, 15)
	padding.Parent = content

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = content

	local rowTitle = createWallText(content, "UpgradeName", 1, 38, Enum.Font.GothamBold, 31, Color3.fromRGB(244, 208, 128))
	rowTitle.Text = "LOADING UPGRADE"

	local rule = Instance.new("Frame")
	rule.Name = "BrassRule"
	rule.LayoutOrder = 2
	rule.Size = UDim2.new(1, 0, 0, 2)
	rule.BackgroundColor3 = Color3.fromRGB(184, 137, 65)
	rule.BorderSizePixel = 0
	rule.Parent = content

	local rowLevel = createWallText(content, "UpgradeLevel", 3, 26, Enum.Font.GothamMedium, 23, Color3.fromRGB(231, 218, 190))
	local rowCost = createWallText(content, "UpgradeCost", 4, 26, Enum.Font.GothamMedium, 23, Color3.fromRGB(231, 218, 190))
	local rowEffect = createWallText(content, "UpgradeEffect", 5, 38, Enum.Font.Gotham, 20, Color3.fromRGB(206, 190, 160))
	rowEffect.Text = "Waiting for authoritative data"

	local buySurfaceGui = Instance.new("SurfaceGui")
	buySurfaceGui.Name = upgradeId .. "BuySurfaceGui"
	buySurfaceGui.Adornee = purchasePlate
	buySurfaceGui.Face = Enum.NormalId.Front
	buySurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	buySurfaceGui.PixelsPerStud = 70
	buySurfaceGui.LightInfluence = 0.15
	buySurfaceGui.AlwaysOnTop = false
	buySurfaceGui.Active = true
	buySurfaceGui.ResetOnSpawn = false
	buySurfaceGui.Parent = playerGui

	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.AnchorPoint = Vector2.new(0.5, 0)
	buyButton.Position = UDim2.new(0.5, 0, 0, 16)
	buyButton.Size = UDim2.new(1, -20, 0, 118)
	buyButton.BackgroundColor3 = Color3.fromRGB(58, 48, 39)
	buyButton.BorderSizePixel = 0
	buyButton.AutoButtonColor = false
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Text = "BUY"
	buyButton.TextColor3 = Color3.fromRGB(164, 147, 121)
	buyButton.TextSize = 36
	buyButton.Parent = buySurfaceGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = buyButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	buttonStroke.Color = Color3.fromRGB(203, 157, 83)
	buttonStroke.Thickness = 2
	buttonStroke.Parent = buyButton

	local buyStatus = Instance.new("TextLabel")
	buyStatus.Name = "Affordability"
	buyStatus.AnchorPoint = Vector2.new(0.5, 0)
	buyStatus.Position = UDim2.new(0.5, 0, 1, -46)
	buyStatus.Size = UDim2.new(1, -12, 0, 36)
	buyStatus.BackgroundTransparency = 1
	buyStatus.Font = Enum.Font.GothamBold
	buyStatus.Text = "SYNCING"
	buyStatus.TextColor3 = Color3.fromRGB(206, 176, 128)
	buyStatus.TextScaled = true
	buyStatus.Parent = buySurfaceGui
	local statusSize = Instance.new("UITextSizeConstraint")
	statusSize.MinTextSize = 14
	statusSize.MaxTextSize = 20
	statusSize.Parent = buyStatus

	local view: UpgradeView = {
		Title = rowTitle,
		Level = rowLevel,
		Cost = rowCost,
		Effect = rowEffect,
		Button = buyButton,
		ButtonStroke = buttonStroke,
		Status = buyStatus,
		Affordable = false,
		Hovering = false,
		Pressed = false,
	}
	upgradeViews[upgradeId] = view
	updateBuyAppearance(view)

	buyButton.MouseEnter:Connect(function()
		view.Hovering = true
		updateBuyAppearance(view)
	end)
	buyButton.MouseLeave:Connect(function()
		view.Hovering = false
		view.Pressed = false
		updateBuyAppearance(view)
	end)
	buyButton.MouseButton1Down:Connect(function()
		view.Pressed = true
		updateBuyAppearance(view)
	end)
	buyButton.MouseButton1Up:Connect(function()
		view.Pressed = false
		updateBuyAppearance(view)
	end)
	buyButton.Activated:Connect(function()
		if view.Affordable then
			-- The server still validates the identifier, cost, balance, and result.
			purchaseUpgrade:FireServer(upgradeId)
		end
	end)
end

local area = Workspace:WaitForChild("ClockworkUpgradeArea")
local wall = area:WaitForChild("TickUpgradesWall") :: Model
local upgradeIds = wall:GetAttribute("UpgradeIds")
while type(upgradeIds) ~= "string" do
	wall:GetAttributeChangedSignal("UpgradeIds"):Wait()
	upgradeIds = wall:GetAttribute("UpgradeIds")
end
for _, upgradeId in string.split(upgradeIds, ",") do
	createWallView(wall, upgradeId)
end

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

	ticksValue.Text = NumberFormatter.Format(ticks) .. " Ticks"
	ticksRate.Text = "+" .. NumberFormatter.Format(ticksPerSecond) .. " Ticks / second"

	local upgrades = snapshot.Upgrades
	if type(upgrades) ~= "table" then
		return
	end

	for upgradeId, view in upgradeViews do
		local upgrade = upgrades[upgradeId]
		if type(upgrade) == "table" then
			local level = upgrade.Level
			local cost = upgrade.Cost
			local displayName = upgrade.DisplayName
			local description = upgrade.Description
			local costCurrency = upgrade.CostCurrency
			if
				type(level) == "number"
				and type(cost) == "number"
				and type(displayName) == "string"
				and type(description) == "string"
				and type(costCurrency) == "string"
			then
				view.Title.Text = string.upper(displayName)
				view.Level.Text = "Level " .. NumberFormatter.Format(level)
				view.Cost.Text = "Cost: " .. NumberFormatter.Format(cost) .. " " .. costCurrency
				view.Effect.Text = description
				local balance = currencies[costCurrency]
				view.Affordable = type(balance) == "number" and balance >= cost
				view.Status.Text = if view.Affordable then "READY" else "NEED " .. string.upper(costCurrency)
				updateBuyAppearance(view)
				if upgradeId == "StrongerSpring" then
					springLevel.Text = "Stronger Spring  Lv " .. NumberFormatter.Format(level)
				elseif upgradeId == "PrecisionGears" then
					gearsLevel.Text = "Precision Gears  Lv " .. NumberFormatter.Format(level)
				end
			end
		end
	end
end

economySnapshot.OnClientEvent:Connect(renderSnapshot)

-- Requests only a fresh server snapshot; the client supplies no economy values.
economySnapshot:FireServer()
