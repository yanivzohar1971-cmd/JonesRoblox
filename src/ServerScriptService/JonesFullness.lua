local MINUTES_PER_DAY = 24 * 60

local JonesFullness = {}

JonesFullness.UNTIL_GAME_MINUTES_ATTR = "JonesFullnessUntilGameMinutes"
JonesFullness.UNTIL_DAY_ATTR = "JonesFullnessUntilDay"
JonesFullness.HUNGER_COST_MULTIPLIER = 0.5

function JonesFullness.clear(player: Player)
	player:SetAttribute(JonesFullness.UNTIL_GAME_MINUTES_ATTR, 0)
	player:SetAttribute(JonesFullness.UNTIL_DAY_ATTR, 0)
end

function JonesFullness.applyFromFood(player: Player, currentDay: number, currentGameMinutes: number, fullnessMinutes: number)
	if fullnessMinutes <= 0 then
		return
	end

	local totalMinutes = currentGameMinutes + fullnessMinutes
	local untilDay = currentDay + math.floor(totalMinutes / MINUTES_PER_DAY)
	local untilGameMinutes = totalMinutes % MINUTES_PER_DAY

	player:SetAttribute(JonesFullness.UNTIL_GAME_MINUTES_ATTR, untilGameMinutes)
	player:SetAttribute(JonesFullness.UNTIL_DAY_ATTR, untilDay)
end

function JonesFullness.isActive(player: Player, currentDay: number, currentGameMinutes: number): boolean
	local untilDay = player:GetAttribute(JonesFullness.UNTIL_DAY_ATTR)
	local untilGameMinutes = player:GetAttribute(JonesFullness.UNTIL_GAME_MINUTES_ATTR)

	if typeof(untilDay) ~= "number" or typeof(untilGameMinutes) ~= "number" then
		return false
	end

	if untilDay <= 0 then
		return false
	end

	if currentDay < untilDay then
		return true
	end

	if currentDay == untilDay and currentGameMinutes < untilGameMinutes then
		return true
	end

	JonesFullness.clear(player)
	return false
end

function JonesFullness.getRemainingMinutes(player: Player, currentDay: number, currentGameMinutes: number): number
	if not JonesFullness.isActive(player, currentDay, currentGameMinutes) then
		return 0
	end

	local untilDay = player:GetAttribute(JonesFullness.UNTIL_DAY_ATTR) :: number
	local untilGameMinutes = player:GetAttribute(JonesFullness.UNTIL_GAME_MINUTES_ATTR) :: number
	local untilAbsolute = (untilDay - 1) * MINUTES_PER_DAY + untilGameMinutes
	local nowAbsolute = (currentDay - 1) * MINUTES_PER_DAY + currentGameMinutes

	return math.max(0, untilAbsolute - nowAbsolute)
end

function JonesFullness.isFull(player: Player, currentDay: number, currentGameMinutes: number): boolean
	return JonesFullness.isActive(player, currentDay, currentGameMinutes)
end

function JonesFullness.getJobHungerCost(baseCost: number, fullnessActive: boolean): number
	if not fullnessActive then
		return baseCost
	end

	return math.max(1, math.ceil(baseCost * JonesFullness.HUNGER_COST_MULTIPLIER))
end

return JonesFullness
