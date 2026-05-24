local JonesFoodItems = require(script.Parent.JonesFoodItems)

export type FoodInventoryData = { [string]: number }

local JonesFoodInventory = {}

local FOLDER_NAME = "FoodInventory"

function JonesFoodInventory.getDefaultInventory(): FoodInventoryData
	local inventory: FoodInventoryData = {}

	for _, item in JonesFoodItems.getAllItems() do
		inventory[item.Id] = 0
	end

	return inventory
end

function JonesFoodInventory.sanitize(raw: any): FoodInventoryData
	local defaults = JonesFoodInventory.getDefaultInventory()

	if typeof(raw) ~= "table" then
		return defaults
	end

	for itemId, _ in defaults do
		local count = tonumber(raw[itemId])
		defaults[itemId] = if count and count >= 0 then math.floor(count) else 0
	end

	return defaults
end

function JonesFoodInventory.ensureFolder(player: Player): Folder
	local folder = player:FindFirstChild(FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = FOLDER_NAME
	folder.Parent = player

	for _, item in JonesFoodItems.getAllItems() do
		local countValue = Instance.new("IntValue")
		countValue.Name = item.Id
		countValue.Value = 0
		countValue.Parent = folder
	end

	return folder
end

function JonesFoodInventory.applyToPlayer(player: Player, inventory: FoodInventoryData)
	local folder = JonesFoodInventory.ensureFolder(player)

	for _, item in JonesFoodItems.getAllItems() do
		local countValue = folder:FindFirstChild(item.Id) :: IntValue?
		if countValue then
			countValue.Value = inventory[item.Id] or 0
		end
	end
end

function JonesFoodInventory.readFromPlayer(player: Player): FoodInventoryData
	local folder = player:FindFirstChild(FOLDER_NAME)
	local inventory = JonesFoodInventory.getDefaultInventory()

	if not folder or not folder:IsA("Folder") then
		return inventory
	end

	for itemId, _ in inventory do
		local countValue = folder:FindFirstChild(itemId) :: IntValue?
		if countValue then
			inventory[itemId] = math.max(0, countValue.Value)
		end
	end

	return inventory
end

function JonesFoodInventory.getCount(player: Player, itemId: string): number
	local folder = player:FindFirstChild(FOLDER_NAME)
	if not folder or not folder:IsA("Folder") then
		return 0
	end

	local countValue = folder:FindFirstChild(itemId) :: IntValue?
	if not countValue then
		return 0
	end

	return math.max(0, countValue.Value)
end

function JonesFoodInventory.addCount(player: Player, itemId: string, delta: number): boolean
	if delta == 0 then
		return true
	end

	local folder = JonesFoodInventory.ensureFolder(player)
	local countValue = folder:FindFirstChild(itemId) :: IntValue?

	if not countValue then
		return false
	end

	local newCount = countValue.Value + delta
	if newCount < 0 then
		return false
	end

	countValue.Value = newCount
	return true
end

return JonesFoodInventory
