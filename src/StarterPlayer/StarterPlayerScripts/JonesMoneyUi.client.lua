local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local UserInputService = game:GetService("UserInputService")

-- HUD layout: bottom-right dock, screen-safe margins, draggable stats/actions headers.
local HUD_SAFE_MARGIN = 16
local HUD_PANEL_WIDTH = 260
local HUD_INVENTORY_WIDTH = 188
local HUD_INVENTORY_HEIGHT = 48
local HUD_HEADER_HEIGHT = 26
local HUD_STACK_GAP = 8
local HUD_STATS_MAX_HEIGHT = 320
local HUD_ACTIONS_MAX_HEIGHT = 240
local HUD_DISPLAY_ORDER = 100
local HUD_COMPACT_PADDING = 3
local HUD_STAT_ROW = 17
local HUD_INNER_PADDING = 8

local function disableDefaultChat()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

	local chatWindow = TextChatService:FindFirstChild("ChatWindowConfiguration")
	if chatWindow and chatWindow:IsA("ChatWindowConfiguration") then
		chatWindow.Enabled = false
	end
end

disableDefaultChat()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local performActionRemote = ReplicatedStorage:WaitForChild("JonesPerformAction")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JonesMoneyUi"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = HUD_DISPLAY_ORDER
screenGui.Parent = playerGui

local hudDockLayer = Instance.new("Frame")
hudDockLayer.Name = "HudDockLayer"
hudDockLayer.Size = UDim2.fromScale(1, 1)
hudDockLayer.BackgroundTransparency = 1
hudDockLayer.BorderSizePixel = 0
hudDockLayer.ZIndex = 1
hudDockLayer.Parent = screenGui

local frame = Instance.new("Frame")
frame.Name = "StatsFrame"
frame.Size = UDim2.fromOffset(HUD_PANEL_WIDTH, HUD_HEADER_HEIGHT + 120)
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -HUD_SAFE_MARGIN, 0, HUD_SAFE_MARGIN + 36)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = hudDockLayer

local statsHeader = Instance.new("TextButton")
statsHeader.Name = "StatsHeader"
statsHeader.Size = UDim2.new(1, 0, 0, HUD_HEADER_HEIGHT)
statsHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
statsHeader.BackgroundTransparency = 0.35
statsHeader.BorderSizePixel = 0
statsHeader.AutoButtonColor = false
statsHeader.Text = ""
statsHeader.Parent = frame

local statsTitleLabel = Instance.new("TextLabel")
statsTitleLabel.Name = "StatsTitleLabel"
statsTitleLabel.Size = UDim2.new(1, -28, 1, 0)
statsTitleLabel.Position = UDim2.fromOffset(HUD_INNER_PADDING, 0)
statsTitleLabel.BackgroundTransparency = 1
statsTitleLabel.Font = Enum.Font.GothamBold
statsTitleLabel.TextSize = 13
statsTitleLabel.TextColor3 = Color3.fromRGB(170, 200, 255)
statsTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
statsTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
statsTitleLabel.Text = "Stats"
statsTitleLabel.Parent = statsHeader

local statsDragHint = Instance.new("TextLabel")
statsDragHint.Name = "DragHint"
statsDragHint.Size = UDim2.fromOffset(24, HUD_HEADER_HEIGHT)
statsDragHint.AnchorPoint = Vector2.new(1, 0)
statsDragHint.Position = UDim2.new(1, -4, 0, 0)
statsDragHint.BackgroundTransparency = 1
statsDragHint.Font = Enum.Font.Gotham
statsDragHint.TextSize = 12
statsDragHint.TextColor3 = Color3.fromRGB(130, 130, 140)
statsDragHint.Text = "⋮⋮"
statsDragHint.Parent = statsHeader

local statsScroll = Instance.new("ScrollingFrame")
statsScroll.Name = "StatsScroll"
statsScroll.Size = UDim2.new(1, 0, 1, -HUD_HEADER_HEIGHT)
statsScroll.Position = UDim2.fromOffset(0, HUD_HEADER_HEIGHT)
statsScroll.BackgroundTransparency = 1
statsScroll.BorderSizePixel = 0
statsScroll.ScrollBarThickness = 5
statsScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
statsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
statsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
statsScroll.CanvasSize = UDim2.new()
statsScroll.Parent = frame

local statsContent = Instance.new("Frame")
statsContent.Name = "StatsContent"
statsContent.Size = UDim2.new(1, 0, 0, 0)
statsContent.AutomaticSize = Enum.AutomaticSize.Y
statsContent.BackgroundTransparency = 1
statsContent.BorderSizePixel = 0
statsContent.Parent = statsScroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, HUD_COMPACT_PADDING)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = statsContent

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, HUD_INNER_PADDING)
padding.PaddingBottom = UDim.new(0, HUD_INNER_PADDING)
padding.PaddingLeft = UDim.new(0, HUD_INNER_PADDING)
padding.PaddingRight = UDim.new(0, HUD_INNER_PADDING)
padding.Parent = statsContent

local clockLabel = Instance.new("TextLabel")
clockLabel.Name = "ClockLabel"
clockLabel.LayoutOrder = 0
clockLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
clockLabel.BackgroundTransparency = 1
clockLabel.Font = Enum.Font.GothamMedium
clockLabel.TextSize = 15
clockLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
clockLabel.TextXAlignment = Enum.TextXAlignment.Left
clockLabel.Text = "Day 1 · 08:00"
clockLabel.Parent = statsContent

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "MoneyLabel"
moneyLabel.LayoutOrder = 1
moneyLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW + 1)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextSize = 17
moneyLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Text = "Wallet: 0"
moneyLabel.Parent = statsContent

local bankLabel = Instance.new("TextLabel")
bankLabel.Name = "BankLabel"
bankLabel.LayoutOrder = 2
bankLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
bankLabel.BackgroundTransparency = 1
bankLabel.Font = Enum.Font.Gotham
bankLabel.TextSize = 15
bankLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
bankLabel.TextXAlignment = Enum.TextXAlignment.Left
bankLabel.Text = "Bank: 0"
bankLabel.Parent = statsContent

local energyLabel = Instance.new("TextLabel")
energyLabel.Name = "EnergyLabel"
energyLabel.LayoutOrder = 3
energyLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
energyLabel.BackgroundTransparency = 1
energyLabel.Font = Enum.Font.Gotham
energyLabel.TextSize = 15
energyLabel.TextColor3 = Color3.fromRGB(120, 220, 140)
energyLabel.TextXAlignment = Enum.TextXAlignment.Left
energyLabel.Text = "Energy: 100"
energyLabel.Parent = statsContent

local hungerLabel = Instance.new("TextLabel")
hungerLabel.Name = "HungerLabel"
hungerLabel.LayoutOrder = 4
hungerLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
hungerLabel.BackgroundTransparency = 1
hungerLabel.Font = Enum.Font.Gotham
hungerLabel.TextSize = 15
hungerLabel.TextColor3 = Color3.fromRGB(255, 170, 100)
hungerLabel.TextXAlignment = Enum.TextXAlignment.Left
hungerLabel.Text = "Hunger: 100"
hungerLabel.Parent = statsContent

local fullnessLabel = Instance.new("TextLabel")
fullnessLabel.Name = "FullnessLabel"
fullnessLabel.LayoutOrder = 5
fullnessLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
fullnessLabel.BackgroundTransparency = 1
fullnessLabel.Font = Enum.Font.Gotham
fullnessLabel.TextSize = 15
fullnessLabel.TextColor3 = Color3.fromRGB(180, 220, 160)
fullnessLabel.TextXAlignment = Enum.TextXAlignment.Left
fullnessLabel.Text = "Fullness: None"
fullnessLabel.Parent = statsContent

local needsStatusLabel = Instance.new("TextLabel")
needsStatusLabel.Name = "NeedsStatusLabel"
needsStatusLabel.LayoutOrder = 6
needsStatusLabel.Size = UDim2.new(1, 0, 0, 18)
needsStatusLabel.BackgroundTransparency = 1
needsStatusLabel.Font = Enum.Font.Gotham
needsStatusLabel.TextSize = 14
needsStatusLabel.TextColor3 = Color3.fromRGB(200, 210, 200)
needsStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
needsStatusLabel.Text = "Needs: OK"
needsStatusLabel.Parent = statsContent

local reputationLabel = Instance.new("TextLabel")
reputationLabel.Name = "ReputationLabel"
reputationLabel.LayoutOrder = 7
reputationLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
reputationLabel.BackgroundTransparency = 1
reputationLabel.Font = Enum.Font.Gotham
reputationLabel.TextSize = 15
reputationLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
reputationLabel.TextXAlignment = Enum.TextXAlignment.Left
reputationLabel.Text = "Reputation: 0"
reputationLabel.Parent = statsContent

local jobLevelLabel = Instance.new("TextLabel")
jobLevelLabel.Name = "JobLevelLabel"
jobLevelLabel.LayoutOrder = 8
jobLevelLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
jobLevelLabel.BackgroundTransparency = 1
jobLevelLabel.Font = Enum.Font.Gotham
jobLevelLabel.TextSize = 15
jobLevelLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
jobLevelLabel.TextXAlignment = Enum.TextXAlignment.Left
jobLevelLabel.Text = "Job Level: 1"
jobLevelLabel.Parent = statsContent

local jobXpLabel = Instance.new("TextLabel")
jobXpLabel.Name = "JobXpLabel"
jobXpLabel.LayoutOrder = 9
jobXpLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
jobXpLabel.BackgroundTransparency = 1
jobXpLabel.Font = Enum.Font.Gotham
jobXpLabel.TextSize = 15
jobXpLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
jobXpLabel.TextXAlignment = Enum.TextXAlignment.Left
jobXpLabel.Text = "Job XP: 0 / 50"
jobXpLabel.Parent = statsContent

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Name = "ZoneLabel"
zoneLabel.LayoutOrder = 10
zoneLabel.Size = UDim2.new(1, 0, 0, HUD_STAT_ROW)
zoneLabel.BackgroundTransparency = 1
zoneLabel.Font = Enum.Font.Gotham
zoneLabel.TextSize = 15
zoneLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
zoneLabel.TextXAlignment = Enum.TextXAlignment.Left
zoneLabel.Text = "Current Zone: None"
zoneLabel.Parent = statsContent

