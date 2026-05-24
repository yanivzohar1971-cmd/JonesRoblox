# Jones In The Lane — Job definitions

Server-side job board data for zone work actions. Definitions live in `src/ServerScriptService/JonesJobs.lua`.

---

## Overview

- Jobs are **data-driven** tables validated and applied on the **server** in `JonesActionService.server.lua`.
- The Industrial zone job board lists **two** jobs: **Warehouse Shift** and **Cleanup Shift**.
- **`WorkShift`** remote action maps to Warehouse Shift (backward compatible).
- **`CleanupShift`** remote action runs Cleanup Shift.

---

## JobDefinition fields

| Field | Purpose |
|-------|---------|
| `Id` | Stable key (e.g. `WarehouseShift`) |
| `DisplayName` | HUD / messages (e.g. `Warehouse Shift`) |
| `Zone` | Required zone (`Industrial`) |
| `BasePay` | Wallet reward at Job Level 1 |
| `EnergyCost` | Energy spent per shift |
| `HungerCost` | Hunger spent per shift |
| `ReputationReward` | Reputation gained |
| `XPReward` | Job XP gained |
| `CooldownSeconds` | Cooldown between starts **for that job** |
| `OpenMinutes` | Open time (minutes from midnight) |
| `CloseMinutes` | Close time (minutes from midnight) |

---

## Cooldowns

Cooldowns are **per job id** (independent). Starting Warehouse Shift does not block Cleanup Shift, and vice versa.

**Server:** On successful job start, sets player attribute `JonesCooldown_<jobId>` to `workspace:GetServerTimeNow() + CooldownSeconds`. Not saved to DataStore.

**Client hint:** Job buttons may show **(Cooldown)** while the attribute indicates time remaining. Server still validates and rejects early retries (`<DisplayName> on cooldown.`).

| Job | Attribute | Cooldown |
|-----|-----------|----------|
| Warehouse Shift | `JonesCooldown_WarehouseShift` | 10s |
| Cleanup Shift | `JonesCooldown_CleanupShift` | 6s |

---

## Complete messages

On success, the server sends a single line via `JonesPerformAction` (shown on HUD **Last Action**):

```
Warehouse Shift complete! +25 Wallet, -20 Energy, -10 Hunger, +10 XP.
Cleanup Shift complete! +15 Wallet, -10 Energy, -5 Hunger, +5 XP.
```

Pay in the message uses scaled pay (`BasePay + (JobLevel - 1) × 5`). Reputation is applied but not listed in the message (keeps the line short).

---

## HUD hints (client display only)

Pay/cost hints are **display-only** on the job board. Server applies values from job definitions.

| Job | Hint format | Example (Level 1) |
|-----|-------------|-------------------|
| Warehouse | `Warehouse: +pay / -EnergyE / -HungerH` | `Warehouse: +25 / -20E / -10H` |
| Cleanup | `Cleanup: +pay / -EnergyE / -HungerH` | `Cleanup: +15 / -10E / -5H` |

Helpers in `JonesJobs.lua`: `getCompleteMessage()`, `getHintText()`, `getCooldownAttributeName()`.

---

## Shared progression constants

Defined in `JonesJobs.lua` (not per-job yet):

| Constant | Value |
|----------|--------|
| `XP_PER_LEVEL` | 50 |
| `PAY_PER_LEVEL` | +5 Wallet per level above 1 |
| `MIN_HUNGER_TO_WORK` | 20 |

Pay formula: **`BasePay + (JobLevel - 1) × PAY_PER_LEVEL`**

Job Level / XP are shared across all Industrial jobs.

---

## Warehouse Shift

| Field | Value |
|-------|--------|
| Id | `WarehouseShift` |
| Action | `WorkShift` (compat) |
| DisplayName | `Warehouse Shift` |
| Zone | `Industrial` |
| BasePay | 25 |
| EnergyCost | 20 |
| HungerCost | 10 |
| ReputationReward | 1 |
| XPReward | 10 |
| CooldownSeconds | 10 |
| Hours | 08:00–18:00 |

---

## Cleanup Shift

| Field | Value |
|-------|--------|
| Id | `CleanupShift` |
| Action | `CleanupShift` |
| DisplayName | `Cleanup Shift` |
| Zone | `Industrial` |
| BasePay | 15 |
| EnergyCost | 10 |
| HungerCost | 5 |
| ReputationReward | 1 |
| XPReward | 5 |
| CooldownSeconds | 6 |
| Hours | 08:00–20:00 |

---

## Adding a job

1. Add a new entry to `jobsById` in `JonesJobs.lua`.
2. Wire a server action in `JonesActionService.server.lua` (or reuse job id as action name).
3. Update HUD job board buttons and **display-only** pay/cost hint labels for that zone.
4. Server owns all pay/energy values — client hints must mirror `JonesJobs.getHintText()` constants only.

---

## Related files

| File | Role |
|------|------|
| `JonesJobs.lua` | Job definitions + helpers |
| `JonesActionService.server.lua` | Runs jobs via `performJob()` |
| `JonesMoneyUi.client.lua` | Job board, hints, Last Action, cooldown button hint |
