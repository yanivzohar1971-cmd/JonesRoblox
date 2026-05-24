local Players = game:GetService("Players")

local JonesFoodInventory = require(script.Parent.JonesFoodInventory)

local DEFAULT_MONEY = 0
local DEFAULT_BANK_BALANCE = 0
local DEFAULT_ENERGY = 100
local DEFAULT_HUNGER = 100
local DEFAULT_REPUTATION = 0
local DEFAULT_JOB_XP = 0
local DEFAULT_JOB_LEVEL = 1

local function setupPlayerStats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = DEFAULT_MONEY
	money.Parent = leaderstats

	local bankBalance = Instance.new("IntValue")
	bankBalance.Name = "BankBalance"
	bankBalance.Value = DEFAULT_BANK_BALANCE
	bankBalance.Parent = leaderstats

	local energy = Instance.new("IntValue")
	energy.Name = "Energy"
	energy.Value = DEFAULT_ENERGY
	energy.Parent = leaderstats

	local hunger = Instance.new("IntValue")
	hunger.Name = "Hunger"
	hunger.Value = DEFAULT_HUNGER
	hunger.Parent = leaderstats

	local reputation = Instance.new("IntValue")
	reputation.Name = "Reputation"
	reputation.Value = DEFAULT_REPUTATION
	reputation.Parent = leaderstats

	local jobXp = Instance.new("IntValue")
	jobXp.Name = "JobXP"
	jobXp.Value = DEFAULT_JOB_XP
	jobXp.Parent = leaderstats

	local jobLevel = Instance.new("IntValue")
	jobLevel.Name = "JobLevel"
	jobLevel.Value = DEFAULT_JOB_LEVEL
	jobLevel.Parent = leaderstats

	local currentZone = Instance.new("StringValue")
	currentZone.Name = "CurrentZone"
	currentZone.Value = "None"
	currentZone.Parent = leaderstats

	JonesFoodInventory.ensureFolder(player)
end

Players.PlayerAdded:Connect(setupPlayerStats)

for _, player in Players:GetPlayers() do
	setupPlayerStats(player)
end
