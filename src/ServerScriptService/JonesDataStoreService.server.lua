local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local JonesFoodInventory = require(script.Parent.JonesFoodInventory)

local DATASTORE_NAME = "JonesPlayerData_v1"
local AUTOSAVE_INTERVAL = 60
local MAX_RETRIES = 3
local RETRY_DELAY = 1

local DEFAULT_MONEY = 0
local DEFAULT_BANK_BALANCE = 0
local DEFAULT_ENERGY = 100
local DEFAULT_HUNGER = 100
local DEFAULT_REPUTATION = 0
local DEFAULT_JOB_XP = 0
local DEFAULT_JOB_LEVEL = 1

local playerDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)

type SavedPlayerData = {
	Money: number,
	BankBalance: number,
	Energy: number,
	Hunger: number,
	Reputation: number,
	JobXP: number,
	JobLevel: number,
	FoodInventory: JonesFoodInventory.FoodInventoryData,
	UpdatedAt: number,
}

local function getDataKey(player: Player): string
	return "player_" .. player.UserId
end

local function getDefaultData(): SavedPlayerData
	return {
		Money = DEFAULT_MONEY,
		BankBalance = DEFAULT_BANK_BALANCE,
		Energy = DEFAULT_ENERGY,
		Hunger = DEFAULT_HUNGER,
		Reputation = DEFAULT_REPUTATION,
		JobXP = DEFAULT_JOB_XP,
		JobLevel = DEFAULT_JOB_LEVEL,
		FoodInventory = JonesFoodInventory.getDefaultInventory(),
		UpdatedAt = os.time(),
	}
end

local function waitForStats(player: Player): (IntValue?, IntValue?, IntValue?, IntValue?, IntValue?, IntValue?, IntValue?)
	local leaderstats = player:WaitForChild("leaderstats", 15)
	if not leaderstats then
		return nil, nil, nil, nil, nil, nil, nil
	end

	local money = leaderstats:WaitForChild("Money", 10) :: IntValue?
	local bankBalance = leaderstats:WaitForChild("BankBalance", 10) :: IntValue?
	local energy = leaderstats:WaitForChild("Energy", 10) :: IntValue?
	local hunger = leaderstats:WaitForChild("Hunger", 10) :: IntValue?
	local reputation = leaderstats:WaitForChild("Reputation", 10) :: IntValue?
	local jobXp = leaderstats:WaitForChild("JobXP", 10) :: IntValue?
	local jobLevel = leaderstats:WaitForChild("JobLevel", 10) :: IntValue?

	if not money or not bankBalance or not energy or not hunger or not reputation or not jobXp or not jobLevel then
		return nil, nil, nil, nil, nil, nil, nil
	end

	return money, bankBalance, energy, hunger, reputation, jobXp, jobLevel
end

local function sanitizeLoadedData(raw: any): SavedPlayerData?
	if typeof(raw) ~= "table" then
		return nil
	end

	local money = tonumber(raw.Money)
	local energy = tonumber(raw.Energy)
	local reputation = tonumber(raw.Reputation)
	local hunger = tonumber(raw.Hunger)
	local bankBalance = tonumber(raw.BankBalance)
	local jobXp = tonumber(raw.JobXP)
	local jobLevel = tonumber(raw.JobLevel)

	if not money or not energy or not reputation then
		return nil
	end

	return {
		Money = math.floor(money),
		BankBalance = bankBalance and math.floor(bankBalance) or DEFAULT_BANK_BALANCE,
		Energy = math.floor(energy),
		Hunger = hunger and math.floor(hunger) or DEFAULT_HUNGER,
		Reputation = math.floor(reputation),
		JobXP = jobXp and math.floor(jobXp) or DEFAULT_JOB_XP,
		JobLevel = jobLevel and math.floor(jobLevel) or DEFAULT_JOB_LEVEL,
		FoodInventory = JonesFoodInventory.sanitize(raw.FoodInventory),
		UpdatedAt = tonumber(raw.UpdatedAt) or os.time(),
	}
end

local function withRetries<T>(operationName: string, player: Player, callback: () -> T): (boolean, T?)
	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(callback)
		if ok then
			return true, result
		end

		warn(
			`[JonesDataStore] {operationName} failed for {player.Name} (attempt {attempt}/{MAX_RETRIES}): {result}`
		)

		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY)
		end
	end

	return false, nil
end

