export type FoodItem = {
	Id: string,
	DisplayName: string,
	Price: number,
	EnergyRestore: number,
	HungerRestore: number,
	FullnessMinutes: number,
	ImageAssetId: string,
	ThemeColor: Color3,
	EmojiFallback: string,
}

local JonesFoodItems = {}

JonesFoodItems.BUY_FOOD_ITEM_ACTION = "BuyFoodItem"
JonesFoodItems.EAT_FOOD_ITEM_ACTION = "EatFoodItem"

JonesFoodItems.Water = {
	Id = "Water",
	DisplayName = "Water",
	Price = 3,
	EnergyRestore = 5,
	HungerRestore = 0,
	FullnessMinutes = 10,
	-- Custom PNG source: Assets/FoodIcons/water.png
	-- Replace ImageAssetId after uploading PNG to Roblox and receiving asset id.
	ImageAssetId = "rbxassetid://103271145720137",
	ThemeColor = Color3.fromRGB(100, 180, 255),
	EmojiFallback = "💧",
} :: FoodItem

JonesFoodItems.Apple = {
	Id = "Apple",
	DisplayName = "Apple",
	Price = 5,
	EnergyRestore = 5,
	HungerRestore = 10,
	FullnessMinutes = 30,
	-- Custom PNG source: Assets/FoodIcons/apple.png
	-- Replace ImageAssetId after uploading PNG to Roblox and receiving asset id.
	ImageAssetId = "rbxassetid://79360984269983",
	ThemeColor = Color3.fromRGB(220, 80, 80),
	EmojiFallback = "🍎",
} :: FoodItem

JonesFoodItems.Bread = {
	Id = "Bread",
	DisplayName = "Bread",
	Price = 8,
	EnergyRestore = 10,
	HungerRestore = 18,
	FullnessMinutes = 45,
	-- Custom PNG source: Assets/FoodIcons/bread.png
	-- Replace ImageAssetId after uploading PNG to Roblox and receiving asset id.
	ImageAssetId = "rbxassetid://84892713452962",
	ThemeColor = Color3.fromRGB(210, 170, 100),
	EmojiFallback = "🍞",
} :: FoodItem

JonesFoodItems.Sandwich = {
	Id = "Sandwich",
	DisplayName = "Sandwich",
	Price = 15,
	EnergyRestore = 25,
	HungerRestore = 35,
	FullnessMinutes = 90,
	-- Custom PNG source: Assets/FoodIcons/sandwich.png
	-- Replace ImageAssetId after uploading PNG to Roblox and receiving asset id.
	ImageAssetId = "rbxassetid://91888167350450",
	ThemeColor = Color3.fromRGB(180, 140, 90),
	EmojiFallback = "🥪",
} :: FoodItem

JonesFoodItems.HotMeal = {
	Id = "HotMeal",
	DisplayName = "Hot Meal",
	Price = 25,
	EnergyRestore = 40,
	HungerRestore = 60,
	FullnessMinutes = 180,
	-- Custom PNG source: Assets/FoodIcons/hot_meal.png
	-- Replace ImageAssetId after uploading PNG to Roblox and receiving asset id.
	ImageAssetId = "rbxassetid://97078004998911",
	ThemeColor = Color3.fromRGB(255, 140, 60),
	EmojiFallback = "🍲",
} :: FoodItem

JonesFoodItems.FamilyMeal = {
	Id = "FamilyMeal",
	DisplayName = "Family Meal",
	Price = 45,
	EnergyRestore = 60,
	HungerRestore = 100,
	FullnessMinutes = 300,
	-- Custom PNG source: Assets/FoodIcons/family_meal.png
	-- Replace ImageAssetId after uploading PNG to Roblox and receiving asset id.
	ImageAssetId = "rbxassetid://99673651923906",
	ThemeColor = Color3.fromRGB(200, 100, 120),
	EmojiFallback = "🍖",
} :: FoodItem

local itemsById: { [string]: FoodItem } = {
	[JonesFoodItems.Water.Id] = JonesFoodItems.Water,
	[JonesFoodItems.Apple.Id] = JonesFoodItems.Apple,
	[JonesFoodItems.Bread.Id] = JonesFoodItems.Bread,
	[JonesFoodItems.Sandwich.Id] = JonesFoodItems.Sandwich,
	[JonesFoodItems.HotMeal.Id] = JonesFoodItems.HotMeal,
	[JonesFoodItems.FamilyMeal.Id] = JonesFoodItems.FamilyMeal,
}

local itemOrder: { FoodItem } = {
	JonesFoodItems.Water,
	JonesFoodItems.Apple,
	JonesFoodItems.Bread,
	JonesFoodItems.Sandwich,
	JonesFoodItems.HotMeal,
	JonesFoodItems.FamilyMeal,
}

function JonesFoodItems.getItem(itemId: string): FoodItem?
	return itemsById[itemId]
end

function JonesFoodItems.getAllItems(): { FoodItem }
	return itemOrder
end

function JonesFoodItems.getInventoryBuyMessage(item: FoodItem): string
	return `Bought {item.DisplayName} for inventory! -{item.Price} Wallet.`
end

function JonesFoodItems.getEatMessage(item: FoodItem, energyGained: number, hungerGained: number): string
	return `Ate {item.DisplayName}! +{energyGained} Energy, +{hungerGained} Hunger. Full for {item.FullnessMinutes} min.`
end

return JonesFoodItems