local objectiveDivider = Instance.new("Frame")
objectiveDivider.Name = "ObjectiveDivider"
objectiveDivider.LayoutOrder = 11
objectiveDivider.Size = UDim2.new(1, 0, 0, 1)
objectiveDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
objectiveDivider.BackgroundTransparency = 0.4
objectiveDivider.BorderSizePixel = 0
objectiveDivider.Parent = statsContent

local objectiveLabel = Instance.new("TextLabel")
objectiveLabel.Name = "ObjectiveLabel"
objectiveLabel.LayoutOrder = 12
objectiveLabel.Size = UDim2.new(1, 0, 0, 30)
objectiveLabel.BackgroundTransparency = 1
objectiveLabel.Font = Enum.Font.GothamMedium
objectiveLabel.TextSize = 13
objectiveLabel.TextColor3 = Color3.fromRGB(255, 235, 180)
objectiveLabel.TextXAlignment = Enum.TextXAlignment.Left
objectiveLabel.TextWrapped = true
objectiveLabel.Text = "Objective: Work a shift at Industrial"
objectiveLabel.Parent = statsContent

local loopStatusLabel = Instance.new("TextLabel")
loopStatusLabel.Name = "LoopStatusLabel"
loopStatusLabel.LayoutOrder = 13
loopStatusLabel.Size = UDim2.new(1, 0, 0, 18)
loopStatusLabel.BackgroundTransparency = 1
loopStatusLabel.Font = Enum.Font.Gotham
loopStatusLabel.TextSize = 13
loopStatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
loopStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
loopStatusLabel.Text = "Loop: Work → Food → Rest"
loopStatusLabel.Parent = statsContent

local messagesDivider = Instance.new("Frame")
messagesDivider.Name = "MessagesDivider"
messagesDivider.LayoutOrder = 14
messagesDivider.Size = UDim2.new(1, 0, 0, 1)
messagesDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
messagesDivider.BackgroundTransparency = 0.4
messagesDivider.BorderSizePixel = 0
messagesDivider.Parent = statsContent

local lastActionLabel = Instance.new("TextLabel")
lastActionLabel.Name = "LastActionLabel"
lastActionLabel.LayoutOrder = 15
lastActionLabel.Size = UDim2.new(1, 0, 0, 28)
lastActionLabel.BackgroundTransparency = 1
lastActionLabel.Font = Enum.Font.Gotham
lastActionLabel.TextSize = 12
lastActionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
lastActionLabel.TextXAlignment = Enum.TextXAlignment.Left
lastActionLabel.TextWrapped = true
lastActionLabel.Text = ""
lastActionLabel.Parent = statsContent

local actionStatusLabel = Instance.new("TextLabel")
actionStatusLabel.Name = "ActionStatusLabel"
actionStatusLabel.LayoutOrder = 16
actionStatusLabel.Size = UDim2.new(1, 0, 0, 0)
actionStatusLabel.Visible = false
actionStatusLabel.Parent = statsContent

local worldMessageLabel = Instance.new("TextLabel")
worldMessageLabel.Name = "WorldMessageLabel"
worldMessageLabel.LayoutOrder = 17
worldMessageLabel.Size = UDim2.new(1, 0, 0, 24)
worldMessageLabel.BackgroundTransparency = 1
worldMessageLabel.Font = Enum.Font.Gotham
worldMessageLabel.TextSize = 12
worldMessageLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
worldMessageLabel.TextXAlignment = Enum.TextXAlignment.Left
worldMessageLabel.TextWrapped = true
worldMessageLabel.Text = ""
worldMessageLabel.Parent = statsContent

local actionsFrame = Instance.new("Frame")
actionsFrame.Name = "ActionsFrame"
actionsFrame.Size = UDim2.fromOffset(HUD_PANEL_WIDTH, HUD_HEADER_HEIGHT + 120)
actionsFrame.AnchorPoint = Vector2.new(1, 1)
actionsFrame.Position = UDim2.new(1, -HUD_SAFE_MARGIN, 1, -HUD_SAFE_MARGIN)
actionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
actionsFrame.BackgroundTransparency = 0.25
actionsFrame.BorderSizePixel = 0
actionsFrame.ClipsDescendants = true
actionsFrame.Visible = false
actionsFrame.Parent = hudDockLayer

local actionsHeader = Instance.new("TextButton")
actionsHeader.Name = "ActionsHeader"
actionsHeader.Size = UDim2.new(1, 0, 0, HUD_HEADER_HEIGHT)
actionsHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
actionsHeader.BackgroundTransparency = 0.35
actionsHeader.BorderSizePixel = 0
actionsHeader.AutoButtonColor = false
actionsHeader.Text = ""
actionsHeader.Parent = actionsFrame

local actionsTitleLabel = Instance.new("TextLabel")
actionsTitleLabel.Name = "ActionsTitleLabel"
actionsTitleLabel.Size = UDim2.new(1, -28, 1, 0)
actionsTitleLabel.Position = UDim2.fromOffset(HUD_INNER_PADDING, 0)
actionsTitleLabel.BackgroundTransparency = 1
actionsTitleLabel.Font = Enum.Font.GothamBold
actionsTitleLabel.TextSize = 13
actionsTitleLabel.TextColor3 = Color3.fromRGB(170, 200, 255)
actionsTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
actionsTitleLabel.TextYAlignment = Enum.TextYAlignment.Center
actionsTitleLabel.Text = "Actions"
actionsTitleLabel.Parent = actionsHeader

local actionsDragHint = Instance.new("TextLabel")
actionsDragHint.Name = "DragHint"
actionsDragHint.Size = UDim2.fromOffset(24, HUD_HEADER_HEIGHT)
actionsDragHint.AnchorPoint = Vector2.new(1, 0)
actionsDragHint.Position = UDim2.new(1, -4, 0, 0)
actionsDragHint.BackgroundTransparency = 1
actionsDragHint.Font = Enum.Font.Gotham
actionsDragHint.TextSize = 12
actionsDragHint.TextColor3 = Color3.fromRGB(130, 130, 140)
actionsDragHint.Text = "⋮⋮"
actionsDragHint.Parent = actionsHeader

local actionsScroll = Instance.new("ScrollingFrame")
actionsScroll.Name = "ActionsScroll"
actionsScroll.Size = UDim2.new(1, 0, 1, -HUD_HEADER_HEIGHT)
actionsScroll.Position = UDim2.fromOffset(0, HUD_HEADER_HEIGHT)
actionsScroll.BackgroundTransparency = 1
actionsScroll.BorderSizePixel = 0
actionsScroll.ScrollBarThickness = 5
actionsScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
actionsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
actionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
actionsScroll.CanvasSize = UDim2.new()
actionsScroll.Parent = actionsFrame

local actionsContent = Instance.new("Frame")
actionsContent.Name = "ActionsContent"
actionsContent.Size = UDim2.new(1, 0, 0, 0)
actionsContent.AutomaticSize = Enum.AutomaticSize.Y
actionsContent.BackgroundTransparency = 1
actionsContent.BorderSizePixel = 0
actionsContent.Parent = actionsScroll

local actionsPadding = Instance.new("UIPadding")
actionsPadding.PaddingTop = UDim.new(0, HUD_INNER_PADDING)
actionsPadding.PaddingBottom = UDim.new(0, HUD_INNER_PADDING)
actionsPadding.PaddingLeft = UDim.new(0, HUD_INNER_PADDING)
actionsPadding.PaddingRight = UDim.new(0, HUD_INNER_PADDING)
actionsPadding.Parent = actionsContent

local actionsLayout = Instance.new("UIListLayout")
actionsLayout.Padding = UDim.new(0, HUD_COMPACT_PADDING)
actionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
actionsLayout.Parent = actionsContent

local actionsDivider = Instance.new("Frame")
actionsDivider.Name = "ActionsDivider"
actionsDivider.LayoutOrder = 0
actionsDivider.Size = UDim2.new(1, 0, 0, 1)
actionsDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
actionsDivider.BackgroundTransparency = 0.4
actionsDivider.BorderSizePixel = 0
actionsDivider.Parent = actionsContent

local WAREHOUSE_SHIFT_NAME = "Warehouse Shift"
local CLEANUP_SHIFT_NAME = "Cleanup Shift"
local WAREHOUSE_SHIFT_ID = "WarehouseShift"
local CLEANUP_SHIFT_ID = "CleanupShift"
local WAREHOUSE_OPEN_START = 8 * 60
local WAREHOUSE_OPEN_END = 18 * 60
local CLEANUP_OPEN_START = 8 * 60
local CLEANUP_OPEN_END = 20 * 60
local WAREHOUSE_BASE_PAY = 25
local CLEANUP_BASE_PAY = 15
local PAY_PER_LEVEL = 5
local WAREHOUSE_ENERGY_COST = 20
local WAREHOUSE_HUNGER_COST = 10
local CLEANUP_ENERGY_COST = 10
local CLEANUP_HUNGER_COST = 5

local jobBoardLabel = Instance.new("TextLabel")
jobBoardLabel.Name = "JobBoardLabel"
jobBoardLabel.LayoutOrder = 1
jobBoardLabel.Size = UDim2.new(1, 0, 0, 18)
jobBoardLabel.BackgroundTransparency = 1
jobBoardLabel.Font = Enum.Font.GothamMedium
jobBoardLabel.TextSize = 13
jobBoardLabel.TextColor3 = Color3.fromRGB(150, 175, 210)
jobBoardLabel.TextXAlignment = Enum.TextXAlignment.Left
jobBoardLabel.Text = "Available Jobs"
jobBoardLabel.Visible = false
jobBoardLabel.Parent = actionsContent

local warehouseHintLabel = Instance.new("TextLabel")
warehouseHintLabel.Name = "WarehouseHintLabel"
warehouseHintLabel.LayoutOrder = 3
warehouseHintLabel.Size = UDim2.new(1, 0, 0, 14)
warehouseHintLabel.BackgroundTransparency = 1
warehouseHintLabel.Font = Enum.Font.Gotham
warehouseHintLabel.TextSize = 12
warehouseHintLabel.TextColor3 = Color3.fromRGB(140, 170, 210)
warehouseHintLabel.TextXAlignment = Enum.TextXAlignment.Left
warehouseHintLabel.Text = "Warehouse: +25 / -20E / -10H"
warehouseHintLabel.Visible = false
warehouseHintLabel.Parent = actionsContent

