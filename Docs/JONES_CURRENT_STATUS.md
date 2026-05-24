# Jones In The Lane (Roblox) — Current MVP Status

> **Checkpoint:** Phase 2 Step 13 — publish readiness (docs only; no gameplay changes).  
> **Last updated:** May 2026 · **DataStore:** `JonesPlayerData_v1` (schema unchanged since Step 1)

Use this document as the single snapshot before adding Downtown, School, or NPCs.

**Related:** [JONES_ROBLOX_ADAPTATION.md](JONES_ROBLOX_ADAPTATION.md) · [JONES_JOBS.md](JONES_JOBS.md) · [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md)

---

## Current gameplay loop

```
Spawn → walk into zone → HUD shows zone actions
    → Work at Industrial (earn Wallet, spend Energy/Hunger, gain Job XP)
    → Buy Food at Market (restore Energy/Hunger, spend Wallet)
    → Rest at Home (restore Energy)
    → Bank: deposit / withdraw
    → Midnight: daily bill (30, bank first)
    → Repeat
```

**Design intent:** Location-driven life sim — not a coin collector. Server validates every action.

**HUD guidance (client-only):** Objective text + **Loop: Work → Food → Rest** + **Last Action** from server status messages.

---

## Current stats

| Stat | `leaderstats` name | Default | Saved | Notes |
|------|-------------------|---------|-------|-------|
| Wallet | `Money` | 0 | Yes | Spending cash; HUD label "Wallet" |
| Bank | `BankBalance` | 0 | Yes | Stored balance |
| Energy | `Energy` | 100 | Yes | Max 100; work/rest/food change it |
| Hunger | `Hunger` | 100 | Yes | Max 100; work drains; min **20** to work |
| Reputation | `Reputation` | 0 | Yes | Jobs +1; daily bill miss −2 |
| Job XP | `JobXP` | 0 | Yes | Level up every **50** XP |
| Job Level | `JobLevel` | 1 | Yes | Scales job pay: `BasePay + (Level−1)×5` |
| Current zone | `CurrentZone` | `None` | No | Server updates from zone volumes |

**Session-only (not in DataStore):**

| State | Where | Notes |
|-------|--------|-------|
| Day / clock | `JonesDay`, `JonesGameMinutes`, `JonesClockText` | Resets each server session |
| World message | `JonesWorldMessage` | Daily bill, job level-up |
| Job cooldowns | Player attributes `JonesCooldown_<jobId>` | Independent per job |
| Rest / Buy Food cooldowns | Server memory tables | Not replicated to client as attributes |
| Objective / Last Action UI | Client | Not saved |

---

## Current zones

| Zone | Detection | Actions available |
|------|-----------|-------------------|
| **Home** | Tag `JonesZone_Home` or Part `Zone_Home` | Rest |
| **Market** | Tag `JonesZone_Market` or Part `Zone_Market` | Buy Food |
| **Industrial** | Tag `JonesZone_Industrial` or Part `Zone_Industrial` | Warehouse Shift, Cleanup Shift |
| **Bank** | Tag `JonesZone_Bank` or Part `Zone_Bank` | Deposit All, Withdraw 25 |
| **None** | Outside all volumes | No zone buttons |

**Not implemented:** Downtown, School, Housing, NPC interaction zones.

Zone setup: [JONES_ZONE_TAGS.md](JONES_ZONE_TAGS.md) · [STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md)

---

## Current actions

All actions use `ReplicatedStorage.JonesPerformAction` (client fires → server validates → client status).

| Remote action | Zone | Hours | Effect (success) | Cooldown |
|---------------|------|-------|------------------|----------|
| `WorkShift` | Industrial | 08:00–18:00 | Warehouse Shift: +Wallet, −20 Energy, −10 Hunger, +10 XP, +1 Rep | 10s (per job) |
| `CleanupShift` | Industrial | 08:00–20:00 | Cleanup Shift: +Wallet, −10 Energy, −5 Hunger, +5 XP, +1 Rep | 6s (per job) |
| `BuyFood` | Market | 07:00–22:00 | −15 Wallet, +25 Energy, +35 Hunger | 3s |
| `Rest` | Home | Anytime | +30 Energy (cap 100) | 10s |
| `DepositAll` | Bank | Anytime | All Wallet → Bank | — |
| `Withdraw25` | Bank | Anytime | 25 Bank → Wallet (need ≥25 bank) | — |

