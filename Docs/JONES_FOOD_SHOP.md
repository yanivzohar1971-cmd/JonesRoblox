# Jones In The Lane — Food Shop (Market)

Server-side food catalog, inventory, and purchase/eat flow. Definitions live in `src/ServerScriptService/JonesFoodItems.lua`.

---

## Overview

- **Food Shop** at the **Market** zone — buy food into **inventory** (Wallet cost only).
- **Food Inventory** — eat owned food **anywhere** to restore Energy/Hunger.
- Food is **not** consumed on purchase; eating applies restores immediately.
- **`FullnessMinutes`** — eating sets a **fullness buff** (session-only) that halves job Hunger cost while active.
- All validation and stat changes are **server-side** via `JonesPerformAction`.
- Inventory is **saved** in `JonesPlayerData_v1` under `FoodInventory`.
- **Fullness state is NOT saved** (resets each session).

---

## FoodItem fields

| Field | Purpose |
|-------|---------|
| `Id` | Stable key sent by client (e.g. `Apple`) |
| `DisplayName` | HUD / messages |
| `Price` | Wallet cost (Market buy) |
| `EnergyRestore` | Energy added when eaten (cap 100) |
| `HungerRestore` | Hunger added when eaten (cap 100) |
| `FullnessMinutes` | Buff duration when eaten (game minutes) |
| `ImageAssetId` | Roblox thumbnail for HUD cards |
| `ThemeColor` | Card accent color (client display) |
| `EmojiFallback` | Shown if thumbnail preload fails |

---

## Catalog (initial)

| Id | DisplayName | Price | Energy | Hunger | Fullness (min) | Emoji |
|----|-------------|-------|--------|--------|----------------|-------|
| `Water` | Water | 3 | +5 | +0 | 10 | 💧 |
| `Apple` | Apple | 5 | +5 | +10 | 30 | 🍎 |
| `Bread` | Bread | 8 | +10 | +18 | 45 | 🍞 |
| `Sandwich` | Sandwich | 15 | +25 | +35 | 90 | 🥪 |
| `HotMeal` | Hot Meal | 25 | +40 | +60 | 180 | 🍲 |
| `FamilyMeal` | Family Meal | 45 | +60 | +100 | 300 | 🍖 |

---

## Image asset strategy

HUD cards use **Roblox default icon asset IDs** (free, simulator-style thumbnails):

| Item | ImageAssetId |
|------|----------------|
| Water | `rbxassetid://6031094678` |
| Apple | `rbxassetid://6031224321` |
| Bread | `rbxassetid://6031250864` |
| Sandwich | `rbxassetid://6031255092` |
| Hot Meal | `rbxassetid://6031280882` |
| Family Meal | `rbxassetid://6031286352` |

**Fallback:** Client runs `ContentProvider:PreloadAsync` on each image. If preload fails, the card shows the **emoji** from `EmojiFallback` instead. No Studio models or Workspace assets required.

---

## Inventory (runtime + saved)

**Runtime:** `player.FoodInventory` folder with one `IntValue` per food id (replicates to client).

**DataStore:** `FoodInventory` table on save:

```lua
FoodInventory = {
  Water = 0,
  Apple = 0,
  Bread = 0,
  Sandwich = 0,
  HotMeal = 0,
  FamilyMeal = 0,
}
```

**Backward compatibility:** Old saves without `FoodInventory` default **all counts to 0**. Store name stays `JonesPlayerData_v1`.

Helpers: `JonesFoodInventory.lua` (`sanitize`, `applyToPlayer`, `readFromPlayer`, `addCount`).

---

## Fullness buff (session-only)

When a food item is **eaten**, the server sets player attributes:

| Attribute | Purpose |
|-----------|---------|
| `JonesFullnessUntilGameMinutes` | Expiry time (minutes from midnight, wrapped 0–1439) |
| `JonesFullnessUntilDay` | Expiry day (`JonesDay` value) |

**Default:** both `0` (no buff). **Not saved** to DataStore.

### On eat

1. Apply Energy/Hunger restore (unchanged).
2. Set expiry = current game time + `FullnessMinutes` (wraps safely past midnight using day + minutes).
3. Message includes: `Full for <FullnessMinutes> min.`

Example:

```
Ate Sandwich! +25 Energy, +35 Hunger. Full for 90 min.
```

### While fullness is active

- **Warehouse Shift** Hunger cost: 10 → **5**
- **Cleanup Shift** Hunger cost: 5 → **3**
- Formula: `math.max(1, math.ceil(baseCost × 0.5))`
- **Passive hunger decay is paused** (see below)

Server decides if buff is active (`JonesFullness.lua`). HUD shows:

- `Fullness: None`
- `Fullness: active (N min left)`

---

## Passive hunger decay

Server-owned tick in `JonesNeedsService.server.lua`:

| Setting | Value |
|---------|--------|
| Interval | **30 real seconds** |
| Decay | **−1 Hunger** per tick |
| Minimum | **0** (no death/health penalty yet) |
| While **fullness active** | **No decay** |
| While **DataStore loading** | **No decay** (`JonesDataLoaded` attribute) |

Hunger is saved normally via existing DataStore. No HUD/status messages on decay ticks (optional debug print when `DEBUG_HUNGER_DECAY = true` locally).

---

## Low Hunger consequences (Step 19)

Makes low Hunger matter **without** health or death systems yet. Server authority in `JonesNeeds.lua` + job flow in `JonesActionService.server.lua`.

| Threshold | Hunger | Effect |
|-----------|--------|--------|
| **OK** | **> 30** | Normal job pay; jobs allowed |
| **Hungry** | **≤ 30** | Warehouse/Cleanup pay **−20%** (`math.floor(pay × 0.8)`); jobs still allowed |
| **Starving** | **≤ 10** | Warehouse/Cleanup **blocked** — `Too hungry to work. Eat something first.` |

**Unchanged when hungry (not starving):** Energy cost, Hunger cost (including fullness discount), Job XP, Reputation.

**Pay penalty timing:** Based on Hunger **before** the shift deducts its Hunger cost.

**Job complete message:** Shows actual pay after penalty; appends `Hunger penalty applied.` when pay was reduced.

**Client only:** Needs Status line and objective priority (server applies pay/block).

### Needs Status (client HUD)

| Hunger | HUD line |
|--------|----------|
| **> 30** | `Needs: OK` |
| **≤ 30 and > 10** | `Needs: Hungry — eat soon` |
| **≤ 10** | `Needs: Starving — eat now` |

### Objective priority (client)

| Hunger | Objective |
|--------|-----------|
| **≤ 10** | `Objective: Eat food now` |
| **≤ 30** | `Objective: Buy or eat food soon` |
| Otherwise | Existing objective logic |

No health/death penalties yet.

---

## Remote actions

| Action | Where | Second arg | Effect |
|--------|-------|------------|--------|
| `BuyFoodItem` | Market (07:00–22:00) | `itemId` | −Wallet, +1 inventory |
| `EatFoodItem` | Anywhere | `itemId` | −1 inventory, +Energy/Hunger |

**Client examples:**

```lua
performActionRemote:FireServer("BuyFoodItem", "Apple")
performActionRemote:FireServer("EatFoodItem", "Apple")
```

---

## BuyFoodItem validation

1. `CurrentZone == "Market"`
2. Market open hours: **07:00–22:00**
3. Item exists
4. Wallet ≥ `Price`

On success:

```
Bought Apple for inventory! -5 Wallet.
```

Energy/Hunger **do not** change on buy.

---

## EatFoodItem validation

1. Item exists
2. Inventory count **> 0**
3. Not both Energy and Hunger already at **100**

On success:

- Inventory count −1
- Energy/Hunger restored (capped)
- Message:

```
Ate Apple! +5 Energy, +10 Hunger. Full for 30 min.
```

Gains reflect **actual** amounts after caps.

---

## Client UI (`JonesMoneyUi.client.lua`)

| Element | Behavior |
|---------|----------|
| **Food Inventory** button | Always visible; toggles inventory panel |
| **Open Food Shop** | Market zone only; toggles shop panel |
| **Food Shop cards** | Thumbnail, name, price, stats, **Owned: N**, Buy |
| **Inventory cards** | Thumbnail, name, count, stats, Eat (hidden when count 0) |
| **Fullness line** | `Fullness: None` or `Fullness: active (N min left)` |
| **Needs Status line** | `Needs: OK` / `Needs: Hungry — eat soon` / `Needs: Starving — eat now` |
| **Leave Market** | Shop closes; inventory stays available |
| **Style** | Rounded corners, dark translucent panels, hover on buttons |

Display values on the client mirror the server catalog (display-only).

---

## Not implemented yet

- Saving fullness across sessions
- Health/death penalties from low Hunger
- Inventory carry limits
- New zones

---

## Related files

| File | Role |
|------|------|
| `JonesFoodItems.lua` | Food catalog + messages + asset ids |
| `JonesFullness.lua` | Fullness buff state + job hunger discount |
| `JonesNeeds.lua` | Low Hunger thresholds, pay penalty, starving block message |
| `JonesNeedsService.server.lua` | Passive hunger decay tick |
| `JonesFoodInventory.lua` | Inventory helpers + DataStore sanitize |
| `JonesActionService.server.lua` | `performBuyFoodItem()`, `performEatFoodItem()` |
| `JonesDataStoreService.server.lua` | Save/load `FoodInventory` |
| `JonesPlayerStats.server.lua` | Creates `FoodInventory` folder on join |
| `JonesMoneyUi.client.lua` | Food shop + inventory HUD |

Legacy action **`BuyFood`** removed — use **`BuyFoodItem`** / **`EatFoodItem`**.