local workShiftButton = Instance.new("TextButton")
workShiftButton.Name = "WorkShiftButton"
workShiftButton.LayoutOrder = 4
workShiftButton.Size = UDim2.new(1, 0, 0, 34)
workShiftButton.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
workShiftButton.BorderSizePixel = 0
workShiftButton.Font = Enum.Font.GothamBold
workShiftButton.TextSize = 15
workShiftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
workShiftButton.Text = "Start Warehouse Shift"
workShiftButton.Active = true
workShiftButton.AutoButtonColor = true
workShiftButton.Visible = false
workShiftButton.Parent = actionsContent

local cleanupHintLabel = Instance.new("TextLabel")
cleanupHintLabel.Name = "CleanupHintLabel"
cleanupHintLabel.LayoutOrder = 5
cleanupHintLabel.Size = UDim2.new(1, 0, 0, 14)
cleanupHintLabel.BackgroundTransparency = 1
cleanupHintLabel.Font = Enum.Font.Gotham
cleanupHintLabel.TextSize = 12
cleanupHintLabel.TextColor3 = Color3.fromRGB(140, 170, 210)
cleanupHintLabel.TextXAlignment = Enum.TextXAlignment.Left
cleanupHintLabel.Text = "Cleanup: +15 / -10E / -5H"
cleanupHintLabel.Visible = false
cleanupHintLabel.Parent = actionsContent

local cleanupShiftButton = Instance.new("TextButton")
cleanupShiftButton.Name = "CleanupShiftButton"
cleanupShiftButton.LayoutOrder = 6
cleanupShiftButton.Size = UDim2.new(1, 0, 0, 34)
cleanupShiftButton.BackgroundColor3 = Color3.fromRGB(55, 120, 110)
cleanupShiftButton.BorderSizePixel = 0
cleanupShiftButton.Font = Enum.Font.GothamBold
cleanupShiftButton.TextSize = 15
cleanupShiftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
cleanupShiftButton.Text = "Start Cleanup Shift"
cleanupShiftButton.Active = true
cleanupShiftButton.AutoButtonColor = true
cleanupShiftButton.Visible = false
cleanupShiftButton.Parent = actionsContent

local buyFoodButton = Instance.new("TextButton")
buyFoodButton.Name = "OpenFoodShopButton"
buyFoodButton.LayoutOrder = 7
buyFoodButton.Size = UDim2.new(1, 0, 0, 34)
buyFoodButton.BackgroundColor3 = Color3.fromRGB(210, 130, 45)
buyFoodButton.BorderSizePixel = 0
buyFoodButton.Font = Enum.Font.GothamBold
buyFoodButton.TextSize = 15
buyFoodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyFoodButton.Text = "Open Food Shop"
buyFoodButton.Active = true
buyFoodButton.AutoButtonColor = true
buyFoodButton.Visible = false
buyFoodButton.Parent = actionsContent

local restButton = Instance.new("TextButton")
restButton.Name = "RestButton"
restButton.LayoutOrder = 8
restButton.Size = UDim2.new(1, 0, 0, 34)
restButton.BackgroundColor3 = Color3.fromRGB(60, 130, 90)
restButton.BorderSizePixel = 0
restButton.Font = Enum.Font.GothamBold
restButton.TextSize = 15
restButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restButton.Text = "Rest"
restButton.Active = true
restButton.AutoButtonColor = true
restButton.Visible = false
restButton.Parent = actionsContent

local depositAllButton = Instance.new("TextButton")
depositAllButton.Name = "DepositAllButton"
depositAllButton.LayoutOrder = 9
depositAllButton.Size = UDim2.new(1, 0, 0, 34)
depositAllButton.BackgroundColor3 = Color3.fromRGB(55, 95, 140)
depositAllButton.BorderSizePixel = 0
depositAllButton.Font = Enum.Font.GothamBold
depositAllButton.TextSize = 15
depositAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
depositAllButton.Text = "Deposit All"
depositAllButton.Active = true
depositAllButton.AutoButtonColor = true
depositAllButton.Visible = false
depositAllButton.Parent = actionsContent

local withdraw25Button = Instance.new("TextButton")
withdraw25Button.Name = "Withdraw25Button"
withdraw25Button.LayoutOrder = 10
withdraw25Button.Size = UDim2.new(1, 0, 0, 34)
withdraw25Button.BackgroundColor3 = Color3.fromRGB(80, 120, 170)
withdraw25Button.BorderSizePixel = 0
withdraw25Button.Font = Enum.Font.GothamBold
withdraw25Button.TextSize = 15
withdraw25Button.TextColor3 = Color3.fromRGB(255, 255, 255)
withdraw25Button.Text = "Withdraw 25"
withdraw25Button.Active = true
withdraw25Button.AutoButtonColor = true
withdraw25Button.Visible = false
withdraw25Button.Parent = actionsContent

local function addCorner(parent: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function styleGlassPanel(panel: Frame)
	panel.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
	panel.BackgroundTransparency = 0.1
	addCorner(panel, 14)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 40, 52)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 32)),
	})
	gradient.Rotation = 90
	gradient.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.78
	stroke.Thickness = 1
	stroke.Parent = panel
end

local function styleCard(card: Frame, themeColor: Color3)
	card.BackgroundColor3 = Color3.fromRGB(
		math.clamp(math.floor(themeColor.R * 255 * 0.18 + 36), 0, 255),
		math.clamp(math.floor(themeColor.G * 255 * 0.18 + 36), 0, 255),
		math.clamp(math.floor(themeColor.B * 255 * 0.18 + 40), 0, 255)
	)
	card.BackgroundTransparency = 0.08
	addCorner(card, 10)
end

local function applyButtonHover(button: TextButton, baseColor: Color3, hoverColor: Color3)
	button.BackgroundColor3 = baseColor
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = hoverColor
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = baseColor
	end)
end

addCorner(frame, 8)
addCorner(statsHeader, 6)
addCorner(actionsFrame, 8)
addCorner(actionsHeader, 6)

local foodInventoryButton = Instance.new("TextButton")
foodInventoryButton.Name = "InventoryQuickButton"
foodInventoryButton.Size = UDim2.fromOffset(HUD_INVENTORY_WIDTH, HUD_INVENTORY_HEIGHT)
foodInventoryButton.AnchorPoint = Vector2.new(1, 1)
foodInventoryButton.Position = UDim2.new(1, -HUD_SAFE_MARGIN, 1, -HUD_SAFE_MARGIN)
foodInventoryButton.BackgroundColor3 = Color3.fromRGB(95, 75, 120)
foodInventoryButton.BorderSizePixel = 0
foodInventoryButton.Font = Enum.Font.GothamBold
foodInventoryButton.TextSize = 14
foodInventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
foodInventoryButton.Text = "Inventory"
foodInventoryButton.Active = true
foodInventoryButton.AutoButtonColor = true
foodInventoryButton.ZIndex = 2
foodInventoryButton.Parent = hudDockLayer
addCorner(foodInventoryButton, 8)

addCorner(workShiftButton, 8)
addCorner(cleanupShiftButton, 8)
addCorner(buyFoodButton, 8)
addCorner(restButton, 8)
addCorner(depositAllButton, 8)
addCorner(withdraw25Button, 8)

type HudDragSession = {
	usesCustom: boolean,
}

local hudPanelDragState: { stats: HudDragSession, actions: HudDragSession } = {
	stats = { usesCustom = false },
	actions = { usesCustom = false },
}

local activeHudDrag: {
	panel: GuiObject,
	startInput: Vector2,
	startPos: Vector2,
	key: string,
}? = nil

local function getHudViewport(): (number, number, number)
	local camera = workspace.CurrentCamera
	local viewport = if camera then camera.ViewportSize else Vector2.new(1280, 720)
	local topInset = GuiService:GetGuiInset().Y
	return viewport.X, viewport.Y, topInset
end

local function clampHudPosition(panel: GuiObject, position: Vector2): Vector2
	local viewportX, viewportY, topInset = getHudViewport()
	local size = panel.AbsoluteSize
	local minX = HUD_SAFE_MARGIN
	local minY = topInset + HUD_SAFE_MARGIN
	local maxX = math.max(minX, viewportX - size.X - HUD_SAFE_MARGIN)
	local maxY = math.max(minY, viewportY - size.Y - HUD_SAFE_MARGIN)
	return Vector2.new(math.clamp(position.X, minX, maxX), math.clamp(position.Y, minY, maxY))
end

local function setPanelOffset(panel: GuiObject, anchor: Vector2, x: number, y: number)
	panel.AnchorPoint = anchor
	panel.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
end

local function refreshHudLayout()
	local viewportX, viewportY, topInset = getHudViewport()
	local safeRight = viewportX - HUD_SAFE_MARGIN
	local safeBottom = viewportY - HUD_SAFE_MARGIN
	local minTop = topInset + HUD_SAFE_MARGIN

	local stackBottom = safeBottom

	local actionsContentHeight = actionsLayout.AbsoluteContentSize.Y + HUD_INNER_PADDING * 2
	local actionsScrollHeight = math.min(math.max(actionsContentHeight, 40), HUD_ACTIONS_MAX_HEIGHT)
	actionsScroll.Size = UDim2.new(1, 0, 0, actionsScrollHeight)
	local actionsPanelHeight = HUD_HEADER_HEIGHT + actionsScrollHeight
	actionsFrame.Size = UDim2.fromOffset(HUD_PANEL_WIDTH, actionsPanelHeight)

	if actionsFrame.Visible then
		if not hudPanelDragState.actions.usesCustom then
			setPanelOffset(actionsFrame, Vector2.new(1, 1), safeRight, stackBottom)
		else
			local clamped = clampHudPosition(actionsFrame, actionsFrame.AbsolutePosition)
			setPanelOffset(actionsFrame, Vector2.new(0, 0), clamped.X, clamped.Y)
		end
		stackBottom -= actionsPanelHeight + HUD_STACK_GAP
	else
		if hudPanelDragState.actions.usesCustom then
			hudPanelDragState.actions.usesCustom = false
		end
	end

	setPanelOffset(foodInventoryButton, Vector2.new(1, 1), safeRight, stackBottom)
	stackBottom -= HUD_INVENTORY_HEIGHT + HUD_STACK_GAP

	local statsContentHeight = layout.AbsoluteContentSize.Y + HUD_INNER_PADDING * 2
	local availableStatsHeight = math.max(stackBottom - minTop, 80)
	local statsScrollHeight = math.min(statsContentHeight, HUD_STATS_MAX_HEIGHT, availableStatsHeight)
	statsScroll.Size = UDim2.new(1, 0, 0, statsScrollHeight)
	local statsPanelHeight = HUD_HEADER_HEIGHT + statsScrollHeight
	frame.Size = UDim2.fromOffset(HUD_PANEL_WIDTH, statsPanelHeight)

	if not hudPanelDragState.stats.usesCustom then
		setPanelOffset(frame, Vector2.new(1, 1), safeRight, stackBottom)
	else
		local clamped = clampHudPosition(frame, frame.AbsolutePosition)
		setPanelOffset(frame, Vector2.new(0, 0), clamped.X, clamped.Y)
	end