**Warehouse pay (level 1):** 25 · **Cleanup pay (level 1):** 15 · Scales with Job Level.

**Complete message examples:**

- `Warehouse Shift complete! +25 Wallet, -20 Energy, -10 Hunger, +10 XP.`
- `Cleanup Shift complete! +15 Wallet, -10 Energy, -5 Hunger, +5 XP.`

Details: [JONES_JOBS.md](JONES_JOBS.md)

**Daily bill (automatic at midnight):** Charge **30** (bank first, then wallet). Paid message: `Daily bill paid: 30.` · Missed: zero both balances, Rep −2, `Daily bill missed. Reputation decreased.`

---

## Current DataStore fields

| Setting | Value |
|---------|--------|
| Name | `JonesPlayerData_v1` |
| Key | `player_<UserId>` |
| Autosave | Every 60s + PlayerRemoving + BindToClose |

| Field | Type | Default if missing |
|-------|------|-------------------|
| `Money` | number | 0 |
| `BankBalance` | number | 0 |
| `Energy` | number | 100 |
| `Hunger` | number | 100 |
| `Reputation` | number | 0 |
| `JobXP` | number | 0 |
| `JobLevel` | number | 1 |
| `UpdatedAt` | number | set on save |

**Schema changes since launch:** None — backward-compatible defaults only.

---

## Scripts map (Rojo)

| System | File |
|--------|------|
| Stats scaffold | `JonesPlayerStats.server.lua` |
| Save/load | `JonesDataStoreService.server.lua` |
| Zone detection | `JonesZoneService.server.lua` |
| Actions + jobs | `JonesActionService.server.lua`, `JonesJobs.lua` |
| Time + bill | `JonesTimeService.server.lua`, `JonesDailyBill.lua` |
| HUD | `JonesMoneyUi.client.lua` |
| Bootstrap | `JonesServerInit.server.lua` |

**Replicated values:** `JonesPerformAction`, `JonesDay`, `JonesGameMinutes`, `JonesClockText`, `JonesWorldMessage`

**Workspace:** Not in Rojo — Studio owns map and zone Parts.

---

## Temporary helpers still present

These **server scripts** auto-position existing Studio zone Parts near spawn for Play testing. They are **not** part of the long-term design.

| Script | Target Part |
|--------|-------------|
| `JonesZoneHomePlacement.server.lua` | `Workspace.Zone_Home` |
| `JonesZoneMarketPlacement.server.lua` | `Workspace.Zone_Market` |
| `JonesZoneIndustrialPlacement.server.lua` | `Workspace.Zone_Industrial` |
| `JonesZoneBankPlacement.server.lua` | `Workspace.Zone_Bank` |

**Before real map polish or publish:** Place zone Parts manually in Studio (size, position, anchors) and **remove** these four placement scripts — see [MANUAL_ZONE_STABILIZATION_PLAN.md](MANUAL_ZONE_STABILIZATION_PLAN.md).

---

## Known limitations

| Area | Limitation |
|------|------------|
| **Map** | No Downtown, School, housing, or NPCs |
| **Persistence** | Day/clock, zone, cooldowns, objectives not saved |
| **Multiplayer** | Shared lane; no per-player housing or instancing |
| **Economy** | No world inflation tick, stocks, credit, or business |
| **UI** | Single HUD panel — no dedicated bank/career screens |
| **Studio Play** | DataStore may behave differently than a live published server |
| **Zones** | Requires Studio Parts; placement helpers are test-only |
| **Monetization** | None (by design) |
| **Combat / vehicles / trading** | Out of scope |

---

## Exact play test checklist

Run after `rojo serve` → Studio **Sync** → **Play**. Enable **Studio Access to API Services** for save tests.

### Setup

- [ ] Zone Parts exist (`Zone_Home`, `Zone_Market`, `Zone_Industrial`, `Zone_Bank`) or tagged equivalents
- [ ] HUD shows **Day 1 · 08:00**, Wallet, Bank, Energy, Hunger, Reputation, Job Level, Job XP
- [ ] Walking into each zone updates **Current Zone**

### Core loop (~5 min)

