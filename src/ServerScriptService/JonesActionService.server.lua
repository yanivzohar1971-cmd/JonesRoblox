local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JonesFullness = require(script.Parent.JonesFullness)
local JonesFoodInventory = require(script.Parent.JonesFoodInventory)
local JonesFoodItems = require(script.Parent.JonesFoodItems)
local JonesJobs = require(script.Parent.JonesJobs)
local JonesNeeds = require(script.Parent.JonesNeeds)

local performActionRemote = ReplicatedStorage:WaitForChild("JonesPerformAction")

local MAX_ENERGY = 100
local MAX_HUNGER = 100

local REST_ZONE = "Home"
local REST_ENERGY_GAIN = 30
local REST_COOLDOWN = 10

local BUY_FOOD_ZONE = "Market"

local BANK_ZONE = "Bank"
local WITHDRAW_AMOUNT = 25

local MARKET_OPEN_START = 7 * 60
local MARKET_OPEN_END = 22 * 60

local jonesDay = ReplicatedStorage:WaitForChild("JonesDay") :: IntValue
local jonesGameMinutes = ReplicatedStorage:WaitForChild("JonesGameMinutes") :: IntValue
local jonesWorldMessage = ReplicatedStorage:WaitForChild("JonesWorldMessage") :: StringValue

local lastRestAt: { [Player]: number } = {}

local function getLeaderstats(player: Player): Folder?
	return player:FindFirstChild("leaderstats") :: Folder?
end

local function sendStatus(player: Player, message: string)
	performActionRemote:FireClient(player, message)
end

local function sendWorldMessage(player: Player, message: string)
	jonesWorldMessage.Value = message
	sendStatus(player, message)
end

local function applyJobXpGain(jobXp: IntValue, jobLevel: IntValue, xpReward: number, player: Player)
	jobXp.Value += xpReward

	while jobXp.Value >= JonesJobs.XP_PER_LEVEL do
		jobXp.Value -= JonesJobs.XP_PER_LEVEL
		jobLevel.Value += 1
		sendWorldMessage(player, `Job level up! Level {jobLevel.Value}.`)
	end
end

local function isWithinHours(minutes: number, startMinutes: number, endMinutes: number): boolean
	return minutes >= startMinutes and minutes <= endMinutes
end

local function isMarketOpen(): boolean
	return isWithinHours(jonesGameMinutes.Value, MARKET_OPEN_START, MARKET_OPEN_END)
end

local function isJobOnCooldown(player: Player, job: JonesJobs.JobDefinition): boolean
	local endTime = player:GetAttribute(JonesJobs.getCooldownAttributeName(job.Id))
	return typeof(endTime) == "number" and workspace:GetServerTimeNow() < endTime
end

local function setJobCooldown(player: Player, job: JonesJobs.JobDefinition)
	player:SetAttribute(
		JonesJobs.getCooldownAttributeName(job.Id),
		workspace:GetServerTimeNow() + job.CooldownSeconds
	)
end

