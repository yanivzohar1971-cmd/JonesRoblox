# Jones In The Lane — Roblox Adaptation Plan

> Align all Roblox work with `Docs/JONES_MASTER_SUMMARY.md` and `Docs/jones_game_idea_pack/`.

This document defines how the **web life-sim vision** maps to **Roblox + Rojo**, what to build when, and how Phase 1 was delivered.

---

## What maps well to Roblox

| Jones concept | Roblox approach |
|---------------|-----------------|
| **Zone-based lane** | Studio-built map; zone volumes tagged `JonesZone_Home`, etc. (CollectionService) |
| **Move → enter zone → act** | `ZonePlus` or region parts + proximity prompts / UI panel |
| **Money / energy / reputation HUD** | `leaderstats` or `Player` attributes + client ScreenGui |
| **Work shift, rest, buy food** | Server-validated actions via RemoteFunctions |
| **NPCs in lane** | Server-spawned NPCs with simple pathing (later phase) |
| **Server authority** | All economy and action outcomes on server |
| **Modular features** | One ModuleScript folder per domain under `ReplicatedStorage/Modules` |
| **Small multiplayer** | Default Roblox server; shared lane, no special netcode yet |
| **Persistence** | `DataStoreService` ✅ Phase 2 |
| **Jobs / career** | Zone action + cooldown + payout tables (not touch coins) |
| **Bank panel** | UI + server wallet vs cash split (later) |

---

## What should stay future scope

| System | Why defer |
|--------|-----------|
| Stocks, credit loans, business tycoon | Phase 8 depth per web roadmap |
| Full housing market dynamics | Needs economy tick + inventory |
| 20 modules at once | Unmaintainable; vertical slice first |
| Firebase / Firestore | Web stack only |
| Canvas / React renderer | Not applicable on Roblox |
| Admin live ops | Production concern |
| Vehicles | Out of scope per project rules |
| Combat | Out of scope per project rules |
| Monetization | After fun core loop |
| Large city / many zones | Start with 3–5 zones in one lane |
| Complex NPC schedules | After one NPC greeter works |

---

## What should NOT be built yet

| Item | Reason |
|------|--------|
| New generic simulator mechanics | Off-brand for Jones |
| Expanding `CollectPower` / coin multiplier | Prototype only; remove later |
| Workspace in Rojo | Studio owns map |
| DataStore save system | ✅ Phase 2 step 1 — `JonesDataStoreService.server.lua` |
| Full bank/inventory/career UIs | Phase 2+ vertical slice |
| Combat, vehicles, trading | Explicit exclusions |
| DevProducts / Game Passes | No monetization yet |
| Massive map generation | Small lane in Studio |

---

## MVP Phase 1 — True Jones loop (Roblox)

**Goal:** Prove the **zone → action → stat change** loop in 3D, replacing the coin simulator mentally (code can stay until replacement lands).

### Phase 1 progress

| Step | Status | Deliverable |
|------|--------|-------------|
| **1. Player stats scaffold** | ✅ Done | `JonesPlayerStats.server.lua` — Money (0), Energy (100), Reputation (0); HUD shows all three |
| **2. Zone tags in Studio** | ✅ Done | [JONES_ZONE_TAGS.md](JONES_ZONE_TAGS.md) — tags documented |
| **3. Zone detection** | ✅ Done | `JonesZoneService.server.lua` — server bounds check, `leaderstats.CurrentZone` |
| **4. Action UI + Work Shift** | ✅ Done | `JonesActionService.server.lua` — Industrial work shift (+25/−20/+1, 10s cooldown) |
| **5. Rest action (Home)** | ✅ Done | Rest (+30 Energy, cap 100, 10s cooldown) |

| Deliverable | Description |
|-------------|-------------|
| **Lane shell** | Studio: Home, Market, Industrial (minimum 3 zones) |
| **Zone detection** | Server bounds check on tagged Studio Parts ✅ |
| **Action UI** | Panel lists zone actions (e.g. Industrial: "Work Shift") ✅ |
| **Core stats** | Money, Energy, Reputation (server-owned values) ✅ |
| **One real action** | Work Shift: −20 energy, +25 money, +1 reputation, 10s cooldown ✅ |
| **One rest action** | Home Rest: +30 energy (cap 100), 10s cooldown ✅ |
| **Rojo scripts only** | No Workspace in project file |

**Success criteria:** Player walks to Industrial → taps Work Shift → sees Money and Energy change on HUD. ✅ **Met.**

**Prototype:** Generic coin/CollectPower systems **retired** — Phase 1 is a clean MVP.

