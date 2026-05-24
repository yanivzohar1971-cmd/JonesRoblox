local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DAILY_BILL_AMOUNT = 30
local REPUTATION_PENALTY = 2

local JonesDailyBill = {}

function JonesDailyBill.processPlayer(player: Player): string?
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local money = leaderstats:FindFirstChild("Money") :: IntValue?
	local bankBalance = leaderstats:FindFirstChild("BankBalance") :: IntValue?
	local reputation = leaderstats:FindFirstChild("Reputation") :: IntValue?

	if not money or not bankBalance or not reputation then
		return nil
	end

	local totalAvailable = money.Value + bankBalance.Value

	if totalAvailable >= DAILY_BILL_AMOUNT then
		local remaining = DAILY_BILL_AMOUNT
		local fromBank = math.min(bankBalance.Value, remaining)
		bankBalance.Value -= fromBank
		remaining -= fromBank
		money.Value -= remaining
		return "Daily bill paid: 30."
	end

	bankBalance.Value = 0
	money.Value = 0
	reputation.Value = math.max(0, reputation.Value - REPUTATION_PENALTY)
	return "Daily bill missed. Reputation decreased."
end

function JonesDailyBill.processAllPlayers()
	local jonesWorldMessage = ReplicatedStorage:FindFirstChild("JonesWorldMessage") :: StringValue?
	local performActionRemote = ReplicatedStorage:FindFirstChild("JonesPerformAction") :: RemoteEvent?

	for _, player in Players:GetPlayers() do
		local message = JonesDailyBill.processPlayer(player)
		if not message then
			continue
		end

		if jonesWorldMessage then
			jonesWorldMessage.Value = message
		end

		if performActionRemote then
			performActionRemote:FireClient(player, message)
		end

		print(`[JonesDailyBill] {player.Name}: {message}`)
	end
end

return JonesDailyBill
