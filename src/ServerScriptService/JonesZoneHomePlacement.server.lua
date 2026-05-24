-- Temporary helper: creates/places Workspace.Zone_Home around the nearest building near spawn.
-- Remove this script when zone layout is finalized in Studio.

local Workspace = game:GetService("Workspace")

local ZONE_PART_NAME = "Zone_Home"
local ZONE_TRANSPARENCY = 0.5
local ZONE_PADDING = Vector3.new(8, 6, 8)
local MIN_BUILDING_VOLUME = 80
local MAX_SEARCH_RADIUS = 300
local FALLBACK_ZONE_SIZE = Vector3.new(40, 15, 40)

local HOUSE_KEYWORDS = {
	"house",
	"home",
	"building",
	"cottage",
	"cabin",
	"residence",
	"apartment",
	"hut",
	"villa",
}

local EXCLUDED_NAMES = {
	Zone_Home = true,
	Zone_Industrial = true,
	Zone_Market = true,
	SpawnLocation = true,
	Terrain = true,
	Camera = true,
}

type BuildingCandidate = {
	instance: Instance,
	center: Vector3,
	size: Vector3,
	volume: number,
	distance: number,
	score: number,
}

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

local function nameMatchesHouseKeyword(name: string): boolean
	local lowerName = string.lower(name)
	for _, keyword in HOUSE_KEYWORDS do
		if string.find(lowerName, keyword, 1, true) then
			return true
		end
	end

	return false
end

local function shouldSkipInstance(instance: Instance): boolean
	if EXCLUDED_NAMES[instance.Name] then
		return true
	end

	if string.sub(instance.Name, 1, 5) == "Zone_" then
		return true
	end

	return false
end

local function getInstanceBounds(instance: Instance): (CFrame?, Vector3?)
	if instance:IsA("Model") then
		local ok, cf, size = pcall(function()
			return instance:GetBoundingBox()
		end)
		if ok and cf and size then
			return cf, size
		end
	end

	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	return nil, nil
end

local function collectBuildingCandidates(spawnPosition: Vector3): { BuildingCandidate }
	local candidates: { BuildingCandidate } = {}
	local seen: { [Instance]: boolean } = {}

	local function tryAddCandidate(instance: Instance)
		if seen[instance] or shouldSkipInstance(instance) then
			return
		end

		local cf, size = getInstanceBounds(instance)
		if not cf or not size then
			return
		end

		local volume = size.X * size.Y * size.Z
		if volume < MIN_BUILDING_VOLUME then
			return
		end

		local distance = (cf.Position - spawnPosition).Magnitude
		if distance > MAX_SEARCH_RADIUS then
			return
		end

		local keywordBonus = if nameMatchesHouseKeyword(instance.Name) then 150 else 0
		local sizeBonus = math.min(volume, 8000) * 0.02
		local score = distance - keywordBonus - sizeBonus

		seen[instance] = true
		table.insert(candidates, {
			instance = instance,
			center = cf.Position,
			size = size,
			volume = volume,
			distance = distance,
			score = score,
		})
	end

	for _, child in Workspace:GetChildren() do
		if child:IsA("Model") or child:IsA("BasePart") then
			tryAddCandidate(child)
		end
	end

	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("Model") then
			tryAddCandidate(descendant)
		end
	end

	return candidates
end

local function pickBestBuilding(candidates: { BuildingCandidate }): BuildingCandidate?
	local best: BuildingCandidate? = nil

	for _, candidate in candidates do
		if not best or candidate.score < best.score then
			best = candidate
		end
	end

	return best
end

local function getOrCreateZonePart(): BasePart
	local existing = Workspace:FindFirstChild(ZONE_PART_NAME)
	if existing and existing:IsA("BasePart") then
		return existing
	end

	local zonePart = Instance.new("Part")
	zonePart.Name = ZONE_PART_NAME
	zonePart.Parent = Workspace
	print(`[JonesZoneHomePlacement] Created {ZONE_PART_NAME}`)
	return zonePart
end

local function applyZoneSettings(zonePart: BasePart, center: Vector3, size: Vector3)
	zonePart.Size = size
	zonePart.CFrame = CFrame.new(center)
	zonePart.Anchored = true
	zonePart.CanCollide = false
	zonePart.Transparency = ZONE_TRANSPARENCY
end

local function placeHomeZoneNearSpawn()
	local spawn = findSpawnLocation()
	local spawnPosition = if spawn then spawn.Position else Vector3.new(0, 0, 0)

	if not spawn then
		warn("[JonesZoneHomePlacement] No SpawnLocation found; searching from origin.")
	end

	local candidates = collectBuildingCandidates(spawnPosition)
	local building = pickBestBuilding(candidates)
	local zonePart = getOrCreateZonePart()

	if building then
		local zoneSize = building.size + ZONE_PADDING
		applyZoneSettings(zonePart, building.center, zoneSize)

		print(`[JonesZoneHomePlacement] Selected building: {building.instance:GetFullName()}`)
		print(`[JonesZoneHomePlacement] Building distance from spawn: {math.floor(building.distance)} studs`)
		print(`[JonesZoneHomePlacement] Final zone size: {zoneSize}`)
		print(`[JonesZoneHomePlacement] Final zone position: {building.center}`)
		return
	end

	warn("[JonesZoneHomePlacement] No suitable building found near spawn; using offset fallback.")
	local fallbackCenter = spawnPosition + Vector3.new(50, FALLBACK_ZONE_SIZE.Y / 2, 0)
	applyZoneSettings(zonePart, fallbackCenter, FALLBACK_ZONE_SIZE)

	print("[JonesZoneHomePlacement] Selected building: (none — fallback)")
	print(`[JonesZoneHomePlacement] Final zone size: {FALLBACK_ZONE_SIZE}`)
	print(`[JonesZoneHomePlacement] Final zone position: {fallbackCenter}`)
end

placeHomeZoneNearSpawn()