---

## MVP Phase 2 — Vertical slice depth

### Phase 2 progress

| Step | Status | Deliverable |
|------|--------|-------------|
| **1. DataStore save/load** | ✅ Done | `JonesDataStoreService.server.lua` — Money, Energy, Reputation |
| **2. Market buy-food** | ✅ Done | Buy Food at Market (−15 Money, +25 Energy, 3s cooldown) |
| **3. Objective tracker** | ✅ Done | Client HUD guidance — Work → Food → Rest (Phase 2 UX layer) |
| **4. Hunger stat** | ✅ Done | Work drains Hunger; food restores Hunger + Energy; saved in DataStore |
| **5. Bank account MVP** | ✅ Done | Wallet + BankBalance; Deposit All / Withdraw 25 at Bank zone |
| **6. Day/clock** | ✅ Done | Server time — Day 1 08:00 start; 5s = +10 min; not saved |
| **7. Time-gated actions** | ✅ Done | Work 08:00–18:00; Market 07:00–22:00; Rest anytime |
| **8. Daily bill** | ✅ Done | 30 at midnight — bank first; miss → Rep −2 |
| **9. Job XP / Level** | ✅ Done | +10 XP per shift; 50 XP/level; scaled pay |
| **10. Job board MVP** | ✅ Done | `JonesJobs.lua` — Warehouse Shift at Industrial |
| **11. Second Industrial job** | ✅ Done | Cleanup Shift — independent cooldown |
| **12. Job action feedback** | ✅ Done | Complete messages, Last Action line, pay hints, cooldown button hint |
| **13. Publish readiness checkpoint** | ✅ Done | [JONES_CURRENT_STATUS.md](JONES_CURRENT_STATUS.md) |
| **14. Manual zone stabilization plan** | ✅ Done | [MANUAL_ZONE_STABILIZATION_PLAN.md](MANUAL_ZONE_STABILIZATION_PLAN.md) |
| **15. Market Food Shop MVP** | ✅ Done | [JONES_FOOD_SHOP.md](JONES_FOOD_SHOP.md) — shop HUD + assets |
| **16. Food Inventory MVP** | ✅ Done | Buy to inventory, `EatFoodItem`, DataStore `FoodInventory` |
| **17. Fullness buff MVP** | ✅ Done | Session fullness; halved job Hunger cost ([JONES_FOOD_SHOP.md](JONES_FOOD_SHOP.md)) |
| **18. Passive Hunger decay** | ✅ Done | `JonesNeedsService` — −1 Hunger / 30s; fullness pauses decay |
| **19. Low Hunger consequences** | ✅ Done | `JonesNeeds` — hungry pay −20%; starving blocks Warehouse/Cleanup; no health/death yet |
| **20. Manual zones stabilization** | 🔄 **In progress** | Studio placement + verification — [MANUAL_ZONE_STABILIZATION_PLAN.md](MANUAL_ZONE_STABILIZATION_PLAN.md); helpers **not removed yet** |
| 20B. Remove placement helpers | Pending | After **"Manual zones verified."** — delete four placement scripts |
| 21. Downtown + School zones | Pending | Enroll course stub, additional Downtown actions |
| 22. Simple NPC | Pending | Greeter dialog stub |

| Deliverable | Description |
|-------------|-------------|
| **DataStore save** | Wallet, BankBalance, Energy, Hunger, Reputation, JobXP, JobLevel ✅ |
| **Market: buy food** | Food Shop + Inventory — buy at Market, eat anywhere ✅ ([JONES_FOOD_SHOP.md](JONES_FOOD_SHOP.md)) |
| **Food inventory save** | `FoodInventory` in DataStore — backward compatible ✅ |
| **Fullness buff** | Session-only; halves job Hunger cost while active ✅ |
| **Passive hunger decay** | −1 Hunger every 30 real seconds; paused while full ✅ |
| **Low Hunger consequences** | Hungry (≤30): −20% job pay; Starving (≤10): block Warehouse/Cleanup ✅ — no health/death yet |
| **Hunger** | Work drains Hunger; food restores; passive decay ✅ |
| **Bank account** | Deposit All / Withdraw 25 at Bank zone ✅ |
| **Day/clock** | `JonesTimeService` — Day 1 08:00; 5 real sec = +10 game min ✅ (not saved) |
| **Time-gated actions** | Work/Market hours enforced server-side ✅ |
| **Daily bill** | 30 at midnight via `JonesDailyBill` — bank first ✅ (world message not saved) |
| **Job progression** | JobXP/JobLevel — Warehouse Shift +10 XP, 50 XP/level, scaled pay ✅ |
| **Job board** | Warehouse Shift + Cleanup Shift at Industrial ✅ ([JONES_JOBS.md](JONES_JOBS.md)) |
| **Job feedback polish** | Complete messages with job name; HUD Last Action; pay/cost hints; cooldown button hint ✅ |
| **Objective tracker** | Client-only HUD hints from Wallet/Energy/Hunger ✅ (not persisted) |
| **Manual zone stabilization** | 🔄 Step 20 — Studio `Zone_*` Parts; helpers remain until verified |
| **Downtown + School zones** | Enroll course stub, additional Downtown actions |
| **Simple NPC** | One greeter with dialog stub |
| **Remove prototype** | ✅ Done — coin/CollectPower removed in Phase 1 cleanup |
| **Module layout** | `Career`, `Health`, `Zones` modules |

