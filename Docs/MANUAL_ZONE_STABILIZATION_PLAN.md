# Manual Zone Stabilization Plan

> **Phase 2 Step 20** — move from temporary runtime zone helpers to **real Studio-placed zones**.  
> **Scope (this pass):** Documentation and verification support only. **Helper scripts, not removed yet.**

**Related:** [STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md) · [JONES_ZONE_TAGS.md](JONES_ZONE_TAGS.md) · [JONES_CURRENT_STATUS.md](JONES_CURRENT_STATUS.md) · [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md)

---

## Why this plan exists

Four **temporary technical debt** scripts run at server start and auto-create or reposition zone Parts for Play testing:

| Script | Behavior |
|--------|----------|
| `JonesZoneIndustrialPlacement.server.lua` | Moves existing `Workspace.Zone_Industrial` near spawn |
| `JonesZoneHomePlacement.server.lua` | Finds a building near spawn; creates/moves `Zone_Home` |
| `JonesZoneMarketPlacement.server.lua` | Finds market-like structures; creates/moves `Zone_Market` |
| `JonesZoneBankPlacement.server.lua` | Finds bank-like structures; creates/moves `Zone_Bank` |

These scripts **override your map layout every session**. They are acceptable for early Rojo testing but **must not ship** in a polished place.

**Goal:** You place and size all four zone Parts manually in Studio, verify gameplay, then delete the four scripts from `src/ServerScriptService/`.

**Rules for this phase:**

- Do **not** add Workspace to Rojo.
- Do **not** create Parts in code.
- Do **not** add gameplay features, DataStore schema changes, or HUD redesign.
- Do **not** delete helper scripts until you confirm **"Manual zones verified."**
- Existing zone detection by **fallback Part names** must remain: `Zone_Industrial`, `Zone_Home`, `Zone_Market`, `Zone_Bank`.

---

## Safe pre-removal mode (Step 20 — first pass)

**This repo pass does NOT delete helper scripts.**

| Phase | What happens |
|-------|----------------|
| **A — Now (Step 20 docs)** | Follow the Studio checklist below; run verification with helpers still present or temporarily disabled in Studio |
| **B — After you confirm** | Reply **"Manual zones verified."** → then remove the four placement scripts from the repo and Sync |

Until Phase B:

- Helpers remain in `src/ServerScriptService/` as **temporary technical debt**.
- You may **disable** a helper in Studio (uncheck **Enabled** on the script) to test manual positions without deleting repo files.
- Do **not** publish with helpers enabled.

---

## Prerequisites

1. Open your Jones place in **Roblox Studio** (**Edit** mode, not Play).
2. Terminal: `rojo serve` → Studio Rojo plugin → **Connect** → **Sync**.
3. Read [STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md) for Part insert/move basics.

---

## Exact Studio checklist (Edit mode)

Complete **every** zone in **Edit mode** before relying on manual placement. Use **Part name fallback** (exact names below) or optional CollectionService tags.

### Shared Part properties (every zone)

For each zone Part, set in **Properties**:

| Property | Testing value | Release value |
|----------|---------------|---------------|
| **Anchored** | `true` ✅ | `true` ✅ |
| **CanCollide** | `false` ☐ | `false` ☐ |
| **Transparency** | `0.5` (see box while testing) | `1` (invisible) |

**Size rule:** The player’s **HumanoidRootPart** (torso area) must be **inside** the Part bounds when standing in the zone. When in doubt, make the box **bigger and taller**.

### Create / position all four Parts

In **Edit mode**, manually create and position:

| Part name (exact) | Location | Actions when inside |
|-------------------|----------|---------------------|
| **`Zone_Industrial`** | Around work / warehouse / job area | Start Warehouse Shift, Start Cleanup Shift |
| **`Zone_Home`** | Around home / house area | Rest |
| **`Zone_Market`** | Around market / stalls / shop area | Open Food Shop |
| **`Zone_Bank`** | Around bank / office area | Deposit All, Withdraw 25 |

For **each** Part:

1. **Home** tab → **Part** → **Block** (or reuse an existing Part and rename).
2. Rename to the exact name above (Explorer → F2).
3. **Move** and **Scale** so the walkable area is fully inside the box.
4. Set **Anchored = true**, **CanCollide = false**, **Transparency = 0.5** while testing.
5. Optional tag (preferred if Tag Editor works): `JonesZone_Industrial`, `JonesZone_Home`, `JonesZone_Market`, `JonesZone_Bank`.

### Save to Roblox

1. **File → Save to Roblox** — zone Parts live in the **place file**, not the Rojo repo.
2. Confirm in **Explorer → Workspace**: exactly **one** Part per zone name (no duplicates).

---

## Per-zone reference

### 1. Zone_Industrial — work area

| Item | Requirement |
|------|-------------|
| **Part name** | Exactly `Zone_Industrial` |
| **Optional tag** | `JonesZone_Industrial` |
| **Suggested size** | Start ~**60 × 20 × 60** studs or larger |

### 2. Zone_Home — house / residence

| Item | Requirement |
|------|-------------|
| **Part name** | Exactly `Zone_Home` |
| **Optional tag** | `JonesZone_Home` |
| **Location** | Around an existing house — **not** necessarily at spawn |
| **Suggested size** | Start ~**40 × 15 × 40** studs or larger |