end

local function enableHudPanelDrag(panel: GuiObject, handle: GuiButton, key: string)
	handle.InputBegan:Connect(function(input: InputObject)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		hudPanelDragState[key].usesCustom = true
		panel.AnchorPoint = Vector2.new(0, 0)
		activeHudDrag = {
			panel = panel,
			startInput = Vector2.new(input.Position.X, input.Position.Y),
			startPos = panel.AbsolutePosition,
			key = key,
		}
	end)
end

UserInputService.InputChanged:Connect(function(input: InputObject)
	if not activeHudDrag then
		return
	end

	if
		input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	local currentInput = Vector2.new(input.Position.X, input.Position.Y)
	local delta = currentInput - activeHudDrag.startInput
	local target = activeHudDrag.startPos + delta
	target = clampHudPosition(activeHudDrag.panel, target)
	setPanelOffset(activeHudDrag.panel, Vector2.new(0, 0), target.X, target.Y)
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
	if
		input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	activeHudDrag = nil
end)

enableHudPanelDrag(frame, statsHeader, "stats")
enableHudPanelDrag(actionsFrame, actionsHeader, "actions")

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshHudLayout)
actionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshHudLayout)
actionsFrame:GetPropertyChangedSignal("Visible"):Connect(refreshHudLayout)

local MODAL_MAX_WIDTH = 700
local MODAL_WIDTH_SCALE = 0.9
local MODAL_HEIGHT_SCALE = 0.82
local MODAL_SAFE_MARGIN = 24
local MODAL_MIN_WIDTH = 300
local MODAL_MIN_HEIGHT = 240
local MODAL_HEADER_HEIGHT = 48
local MODAL_CLOSE_SIZE = 36
local FOOD_GRID_GAP = 12
local FOOD_CARD_HEIGHT = 192
local FOOD_CARD_MIN_WIDTH = 148
local FOOD_GRID_THREE_COL_MIN = 500
local FOOD_CARD_BUTTON_HEIGHT = 44
local FOOD_CARD_INNER_PADDING = 8
local FOOD_CARD_TOP_HEIGHT = 112
local FOOD_CARD_THUMB_SIZE = 80
local FOOD_CARD_SECTION_GAP = 6
local FOOD_CARD_META_ROW = 12
local FOOD_CARD_NAME_ROW = 16
local FOOD_SHOP_CONFIRM_THRESHOLD = 15

type ModalController = {
	root: Frame,
	scrollContent: Frame,
	scrollFrame: ScrollingFrame,
	gridHost: Frame,
	gridLayout: UIGridLayout,
	setOpen: (boolean) -> (),
	isOpen: () -> boolean,
	refreshGridLayout: () -> (),
}

local modalSizeRefreshers: { () -> () } = {}

local function getSafeViewportSize(): Vector2
	local camera = workspace.CurrentCamera
	if not camera then
		return Vector2.new(1280, 720)
	end

	local viewport = camera.ViewportSize
	local topInset = GuiService:GetGuiInset().Y
	return Vector2.new(viewport.X, math.max(viewport.Y - topInset, MODAL_MIN_HEIGHT + MODAL_SAFE_MARGIN * 2))
end

local function refreshAllModalSizes()
	for _, refresh in modalSizeRefreshers do
		refresh()
	end
end

local function createCenteredModal(
	modalName: string,
	titleText: string,
	titleIcon: string,
	titleColor: Color3
): ModalController
	local root = Instance.new("Frame")
	root.Name = modalName
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Visible = false
	root.ZIndex = 20
	root.Parent = screenGui

	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
	overlay.BackgroundTransparency = 0.35
	overlay.BorderSizePixel = 0
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.ZIndex = 1
	overlay.Parent = root

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.new(MODAL_WIDTH_SCALE, 0, MODAL_HEIGHT_SCALE, 0)
	panel.BorderSizePixel = 0
	panel.ZIndex = 2
	panel.Parent = root
	styleGlassPanel(panel)

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(MODAL_MIN_WIDTH, MODAL_MIN_HEIGHT)
	sizeConstraint.Parent = panel

	local function refreshPanelSize()
		local safeViewport = getSafeViewportSize()
		local maxWidth = math.min(MODAL_MAX_WIDTH, math.floor(safeViewport.X * MODAL_WIDTH_SCALE))
		local maxHeight = math.min(
			math.floor(safeViewport.Y * MODAL_HEIGHT_SCALE),
			math.floor(safeViewport.Y - MODAL_SAFE_MARGIN * 2)
		)
		sizeConstraint.MaxSize = Vector2.new(maxWidth, math.max(maxHeight, MODAL_MIN_HEIGHT))
	end

	table.insert(modalSizeRefreshers, refreshPanelSize)
	refreshPanelSize()

	local panelPadding = Instance.new("UIPadding")
	panelPadding.PaddingTop = UDim.new(0, 14)
	panelPadding.PaddingBottom = UDim.new(0, 14)
	panelPadding.PaddingLeft = UDim.new(0, 16)
	panelPadding.PaddingRight = UDim.new(0, 16)
	panelPadding.Parent = panel

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, MODAL_HEADER_HEIGHT)
	header.BackgroundTransparency = 1
	header.BorderSizePixel = 0
	header.ZIndex = 3
	header.Parent = panel

	local titleIconLabel = Instance.new("TextLabel")
	titleIconLabel.Name = "TitleIcon"
	titleIconLabel.Size = UDim2.fromOffset(28, MODAL_HEADER_HEIGHT)
	titleIconLabel.BackgroundTransparency = 1
	titleIconLabel.Font = Enum.Font.GothamBold
	titleIconLabel.TextSize = 20
	titleIconLabel.TextColor3 = titleColor
	titleIconLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleIconLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleIconLabel.Text = titleIcon
	titleIconLabel.ZIndex = 3
	titleIconLabel.Parent = header

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -(28 + MODAL_CLOSE_SIZE + 12), 1, 0)
	titleLabel.Position = UDim2.fromOffset(32, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 21
	titleLabel.TextColor3 = titleColor
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Text = titleText
	titleLabel.ZIndex = 3
	titleLabel.Parent = header

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.fromOffset(MODAL_CLOSE_SIZE, MODAL_CLOSE_SIZE)
	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.Position = UDim2.new(1, 0, 0.5, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(52, 54, 64)
	closeButton.BackgroundTransparency = 0.15
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 18
	closeButton.TextColor3 = Color3.fromRGB(230, 230, 240)
	closeButton.Text = "×"
	closeButton.ZIndex = 3
	closeButton.Parent = header
	addCorner(closeButton, 8)
	local closeStroke = Instance.new("UIStroke")
	closeStroke.Color = Color3.fromRGB(255, 255, 255)
	closeStroke.Transparency = 0.82
	closeStroke.Thickness = 1
	closeStroke.Parent = closeButton
	applyButtonHover(closeButton, Color3.fromRGB(52, 54, 64), Color3.fromRGB(72, 74, 88))

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, 0, 1, -(MODAL_HEADER_HEIGHT + 4))
	scrollFrame.Position = UDim2.fromOffset(0, MODAL_HEADER_HEIGHT + 4)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
	scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.CanvasSize = UDim2.new()
	scrollFrame.ZIndex = 3
	scrollFrame.Parent = panel

	local scrollContent = Instance.new("Frame")
	scrollContent.Name = "ScrollContent"
	scrollContent.Size = UDim2.new(1, 0, 0, 0)
	scrollContent.AutomaticSize = Enum.AutomaticSize.Y
	scrollContent.BackgroundTransparency = 1
	scrollContent.BorderSizePixel = 0
	scrollContent.Parent = scrollFrame

	local scrollPadding = Instance.new("UIPadding")
	scrollPadding.PaddingBottom = UDim.new(0, 4)
	scrollPadding.Parent = scrollContent

	local scrollStack = Instance.new("UIListLayout")
	scrollStack.Padding = UDim.new(0, 8)
	scrollStack.SortOrder = Enum.SortOrder.LayoutOrder
	scrollStack.Parent = scrollContent

	local gridHost = Instance.new("Frame")
	gridHost.Name = "CardGridHost"
	gridHost.LayoutOrder = 1
	gridHost.Size = UDim2.new(1, 0, 0, 0)
	gridHost.AutomaticSize = Enum.AutomaticSize.Y
	gridHost.BackgroundTransparency = 1
	gridHost.BorderSizePixel = 0
	gridHost.Parent = scrollContent

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellPadding = UDim2.fromOffset(FOOD_GRID_GAP, FOOD_GRID_GAP)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	gridLayout.Parent = gridHost

	local function refreshGridLayout()
		local contentWidth = scrollFrame.AbsoluteSize.X
		if contentWidth <= 0 then
			contentWidth = math.max(panel.AbsoluteSize.X - FOOD_CARD_INNER_PADDING * 2, FOOD_CARD_MIN_WIDTH)
		end

		local columns = if contentWidth >= FOOD_GRID_THREE_COL_MIN then 3 else 2
		while columns > 1 do
			local totalGap = FOOD_GRID_GAP * (columns - 1)
			if columns * FOOD_CARD_MIN_WIDTH + totalGap <= contentWidth then
				break
			end
			columns -= 1
		end
		local totalGap = FOOD_GRID_GAP * (columns - 1)
		local cardWidth = math.floor((contentWidth - totalGap) / columns)
		cardWidth = math.max(cardWidth, FOOD_CARD_MIN_WIDTH)
		gridLayout.CellSize = UDim2.fromOffset(cardWidth, FOOD_CARD_HEIGHT)
	end

	table.insert(modalSizeRefreshers, refreshGridLayout)
	panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshGridLayout)
	scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshGridLayout)
	gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		gridHost.Size = UDim2.new(1, 0, 0, gridLayout.AbsoluteContentSize.Y)
	end)

	local isOpen = false

	local function setOpen(open: boolean)
		isOpen = open
		root.Visible = open
		if open then
			refreshPanelSize()
			task.defer(refreshGridLayout)
		else
			scrollFrame.CanvasPosition = Vector2.zero
		end
	end

	overlay.MouseButton1Click:Connect(function()
		setOpen(false)
	end)
	closeButton.MouseButton1Click:Connect(function()
		setOpen(false)
	end)

	return {
		root = root,
		scrollContent = scrollContent,
		scrollFrame = scrollFrame,
		gridHost = gridHost,
		gridLayout = gridLayout,
		setOpen = setOpen,
		isOpen = function()
			return isOpen
		end,
		refreshGridLayout = refreshGridLayout,
	}
