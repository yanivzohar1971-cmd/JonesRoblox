local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JonesDailyBill = require(script.Parent.JonesDailyBill)

-- Testing only: set true locally to reach midnight faster. Must stay false in repo.
local TEST_FAST_DAY = false

local TICK_INTERVAL = if TEST_FAST_DAY then 1 else 5
local MINUTES_PER_TICK = if TEST_FAST_DAY then 120 else 10
local MINUTES_PER_DAY = 24 * 60
local START_DAY = 1
local START_MINUTES = 8 * 60

local jonesDay = ReplicatedStorage:WaitForChild("JonesDay") :: IntValue
local jonesClockText = ReplicatedStorage:WaitForChild("JonesClockText") :: StringValue
local jonesGameMinutes = ReplicatedStorage:WaitForChild("JonesGameMinutes") :: IntValue

local currentDay = START_DAY
local currentMinutes = START_MINUTES

local function formatClockText(day: number, minutesFromMidnight: number): string
	local hour = math.floor(minutesFromMidnight / 60)
	local minute = minutesFromMidnight % 60
	return ("Day %d · %02d:%02d"):format(day, hour, minute)
end

local function replicateTime()
	jonesDay.Value = currentDay
	jonesGameMinutes.Value = currentMinutes
	jonesClockText.Value = formatClockText(currentDay, currentMinutes)
end

local function advanceTime()
	currentMinutes += MINUTES_PER_TICK

	while currentMinutes >= MINUTES_PER_DAY do
		currentMinutes -= MINUTES_PER_DAY
		currentDay += 1
		print(`[JonesTimeService] New day: Day {currentDay}`)
		JonesDailyBill.processAllPlayers()
	end

	replicateTime()
end

replicateTime()

if TEST_FAST_DAY then
	warn("[JonesTimeService] TEST_FAST_DAY is enabled — fast-forwarding game time for bill testing.")
end

print(
	`[JonesTimeService] Started at {jonesClockText.Value} (every {TICK_INTERVAL}s = +{MINUTES_PER_TICK} game minutes)`
)

while true do
	task.wait(TICK_INTERVAL)
	advanceTime()
end
