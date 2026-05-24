local JonesNeeds = {}

JonesNeeds.HUNGRY_THRESHOLD = 30
JonesNeeds.STARVING_THRESHOLD = 10
JonesNeeds.HUNGRY_PAY_MULTIPLIER = 0.8

JonesNeeds.STARVING_BLOCK_MESSAGE = "Too hungry to work. Eat something first."

function JonesNeeds.isHungry(hunger: number): boolean
	return hunger <= JonesNeeds.HUNGRY_THRESHOLD
end

function JonesNeeds.isStarving(hunger: number): boolean
	return hunger <= JonesNeeds.STARVING_THRESHOLD
end

function JonesNeeds.applyJobPayPenalty(basePay: number, hunger: number): (number, boolean)
	if not JonesNeeds.isHungry(hunger) then
		return basePay, false
	end

	return math.floor(basePay * JonesNeeds.HUNGRY_PAY_MULTIPLIER), true
end

function JonesNeeds.getNeedsStatusText(hunger: number): string
	if JonesNeeds.isStarving(hunger) then
		return "Needs: Starving — eat now"
	end

	if JonesNeeds.isHungry(hunger) then
		return "Needs: Hungry — eat soon"
	end

	return "Needs: OK"
end

return JonesNeeds