end

local function bindFoodThumbnail(imageLabel: ImageLabel, emojiLabel: TextLabel, assetId: string, emoji: string)
	emojiLabel.Text = emoji
	imageLabel.Image = assetId
	imageLabel.Visible = true
	emojiLabel.Visible = false

	task.defer(function()
		local ok = pcall(function()
			ContentProvider:PreloadAsync({ assetId })
		end)
		if not ok then
			imageLabel.Visible = false
			emojiLabel.Visible = true
		end
	end)
end

local FOOD_SHOP_DISPLAY_ITEMS = {
	{
		Id = "Water",
		DisplayName = "Water",
		Price = 3,
		EnergyRestore = 5,
		HungerRestore = 0,
		FullnessMinutes = 10,
		ImageAssetId = "rbxassetid://103271145720137",
		ThemeColor = Color3.fromRGB(100, 180, 255),
		EmojiFallback = "💧",
	},
	{
		Id = "Apple",
		DisplayName = "Apple",
		Price = 5,
		EnergyRestore = 5,
		HungerRestore = 10,
		FullnessMinutes = 30,
		ImageAssetId = "rbxassetid://79360984269983",
		ThemeColor = Color3.fromRGB(220, 80, 80),
		EmojiFallback = "🍎",
	},
	{
		Id = "Bread",
		DisplayName = "Bread",
		Price = 8,
		EnergyRestore = 10,
		HungerRestore = 18,
		FullnessMinutes = 45,
		ImageAssetId = "rbxassetid://84892713452962",
		ThemeColor = Color3.fromRGB(210, 170, 100),
		EmojiFallback = "🍞",
	},
	{
		Id = "Sandwich",
		DisplayName = "Sandwich",
		Price = 15,
		EnergyRestore = 25,
		HungerRestore = 35,
		FullnessMinutes = 90,
		ImageAssetId = "rbxassetid://91888167350450",
		ThemeColor = Color3.fromRGB(180, 140, 90),
		EmojiFallback = "🥪",
	},
	{
		Id = "HotMeal",
		DisplayName = "Hot Meal",
		Price = 25,
		EnergyRestore = 40,
		HungerRestore = 60,
		FullnessMinutes = 180,
		ImageAssetId = "rbxassetid://97078004998911",
		ThemeColor = Color3.fromRGB(255, 140, 60),
		EmojiFallback = "🍲",
	},
	{
		Id = "FamilyMeal",
		DisplayName = "Family Meal",
		Price = 45,
		EnergyRestore = 60,
		HungerRestore = 100,
		FullnessMinutes = 300,
		ImageAssetId = "rbxassetid://99673651923906",
		ThemeColor = Color3.fromRGB(200, 100, 120),
		EmojiFallback = "🍖",
	},
}

local foodShopOwnedLabels: { [string]: TextLabel } = {}
local foodInventoryCards: { [string]: { card: Frame, countLabel: TextLabel, eatButton: TextButton } } = {}

local function addCardStroke(card: Frame)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.84
	stroke.Thickness = 1
	stroke.Parent = card
end

local function setActionButtonEnabled(button: TextButton, enabled: boolean, baseColor: Color3, hoverColor: Color3)
	button.Active = enabled
	button.AutoButtonColor = enabled
	if enabled then
		button.BackgroundColor3 = baseColor
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.BackgroundTransparency = 0
	else
		button.BackgroundColor3 = Color3.fromRGB(58, 60, 68)
		button.TextColor3 = Color3.fromRGB(150, 150, 158)
		button.BackgroundTransparency = 0.2
	end
end

local function createCardMetaLabel(
	parent: Frame,
	layoutOrder: number,
	text: string,
	textSize: number,
	color: Color3,
	height: number?
): TextLabel
	local label = Instance.new("TextLabel")
	label.LayoutOrder = layoutOrder
	label.Size = UDim2.new(1, 0, 0, height or FOOD_CARD_META_ROW)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = textSize
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = text
	label.Parent = parent
	return label
end

local function createFoodThumbSquare(parent: Frame, item: typeof(FOOD_SHOP_DISPLAY_ITEMS[1])): Frame
	local thumbFrame = Instance.new("Frame")
	thumbFrame.Name = "ThumbnailFrame"
	thumbFrame.Size = UDim2.fromOffset(FOOD_CARD_THUMB_SIZE, FOOD_CARD_THUMB_SIZE)
	thumbFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
	thumbFrame.BackgroundTransparency = 0.08
	thumbFrame.BorderSizePixel = 0
	thumbFrame.Parent = parent
	addCorner(thumbFrame, 8)

	local thumbInnerStroke = Instance.new("UIStroke")
	thumbInnerStroke.Color = Color3.fromRGB(255, 255, 255)
	thumbInnerStroke.Transparency = 0.9
	thumbInnerStroke.Thickness = 1
	thumbInnerStroke.Parent = thumbFrame

	local thumbImage = Instance.new("ImageLabel")
	thumbImage.Name = "ThumbImage"
	thumbImage.Size = UDim2.new(1, -8, 1, -8)
	thumbImage.Position = UDim2.fromOffset(4, 4)
	thumbImage.BackgroundTransparency = 1
	thumbImage.ScaleType = Enum.ScaleType.Fit
	thumbImage.Parent = thumbFrame

	local thumbEmoji = Instance.new("TextLabel")
	thumbEmoji.Name = "ThumbEmoji"
	thumbEmoji.Size = UDim2.fromScale(1, 1)
	thumbEmoji.BackgroundTransparency = 1
	thumbEmoji.Font = Enum.Font.GothamBold
	thumbEmoji.TextSize = 32
	thumbEmoji.TextXAlignment = Enum.TextXAlignment.Center
	thumbEmoji.TextYAlignment = Enum.TextYAlignment.Center
	thumbEmoji.Visible = false
	thumbEmoji.Parent = thumbFrame
	bindFoodThumbnail(thumbImage, thumbEmoji, item.ImageAssetId, item.EmojiFallback)

	return thumbFrame
end

type CompactFoodCardResult = {
	ownedLabel: TextLabel?,
	countLabel: TextLabel?,
	actionButton: TextButton,
}

local function buildCompactFoodCard(
	card: Frame,
	item: typeof(FOOD_SHOP_DISPLAY_ITEMS[1]),
	mode: "shop" | "inventory",
	actionText: string,
	actionBaseColor: Color3,
	actionHoverColor: Color3,
	onActionClick: (TextButton) -> ()
): CompactFoodCardResult
	local cardPadding = Instance.new("UIPadding")
	cardPadding.PaddingTop = UDim.new(0, FOOD_CARD_INNER_PADDING)
	cardPadding.PaddingBottom = UDim.new(0, FOOD_CARD_INNER_PADDING)
	cardPadding.PaddingLeft = UDim.new(0, FOOD_CARD_INNER_PADDING)
	cardPadding.PaddingRight = UDim.new(0, FOOD_CARD_INNER_PADDING)
	cardPadding.Parent = card

	local cardLayout = Instance.new("UIListLayout")
	cardLayout.Padding = UDim.new(0, FOOD_CARD_SECTION_GAP)
	cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
	cardLayout.Parent = card

	local topContent = Instance.new("Frame")
	topContent.Name = "TopContentFrame"
	topContent.LayoutOrder = 1
	topContent.Size = UDim2.new(1, 0, 0, FOOD_CARD_TOP_HEIGHT)
	topContent.BackgroundTransparency = 1
	topContent.BorderSizePixel = 0
	topContent.Parent = card

	local thumbFrame = createFoodThumbSquare(topContent, item)
	thumbFrame.AnchorPoint = Vector2.new(0, 0.5)
	thumbFrame.Position = UDim2.new(0, 0, 0.5, 0)

	local detailsFrame = Instance.new("Frame")
	detailsFrame.Name = "DetailsFrame"
	detailsFrame.Size = UDim2.new(1, -(FOOD_CARD_THUMB_SIZE + 8), 1, 0)
	detailsFrame.Position = UDim2.fromOffset(FOOD_CARD_THUMB_SIZE + 8, 0)
	detailsFrame.BackgroundTransparency = 1
	detailsFrame.BorderSizePixel = 0
	detailsFrame.Parent = topContent

	local detailsLayout = Instance.new("UIListLayout")
	detailsLayout.Padding = UDim.new(0, 1)
	detailsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	detailsLayout.Parent = detailsFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.LayoutOrder = 1
	nameLabel.Size = UDim2.new(1, 0, 0, FOOD_CARD_NAME_ROW)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 13
	nameLabel.TextColor3 = Color3.fromRGB(255, 245, 225)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Text = item.DisplayName
	nameLabel.Parent = detailsFrame

	local ownedLabel: TextLabel? = nil
	local countLabel: TextLabel? = nil

	if mode == "shop" then
		ownedLabel = createCardMetaLabel(
			detailsFrame,
			2,
			"Owned: 0",
			11,
			Color3.fromRGB(165, 200, 255),
			FOOD_CARD_META_ROW
		)
		ownedLabel.Name = "OwnedLabel"
	else
		countLabel = createCardMetaLabel(detailsFrame, 2, "x0", 11, Color3.fromRGB(165, 200, 255), FOOD_CARD_META_ROW)
		countLabel.Name = "CountLabel"
		countLabel.Font = Enum.Font.GothamMedium
	end

	createCardMetaLabel(
		detailsFrame,
		3,
		("+%d Energy"):format(item.EnergyRestore),
		11,
		Color3.fromRGB(120, 220, 140),
		FOOD_CARD_META_ROW
	)
	createCardMetaLabel(
		detailsFrame,
		4,
		("+%d Hunger"):format(item.HungerRestore),
		11,
		Color3.fromRGB(255, 170, 100),
		FOOD_CARD_META_ROW
	)
	createCardMetaLabel(
		detailsFrame,
		5,
		("%d min fullness"):format(item.FullnessMinutes),
		11,
		Color3.fromRGB(220, 210, 150),
		FOOD_CARD_META_ROW
	)

	local actionButton = Instance.new("TextButton")
	actionButton.Name = if mode == "shop" then "BuyButton" else "EatButton"
	actionButton.LayoutOrder = 2
	actionButton.Size = UDim2.new(1, 0, 0, FOOD_CARD_BUTTON_HEIGHT)
	actionButton.BorderSizePixel = 0
	actionButton.Font = Enum.Font.GothamBold
	actionButton.TextSize = 14
	actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionButton.Text = actionText
	actionButton.Parent = card
	addCorner(actionButton, 8)
	applyButtonHover(actionButton, actionBaseColor, actionHoverColor)

	if mode == "inventory" then
		setActionButtonEnabled(actionButton, false, actionBaseColor, actionHoverColor)
	end

	actionButton.MouseButton1Click:Connect(function()
		onActionClick(actionButton)
	end)

	return {
		ownedLabel = ownedLabel,
		countLabel = countLabel,
		actionButton = actionButton,
	}
