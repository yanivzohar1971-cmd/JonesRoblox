export type JobDefinition = {
	Id: string,
	DisplayName: string,
	Zone: string,
	BasePay: number,
	EnergyCost: number,
	HungerCost: number,
	ReputationReward: number,
	XPReward: number,
	CooldownSeconds: number,
	OpenMinutes: number,
	CloseMinutes: number,
}

local JonesJobs = {}

JonesJobs.WORK_SHIFT_ACTION = "WorkShift"
JonesJobs.WAREHOUSE_SHIFT_ID = "WarehouseShift"
JonesJobs.CLEANUP_SHIFT_ID = "CleanupShift"
JonesJobs.CLEANUP_SHIFT_ACTION = "CleanupShift"
JonesJobs.XP_PER_LEVEL = 50
JonesJobs.PAY_PER_LEVEL = 5
JonesJobs.MIN_HUNGER_TO_WORK = 10

JonesJobs.WarehouseShift = {
	Id = "WarehouseShift",
	DisplayName = "Warehouse Shift",
	Zone = "Industrial",
	BasePay = 25,
	EnergyCost = 20,
	HungerCost = 10,
	ReputationReward = 1,
	XPReward = 10,
	CooldownSeconds = 10,
	OpenMinutes = 8 * 60,
	CloseMinutes = 18 * 60,
} :: JobDefinition

JonesJobs.CleanupShift = {
	Id = "CleanupShift",
	DisplayName = "Cleanup Shift",
	Zone = "Industrial",
	BasePay = 15,
	EnergyCost = 10,
	HungerCost = 5,
	ReputationReward = 1,
	XPReward = 5,
	CooldownSeconds = 6,
	OpenMinutes = 8 * 60,
	CloseMinutes = 20 * 60,
} :: JobDefinition

local jobsById: { [string]: JobDefinition } = {
	[JonesJobs.WAREHOUSE_SHIFT_ID] = JonesJobs.WarehouseShift,
	[JonesJobs.CLEANUP_SHIFT_ID] = JonesJobs.CleanupShift,
}

function JonesJobs.getJob(jobId: string): JobDefinition?
	return jobsById[jobId]
end

function JonesJobs.getJobsForZone(zoneName: string): { JobDefinition }
	local jobs: { JobDefinition } = {}

	for _, job in jobsById do
		if job.Zone == zoneName then
			table.insert(jobs, job)
		end
	end

	return jobs
end

function JonesJobs.getPay(job: JobDefinition, jobLevel: number): number
	return job.BasePay + (jobLevel - 1) * JonesJobs.PAY_PER_LEVEL
end

function JonesJobs.isOpen(job: JobDefinition, gameMinutes: number): boolean
	return gameMinutes >= job.OpenMinutes and gameMinutes <= job.CloseMinutes
end

function JonesJobs.formatHours(minutesFromMidnight: number): string
	local hour = math.floor(minutesFromMidnight / 60)
	local minute = minutesFromMidnight % 60
	return ("%02d:%02d"):format(hour, minute)
end

function JonesJobs.getClosedMessage(job: JobDefinition): string
	return `{job.DisplayName} is closed. Come back between {JonesJobs.formatHours(job.OpenMinutes)} and {JonesJobs.formatHours(job.CloseMinutes)}.`
end

function JonesJobs.getCooldownAttributeName(jobId: string): string
	return "JonesCooldown_" .. jobId
end

function JonesJobs.getCompleteMessage(
	job: JobDefinition,
	moneyReward: number,
	energyCost: number,
	hungerCost: number,
	hungerPenaltyApplied: boolean
): string
	local message = `{job.DisplayName} complete! +{moneyReward} Wallet, -{energyCost} Energy, -{hungerCost} Hunger, +{job.XPReward} XP.`

	if hungerPenaltyApplied then
		message ..= " Hunger penalty applied."
	end

	return message
end

function JonesJobs.getHintText(job: JobDefinition, jobLevel: number): string
	local pay = JonesJobs.getPay(job, jobLevel)
	return `+{pay} / -{job.EnergyCost}E / -{job.HungerCost}H`
end

return JonesJobs
