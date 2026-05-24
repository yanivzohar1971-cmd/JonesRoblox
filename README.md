# Jones In The Lane (Roblox)

A Roblox port of **Jones In The Lane** — a life simulation in a city lane (work, housing, education, reputation, and zone-based actions). This repo uses [Rojo](https://rojo.space/) for **scripts only**; Roblox Studio owns the map.

> **Read before coding:** [Docs/JONES_MASTER_SUMMARY.md](Docs/JONES_MASTER_SUMMARY.md) · [Docs/JONES_ROBLOX_ADAPTATION.md](Docs/JONES_ROBLOX_ADAPTATION.md) · [Docs/JONES_DEVELOPMENT_RULES.md](Docs/JONES_DEVELOPMENT_RULES.md) · **New machine?** [Docs/DEVELOPMENT_MACHINE_SETUP.md](Docs/DEVELOPMENT_MACHINE_SETUP.md)

---

## Documentation

| Document | Purpose |
|----------|---------|
| [Docs/JONES_MASTER_SUMMARY.md](Docs/JONES_MASTER_SUMMARY.md) | Full game vision distilled from the idea pack |
| [Docs/JONES_ROBLOX_ADAPTATION.md](Docs/JONES_ROBLOX_ADAPTATION.md) | Roblox MVP phases and architecture |
| [Docs/JONES_DEVELOPMENT_RULES.md](Docs/JONES_DEVELOPMENT_RULES.md) | Mandatory rules for all development |
| [Docs/DEVELOPMENT_MACHINE_SETUP.md](Docs/DEVELOPMENT_MACHINE_SETUP.md) | **New Windows machine** — tools, install, verification |
| [Docs/JONES_ZONE_TAGS.md](Docs/JONES_ZONE_TAGS.md) | Studio zone Part setup and CollectionService tags |
| [Docs/JONES_JOBS.md](Docs/JONES_JOBS.md) | Server job definitions (Industrial job board) |
| [Docs/JONES_FOOD_SHOP.md](Docs/JONES_FOOD_SHOP.md) | Market food shop catalog and purchase flow |
| [Docs/JONES_CURRENT_STATUS.md](Docs/JONES_CURRENT_STATUS.md) | **MVP checkpoint** — loop, stats, zones, publish checklist |
| [Docs/MANUAL_ZONE_STABILIZATION_PLAN.md](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md) | **Manual zone plan** — Studio placement + helper removal |
| [Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md) | Beginner click-by-click zone setup in Studio |
| [Docs/BLENDER_ASSET_PIPELINE.md](Docs/BLENDER_ASSET_PIPELINE.md) | Blender CLI asset pipeline (GLB export, Studio import checklist) |
| [Assets/FoodIcons/README.md](Assets/FoodIcons/README.md) | Custom food UI icon source PNGs + Roblox upload workflow |
| [Docs/jones_game_idea_pack/](Docs/jones_game_idea_pack/) | Source-of-truth idea pack (web vision, modules, roadmap) |

---

## Current MVP Status

**Phase 2 Steps 1–19 complete** · **Step 20 in progress** — manual zone stabilization in Studio ([MANUAL_ZONE_STABILIZATION_PLAN.md](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md)). Food/needs: **[Docs/JONES_FOOD_SHOP.md](Docs/JONES_FOOD_SHOP.md)**.

| At a glance | |
|-------------|--|
| **Loop** | Industrial work → Market food → Home rest → Bank |
| **Zones** | Home, Market, Industrial, Bank |
| **Saved** | Wallet, Bank, Energy, Hunger, Reputation, Job XP/Level, **FoodInventory** |
| **Not saved** | Day/clock, zone, cooldowns, objectives |

### Quick test checklist

1. `rojo serve` → Studio **Sync** → **Play** (enable [API access](#studio-enable-api-access-required-for-saveload) for saves).
2. Walk **Industrial** → **Start Warehouse Shift** → Last Action shows complete message; Wallet +25.
3. **Start Cleanup Shift** → independent cooldown from Warehouse.
4. **Market** → **Open Food Shop** → buy **Apple** (Wallet −5; Energy/Hunger unchanged).
5. **Food Inventory** → **Eat Apple** → stats restore.
5. **Home** → **Rest** (+30 Energy).
6. **Bank** → **Deposit All** / **Withdraw 25**.
7. **Stop** → **Play** → stats restored (clock resets to Day 1 · 08:00).

Full checklist and publish steps: [Docs/JONES_CURRENT_STATUS.md](Docs/JONES_CURRENT_STATUS.md).

### Temporary zone placement helpers (technical debt)

Four server scripts are **temporary technical debt** — they auto-create or reposition zone Parts at runtime so early Play tests work without a finished map:

| Script | Debt |
|--------|------|
| `JonesZoneIndustrialPlacement.server.lua` | Moves `Zone_Industrial` to spawn |
| `JonesZoneHomePlacement.server.lua` | Auto-places `Zone_Home` near a building |
| `JonesZoneMarketPlacement.server.lua` | Auto-places `Zone_Market` near stalls/shops |
| `JonesZoneBankPlacement.server.lua` | Auto-places `Zone_Bank` near bank-like structures |

**They must be removed before publish.** Follow **[Docs/MANUAL_ZONE_STABILIZATION_PLAN.md](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md)** to place zones manually in Studio, verify detection and actions, then delete these four files from `src/ServerScriptService/` **only after you confirm "Manual zones verified."**

**Studio owns real zone Parts** — Rojo does not sync Workspace. Zone volumes are created, positioned, and saved in Roblox Studio (`File → Save to Roblox`).

---

## Phase 2 Step 20 — Manual Zones Stabilization

**Goal:** Replace temporary runtime zone helpers with **permanent Studio-placed zone Parts**.

| Part | Covers | HUD when inside | Actions |
|------|--------|-----------------|---------|
| `Zone_Industrial` | Work / warehouse area | Current Zone: Industrial | Warehouse Shift, Cleanup Shift |
| `Zone_Home` | House / residence | Current Zone: Home | Rest |
| `Zone_Market` | Market / stalls / shops | Current Zone: Market | Open Food Shop |
| `Zone_Bank` | Bank / office | Current Zone: Bank | Deposit All, Withdraw 25 |

**Full checklist:** [Docs/MANUAL_ZONE_STABILIZATION_PLAN.md](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md)

### Studio steps (Edit mode)

1. `rojo serve` → Studio **Connect** → **Sync** (stay in **Edit**, not Play).
2. For each zone, insert a **Block** Part, rename exactly (`Zone_Industrial`, `Zone_Home`, `Zone_Market`, `Zone_Bank`).
3. Move and scale over the correct map area — large enough to stand inside.
4. Set **Anchored = true**, **CanCollide = false**, **Transparency = 0.5** (testing).
5. **File → Save to Roblox**.

### Verification (Play mode)

Walk each zone and confirm **Current Zone** and buttons match the table above. Test save/load. See the [verification checklist](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md#verification-checklist) in the plan doc.

### Helper scripts (still present)

The four `JonesZone*Placement.server.lua` scripts **remain in the repo** until manual zones pass verification. Do **not** publish with them enabled. After verification, reply **"Manual zones verified."** to trigger helper removal (Phase B).

---

## Current status: Phase 2 (economy loop + Bank + day/clock)

Phase 1 gameplay loop is confirmed. **Phase 2:** Wallet/Bank split, Hunger, work/food/rest loop, bank actions, and a **server-owned day/clock** that makes the lane feel alive.

| System | Script |
|--------|--------|
| **Stats** (Wallet, BankBalance, Energy, Hunger, Reputation, JobXP, JobLevel, CurrentZone) | `JonesPlayerStats.server.lua` |
| **Save/load** (Wallet, BankBalance, Energy, Hunger, Reputation, JobXP, JobLevel, FoodInventory) | `JonesDataStoreService.server.lua` |
| **Passive needs** (Hunger decay) | `JonesNeedsService.server.lua` |
| **Low Hunger consequences** (pay penalty, work block) | `JonesNeeds.lua` + `JonesActionService.server.lua` |
| **Day/clock + daily bill** (not saved) | `JonesTimeService.server.lua`, `JonesDailyBill.lua` |
| **Zone detection** | `JonesZoneService.server.lua` |
| **Zone actions** (jobs, Food Shop/Inventory, Rest, bank) | `JonesActionService.server.lua`, `JonesFoodItems.lua`, `JonesFoodInventory.lua` |
| **Job definitions** | `JonesJobs.lua` |
| **HUD + objective tracker + clock** | `JonesMoneyUi.client.lua` — Stats / Inventory quick access / Actions / Modals |
| **Zone placement helpers** (temporary **technical debt**) | `JonesZoneIndustrialPlacement`, `JonesZoneHomePlacement`, `JonesZoneMarketPlacement`, `JonesZoneBankPlacement` — remove per [MANUAL_ZONE_STABILIZATION_PLAN.md](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md) |

**Saved:** Wallet (`Money`), BankBalance, Energy, Hunger, Reputation, **JobXP**, **JobLevel**, **FoodInventory** · **Not saved:** Day/clock, **Fullness buff**, world messages, CurrentZone, cooldowns, UI state, objectives

**Job board (Industrial):** **Warehouse Shift** (`WorkShift`) and **Cleanup Shift** (`CleanupShift`). HUD shows **Jobs: Warehouse · Cleanup** with pay/cost hints, start buttons, and a **Last Action** line. Cooldowns are **per job** (independent); buttons show **(Cooldown)** as a hint — server remains source of truth via player attributes `JonesCooldown_<jobId>` (not saved).

**Job progression:** Jobs grant Job XP (varies by job). Level up every **50 XP**. Pay: **BasePay + (JobLevel − 1) × 5** per job definition.

**Daily bill (midnight):** When the day increments at midnight, each player is charged **30** total — **Bank first**, then **Wallet**. Paid: `Daily bill paid: 30.` · Missed (total < 30): both balances zeroed, **Reputation −2** (min 0), `Daily bill missed. Reputation decreased.` Message shown via `JonesWorldMessage` + HUD (not saved).

**Day/clock (not saved):** Starts **Day 1 · 08:00** each server session. Every **5 real seconds** = **+10 game minutes**. Midnight wraps to the next day and triggers the daily bill. Replicated via `JonesDay`, `JonesGameMinutes`, `JonesClockText`, and `JonesWorldMessage` in ReplicatedStorage.

**Fast day testing:** In `JonesTimeService.server.lua`, set `TEST_FAST_DAY = true` locally to reach midnight in ~8 seconds (1s = +120 game minutes). **Must stay `false` in repo.**

**Time-gated actions (server-validated):**

| Action | Hours | Closed message |
|--------|-------|----------------|
| Warehouse Shift | 08:00–18:00 | `Warehouse Shift is closed...` |
| Cleanup Shift | 08:00–20:00 | `Cleanup Shift is closed...` |
| Buy Food (Food Shop) | 07:00–22:00 | `Market is closed. Come back between 07:00 and 22:00.` |
| Rest | Anytime | — |

Buttons may show **(Closed)** when outside hours; server always rejects invalid times.

**Wallet vs bank:** HUD shows **Wallet** (spending cash) and **Bank** (stored balance). Food shop uses Wallet only. Bank zone moves money between them.

**Food shop + inventory:** Buy at Market into inventory; **Eat** anywhere. **Food Shop** and **Food Inventory** follow the **premium card-grid modal design reference** — centered dark glass panels, responsive 2–3 column tiles, **compact thumbnail-left / details-right food cards**, and full-width Buy/Eat buttons. **Food Shop UX:** Wallet shown in modal header, Buy buttons use plain `Buy (price)` text, purchases at **15+** Wallet show a confirm dialog, and successful buys show a short **Purchased … for …** toast. **HUD layout:** compact **Stats** panel (scrollable, bottom-right stack) · **Inventory** quick button (188×48, bottom-right) · **Actions** panel (zone-specific, scrollable) · **Modals** (shop/inventory, centered). Panels clamp to screen with 16px margins; **Stats** and **Actions** headers are draggable (session-only). **Fullness** halves job Hunger cost and **pauses passive Hunger decay**. Hunger drops **−1 every 30 real seconds** when not full. **Low Hunger:** at **≤30** pay is reduced **20%** on Warehouse/Cleanup; at **≤10** those jobs are blocked until you eat. No health/death penalties yet. See [Docs/JONES_FOOD_SHOP.md](Docs/JONES_FOOD_SHOP.md).

**Needs Status (client HUD):** `Needs: OK` · `Needs: Hungry — eat soon` (≤30) · `Needs: Starving — eat now` (≤10).

**Objective tracker (client-only, not saved):** HUD text updates from Money, Energy, and Hunger.

| Condition | Objective text |
|-----------|----------------|
| **Hunger ≤ 10** | **Eat food now** |
| **Hunger ≤ 30** | **Buy or eat food soon** |
| **Job Level < 2 and Wallet < 25** | **Work shifts to reach Job Level 2** |
| Wallet < 25 | Choose a job at Industrial |
| Energy < 100 and Money ≥ 3 | Buy food at Market |
| Energy < 100 and Money < 15 | Rest at Home or work more |
| Otherwise | Explore Jones In The Lane |

Status line always shows: **Loop: Work → Food → Rest**

**Core loop:** earn at Industrial → buy food at Market (Energy + Hunger) → rest at Home.

| Zone | Action | Effect |
|------|--------|--------|
| Industrial | **Warehouse Shift** | +Wallet (25 + (Level−1)×5, **−20% if Hunger ≤30**), +10 XP, −20 Energy, −10 Hunger, +1 Rep (08:00–18:00); **blocked if Hunger ≤10** |
| Industrial | **Cleanup Shift** | +Wallet (15 + (Level−1)×5, **−20% if Hunger ≤30**), +5 XP, −10 Energy, −5 Hunger, +1 Rep (08:00–20:00); **blocked if Hunger ≤10** |
| **Market** | **Food Shop** | Buy into inventory (e.g. Apple −5 Wallet) (**07:00–22:00**) |
| **Anywhere** | **Food Inventory** | Eat owned food → +Energy / +Hunger |
| Home | Rest | +30 Energy free (anytime) |
| **Bank** | **Deposit All** | Move all Wallet → BankBalance |
| **Bank** | **Withdraw 25** | Move 25 BankBalance → Wallet (need ≥25 in bank) |

Studio zone setup: [Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md) · Stabilization plan: [Docs/MANUAL_ZONE_STABILIZATION_PLAN.md](Docs/MANUAL_ZONE_STABILIZATION_PLAN.md)

**Blender asset pipeline:** Scripts and headless export live under `Assets/Blender/` — see [Docs/BLENDER_ASSET_PIPELINE.md](Docs/BLENDER_ASSET_PIPELINE.md). The pipeline exists for **future asset generation** (food props, lane decor). **Generated GLB/FBX files must be manually reviewed before any Roblox Studio import** — never auto-import into the live place.

**Food UI icons:** Custom source PNGs live under [`Assets/FoodIcons/`](Assets/FoodIcons/README.md) — see [Assets/FoodIcons/README.md](Assets/FoodIcons/README.md). Uploaded Roblox `ImageAssetId` values are **active** in `JonesFoodItems.lua` and `JonesMoneyUi.client.lua`; `EmojiFallback` remains if preload fails.

**Zone detection:** CollectionService tags **or** Part name fallback (`Zone_Home`, `Zone_Industrial`, `Zone_Market`, `Zone_Bank`). Tags preferred; names work if Tag Editor fails.

---

## What Rojo manages

| Roblox service | Local folder |
|----------------|--------------|
| ReplicatedStorage | `src/ReplicatedStorage` |
| ServerScriptService | `src/ServerScriptService` |
| StarterPlayerScripts | `src/StarterPlayer/StarterPlayerScripts` |
| StarterGui | `src/StarterGui` |

**Workspace is not managed by Rojo.**

---

## Prerequisites

- [Rojo](https://rojo.space/docs/v7/getting-started/installation/) (7.6.1+)
- [Rojo Studio plugin](https://rojo.space/docs/v7/getting-started/installation/#install-the-plugin)

---

## Run Rojo

```powershell
cd c:\Users\Yaniv\source\repos\JonesRoblox
rojo serve
```

In Studio: Rojo plugin → **Connect** → **Sync**.

---

## Studio: enable API access (required for save/load)

DataStore only works in Studio when API access is enabled:

1. **Home** → **Game Settings**
2. **Security** (left sidebar)
3. Enable **Studio Access to API Services** ✅
4. Click **Save**

Without this, saves fail in Studio Play tests (logged as warnings in Output).

---

## Test in Play mode

Requires zone Parts in Studio — see [Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md).

- **Home:** `Zone_Home` (temporary helper may auto-place near a building).
- **Market:** `Zone_Market` (temporary helper may auto-place near stalls/shops).
- **Bank:** `Zone_Bank` (temporary helper may auto-place near bank/office buildings).

1. Run `rojo serve` and **Sync** from Studio.
2. Press **Play**.
3. Confirm HUD shows **Day/Clock** at top, then Wallet, Bank, Energy, Hunger, Reputation, Current Zone.
4. **Start:** Hunger **100**, objective **Work a shift at Industrial** (Money 0).
5. **Industrial:** **Work Shift** → Money +25, Energy −20, **Hunger −10** (now **90**).
6. Repeat shifts until Hunger drops — at **Hunger ≤ 30**, pay is **−20%** and HUD shows **Needs: Hungry — eat soon**; complete message may include `Hunger penalty applied.`
7. At **Hunger ≤ 10**, **Work Shift** fails: `Too hungry to work. Eat something first.` — HUD **Needs: Starving — eat now**
8. **Market:** **Open Food Shop** → buy food → **Food Inventory** → **Eat** to restore Hunger

9. **Home:** **Rest** → Energy +30 (Hunger unchanged).
10. **Economy loop:** Work → Buy/Eat food (when hungry or low Energy) → Rest when tired.

### Test Hunger + food meaning

1. **Play** → confirm HUD **Hunger: 100**, **Needs: OK**.
2. **Industrial** → **Work Shift** until Hunger **≤ 30** → HUD **Needs: Hungry — eat soon**; next shift pays **floor(pay × 0.8)** with `Hunger penalty applied.` in Last Action.
3. Continue until Hunger **≤ 10** → HUD **Needs: Starving — eat now**; **Work Shift** blocked: `Too hungry to work. Eat something first.`
4. Objective → **Eat food now** (starving) or **Buy or eat food soon** (hungry).
5. **Market** → buy food → **Food Inventory** → **Eat** → Hunger restored; jobs work again.
6. **Stop** → **Play** → Hunger restored from DataStore.

**DataStore backward compatibility:** Old saves without `Hunger` default to **100**; old saves without `BankBalance` default to **0**. Store name stays `JonesPlayerData_v1`.

### Test Bank account MVP

1. Enable **Studio Access to API Services**.
2. **Play** → **Industrial** → **Work Shift** twice (10s cooldown) → Wallet **50**, Bank **0**.
3. Walk to **Bank** → HUD: **Current Zone: Bank** → **Deposit All** + **Withdraw 25** buttons.
4. **Deposit All** → Wallet **0**, Bank **50** → `Deposited all wallet money.`
5. **Deposit All** again → `No wallet money to deposit.`
6. **Withdraw 25** → Wallet **25**, Bank **25** → `Withdrew 25 from bank.`
7. **Withdraw 25** again → Wallet **50**, Bank **0**.
8. **Withdraw 25** with Bank **0** → `Not enough bank balance.`
9. **Stop** → **Play** → Wallet and Bank restored from DataStore.

### Test day/clock

1. **Play** → HUD top line: **Day 1 · 08:00**
2. Wait **5 seconds** → clock advances to **08:10**
3. Wait **5 more seconds** → **08:20** (every 5s = +10 game minutes)
4. Output shows: `[JonesTimeService] Started at Day 1 · 08:00 ...`
5. To see day rollover: wait until clock passes **23:50** → next tick → **Day 2 · 00:00** (Output: `New day: Day 2`)
6. **Stop** → **Play** again → clock resets to **Day 1 · 08:00** (not saved yet)

### Test time-gated actions

1. **Play** at **08:00** → **Industrial** → **Work Shift** succeeds.
2. **Market** → **Buy Food** succeeds (market open from 07:00).
3. Wait until clock shows **18:10** (~5 real minutes from start) → **Industrial** → **Work Shift** → `Work is closed. Come back between 08:00 and 18:00.`
4. Button shows **Work Shift (Closed)** while in Industrial zone.
5. **Market** → **Buy Food** still works at 18:10.
6. Wait until **22:10** → **Market** → **Buy Food** → `Market is closed. Come back between 07:00 and 22:00.`
7. **Home** → **Rest** works at any time (e.g. after 22:10).

### Test daily bill (midnight)

**Paid bill:**

1. **Play** → **Work Shift** twice → Wallet **50**.
2. **Bank** → **Deposit All** → Wallet **0**, Bank **50**.
3. Wait for midnight (**Day 2 · 00:00**) — ~5 real minutes from 08:00, or set `TEST_FAST_DAY = true` in `JonesTimeService.server.lua` (~8 seconds).
4. Confirm **Bank 20**, Wallet **0** (30 taken from bank).
5. HUD world message: `Daily bill paid: 30.`

**Missed bill:**

1. **Play** with Wallet **0**, Bank **0**, Reputation **2**.
2. Trigger midnight (wait or `TEST_FAST_DAY`).
3. Confirm Wallet **0**, Bank **0**, Reputation **0**.
4. HUD world message: `Daily bill missed. Reputation decreased.`

**Note:** No bill on session start — only when the day increments past midnight.

### Test Job Board (Industrial)

1. **Play** → **Industrial** → HUD: **Jobs: Warehouse · Cleanup**
2. Hint lines: **Warehouse: +25 / -20E / -10H** and **Cleanup: +15 / -10E / -5H** (warehouse pay scales with Job Level)
3. **Start Cleanup Shift** → **Last Action:** `Cleanup Shift complete! +15 Wallet, -10 Energy, -5 Hunger, +5 XP.`
4. **Start Warehouse Shift** → **Last Action:** `Warehouse Shift complete! +25 Wallet, -20 Energy, -10 Hunger, +10 XP.` (`WorkShift` remote unchanged)
5. Immediate retry → button **Start Cleanup Shift (Cooldown)**; server: `Cleanup Shift on cooldown.`
6. **Start Warehouse Shift** still works within 6s (**independent cooldowns**)
7. After cooldown expires, Cleanup button returns to **Start Cleanup Shift**
8. After **18:10** → Warehouse **(Closed)**; Cleanup open until 20:00

### Test Job action feedback (Step 12)

1. **Industrial** → run any zone action (job, Rest elsewhere, etc.) → **Last Action** line updates from server status text
2. Confirm complete messages use **Wallet** (not Money) and include job name + XP
3. Cooldown hint on button is cosmetic only — spam-click during cooldown still rejected server-side

### Test Job XP and Job Level

1. Enable **Studio Access to API Services**.
2. **Play** → HUD: **Job Level: 1**, **Job XP: 0 / 50**.
3. **Industrial** → **Start Warehouse Shift** ×5 (10s cooldown between) — eat food if Hunger drops to **≤ 30** (penalty) or **≤ 10** (blocked).
4. After 5th shift: **Job Level 2**, **Job XP: 0 / 50**, world message `Job level up! Level 2.`
5. 5th shift pays **+30 Wallet** (scaled reward); shifts 1–4 pay **+25**.
6. **Stop** → **Play** → Job Level and Job XP restored from DataStore.

**DataStore backward compatibility:** Old saves without `JobXP` / `JobLevel` default to **0** and **1**.

### Test objective tracker

1. **Play** with fresh stats (or reset by clearing DataStore in a new test place).
2. Confirm objective: **Work a shift at Industrial** (Money < 25, Hunger > 30).
3. **Work Shift** once → Money **25**, Energy **80**, Hunger **90** → objective follows Energy/Money rules (Hunger > 30).
4. Work until Hunger **≤ 30** → objective: **Buy or eat food soon** (takes priority over other hints).
5. Work until Hunger **≤ 10** → objective: **Eat food now**; jobs blocked until you eat.
6. Confirm **Loop: Work → Food → Rest** stays visible; objectives are **not** saved after Stop/Play.

### Test Low Hunger Consequences

1. **Play** → note **Needs: OK** on HUD.
2. Work or wait until **Hunger ≤ 30** → **Needs: Hungry — eat soon**; objective **Buy or eat food soon**.
3. **Industrial** → **Warehouse Shift** → Last Action shows reduced pay (e.g. **+20** instead of **+25**) and `Hunger penalty applied.` — Energy/XP/Rep unchanged; Hunger cost still applies (fullness still halves cost).
4. Reduce Hunger to **≤ 10** → **Needs: Starving — eat now**; objective **Eat food now**.
5. Try **Warehouse Shift** or **Cleanup Shift** → `Too hungry to work. Eat something first.`
6. **Food Inventory** → **Eat** (any owned food) → Hunger rises; jobs succeed again when Hunger **> 10**.

### Test Passive Hunger Decay

1. **Play** → note **Hunger** (e.g. 100)
2. Wait **30 seconds** without eating → Hunger **−1**
3. **Eat Sandwich** → **Fullness: active**
4. Wait **30 seconds** → Hunger **unchanged** (decay paused)
5. Wait until fullness expires (or eat Water for 10 min buff test)
6. Wait **30 seconds** → Hunger **−1** again (decay resumes)
7. **Stop** → **Play** → Hunger restored from DataStore (decay during session was saved on stop)

### Test Fullness buff

1. **Play** → buy/eat **Sandwich** (or any food with fullness)
2. HUD: **Fullness: active (90 min left)** (Sandwich)
3. Note **Hunger** before shift → **Industrial** → **Warehouse Shift** → Hunger drops by **5** (not 10)
4. **Cleanup Shift** while full → Hunger drops by **3** (not 5)
5. Wait until fullness expires (Sandwich = 90 game min ≈ 7.5 real min at 5s/tick) OR eat Water (10 min) for faster test
6. HUD: **Fullness: None** → next shift uses normal Hunger cost (10 / 5)

### Test HUD layout (Stats / Actions / Inventory)

1. **Play** → HUD docks **bottom-right**; nothing clips below the screen edge
2. **Stats** panel shows Day, Wallet, stats, zone, objective, Last Action — scroll inside panel if viewport is short
3. **Inventory** button is compact (not full width), bottom-right, always visible
4. **Industrial** → **Actions** panel appears above Inventory with Warehouse/Cleanup fully visible (scroll if needed)
5. **Market** → Actions shows **Open Food Shop** only
6. **Home** → Actions shows **Rest** only
7. **Bank** → Actions shows **Deposit All** / **Withdraw 25** only
8. **None** zone → Actions panel hidden; Stats + Inventory remain
9. Drag **Stats** or **Actions** header (⋮⋮ area) → panel moves; cannot leave screen bounds (session-only, not saved)
10. Resize viewport smaller → panels re-stack and clamp; Food Shop modal stays centered
11. **Inventory** opens centered modal from any zone; Food Shop still Market-only under Actions

### Test Food Shop + Inventory (premium card-grid modals)

1. **Play** → click **Food Inventory** with no food → **No food in inventory yet.**
2. Walk to **Market** → **Open Food Shop** → centered dark glass modal with icon title and **×** close button
3. Confirm **3-column** card grid on wide viewport; thumbnails top-left; **🪙 price Buy** buttons full-width and not clipped
4. **Buy Water**, **Apple**, and **Sandwich** → Owned counts update on shop cards
5. Open **Food Inventory** → shop closes; matching premium modal with **xN** counts and green **Eat** buttons
6. **Eat** an item → count decreases; stats update
7. Walk out of Market → shop closes; inventory can stay open
8. Resize Studio viewport smaller → cards reflow to **2 columns**; vertical scroll works; no horizontal overflow
9. Widen viewport → grid expands to **3 columns** when modal width ≥ 500px
10. With insufficient Wallet, **Buy** fails; at full stats **Eat** fails
11. **Stop** → **Play** → inventory counts restored from DataStore

### Test Food Shop (Market) — legacy checklist

1. **Play** → walk to **Market** → **Open Food Shop**
2. Confirm six items with Price, Energy, Hunger, and fullness minutes
3. **Buy Apple** → Last Action: `Bought Apple! -5 Wallet, +5 Energy, +10 Hunger. Keeps you full for 30 min.`
4. **Buy Hot Meal** → larger Wallet deduction and stat gains
5. With Wallet **< 3**, try **Buy Water** → `Not enough Wallet (need 3).`
6. At Energy **100** and Hunger **100**, try any item → `Energy and Hunger are already full.`
7. Walk out of Market → shop panel closes automatically
8. **Stop** → **Play** → stats restored (no food inventory saved)

### Test Market + save/load

1. Enable **Studio Access to API Services** (Game Settings → Security).
2. **Play** → **Work Shift** at Industrial (earn Money).
3. Walk to **Market** → **Open Food Shop** → buy **Sandwich** (or any item).
4. Confirm Wallet decreases by item price; Energy/Hunger update.
5. **Home** → **Rest** if needed.
6. **Stop** Play → **Play** again → stats restored via DataStore.

**Note:** Legacy single **Buy Food** action removed — use **Food Shop** per-item purchases.

### Test save/load persistence

1. Enable **Studio Access to API Services** (see above).
2. `rojo serve` → **Sync** → **Play**.
3. **Work Shift** twice (wait 10s cooldown between) → e.g. Money **50**, Energy **60**, **Hunger 80**, Reputation **2**.
4. **Rest** once at Home → Energy **90** (Hunger still **80**).
5. **Stop** Play.
6. **Play** again.
7. Confirm values **restored** (Money 50, Energy 90, **Hunger 80**, Reputation 2).
8. Output should show:
   ```
   [JonesDataStore] Loading ...
   [JonesDataStore] Load success ...
   [JonesDataStore] Save success ... (on Stop)
   ```

**Note:** Studio Play sessions may not always persist like a published game — publish/test in live server for production validation.

### Troubleshooting: `Current Zone` stays `None`

1. **Part name fallback (easiest):** rename Part to exactly `Zone_Industrial` or `Zone_Home` — tags not required.
2. Part must be **big enough** — character standing **inside** the box.
3. **Anchored** ✅, **CanCollide** ❌.
4. Rojo **Sync** after script changes, then Play again.
5. Check **Output** for `[JonesZoneService] Found named zone fallback: ...` or `Found tagged zone: ...`.

See [Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](Docs/STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md).

---

## Project layout

```
JonesRoblox/
├── default.project.json
├── README.md
├── Docs/
└── src/
    ├── ReplicatedStorage/
    │   ├── JonesClockText.model.json
    │   ├── JonesDay.model.json
    │   ├── JonesGameMinutes.model.json
    │   ├── JonesPerformAction.model.json
    │   └── JonesWorldMessage.model.json
    ├── ServerScriptService/
    │   ├── JonesActionService.server.lua
    │   ├── JonesDailyBill.lua
    │   ├── JonesDataStoreService.server.lua
    │   ├── JonesFoodItems.lua
    │   ├── JonesFoodInventory.lua
    │   ├── JonesNeedsService.server.lua
    │   ├── JonesFullness.lua
    │   ├── JonesJobs.lua
    │   ├── JonesPlayerStats.server.lua
    │   ├── JonesServerInit.server.lua
    │   ├── JonesTimeService.server.lua
    │   ├── JonesZoneBankPlacement.server.lua      ← temporary
    │   ├── JonesZoneHomePlacement.server.lua      ← temporary
    │   ├── JonesZoneIndustrialPlacement.server.lua ← temporary
    │   ├── JonesZoneMarketPlacement.server.lua    ← temporary
    │   └── JonesZoneService.server.lua
    └── StarterPlayer/StarterPlayerScripts/
        └── JonesMoneyUi.client.lua
```

---

## Important

- **Studio owns** map, terrain, models, zone parts.
- **Rojo owns** code only.
- **DataStore** saves Wallet (`Money`), BankBalance, Energy, Hunger, Reputation (`JonesPlayerData_v1`).
- **No monetization, vehicles, or combat** yet — see development rules.
- **Next up:** Downtown/School zone stubs.
