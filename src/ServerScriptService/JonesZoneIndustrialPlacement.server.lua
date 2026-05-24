-- Temporary helper: positions existing Studio Part Workspace.Zone_Industrial at spawn for testing.
-- Remove this script when zone layout is finalized in Studio.

local Workspace = game:GetService("Workspace")

local ZONE_PART_NAME = "Zone_Industrial"
local ZONE_SIZE = Vector3.new(60, 20, 60)
local ZONE_TRANSPARENCY = 0.5

local function findSpawnLocation(): SpawnLocation?
	local spawn = Workspace:FindFirstChild("SpawnLocation")
	if spawn and spawn:IsA("SpawnLocation") then
		return spawn
	end

	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("SpawnLocation") then
			return descendant
		end
	end

	return nil
end

local function placeIndustrialZoneAtSpawn()
	local zonePart = Workspace:FindFirstChild(ZONE_PART_NAME)
	if not zonePart or not zonePart:IsA("BasePart") then
		warn(`[JonesZonePlacement] Missing Workspace.{ZONE_PART_NAME} — create it in Studio first.`)
		return
	end

	local spawn = findSpawnLocation()
	local centerPosition: Vector3

	if spawn then
		centerPosition = Vector3.new(
			spawn.Position.X,
			spawn.Position.Y + ZONE_SIZE.Y / 2,
			spawn.Position.Z
		)
	else
		warn("[JonesZonePlacement] No SpawnLocation found; using origin fallback.")
		centerPosition = Vector3.new(0, ZONE_SIZE.Y / 2, 0)
	end

	zonePart.Size = ZONE_SIZE
	zonePart.CFrame = CFrame.new(centerPosition)
	zonePart.Anchored = true
	zonePart.CanCollide = false
	zonePart.Transparency = ZONE_TRANSPARENCY

	print(
		`[JonesZonePlacement] Placed {ZONE_PART_NAME} | Position: {centerPosition} | Size: {ZONE_SIZE} | Transparency: {ZONE_TRANSPARENCY}`
	)
end

placeIndustrialZoneAtSpawn()