end

local foodShopModal = createCenteredModal("FoodShopModal", "Food Shop", "🛒", Color3.fromRGB(255, 215, 140))
local foodShopGridHost = foodShopModal.gridHost

local foodShopPanel = foodShopModal.root:FindFirstChild("Panel") :: Frame
local foodShopHeader = if foodShopPanel then foodShopPanel:FindFirstChild("Header") :: Frame? else nil
local foodShopTitleLabel = if foodShopHeader then foodShopHeader:FindFirstChild("TitleLabel") :: TextLabel? else nil

local foodShopWalletLabel = Instance.new("TextLabel")
foodShopWalletLabel.Name = "WalletLabel"
foodShopWalletLabel.Size = UDim2.fromOffset(96, MODAL_HEADER_HEIGHT)
foodShopWalletLabel.AnchorPoint = Vector2.new(1, 0.5)
foodShopWalletLabel.Position = UDim2.new(1, -(MODAL_CLOSE_SIZE + 10), 0.5, 0)
foodShopWalletLabel.BackgroundTransparency = 1
foodShopWalletLabel.Font = Enum.Font.GothamBold
foodShopWalletLabel.TextSize = 14
foodShopWalletLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
foodShopWalletLabel.TextXAlignment = Enum.TextXAlignment.Right
foodShopWalletLabel.TextYAlignment = Enum.TextYAlignment.Center
foodShopWalletLabel.Text = "Wallet: 0"
foodShopWalletLabel.ZIndex = 3
if foodShopHeader then
	foodShopWalletLabel.Parent = foodShopHeader
end
if foodShopTitleLabel then
	foodShopTitleLabel.Size = UDim2.new(1, -(28 + MODAL_CLOSE_SIZE + 108), 1, 0)
end

local foodShopPurchaseToast = Instance.new("TextLabel")
foodShopPurchaseToast.Name = "PurchaseToast"
foodShopPurchaseToast.LayoutOrder = 0
foodShopPurchaseToast.Size = UDim2.new(1, 0, 0, 28)
foodShopPurchaseToast.BackgroundTransparency = 1
foodShopPurchaseToast.Font = Enum.Font.GothamMedium
foodShopPurchaseToast.TextSize = 14
foodShopPurchaseToast.TextColor3 = Color3.fromRGB(180, 235, 170)
foodShopPurchaseToast.TextXAlignment = Enum.TextXAlignment.Center
foodShopPurchaseToast.Text = ""
foodShopPurchaseToast.Visible = false
foodShopPurchaseToast.Parent = foodShopModal.scrollContent

local foodShopConfirmRoot = Instance.new("Frame")
foodShopConfirmRoot.Name = "PurchaseConfirm"
foodShopConfirmRoot.Size = UDim2.fromScale(1, 1)
foodShopConfirmRoot.BackgroundTransparency = 1
foodShopConfirmRoot.Visible = false
foodShopConfirmRoot.ZIndex = 5
foodShopConfirmRoot.Parent = foodShopModal.root

local foodShopConfirmOverlay = Instance.new("TextButton")
foodShopConfirmOverlay.Name = "Overlay"
foodShopConfirmOverlay.Size = UDim2.fromScale(1, 1)
foodShopConfirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
foodShopConfirmOverlay.BackgroundTransparency = 0.5
foodShopConfirmOverlay.BorderSizePixel = 0
foodShopConfirmOverlay.Text = ""
foodShopConfirmOverlay.AutoButtonColor = false
foodShopConfirmOverlay.ZIndex = 1
foodShopConfirmOverlay.Parent = foodShopConfirmRoot

local foodShopConfirmPanel = Instance.new("Frame")
foodShopConfirmPanel.Name = "Panel"
foodShopConfirmPanel.AnchorPoint = Vector2.new(0.5, 0.5)
foodShopConfirmPanel.Position = UDim2.fromScale(0.5, 0.5)
foodShopConfirmPanel.Size = UDim2.fromOffset(280, 132)
foodShopConfirmPanel.BorderSizePixel = 0
foodShopConfirmPanel.ZIndex = 2
foodShopConfirmPanel.Parent = foodShopConfirmRoot
styleGlassPanel(foodShopConfirmPanel)

local foodShopConfirmMessage = Instance.new("TextLabel")
foodShopConfirmMessage.Name = "MessageLabel"
foodShopConfirmMessage.Size = UDim2.new(1, -24, 0, 48)
foodShopConfirmMessage.Position = UDim2.fromOffset(12, 14)
foodShopConfirmMessage.BackgroundTransparency = 1
foodShopConfirmMessage.Font = Enum.Font.GothamMedium
foodShopConfirmMessage.TextSize = 16
foodShopConfirmMessage.TextColor3 = Color3.fromRGB(240, 240, 245)
foodShopConfirmMessage.TextXAlignment = Enum.TextXAlignment.Center
foodShopConfirmMessage.TextWrapped = true
foodShopConfirmMessage.Text = "Buy item?"
foodShopConfirmMessage.ZIndex = 3
foodShopConfirmMessage.Parent = foodShopConfirmPanel

local foodShopConfirmButton = Instance.new("TextButton")
foodShopConfirmButton.Name = "ConfirmButton"
foodShopConfirmButton.Size = UDim2.new(0.48, 0, 0, 36)
foodShopConfirmButton.Position = UDim2.new(0.02, 0, 1, -44)
foodShopConfirmButton.BorderSizePixel = 0
foodShopConfirmButton.Font = Enum.Font.GothamBold
foodShopConfirmButton.TextSize = 14
foodShopConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
foodShopConfirmButton.Text = "Confirm"
foodShopConfirmButton.ZIndex = 3
foodShopConfirmButton.Parent = foodShopConfirmPanel
addCorner(foodShopConfirmButton, 8)
applyButtonHover(foodShopConfirmButton, Color3.fromRGB(210, 135, 45), Color3.fromRGB(235, 165, 70))

local foodShopCancelButton = Instance.new("TextButton")
foodShopCancelButton.Name = "CancelButton"
foodShopCancelButton.Size = UDim2.new(0.48, 0, 0, 36)
foodShopCancelButton.AnchorPoint = Vector2.new(1, 0)
foodShopCancelButton.Position = UDim2.new(0.98, 0, 1, -44)
foodShopCancelButton.BorderSizePixel = 0
foodShopCancelButton.Font = Enum.Font.GothamBold
foodShopCancelButton.TextSize = 14
foodShopCancelButton.TextColor3 = Color3.fromRGB(230, 230, 240)
foodShopCancelButton.Text = "Cancel"
foodShopCancelButton.ZIndex = 3
foodShopCancelButton.Parent = foodShopConfirmPanel
addCorner(foodShopCancelButton, 8)
applyButtonHover(foodShopCancelButton, Color3.fromRGB(58, 60, 68), Color3.fromRGB(78, 80, 90))

local currentWalletAmount = 0
local pendingFoodPurchase: { name: string, price: number }? = nil
local pendingFoodPurchaseConfirm: (() -> ())? = nil
local purchaseToastToken = 0

local function updateFoodShopWalletLabel(amount: number)
	currentWalletAmount = amount
	foodShopWalletLabel.Text = ("Wallet: %d"):format(amount)
end

local function hideFoodShopConfirm()
	foodShopConfirmRoot.Visible = false
	pendingFoodPurchaseConfirm = nil
end

local function showFoodShopPurchaseToast(text: string)
	purchaseToastToken += 1
	local token = purchaseToastToken
	foodShopPurchaseToast.Text = text
	foodShopPurchaseToast.Visible = true
	task.delay(3, function()
		if purchaseToastToken == token then
			foodShopPurchaseToast.Visible = false
		end
	end)
end

local function executeFoodShopPurchase(item: typeof(FOOD_SHOP_DISPLAY_ITEMS[1]))
	pendingFoodPurchase = {
		name = item.DisplayName,
		price = item.Price,
	}
	performActionRemote:FireServer("BuyFoodItem", item.Id)
end

local function requestFoodShopPurchase(item: typeof(FOOD_SHOP_DISPLAY_ITEMS[1]))
	if item.Price >= FOOD_SHOP_CONFIRM_THRESHOLD then
		foodShopConfirmMessage.Text = ("Buy %s for %d?"):format(item.DisplayName, item.Price)
		pendingFoodPurchaseConfirm = function()
			hideFoodShopConfirm()
			executeFoodShopPurchase(item)
		end
		foodShopConfirmRoot.Visible = true
		return
	end

	executeFoodShopPurchase(item)
end

foodShopConfirmOverlay.MouseButton1Click:Connect(hideFoodShopConfirm)
foodShopCancelButton.MouseButton1Click:Connect(hideFoodShopConfirm)
foodShopConfirmButton.MouseButton1Click:Connect(function()
	if pendingFoodPurchaseConfirm then
		pendingFoodPurchaseConfirm()
	end
end)

