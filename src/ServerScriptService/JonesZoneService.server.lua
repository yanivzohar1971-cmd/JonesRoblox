local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ZONE_TAGS = {
	JonesZone_Home = "Home",
	JonesZone_Market = "Market",
	JonesZone_Industrial = "Industrial",
	JonesZone_Bank = "Bank",
}

local ZONE_NAMES = {
	Zone_Home = "Home",
	Zone_Market = "Market",
	Zone_Industrial = "Industrial",
	Zone_Bank = "Bank",
}

local TAG_PRIORITY = 1
local NAME_PRIORITY = 2

local POLL_INTERVAL = 0.25
local DEFAULT_ZONE = "None"

type ZoneEntry = {
	part: BasePart,
	name: string,
	volume: number,
	priority: number,
}

local zoneEntries: { ZoneEntry } = {}

local function isPointInPart(point: Vector3, part: BasePart): boolean
	local localPoint = part.CFrame:PointToObjectSpace(point)
	local halfSize = part.Size / 2

	return math.abs(localPoint.X) <= halfSize.X
		and math.abs(localPoint.Y) <= halfSize.Y
		and math.abs(localPoint.Z) <= halfSize.Z
end

local function getPartVolume(part: BasePart): number
	return part.Size.X * part.Size.Y * part.Size.Z
end

local function removeZonePart(part: Instance)
	for index, entry in zoneEntries do
		if entry.part == part then
			table.remove(zoneEntries, index)
			return
		end
	end
end

local function hasTaggedRegistration(part: BasePart): boolean
	for _, entry in zoneEntries do
		if entry.part == part and entry.priority == TAG_PRIORITY then
			return true
		end
	end

	return false
end

local function registerZonePart(part: BasePart, zoneName: string, priority: number)
	removeZonePart(part)

	table.insert(zoneEntries, {
		part = part,
		name = zoneName,
		volume = getPartVolume(part),
		priority = priority,
	})
end

local function addTaggedZonePart(instance: Instance, tag: string)
	if not instance:IsA("BasePart") then
		return
	end

	local zoneName = ZONE_TAGS[tag]
	if not zoneName then
		return
	end

	registerZonePart(instance, zoneName, TAG_PRIORITY)
	print(`[JonesZoneService] Found tagged zone: {tag} on {instance.Name}`)
end

local function tryAddNamedZonePart(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end

	if hasTaggedRegistration(instance) then
		return
	end

	local zoneName = ZONE_NAMES[instance.Name]
	if not zoneName then
		return
	end

	registerZonePart(instance, zoneName, NAME_PRIORITY)
	print(`[JonesZoneService] Found named zone fallback: {instance.Name} -> {zoneName}`)
end

local function getZoneAtPosition(position: Vector3): string
	local bestTaggedZone = DEFAULT_ZONE
	local bestTaggedVolume = math.huge
	local bestNamedZone = DEFAULT_ZONE
	local bestNamedVolume = math.huge

	for _, entry in zoneEntries do
		if not entry.part.Parent then
			continue
		end

		if not isPointInPart(position, entry.part) then
			continue
		end

		if entry.priority == TAG_PRIORITY then
			if entry.volume < bestTaggedVolume then
				bestTaggedVolume = entry.volume
				bestTaggedZone = entry.name
			end
		elseif entry.volume < bestNamedVolume then
			bestNamedVolume = entry.volume
			bestNamedZone = entry.name
		end
	end

	if bestTaggedZone ~= DEFAULT_ZONE then
		return bestTaggedZone
	end

	if bestNamedZone ~= DEFAULT_ZONE then
		return bestNamedZone
	end

	return DEFAULT_ZONE
end

local function setPlayerZone(player: Player, zoneName: string)
	local leaderstats = player:FindFirstChild("leaderstats") or player:WaitForChild("leaderstats", 10)
	if not leaderstats then
		return
	end

	local currentZone = leaderstats:FindFirstChild("CurrentZone") or leaderstats:WaitForChild("CurrentZone", 10)
	if not currentZone then
		return
	end

	if currentZone.Value ~= zoneName then
		currentZone.Value = zoneName
	end
end

local function updatePlayerZone(player: Player)
	local character = player.Character
	if not character then
		setPlayerZone(player, DEFAULT_ZONE)
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then
		setPlayerZone(player, DEFAULT_ZONE)
		return
	end

	setPlayerZone(player, getZoneAtPosition(rootPart.Position))
end

local function scanWorkspaceForNamedZones()
	for _, descendant in Workspace:GetDescendants() do
		tryAddNamedZonePart(descendant)
	end
end

for tag, _ in ZONE_TAGS do
	for _, instance in CollectionService:GetTagged(tag) do
		addTaggedZonePart(instance, tag)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		addTaggedZonePart(instance, tag)
	end)

	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		removeZonePart(instance)
		tryAddNamedZonePart(instance)
	end)
end

scanWorkspaceForNamedZones()

Workspace.DescendantAdded:Connect(function(descendant)
	tryAddNamedZonePart(descendant)
end)

Workspace.DescendantRemoving:Connect(function(descendant)
	removeZonePart(descendant)
end)

local function trackPlayer(player: Player)
	player.CharacterAdded:Connect(function()
		updatePlayerZone(player)
	end)

	if player.Character then
		updatePlayerZone(player)
	end
end

Players.PlayerAdded:Connect(trackPlayer)

for _, player in Players:GetPlayers() do
	trackPlayer(player)
end

local elapsed = 0
RunService.Heartbeat:Connect(function(deltaTime)
	elapsed += deltaTime
	if elapsed < POLL_INTERVAL then
		return
	end

	elapsed = 0

	for _, player in Players:GetPlayers() do
		updatePlayerZone(player)
	end
end)