---

## Roblox-specific architecture constraints

```
┌─────────────────────────────────────────────────────────┐
│  Roblox Studio (owns)                                   │
│  Workspace · Terrain · Models · Zone parts · NPC models │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼ sync (tags, names only)
┌─────────────────────────────────────────────────────────┐
│  Rojo repo (owns)                                       │
│  ServerScriptService · ReplicatedStorage · Starter*     │
└─────────────────────────────────────────────────────────┘
```

| Constraint | Rule |
|------------|------|
| Map size | One lane, handful of zones — not open world |
| 3D vs 2D | Roblox is 3D; keep camera readable (top-down or fixed angle in Studio) |
| Script count | Prefer few clear scripts → modules as features grow |
| Remote surface | One RemoteFunction per action family, not per coin |
| State | Server is source of truth; replicate via values/attributes for UI |

---

## Client / server authority rules

| Concern | Authority |
|---------|-----------|
| Money, energy, reputation changes | **Server only** |
| Zone action requests | Client fires Remote → **server validates** zone + cooldown + stats |
| HUD display | **Client** reads replicated values |
| NPC movement (later) | **Server** simulates or uses simple server AI |
| Inventory (later) | **Server** owns inventory table |
| World economy ticks (later) | **Server** heartbeat |
| Exploit resistance | Never trust client-sent amounts |

---

## Rojo ownership rules

| Service | Rojo path | Notes |
|---------|-----------|-------|
| ReplicatedStorage | `src/ReplicatedStorage` | Modules, remotes, shared config |
| ServerScriptService | `src/ServerScriptService` | Bootstrap, services, zone handlers |
| StarterPlayerScripts | `src/StarterPlayer/StarterPlayerScripts` | Input, HUD, zone UI |
| StarterGui | `src/StarterGui` | Optional static UI |
| **Workspace** | **Not in Rojo** | Ever, unless explicitly decided later |

---

## Studio ownership rules

| Asset | Owner |
|-------|--------|
| Map layout, lanes, buildings | Studio |
| Zone region parts / attachments | Studio (tagged) |
| Lighting, spawn, camera | Studio |
| NPC models (future) | Studio models; Rojo scripts behavior |

---

## Prototype retirement (complete)

The early **generic touch-coin + CollectPower upgrade** loop validated Rojo plumbing only. It has been **removed**.

| Removed | Date |
|---------|------|
| `JonesCoinPickup.server.lua` | Phase 1 cleanup |
| `JonesUpgrade.server.lua` | Phase 1 cleanup |
| `JonesBuyCollectPowerUpgrade` RemoteEvent | Phase 1 cleanup |
| `CollectPower` stat + upgrade UI | Phase 1 cleanup |

Validation patterns from the upgrade flow live on in `JonesActionService.server.lua`.

---

## Historical prototype analysis

The Roblox repo briefly used a **generic touch-coin + power multiplier** loop. This validated Rojo plumbing but was **not** the Jones design.

### `Money` (leaderstats IntValue)

| Verdict | Detail |
|---------|--------|
| **Keep** | Cash-on-hand is core Jones |
| **Rename later** | Consider `Cash` vs bank balance when bank module exists |
| **Refactor** | Move creation to a `PlayerData` service module; add Energy + Reputation |
| **Remove later** | No — stat stays |
| **Maps to Jones** | `economy` / player wallet — paying for food, rent, courses |

### `JonesCoin` (CollectionService tag, +10 × CollectPower)

| Verdict | Detail |
|---------|--------|
| **Keep** | **No** — temporary test only |
| **Rename** | N/A |
| **Refactor** | Replace with zone actions (Work Shift pays from server table) |
| **Remove later** | **Yes** — first cleanup when Phase 1 action ships |
| **Maps to Jones** | **Does not map** — generic simulator pickup |