for index, item in FOOD_SHOP_DISPLAY_ITEMS do
	local card = Instance.new("Frame")
	card.Name = item.Id .. "ShopCard"
	card.LayoutOrder = index
	card.BorderSizePixel = 0
	card.ClipsDescendants = false
	card.Parent = foodShopGridHost
	styleCard(card, item.ThemeColor)
	addCardStroke(card)

	local cardResult = buildCompactFoodCard(
		card,
		item,
		"shop",
		("Buy (%d)"):format(item.Price),
		Color3.fromRGB(210, 135, 45),
		Color3.fromRGB(235, 165, 70),
		function(_actionButton: TextButton)
			requestFoodShopPurchase(item)
		end
	)

	if cardResult.ownedLabel then
		foodShopOwnedLabels[item.Id] = cardResult.ownedLabel
	end
end

local foodInventoryModal = createCenteredModal(
	"FoodInventoryModal",
	"Food Inventory",
	"🎒",
	Color3.fromRGB(210, 190, 255)
)
local foodInventoryGridHost = foodInventoryModal.gridHost

local foodInventoryEmptyLabel = Instance.new("TextLabel")
foodInventoryEmptyLabel.Name = "EmptyLabel"
foodInventoryEmptyLabel.LayoutOrder = 0
foodInventoryEmptyLabel.Size = UDim2.new(1, 0, 0, 56)
foodInventoryEmptyLabel.BackgroundTransparency = 1
foodInventoryEmptyLabel.Font = Enum.Font.GothamMedium
foodInventoryEmptyLabel.TextSize = 15
foodInventoryEmptyLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
foodInventoryEmptyLabel.TextXAlignment = Enum.TextXAlignment.Center
foodInventoryEmptyLabel.TextYAlignment = Enum.TextYAlignment.Center
foodInventoryEmptyLabel.TextWrapped = true
foodInventoryEmptyLabel.Text = "No food in inventory yet."
foodInventoryEmptyLabel.Visible = true
foodInventoryEmptyLabel.Parent = foodInventoryModal.scrollContent

for index, item in FOOD_SHOP_DISPLAY_ITEMS do
	local card = Instance.new("Frame")
	card.Name = item.Id .. "InventoryCard"
	card.LayoutOrder = index
	card.BorderSizePixel = 0
	card.ClipsDescendants = false
	card.Visible = false
	card.Parent = foodInventoryGridHost
	styleCard(card, item.ThemeColor)
	addCardStroke(card)

	local eatBaseColor = Color3.fromRGB(62, 145, 98)
	local eatHoverColor = Color3.fromRGB(82, 170, 118)
	local cardResult = buildCompactFoodCard(
		card,
		item,
		"inventory",
		"Eat",
		eatBaseColor,
		eatHoverColor,
		function(actionButton: TextButton)
			if actionButton.Active then
				performActionRemote:FireServer("EatFoodItem", item.Id)
			end
		end
	)

	if cardResult.countLabel then
		foodInventoryCards[item.Id] = {
			card = card,
			countLabel = cardResult.countLabel,
			eatButton = cardResult.actionButton,
		}
	end
end

local function refreshFoodInventoryUi(inventoryFolder: Folder)
	local anyOwned = false

	for _, item in FOOD_SHOP_DISPLAY_ITEMS do
		local countValue = inventoryFolder:FindFirstChild(item.Id) :: IntValue?
		local count = if countValue then countValue.Value else 0

		local ownedLabel = foodShopOwnedLabels[item.Id]
		if ownedLabel then
			ownedLabel.Text = ("Owned: %d"):format(count)
			ownedLabel.TextColor3 = if count > 0
				then Color3.fromRGB(160, 200, 255)
				else Color3.fromRGB(120, 120, 130)
		end

		local invCard = foodInventoryCards[item.Id]
		if invCard then
			invCard.card.Visible = count > 0
			invCard.countLabel.Text = ("x%d"):format(count)
			setActionButtonEnabled(
				invCard.eatButton,
				count > 0,
				Color3.fromRGB(62, 145, 98),
				Color3.fromRGB(82, 170, 118)
			)
			if count > 0 then
				anyOwned = true
			end
		end
	end

	foodInventoryEmptyLabel.Visible = not anyOwned
	foodInventoryGridHost.Visible = anyOwned
end

local function setFoodShopOpen(open: boolean)
	if open then
		foodInventoryModal.setOpen(false)
	else
		hideFoodShopConfirm()
		foodShopPurchaseToast.Visible = false
	end
	foodShopModal.setOpen(open)
	if open then
		updateFoodShopWalletLabel(currentWalletAmount)
		foodShopModal.refreshGridLayout()
	end
end

local function setFoodInventoryOpen(open: boolean)
	if open then
		foodShopModal.setOpen(false)
	end
	foodInventoryModal.setOpen(open)
	if open then
		foodInventoryModal.refreshGridLayout()
	end
end

local function bindModalViewportRefresh()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshAllModalSizes)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindModalViewportRefresh()
	refreshAllModalSizes()
end)
bindModalViewportRefresh()

foodInventoryButton.MouseButton1Click:Connect(function()
	setFoodInventoryOpen(not foodInventoryModal.isOpen())
end)

local HUNGRY_THRESHOLD = 30
local STARVING_THRESHOLD = 10

local function getNeedsStatusText(hunger: number): string
	if hunger <= STARVING_THRESHOLD then
		return "Needs: Starving — eat now"
	end

	if hunger <= HUNGRY_THRESHOLD then
		return "Needs: Hungry — eat soon"
	end

	return "Needs: OK"
end

local function updateNeedsStatusLabel(hunger: IntValue)
	needsStatusLabel.Text = getNeedsStatusText(hunger.Value)

	if hunger.Value <= STARVING_THRESHOLD then
		needsStatusLabel.TextColor3 = Color3.fromRGB(255, 120, 100)
	elseif hunger.Value <= HUNGRY_THRESHOLD then
		needsStatusLabel.TextColor3 = Color3.fromRGB(255, 190, 110)
	else
		needsStatusLabel.TextColor3 = Color3.fromRGB(200, 210, 200)
	end
end

local JOB_XP_PER_LEVEL = 50

local function getObjectiveText(money: number, energy: number, hunger: number, jobLevel: number): string
	if hunger <= STARVING_THRESHOLD then
		return "Objective: Eat food now"
	end

	if hunger <= HUNGRY_THRESHOLD then
		return "Objective: Buy or eat food soon"
	end

	if jobLevel < 2 and money < 25 then
		return "Objective: Work shifts to reach Job Level 2"
	end

	if money < 25 then
		return "Objective: Choose a job at Industrial"
	elseif energy < 100 and money >= 3 then
		return "Objective: Buy food at Market"
	elseif energy < 100 and money < 15 then
		return "Objective: Rest at Home or work more"
	else
		return "Objective: Explore Jones In The Lane"
	end
end

local function updateJobXpLabel(jobXp: IntValue)
	jobXpLabel.Text = ("Job XP: %d / %d"):format(jobXp.Value, JOB_XP_PER_LEVEL)
end

local function updateObjectivePanel(money: IntValue, energy: IntValue, hunger: IntValue, jobLevel: IntValue)
	objectiveLabel.Text = getObjectiveText(money.Value, energy.Value, hunger.Value, jobLevel.Value)
end

local function bindStat(label: TextLabel, stat: IntValue, prefix: string)
	label.Text = ("%s: %d"):format(prefix, stat.Value)
	stat.Changed:Connect(function()
		label.Text = ("%s: %d"):format(prefix, stat.Value)
	end)
end

local function bindStringStat(label: TextLabel, stat: StringValue, prefix: string)
	label.Text = ("%s: %s"):format(prefix, stat.Value)
	stat.Changed:Connect(function()
		label.Text = ("%s: %s"):format(prefix, stat.Value)
	end)
end

local MINUTES_PER_DAY = 24 * 60
local FULLNESS_UNTIL_GAME_MINUTES_ATTR = "JonesFullnessUntilGameMinutes"
local FULLNESS_UNTIL_DAY_ATTR = "JonesFullnessUntilDay"

local function isFullnessActive(currentDay: number, currentGameMinutes: number): boolean
	local untilDay = player:GetAttribute(FULLNESS_UNTIL_DAY_ATTR)
	local untilGameMinutes = player:GetAttribute(FULLNESS_UNTIL_GAME_MINUTES_ATTR)

	if typeof(untilDay) ~= "number" or typeof(untilGameMinutes) ~= "number" then
		return false
	end

	if untilDay <= 0 then
		return false
	end

	if currentDay < untilDay then
		return true
	end

	return currentDay == untilDay and currentGameMinutes < untilGameMinutes
end

local function getFullnessRemainingMinutes(currentDay: number, currentGameMinutes: number): number
	if not isFullnessActive(currentDay, currentGameMinutes) then
		return 0
	end

	local untilDay = player:GetAttribute(FULLNESS_UNTIL_DAY_ATTR) :: number
	local untilGameMinutes = player:GetAttribute(FULLNESS_UNTIL_GAME_MINUTES_ATTR) :: number
	local untilAbsolute = (untilDay - 1) * MINUTES_PER_DAY + untilGameMinutes
	local nowAbsolute = (currentDay - 1) * MINUTES_PER_DAY + currentGameMinutes

	return math.max(0, untilAbsolute - nowAbsolute)
end

local function updateFullnessLabel(currentDay: number, currentGameMinutes: number)
	if not isFullnessActive(currentDay, currentGameMinutes) then
		fullnessLabel.Text = "Fullness: None"
		return
	end

	local remaining = getFullnessRemainingMinutes(currentDay, currentGameMinutes)
	fullnessLabel.Text = ("Fullness: active (%d min left)"):format(remaining)
end

local MARKET_OPEN_START = 7 * 60
local MARKET_OPEN_END = 22 * 60

local currentZoneName = "None"
local currentJobLevel = 1

local function getCooldownAttributeName(jobId: string): string
	return "JonesCooldown_" .. jobId
end

local function isJobOnCooldown(jobId: string): boolean
	local endTime = player:GetAttribute(getCooldownAttributeName(jobId))
	return typeof(endTime) == "number" and workspace:GetServerTimeNow() < endTime
end

local function updateWarehouseHint(jobLevel: number)
	local pay = WAREHOUSE_BASE_PAY + (jobLevel - 1) * PAY_PER_LEVEL
	warehouseHintLabel.Text = ("Warehouse: +%d / -%dE / -%dH"):format(pay, WAREHOUSE_ENERGY_COST, WAREHOUSE_HUNGER_COST)