local function applyDataToStats(
	money: IntValue,
	bankBalance: IntValue,
	energy: IntValue,
	hunger: IntValue,
	reputation: IntValue,
	jobXp: IntValue,
	jobLevel: IntValue,
	data: SavedPlayerData
)
	money.Value = data.Money
	bankBalance.Value = data.BankBalance
	energy.Value = data.Energy
	hunger.Value = data.Hunger
	reputation.Value = data.Reputation
	jobXp.Value = data.JobXP
	jobLevel.Value = data.JobLevel
end

local function readStatsFromPlayer(player: Player): SavedPlayerData?
	local money, bankBalance, energy, hunger, reputation, jobXp, jobLevel = waitForStats(player)
	if not money or not bankBalance or not energy or not hunger or not reputation or not jobXp or not jobLevel then
		return nil
	end

	return {
		Money = money.Value,
		BankBalance = bankBalance.Value,
		Energy = energy.Value,
		Hunger = hunger.Value,
		Reputation = reputation.Value,
		JobXP = jobXp.Value,
		JobLevel = jobLevel.Value,
		FoodInventory = JonesFoodInventory.readFromPlayer(player),
		UpdatedAt = os.time(),
	}
end

local DATA_LOADED_ATTR = "JonesDataLoaded"

local function markDataLoaded(player: Player)
	player:SetAttribute(DATA_LOADED_ATTR, true)
end

local function loadPlayerData(player: Player)
	player:SetAttribute(DATA_LOADED_ATTR, false)
	print(`[JonesDataStore] Loading {player.Name} ({player.UserId})...`)

	local money, bankBalance, energy, hunger, reputation, jobXp, jobLevel = waitForStats(player)
	if not money or not bankBalance or not energy or not hunger or not reputation or not jobXp or not jobLevel then
		warn(`[JonesDataStore] Load skipped — leaderstats not ready for {player.Name}`)
		return
	end

	JonesFoodInventory.ensureFolder(player)

	local key = getDataKey(player)
	local loadedData: SavedPlayerData? = nil

	local success, result = withRetries("Load", player, function()
		return playerDataStore:GetAsync(key)
	end)

	if success and result ~= nil then
		loadedData = sanitizeLoadedData(result)
		if loadedData then
			applyDataToStats(money, bankBalance, energy, hunger, reputation, jobXp, jobLevel, loadedData)
			JonesFoodInventory.applyToPlayer(player, loadedData.FoodInventory)
			print(
				`[JonesDataStore] Load success for {player.Name} | Wallet={loadedData.Money} Bank={loadedData.BankBalance} JobL={loadedData.JobLevel} JobXP={loadedData.JobXP} Reputation={loadedData.Reputation}`
			)
			markDataLoaded(player)
			return
		end

		warn(`[JonesDataStore] Invalid saved data for {player.Name}; using defaults.`)
	elseif success then
		print(`[JonesDataStore] No saved data for {player.Name}; using defaults.`)
	else
		warn(`[JonesDataStore] Load failed for {player.Name}; using defaults.`)
	end

	local defaults = getDefaultData()
	applyDataToStats(money, bankBalance, energy, hunger, reputation, jobXp, jobLevel, defaults)
	JonesFoodInventory.applyToPlayer(player, defaults.FoodInventory)
	markDataLoaded(player)
end

local function savePlayerData(player: Player, reason: string): boolean
	local data = readStatsFromPlayer(player)
	if not data then
		warn(`[JonesDataStore] Save skipped — leaderstats not ready for {player.Name} ({reason})`)
		return false
	end

	local key = getDataKey(player)
	local success, _ = withRetries("Save", player, function()
		playerDataStore:SetAsync(key, data)
		return true
	end)

	if success then
		print(
			`[JonesDataStore] Save success for {player.Name} ({reason}) | Wallet={data.Money} Bank={data.BankBalance} JobL={data.JobLevel} JobXP={data.JobXP} Reputation={data.Reputation}`
		)
		return true
	end

	warn(`[JonesDataStore] Save failed for {player.Name} ({reason})`)
	return false
end

local function saveAllPlayers(reason: string)
	for _, player in Players:GetPlayers() do
		savePlayerData(player, reason)
	end
end

local function onPlayerAdded(player: Player)
	task.spawn(function()
		loadPlayerData(player)
	end)
end

local function onPlayerRemoving(player: Player)
	savePlayerData(player, "PlayerRemoving")
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
	task.spawn(function()
		loadPlayerData(player)
	end)
end

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		print("[JonesDataStore] Autosave tick...")
		saveAllPlayers("Autosave")
	end
end)

game:BindToClose(function()
	print("[JonesDataStore] BindToClose — saving all players...")
	saveAllPlayers("BindToClose")
	task.wait(2)
end)