### `CollectPower` (leaderstats, upgradeable)

| Verdict | Detail |
|---------|--------|
| **Keep** | **No** |
| **Rename** | N/A |
| **Refactor** | Remove; job payouts use career tier / education later |
| **Remove later** | **Yes** — with coin system |
| **Maps to Jones** | **Does not map** — idle multiplier mechanic |

### Upgrade button (`JonesBuyCollectPowerUpgrade`)

| Verdict | Detail |
|---------|--------|
| **Keep** | **No** |
| **Rename** | Replace with `ZoneActionPanel` + per-action remotes |
| **Refactor** | Pattern (server validates purchase) **reusable** for buy food, enroll, etc. |
| **Remove later** | **Yes** |
| **Maps to Jones** | Partially — **validation pattern** is good; **CollectPower product** is not |

### Files retired ✅

- ~~`JonesCoinPickup.server.lua`~~
- ~~`JonesUpgrade.server.lua`~~
- ~~`JonesBuyCollectPowerUpgrade` RemoteEvent~~
- ~~CollectPower in `JonesPlayerStats.server.lua`~~
- ~~Upgrade UI section in `JonesMoneyUi.client.lua`~~

### Active Phase 1 files

- `JonesPlayerStats.server.lua` — Money, Energy, Reputation, CurrentZone
- `JonesDataStoreService.server.lua` — save/load Money, Energy, Reputation
- `JonesZoneService.server.lua` — zone detection
- `JonesActionService.server.lua` — Work Shift, Rest, Buy Food
- `JonesServerInit.server.lua` — bootstrap
- `JonesMoneyUi.client.lua` — HUD + zone action buttons

---

## Recommended TRUE Jones MVP loop (Roblox)

```
Spawn in lane
    → Walk into zone (Studio regions + tags)
    → Zone UI shows contextual actions
    → Player picks "Work Shift" / "Rest" / "Buy Food"
    → Server checks: correct zone, energy, cooldown
    → Server updates Money / Energy / Reputation
    → HUD updates
    → (Later) life event or economy tick changes costs
```

**Not:**

```
Walk into coin → auto money → buy abstract power → coins worth more
```

---

## Web ↔ Roblox parity matrix

| Web (idea pack) | Roblox MVP target |
|-----------------|-------------------|
| Canvas map + zones | Studio 3D lane + zone parts |
| `zoneInteractions.ts` | `JonesZones` module + region detection |
| `actionDispatcher.ts` | `JonesActionService` server |
| `PlayerHudPanel` | `JonesHud.client.lua` |
| `GameEngine` tick/day | `JonesTimeService.server.lua` ✅ (session-only, not saved) |
| Firestore save | DataStore (Phase 2) ✅ |

---

## DataStore (Phase 2)

| Setting | Value |
|---------|-------|
| DataStore name | `JonesPlayerData_v1` |
| Key | `player_<UserId>` |
| Saved fields | Wallet (Money), BankBalance, Energy, Hunger, Reputation, JobXP, JobLevel, FoodInventory, UpdatedAt |
| Backward compatible | Missing `Hunger` → **100**; `BankBalance` → **0**; `JobXP` → **0**; `JobLevel` → **1**; `FoodInventory` → **all 0** |
| Not saved | Day/clock, JonesWorldMessage, CurrentZone, cooldowns, **Fullness buff**, UI state |
| Save triggers | PlayerRemoving, BindToClose, autosave every 60s |
| Studio requirement | Game Settings → Security → **Studio Access to API Services** |

---
| 20 feature modules | Start with 3: Zones, Career, Health |

---

## Next recommended task

**Phase 2 steps 1–19 complete** · **Step 20 in progress** — manual zone stabilization.

**Current task (Step 20 — you in Studio):**

1. Follow [MANUAL_ZONE_STABILIZATION_PLAN.md](MANUAL_ZONE_STABILIZATION_PLAN.md) — place `Zone_Industrial`, `Zone_Home`, `Zone_Market`, `Zone_Bank` manually in Edit mode.
2. **Save to Roblox** and run the verification checklist (zone detection, actions, save/load).
3. Confirm **"Manual zones verified."** → then remove the four `JonesZone*Placement.server.lua` scripts (Step 20B).

**After Step 20B:**

1. **Downtown + School** zone stubs (Step 21).
2. **Simple NPC** greeter dialog stub (Step 22).

Do not reintroduce coin or CollectPower mechanics. Do not add quest persistence until a later phase.