local function performJob(player: Player, job: JonesJobs.JobDefinition)
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return
	end

	local currentZone = leaderstats:FindFirstChild("CurrentZone") :: StringValue?
	local energy = leaderstats:FindFirstChild("Energy") :: IntValue?
	local hunger = leaderstats:FindFirstChild("Hunger") :: IntValue?
	local money = leaderstats:FindFirstChild("Money") :: IntValue?
	local reputation = leaderstats:FindFirstChild("Reputation") :: IntValue?
	local jobXp = leaderstats:FindFirstChild("JobXP") :: IntValue?
	local jobLevel = leaderstats:FindFirstChild("JobLevel") :: IntValue?

	if not currentZone or not energy or not hunger or not money or not reputation or not jobXp or not jobLevel then
		return
	end

	if currentZone.Value ~= job.Zone then
		sendStatus(player, `Not in {job.Zone} zone.`)
		return
	end

	if not JonesJobs.isOpen(job, jonesGameMinutes.Value) then
		sendStatus(player, JonesJobs.getClosedMessage(job))
		return
	end

	if isJobOnCooldown(player, job) then
		sendStatus(player, `{job.DisplayName} on cooldown.`)
		return
	end

	if energy.Value < job.EnergyCost then
		sendStatus(player, `Not enough Energy (need {job.EnergyCost}).`)
		return
	end

	if JonesNeeds.isStarving(hunger.Value) then
		sendStatus(player, JonesNeeds.STARVING_BLOCK_MESSAGE)
		return
	end

	local hungerBeforeJob = hunger.Value

	energy.Value -= job.EnergyCost

	local fullnessActive = JonesFullness.isActive(player, jonesDay.Value, jonesGameMinutes.Value)
	local hungerCost = JonesFullness.getJobHungerCost(job.HungerCost, fullnessActive)
	hunger.Value -= hungerCost

	reputation.Value += job.ReputationReward
	applyJobXpGain(jobXp, jobLevel, job.XPReward, player)

	local basePay = JonesJobs.getPay(job, jobLevel.Value)
	local moneyReward, hungerPenaltyApplied = JonesNeeds.applyJobPayPenalty(basePay, hungerBeforeJob)
	money.Value += moneyReward
	setJobCooldown(player, job)

	sendStatus(
		player,
		JonesJobs.getCompleteMessage(job, moneyReward, job.EnergyCost, hungerCost, hungerPenaltyApplied)
	)
end

local function performJobById(player: Player, jobId: string)
	local job = JonesJobs.getJob(jobId)
	if not job then
		sendStatus(player, "Job not available.")
		return
	end

	performJob(player, job)
end

local function performWorkShift(player: Player)
	performJobById(player, JonesJobs.WAREHOUSE_SHIFT_ID)
end

local function performRest(player: Player)
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return
	end

	local currentZone = leaderstats:FindFirstChild("CurrentZone") :: StringValue?
	local energy = leaderstats:FindFirstChild("Energy") :: IntValue?

	if not currentZone or not energy then
		return
	end

	if currentZone.Value ~= REST_ZONE then
		sendStatus(player, "Not in Home zone.")
		return
	end

	if energy.Value >= MAX_ENERGY then
		sendStatus(player, "Energy is already full.")
		return
	end

	local now = os.clock()
	local lastRest = lastRestAt[player]
	if lastRest and now - lastRest < REST_COOLDOWN then
		sendStatus(player, "Rest on cooldown.")
		return
	end

	energy.Value = math.min(MAX_ENERGY, energy.Value + REST_ENERGY_GAIN)
	lastRestAt[player] = now

	sendStatus(player, "Rest complete! +30 Energy.")
end

local function performBuyFoodItem(player: Player, itemId: string)
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return
	end

	local currentZone = leaderstats:FindFirstChild("CurrentZone") :: StringValue?
	local money = leaderstats:FindFirstChild("Money") :: IntValue?

	if not currentZone or not money then
		return
	end

	if currentZone.Value ~= BUY_FOOD_ZONE then
		sendStatus(player, "Not in Market zone.")
		return
	end

	if not isMarketOpen() then
		sendStatus(player, "Market is closed. Come back between 07:00 and 22:00.")
		return
	end

	local item = JonesFoodItems.getItem(itemId)
	if not item then
		sendStatus(player, "Food item not available.")
		return
	end

	if money.Value < item.Price then
		sendStatus(player, `Not enough Wallet (need {item.Price}).`)
		return
	end

	money.Value -= item.Price
	if not JonesFoodInventory.addCount(player, itemId, 1) then
		money.Value += item.Price
		sendStatus(player, "Could not add food to inventory.")
		return
	end

	sendStatus(player, JonesFoodItems.getInventoryBuyMessage(item))
end

