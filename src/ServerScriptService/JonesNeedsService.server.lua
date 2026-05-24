local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JonesFullness = require(script.Parent.JonesFullness)

-- Testing only: set true locally to log hunger decay ticks. Must stay false in repo.
local DEBUG_HUNGER_DECAY = false

local HUNGER_DECAY_INTERVAL_SECONDS = 30
local HUNGER_DECAY_AMOUNT = 1
local MIN_HUNGER = 0
local MAX_HUNGER = 100

local DATA_LOADED_ATTR = "JonesDataLoaded"

local jonesDay = ReplicatedStorage:WaitForChild("JonesDay") :: IntValue
local jonesGameMinutes = ReplicatedStorage:WaitForChild("JonesGameMinutes") :: IntValue

local function isPlayerDataLoaded(player: Player): boolean
	return player:GetAttribute(DATA_LOADED_ATTR) == true
end

local function getHunger(player: Player): IntValue?
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local hunger = leaderstats:FindFirstChild("Hunger")
	if hunger and hunger:IsA("IntValue") then
		return hunger
	end

	return nil
end

local function tickHungerDecay()
	for _, player in Players:GetPlayers() do
		if not isPlayerDataLoaded(player) then
			continue
		end

		local hunger = getHunger(player)
		if not hunger then
			continue
		end

		if JonesFullness.isActive(player, jonesDay.Value, jonesGameMinutes.Value) then
			if DEBUG_HUNGER_DECAY then
				print(`[JonesNeedsService] {player.Name} fullness active — hunger decay paused`)
			end
			continue
		end

		if hunger.Value <= MIN_HUNGER then
			continue
		end

		local before = hunger.Value
		hunger.Value = math.clamp(hunger.Value - HUNGER_DECAY_AMOUNT, MIN_HUNGER, MAX_HUNGER)

		if DEBUG_HUNGER_DECAY and hunger.Value ~= before then
			print(`[JonesNeedsService] {player.Name} hunger decay {before} -> {hunger.Value}`)
		end
	end
end

if DEBUG_HUNGER_DECAY then
	warn("[JonesNeedsService] DEBUG_HUNGER_DECAY is enabled — logging passive hunger decay.")
end

task.spawn(function()
	while true do
		task.wait(HUNGER_DECAY_INTERVAL_SECONDS)
		tickHungerDecay()
	end
end)
