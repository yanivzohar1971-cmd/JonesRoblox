-- Temporary helper: creates/places Workspace.Zone_Bank near bank/store/office buildings by spawn.
-- Remove this script when zone layout is finalized in Studio.

local Workspace = game:GetService("Workspace")

local ZONE_PART_NAME = "Zone_Bank"
local ZONE_TRANSPARENCY = 0.5
local ZONE_SIZE = Vector3.new(50, 18, 50)
local MIN_STRUCTURE_VOLUME = 40
local MAX_SEARCH_RADIUS = 300

local BANK_KEYWORDS = {
	"bank",
	"office",
	"finance",
	"vault",
	"credit",
	"downtown",
	"store",
	"building",
}

local EXCLUDED_NAMES = {
	Zone_Home = true,
	Zone_Industrial = true,
	Zone_Market = true,
	Zone_Bank = true,
	SpawnLocation = true,
	Terrain = true,
	Camera = true,
}

type BankCandidate = {
	instance: Instance,
	center: Vector3,
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

local function nameMatchesBankKeyword(name: string): boolean
	local lowerName = string.lower(name)
	for _, keyword in BANK_KEYWORDS do
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

local function collectBankCandidates(spawnPosition: Vector3): { BankCandidate }
	local candidates: { BankCandidate } = {}
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
		if volume < MIN_STRUCTURE_VOLUME then
			return
		end

		local distance = (cf.Position - spawnPosition).Magnitude
		if distance > MAX_SEARCH_RADIUS then
			return
		end

		local keywordBonus = if nameMatchesBankKeyword(instance.Name) then 250 else 0
		local sizeBonus = math.min(volume, 8000) * 0.01
		local score = distance - keywordBonus - sizeBonus

		seen[instance] = true
		table.insert(candidates, {
			instance = instance,
			center = cf.Position,
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

local function pickBestBank(candidates: { BankCandidate }): BankCandidate?
	local best: BankCandidate? = nil

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
	print(`[JonesZoneBankPlacement] Created {ZONE_PART_NAME}`)
	return zonePart
end

local function applyZoneSettings(zonePart: BasePart, center: Vector3)
	zonePart.Size = ZONE_SIZE
	zonePart.CFrame = CFrame.new(center)
	zonePart.Anchored = true
	zonePart.CanCollide = false
	zonePart.Transparency = ZONE_TRANSPARENCY
end

local function placeBankZoneNearSpawn()
	local spawn = findSpawnLocation()
	local spawnPosition = if spawn then spawn.Position else Vector3.new(0, 0, 0)

	if not spawn then
		warn("[JonesZoneBankPlacement] No SpawnLocation found; searching from origin.")
	end

	local candidates = collectBankCandidates(spawnPosition)
	local bankStructure = pickBestBank(candidates)
	local zonePart = getOrCreateZonePart()

	if bankStructure then
		applyZoneSettings(zonePart, bankStructure.center)

		print(`[JonesZoneBankPlacement] Selected structure: {bankStructure.instance:GetFullName()}`)
		print(`[JonesZoneBankPlacement] Distance from spawn: {math.floor(bankStructure.distance)} studs`)
		print(`[JonesZoneBankPlacement] Final zone size: {ZONE_SIZE}`)
		print(`[JonesZoneBankPlacement] Final zone position: {bankStructure.center}`)
		return
	end

	warn("[JonesZoneBankPlacement] No bank structure found; using offset fallback.")
	local fallbackCenter = spawnPosition + Vector3.new(55, ZONE_SIZE.Y / 2, -25)
	applyZoneSettings(zonePart, fallbackCenter)

	print("[JonesZoneBankPlacement] Selected structure: (none — fallback)")
	print(`[JonesZoneBankPlacement] Final zone size: {ZONE_SIZE}`)
	print(`[JonesZoneBankPlacement] Final zone position: {fallbackCenter}`)
end

placeBankZoneNearSpawn()