end

local function updateCleanupHint(jobLevel: number)
	local pay = CLEANUP_BASE_PAY + (jobLevel - 1) * PAY_PER_LEVEL
	cleanupHintLabel.Text = ("Cleanup: +%d / -%dE / -%dH"):format(pay, CLEANUP_ENERGY_COST, CLEANUP_HUNGER_COST)
end

local function setLastActionText(message: string)
	if message == "" then
		lastActionLabel.Text = ""
		return
	end

	lastActionLabel.Text = ("Last Action: %s"):format(message)
end

local function getJobStartButtonText(
	displayName: string,
	openStart: number,
	openEnd: number,
	gameMinutes: number,
	jobId: string
): string
	if not isWithinHours(gameMinutes, openStart, openEnd) then
		return ("Start %s (Closed)"):format(displayName)
	end

	if isJobOnCooldown(jobId) then
		return ("Start %s (Cooldown)"):format(displayName)
	end

	return ("Start %s"):format(displayName)
end

local function isWithinHours(minutes: number, startMinutes: number, endMinutes: number): boolean
	return minutes >= startMinutes and minutes <= endMinutes
end

local function updateZoneActionButtons(zoneName: string, gameMinutes: number)
	currentZoneName = zoneName

	local inIndustrial = zoneName == "Industrial"
	local inMarket = zoneName == "Market"
	local inHome = zoneName == "Home"
	local inBank = zoneName == "Bank"
	actionsFrame.Visible = inIndustrial or inMarket or inHome or inBank

	workShiftButton.Visible = inIndustrial
	cleanupShiftButton.Visible = inIndustrial
	jobBoardLabel.Visible = inIndustrial
	warehouseHintLabel.Visible = inIndustrial
	cleanupHintLabel.Visible = inIndustrial

	if inIndustrial then
		updateWarehouseHint(currentJobLevel)
		updateCleanupHint(currentJobLevel)
		workShiftButton.Text = getJobStartButtonText(
			WAREHOUSE_SHIFT_NAME,
			WAREHOUSE_OPEN_START,
			WAREHOUSE_OPEN_END,
			gameMinutes,
			WAREHOUSE_SHIFT_ID
		)
		cleanupShiftButton.Text = getJobStartButtonText(
			CLEANUP_SHIFT_NAME,
			CLEANUP_OPEN_START,
			CLEANUP_OPEN_END,
			gameMinutes,
			CLEANUP_SHIFT_ID
		)
	end

	restButton.Visible = inHome
	buyFoodButton.Visible = inMarket
	if inMarket then
		local open = isWithinHours(gameMinutes, MARKET_OPEN_START, MARKET_OPEN_END)
		buyFoodButton.Text = if open then "Open Food Shop" else "Open Food Shop (Closed)"
	else
		setFoodShopOpen(false)
	end

	depositAllButton.Visible = inBank
	withdraw25Button.Visible = inBank
	task.defer(refreshHudLayout)
end

local function bindLeaderstats(leaderstats: Folder, gameMinutes: IntValue)
	local money = leaderstats:WaitForChild("Money") :: IntValue
	local bankBalance = leaderstats:WaitForChild("BankBalance") :: IntValue
	local energy = leaderstats:WaitForChild("Energy") :: IntValue
	local hunger = leaderstats:WaitForChild("Hunger") :: IntValue
	local reputation = leaderstats:WaitForChild("Reputation") :: IntValue
	local jobXp = leaderstats:WaitForChild("JobXP") :: IntValue
	local jobLevel = leaderstats:WaitForChild("JobLevel") :: IntValue
	local currentZone = leaderstats:WaitForChild("CurrentZone") :: StringValue

	bindStat(moneyLabel, money, "Wallet")
	updateFoodShopWalletLabel(money.Value)
	money.Changed:Connect(function()
		updateFoodShopWalletLabel(money.Value)
	end)
	bindStat(bankLabel, bankBalance, "Bank")
	bindStat(energyLabel, energy, "Energy")
	bindStat(hungerLabel, hunger, "Hunger")
	updateNeedsStatusLabel(hunger)
	hunger.Changed:Connect(function()
		updateNeedsStatusLabel(hunger)
	end)
	bindStat(reputationLabel, reputation, "Reputation")
	bindStat(jobLevelLabel, jobLevel, "Job Level")
	currentJobLevel = jobLevel.Value
	updateWarehouseHint(currentJobLevel)
	updateCleanupHint(currentJobLevel)
	updateJobXpLabel(jobXp)
	jobXp.Changed:Connect(function()
		updateJobXpLabel(jobXp)
	end)
	jobLevel.Changed:Connect(function()
		currentJobLevel = jobLevel.Value
		updateWarehouseHint(currentJobLevel)
		updateCleanupHint(currentJobLevel)
		updateZoneActionButtons(currentZone.Value, gameMinutes.Value)
		updateObjectivePanel(money, energy, hunger, jobLevel)
	end)
	bindStringStat(zoneLabel, currentZone, "Current Zone")

	updateObjectivePanel(money, energy, hunger, jobLevel)
	money.Changed:Connect(function()
		updateObjectivePanel(money, energy, hunger, jobLevel)
	end)
	energy.Changed:Connect(function()
		updateObjectivePanel(money, energy, hunger, jobLevel)
	end)
	hunger.Changed:Connect(function()
		updateObjectivePanel(money, energy, hunger, jobLevel)
	end)

	updateZoneActionButtons(currentZone.Value, gameMinutes.Value)
	currentZone.Changed:Connect(function()
		updateZoneActionButtons(currentZone.Value, gameMinutes.Value)
	end)
end

workShiftButton.MouseButton1Click:Connect(function()
	performActionRemote:FireServer("WorkShift")
end)

cleanupShiftButton.MouseButton1Click:Connect(function()
	performActionRemote:FireServer("CleanupShift")
end)

restButton.MouseButton1Click:Connect(function()
	performActionRemote:FireServer("Rest")
end)

buyFoodButton.MouseButton1Click:Connect(function()
	setFoodShopOpen(not foodShopModal.isOpen())
end)

depositAllButton.MouseButton1Click:Connect(function()
	performActionRemote:FireServer("DepositAll")
end)

withdraw25Button.MouseButton1Click:Connect(function()
	performActionRemote:FireServer("Withdraw25")
end)

performActionRemote.OnClientEvent:Connect(function(message: string)
	setLastActionText(message)

	if pendingFoodPurchase and string.sub(message, 1, 6) == "Bought" then
		showFoodShopPurchaseToast(
			("Purchased %s for %d"):format(pendingFoodPurchase.name, pendingFoodPurchase.price)
		)
		pendingFoodPurchase = nil
	elseif pendingFoodPurchase then
		pendingFoodPurchase = nil
	end

	if string.sub(message, 1, 10) == "Daily bill" or string.sub(message, 1, 4) == "Job " then
		worldMessageLabel.Text = message
	end
end)

local jonesWorldMessage = ReplicatedStorage:WaitForChild("JonesWorldMessage") :: StringValue
worldMessageLabel.Text = jonesWorldMessage.Value
jonesWorldMessage.Changed:Connect(function()
	worldMessageLabel.Text = jonesWorldMessage.Value
end)

local jonesClockText = ReplicatedStorage:WaitForChild("JonesClockText") :: StringValue
clockLabel.Text = jonesClockText.Value
jonesClockText.Changed:Connect(function()
	clockLabel.Text = jonesClockText.Value
end)

local jonesGameMinutes = ReplicatedStorage:WaitForChild("JonesGameMinutes") :: IntValue
local jonesDay = ReplicatedStorage:WaitForChild("JonesDay") :: IntValue

local function refreshFullnessDisplay()
	updateFullnessLabel(jonesDay.Value, jonesGameMinutes.Value)
end

jonesGameMinutes.Changed:Connect(function()
	updateZoneActionButtons(currentZoneName, jonesGameMinutes.Value)
	refreshFullnessDisplay()
end)

jonesDay.Changed:Connect(function()
	refreshFullnessDisplay()
end)

player:GetAttributeChangedSignal(FULLNESS_UNTIL_DAY_ATTR):Connect(refreshFullnessDisplay)
player:GetAttributeChangedSignal(FULLNESS_UNTIL_GAME_MINUTES_ATTR):Connect(refreshFullnessDisplay)

refreshFullnessDisplay()

player:GetAttributeChangedSignal(getCooldownAttributeName(WAREHOUSE_SHIFT_ID)):Connect(function()
	if currentZoneName == "Industrial" then
		updateZoneActionButtons(currentZoneName, jonesGameMinutes.Value)
	end
end)

player:GetAttributeChangedSignal(getCooldownAttributeName(CLEANUP_SHIFT_ID)):Connect(function()
	if currentZoneName == "Industrial" then
		updateZoneActionButtons(currentZoneName, jonesGameMinutes.Value)
	end
end)

local lastCooldownRefresh = 0
RunService.Heartbeat:Connect(function()
	if currentZoneName ~= "Industrial" then
		return
	end

	local now = os.clock()
	if now - lastCooldownRefresh < 0.25 then
		return
	end
	lastCooldownRefresh = now

	updateZoneActionButtons(currentZoneName, jonesGameMinutes.Value)
end)

local function bindFoodInventory(inventoryFolder: Folder)
	refreshFoodInventoryUi(inventoryFolder)

	for _, item in FOOD_SHOP_DISPLAY_ITEMS do
		local countValue = inventoryFolder:FindFirstChild(item.Id) :: IntValue?
		if countValue then
			countValue.Changed:Connect(function()
				refreshFoodInventoryUi(inventoryFolder)
			end)
		end
	end
end

local leaderstats = player:WaitForChild("leaderstats")
bindLeaderstats(leaderstats, jonesGameMinutes)

player.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		bindLeaderstats(child, jonesGameMinutes)
	end
	if child.Name == "FoodInventory" then
		bindFoodInventory(child)
	end
end)

local foodInventoryFolder = player:WaitForChild("FoodInventory")
bindFoodInventory(foodInventoryFolder)

local function bindHudViewportRefresh()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshHudLayout)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindHudViewportRefresh()
	task.defer(refreshHudLayout)
end)
bindHudViewportRefresh()
task.defer(refreshHudLayout)