### 3. Zone_Market — market / stalls / shops

| Item | Requirement |
|------|-------------|
| **Part name** | Exactly `Zone_Market` |
| **Optional tag** | `JonesZone_Market` |
| **Suggested size** | Start ~**50 × 15 × 50** studs or larger |

### 4. Zone_Bank — bank / office

| Item | Requirement |
|------|-------------|
| **Part name** | Exactly `Zone_Bank` |
| **Optional tag** | `JonesZone_Bank` |
| **Suggested size** | Start ~**40 × 15 × 40** studs or larger |

---

## Verification checklist

Run after manual Parts are saved. For a **true** pre-removal test, **disable** the four placement scripts in Studio (or remove them only after Phase B).

### Setup

- [ ] `rojo serve` running; Rojo **Sync** done
- [ ] **Studio Access to API Services** enabled (for save/load test)
- [ ] **Play** starts; HUD shows Day/Clock and stats

### Zone detection and actions

- [ ] Walk into **`Zone_Industrial`** → HUD **Current Zone: Industrial** → **Start Warehouse Shift** and **Start Cleanup Shift** buttons appear
- [ ] Walk into **`Zone_Market`** → **Current Zone: Market** → **Open Food Shop** appears
- [ ] Walk into **`Zone_Home`** → **Current Zone: Home** → **Rest** appears
- [ ] Walk into **`Zone_Bank`** → **Current Zone: Bank** → **Deposit All** and **Withdraw 25** appear
- [ ] Walk outside all zones → **Current Zone: None** → zone action buttons hidden

### Actions work in correct zone

- [ ] **Industrial** → Warehouse Shift succeeds (08:00–18:00)
- [ ] **Industrial** → Cleanup Shift succeeds (08:00–20:00)
- [ ] **Market** → Open Food Shop → buy food (07:00–22:00)
- [ ] **Home** → Rest succeeds
- [ ] **Bank** → Deposit All and Withdraw 25 succeed

### Save/load

- [ ] Work a shift or buy food → change Wallet / Energy / Hunger
- [ ] **Stop** → **Play** → stats restored from DataStore
- [ ] Zone detection still works after rejoin

### After helper removal only (Phase B)

- [ ] No helper placement logs in **Output** on server start (see table below)
- [ ] `[JonesZoneService] Found named zone fallback:` or `Found tagged zone:` lines still appear
- [ ] Play works with **no runtime helper** needed

### Helper log prefixes (must disappear after removal)

| Prefix | Script |
|--------|--------|
| `[JonesZonePlacement]` | Industrial |
| `[JonesZoneHomePlacement]` | Home |
| `[JonesZoneMarketPlacement]` | Market |
| `[JonesZoneBankPlacement]` | Bank |

### Release polish (before publish)

- [ ] All four zone Parts: **Transparency = 1**
- [ ] Four placement scripts **deleted** from repo and Synced
- [ ] **File → Save to Roblox**
- [ ] Full [publish checklist](JONES_CURRENT_STATUS.md#publish-checklist)

---

## Helper removal plan (Phase B — after "Manual zones verified.")

**Only run this after** the verification checklist passes and you confirm **"Manual zones verified."**

### Step 1 — Delete from repo

Remove these files from `src/ServerScriptService/`:

- `JonesZoneIndustrialPlacement.server.lua`
- `JonesZoneHomePlacement.server.lua`
- `JonesZoneMarketPlacement.server.lua`
- `JonesZoneBankPlacement.server.lua`

### Step 2 — Sync and save

1. `rojo serve` → Studio **Sync**.
2. Confirm the four scripts are **gone** from **ServerScriptService** in Explorer.
3. **File → Save to Roblox**.

### Step 3 — Update docs

- Mark Step 20 complete in [JONES_ROBLOX_ADAPTATION.md](JONES_ROBLOX_ADAPTATION.md).
- Update README technical-debt note to **removed**.
- Update [JONES_CURRENT_STATUS.md](JONES_CURRENT_STATUS.md) temporary helpers section.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Zone stays `None` | Check exact Part name; increase size; lower/raise Part so torso is inside |
| Wrong zone name | Overlapping boxes — smallest volume wins; separate zones or resize |
| Buttons wrong zone | Fix `CurrentZone` first; then Rojo **Sync** |
| Helpers keep moving zones | Disable or delete placement scripts; save manual positions in Studio |
| Duplicate `Zone_Home` etc. | Delete extras in Workspace; keep one Part per zone name |
| Tags not working | Name fallback is enough — use exact `Zone_*` names |

---

## Phase tracking

| Step | Status | Deliverable |
|------|--------|-------------|
| **14. Manual zone stabilization plan (initial)** | ✅ Done | First version of this document |
| **20. Manual zones stabilization** | 🔄 **In progress** | Studio placement + verification; helpers **still in repo** until confirmed |
| **20B. Remove placement helpers** | Pending | After **"Manual zones verified."** — delete four scripts |
| **21. Downtown + School stubs** | Pending | After zones are stable |

---

## One-line summary

**In Edit mode, place four anchored non-colliding `Zone_*` Parts in Studio → Save to Roblox → verify HUD and actions → confirm "Manual zones verified." → delete the four `JonesZone*Placement` scripts → confirm no helper logs in Output.**
