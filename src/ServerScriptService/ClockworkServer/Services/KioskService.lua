--!strict

local Workspace = game:GetService("Workspace")

local BalanceConfig = require(script.Parent.Parent.Data.BalanceConfig)

local AREA_NAME = "ClockworkUpgradeArea"
local WALL_NAME = "TickUpgradesWall"
local ROW_STEP = 3.3

local DARK_METAL = Color3.fromRGB(32, 29, 27)
local DEEP_METAL = Color3.fromRGB(18, 18, 17)
local BRONZE = Color3.fromRGB(120, 77, 39)
local BRASS = Color3.fromRGB(184, 137, 65)

-- This ordered list drives the physical rows. Adding a configured Tick upgrade
-- later extends the same wall without a new kiosk.
local UPGRADE_IDS = { "StrongerSpring", "PrecisionGears" }

local KioskService = {}

local function createPart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	canCollide: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = canCollide
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addStaticFace(part: BasePart, text: string, textSize: number)
	local face = Instance.new("SurfaceGui")
	face.Name = "StationLettering"
	face.Face = Enum.NormalId.Front
	face.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	face.PixelsPerStud = 70
	face.LightInfluence = 0.15
	face.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(244, 208, 128)
	label.TextSize = textSize
	label.Parent = face
end

local function getGroundOrigin(): Vector3
	local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn and spawn:IsA("BasePart") then
		return spawn.Position - Vector3.new(0, spawn.Size.Y / 2, 0)
	end
	return Vector3.new(0, 0, 0)
end

local function createUpgradeRow(wall: Model, pivot: CFrame, wallTop: number, index: number, upgradeId: string)
	local definition = BalanceConfig.GetUpgrade(upgradeId)
	assert(definition, "Wall references an unknown upgrade: " .. upgradeId)

	local row = Instance.new("Model")
	row.Name = upgradeId .. "Row"
	row:SetAttribute("UpgradeId", upgradeId)
	row.Parent = wall

	local rowY = wallTop - 1.7 - ROW_STEP * (index - 0.5)
	createPart(
		row,
		"Display",
		Vector3.new(11.5, 2.8, 0.18),
		pivot * CFrame.new(-1.75, rowY, 0.14),
		DEEP_METAL,
		Enum.Material.SmoothPlastic,
		false
	)

	local purchasePlate = createPart(
		row,
		"PurchasePlate",
		Vector3.new(2.9, 2.8, 0.28),
		pivot * CFrame.new(5.75, rowY, 0.12),
		BRONZE,
		Enum.Material.Metal,
		false
	)
	-- Interactive SurfaceGuis need to query the adorned part for mouse/touch input.
	purchasePlate.CanQuery = true
end

function KioskService.Init()
	local existingArea = Workspace:FindFirstChild(AREA_NAME)
	if existingArea then
		existingArea:Destroy()
	end

	local area = Instance.new("Folder")
	area.Name = AREA_NAME

	local origin = getGroundOrigin()
	local position = origin + Vector3.new(0, 0, -16)
	local pivot = CFrame.lookAt(position, Vector3.new(origin.X, position.Y, origin.Z))
	local wallHeight = 2.65 + #UPGRADE_IDS * ROW_STEP
	local wallTop = 0.7 + wallHeight

	local wall = Instance.new("Model")
	wall.Name = WALL_NAME
	wall:SetAttribute("UpgradeIds", table.concat(UPGRADE_IDS, ","))
	wall.Parent = area

	createPart(wall, "Foundation", Vector3.new(18, 0.7, 3.2), pivot * CFrame.new(0, 0.35, 0.5), DARK_METAL, Enum.Material.Metal, true)
	createPart(wall, "Body", Vector3.new(17, wallHeight, 0.8), pivot * CFrame.new(0, 0.7 + wallHeight / 2, 0.7), DARK_METAL, Enum.Material.Metal, true)
	createPart(wall, "LeftFrame", Vector3.new(0.4, wallHeight + 0.25, 1), pivot * CFrame.new(-8.5, 0.7 + wallHeight / 2, 0.55), BRONZE, Enum.Material.Metal, true)
	createPart(wall, "RightFrame", Vector3.new(0.4, wallHeight + 0.25, 1), pivot * CFrame.new(8.5, 0.7 + wallHeight / 2, 0.55), BRONZE, Enum.Material.Metal, true)
	createPart(wall, "TopBeam", Vector3.new(17.4, 0.35, 1), pivot * CFrame.new(0, wallTop, 0.55), BRASS, Enum.Material.Metal, true)

	local header = createPart(wall, "Header", Vector3.new(14.8, 1, 0.18), pivot * CFrame.new(0, wallTop - 0.85, 0.14), DEEP_METAL, Enum.Material.SmoothPlastic, false)
	addStaticFace(header, "TICK UPGRADES", 38)

	for index, upgradeId in UPGRADE_IDS do
		createUpgradeRow(wall, pivot, wallTop, index, upgradeId)
	end

	area.Parent = Workspace
end

return KioskService