local function performEatFoodItem(player: Player, itemId: string)
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return
	end

	local energy = leaderstats:FindFirstChild("Energy") :: IntValue?
	local hunger = leaderstats:FindFirstChild("Hunger") :: IntValue?

	if not energy or not hunger then
		return
	end

	local item = JonesFoodItems.getItem(itemId)
	if not item then
		sendStatus(player, "Food item not available.")
		return
	end

	if JonesFoodInventory.getCount(player, itemId) <= 0 then
		sendStatus(player, `No {item.DisplayName} in inventory.`)
		return
	end

	if energy.Value >= MAX_ENERGY and hunger.Value >= MAX_HUNGER then
		sendStatus(player, "Energy and Hunger are already full.")
		return
	end

	local energyBefore = energy.Value
	local hungerBefore = hunger.Value

	if not JonesFoodInventory.addCount(player, itemId, -1) then
		sendStatus(player, `No {item.DisplayName} in inventory.`)
		return
	end

	energy.Value = math.min(MAX_ENERGY, energy.Value + item.EnergyRestore)
	hunger.Value = math.min(MAX_HUNGER, hunger.Value + item.HungerRestore)

	local energyGained = energy.Value - energyBefore
	local hungerGained = hunger.Value - hungerBefore

	JonesFullness.applyFromFood(player, jonesDay.Value, jonesGameMinutes.Value, item.FullnessMinutes)

	sendStatus(player, JonesFoodItems.getEatMessage(item, energyGained, hungerGained))
end

local function performDepositAll(player: Player)
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return
	end

	local currentZone = leaderstats:FindFirstChild("CurrentZone") :: StringValue?
	local money = leaderstats:FindFirstChild("Money") :: IntValue?
	local bankBalance = leaderstats:FindFirstChild("BankBalance") :: IntValue?

	if not currentZone or not money or not bankBalance then
		return
	end

	if currentZone.Value ~= BANK_ZONE then
		sendStatus(player, "Not in Bank zone.")
		return
	end

	if money.Value <= 0 then
		sendStatus(player, "No wallet money to deposit.")
		return
	end

	bankBalance.Value += money.Value
	money.Value = 0

	sendStatus(player, "Deposited all wallet money.")
end

local function performWithdraw25(player: Player)
	local leaderstats = getLeaderstats(player)
	if not leaderstats then
		return
	end

	local currentZone = leaderstats:FindFirstChild("CurrentZone") :: StringValue?
	local money = leaderstats:FindFirstChild("Money") :: IntValue?
	local bankBalance = leaderstats:FindFirstChild("BankBalance") :: IntValue?

	if not currentZone or not money or not bankBalance then
		return
	end

	if currentZone.Value ~= BANK_ZONE then
		sendStatus(player, "Not in Bank zone.")
		return
	end

	if bankBalance.Value < WITHDRAW_AMOUNT then
		sendStatus(player, "Not enough bank balance.")
		return
	end

	bankBalance.Value -= WITHDRAW_AMOUNT
	money.Value += WITHDRAW_AMOUNT

	sendStatus(player, "Withdrew 25 from bank.")
end

performActionRemote.OnServerEvent:Connect(function(player: Player, actionName: string, itemId: any)
	if actionName == JonesJobs.WORK_SHIFT_ACTION then
		performWorkShift(player)
		return
	end

	if actionName == JonesJobs.CLEANUP_SHIFT_ACTION then
		performJobById(player, JonesJobs.CLEANUP_SHIFT_ID)
		return
	end

	if actionName == "Rest" then
		performRest(player)
		return
	end

	if actionName == JonesFoodItems.BUY_FOOD_ITEM_ACTION then
		if typeof(itemId) ~= "string" then
			sendStatus(player, "Invalid food item.")
			return
		end

		performBuyFoodItem(player, itemId)
		return
	end

	if actionName == JonesFoodItems.EAT_FOOD_ITEM_ACTION then
		if typeof(itemId) ~= "string" then
			sendStatus(player, "Invalid food item.")
			return
		end

		performEatFoodItem(player, itemId)
		return
	end

	if actionName == "DepositAll" then
		performDepositAll(player)
		return
	end

	if actionName == "Withdraw25" then
		performWithdraw25(player)
		return
	end

	sendStatus(player, "Unknown action.")
end)

Players.PlayerRemoving:Connect(function(player)
	lastRestAt[player] = nil
	JonesFullness.clear(player)
end)