- [ ] **Industrial** → **Start Warehouse Shift** → Wallet +25, Energy −20, Hunger −10, Last Action shows complete message
- [ ] **Industrial** → **Start Cleanup Shift** → Wallet +15, lower costs, +5 XP in message
- [ ] Spam Cleanup during cooldown → button **(Cooldown)**; server rejects
- [ ] Within 6s, Warehouse shift still works (independent cooldowns)
- [ ] **Market** → **Buy Food** → Wallet −15, Energy/Hunger up
- [ ] **Home** → **Rest** → Energy +30
- [ ] **Bank** → **Deposit All** → Wallet 0, Bank increased
- [ ] **Bank** → **Withdraw 25** → Wallet +25, Bank −25

### Hunger gate

- [ ] Work until Hunger **< 20** → shift fails: `Too hungry to work (need 20 Hunger).`
- [ ] Objective prioritizes **Buy food at Market**

### Time gates

- [ ] At **08:00** both jobs open; Market open from **07:00**
- [ ] After **18:10** → Warehouse **(Closed)**; Cleanup until **20:00**
- [ ] After **22:10** → Buy Food closed; Rest still works

### Job progression

- [ ] Five Warehouse shifts (with food as needed) → **Job Level 2**, world message `Job level up! Level 2.`
- [ ] Sixth Warehouse shift pays **+30** Wallet at level 2

### Daily bill (optional — long wait or local `TEST_FAST_DAY`)

- [ ] With Bank ≥ 30, midnight → `Daily bill paid: 30.`
- [ ] With Wallet + Bank **< 30**, midnight → balances zero, Rep −2, missed message

### Save/load

- [ ] **Stop** → **Play** → Wallet, Bank, Energy, Hunger, Rep, Job XP/Level restored
- [ ] Day/clock resets to **Day 1 · 08:00** (expected)

---

## Publish checklist

### Studio place

- [ ] Map lane playable on foot; spawn not inside walls
- [ ] Zone Parts **manually placed** and sized (helpers removed or disabled)
- [ ] Zone tags or `Zone_*` names verified in Play
- [ ] Lighting and spawn set for readable top-down / lane camera (your choice)

### Game settings

- [ ] **Security → Studio Access to API Services** enabled for Studio testing
- [ ] For published game: DataStore enabled (Roblox handles on publish; test on live server)
- [ ] Appropriate **genre / description** — life sim, not combat
- [ ] No monetization products until approved later

### Code / Rojo

- [ ] `rojo build` succeeds
- [ ] `TEST_FAST_DAY = false` in `JonesTimeService.server.lua` (repo default)
- [ ] No secrets in repo
- [ ] `default.project.json` does **not** include Workspace

### Pre-publish smoke test (published place)

- [ ] Join live server (not Studio-only)
- [ ] Full play test checklist above on live DataStore
- [ ] Two players: zones and actions work independently
- [ ] No errors in server log on join / leave / save

### Post-publish monitoring

- [ ] Watch DataStore errors in Analytics / logs
- [ ] Confirm autosave on leave (no stat rollback every session)

---

## Phase 2 progress at this checkpoint

| Step | Status |
|------|--------|
| 1–13 | ✅ DataStore through publish readiness checkpoint |
| **14** | ✅ Manual zone stabilization **plan** ([MANUAL_ZONE_STABILIZATION_PLAN.md](MANUAL_ZONE_STABILIZATION_PLAN.md)) |
| 15+ | Pending — execute plan in Studio, then new gameplay |

---

## Recommended next feature after checkpoint

**Phase 2 Step 15 — Execute manual zone stabilization in Studio**

1. Follow [MANUAL_ZONE_STABILIZATION_PLAN.md](MANUAL_ZONE_STABILIZATION_PLAN.md) — place `Zone_Industrial`, `Zone_Home`, `Zone_Market`, `Zone_Bank` manually.
2. Run the verification checklist (zone detection, actions, save/load, daily bill).
3. Delete the four `JonesZone*Placement.server.lua` scripts from the repo and Sync.

**After Step 15:** Phase 2 Step 16 — Downtown + School zone stubs.

---

## Quick reference — what is NOT in MVP

- Downtown / School gameplay (stubs only next)
- NPCs / dialog
- Housing / rent beyond daily bill
- Inventory, vehicles, combat, trading, monetization
- Quest persistence
- Workspace in Rojo
