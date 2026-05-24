# Jones In The Lane — Master Summary

> **Source of truth:** `Docs/jones_game_idea_pack/` (read before designing or coding gameplay).

This document distills the full Jones vision from the idea pack into a single planning reference for the Roblox port and all future development.

---

## Core game fantasy

**Jones In The Lane** is a **life simulation inside a city lane**. The player is not grinding abstract coins — they are building a life through **work, housing, education, relationships, banking, risk, reputation, business, inventory, health, and events**.

The fantasy is: *start as a simple citizen in a small urban lane and grow into an advanced city actor* — someone who manages money responsibly, improves skills, finds housing, handles social pressure, and reacts to an economy that does not stand still.

**Tone and style (original web vision):**

- 2D top-down lane / city feeling (GTA2-inspired map readability)
- Systems depth inspired by RimWorld and The Sims (needs, schedules, consequences)
- Management panels inspired by tycoon / life-sim UIs (clear actions, readable state)
- **Not** a generic idle coin collector or abstract power multiplier simulator

---

## Main gameplay loop

The canonical loop from the idea pack:

1. **Move** around the map (lane / zones)
2. **Enter zones** (Home, Downtown, Market, School, Industrial)
3. **Choose actions** contextually per zone
4. **Earn money / lose energy / gain reputation** (and other stat changes)
5. **Unlock** education, jobs, housing, business over time
6. **React** to life events and economy changes
7. **Progress** from simple citizen → capable city actor

**First actions (vertical slice targets):**

| Action        | Typical zone   |
|---------------|----------------|
| Rest          | Home           |
| Browse items  | Market         |
| Buy food      | Market         |
| Enroll course | School         |
| Search jobs   | Downtown       |
| Visit bank    | Downtown       |
| Work shift    | Industrial     |

The loop is **location-driven**: where you are determines what you can do.

---

## Economy systems

From modules `economy`, `bank`, `credit`, `stocks`, `business`, `production`:

| System | Role |
|--------|------|
| **Player money** | Cash on hand for daily actions (food, rent, courses) |
| **Bank** | Deposits, withdrawals, transfers, financial state |
| **World economy** | Ticks, inflation, market state (server/world authority) |
| **Credit** | Credit score, loans, repayment |
| **Business** | Player-owned business flow |
| **Stocks** | Market investments (late-game depth) |
| **Production** | Stability gates, production-ready checks |

Economy is **consequential**: spending, risk, and world ticks matter — not infinite linear scaling from touch pickups.

---

## Housing systems

From modules `housing`, `housingMarket`:

| System | Role |
|--------|------|
| **Housing** | Rent, apartments, moving between homes |
| **Housing market** | Pricing, availability, demand |

Housing ties to **money, reputation, and life stage** — a core progression pillar, not a cosmetic shop item.

---

## Jobs / tasks

From modules `career`, `education`, `production`:

| System | Role |
|--------|------|
| **Career** | Jobs, shifts, promotions |
| **Education** | Courses, skill progress, credentials |
| **Production** | Operational gates for live features |

Work is **shift-based and zone-bound** (e.g. Industrial zone → work shift), not passive collection.

---

## Social / NPC systems

From modules `social`, `npcs`, `messaging`:

| System | Role |
|--------|------|
| **NPCs** | Citizens, roles, schedules, behaviors |
| **Social** | Relationships and social actions |
| **Messaging** | NPC / player communication |

The web prototype already targets **~10 NPCs with idle movement** and zone-aware interaction — social density without full MMO complexity.

---

## Reputation / progression

From modules `reputation`, `health`, `risk`, `events`:

| Stat / system | Role |
|---------------|------|
| **Reputation** | Social and city standing |
| **Health / energy** | Condition, recovery, action costs |
| **Risk** | Negative events, financial risk, safety |
| **Events** | Life events, choices, outcomes |

Progression is **multi-axis**: money alone does not define success. Energy and reputation appear in the interaction layer HUD on web.

---

## Multiplayer direction

The idea pack describes a **web-first single-player simulation** with Firestore-backed world state. For Roblox:

- **Natural fit:** multiple players in the same lane, shared zones, visible NPCs, optional co-presence
- **Authority model:** server validates actions, economy, and inventory changes
- **Not in early MVP:** trading, PvP, combat, vehicles, large open-world sync

Multiplayer should enhance **shared city life**, not turn Jones into a battle royale or driving game.

---

## UI / UX direction

Web stack: **React panels + Canvas map** (read-only renderer; GameEngine owns simulation).

UX principles:

- **Zone interaction panel** — changes based on player location
- **Player HUD** — money, energy, reputation at a glance
- **Feature panels** — Bank, Inventory, Jobs, Education (vertical slice)
- **Debug / status** — simulation day, tick index (dev-facing)

Roblox adaptation: **ScreenGui / client UI for display** + **RemoteEvents/Functions for requests**; server applies all outcomes.

---

## Long-term systems

From `MODULES.md` and `ROADMAP.md` Phase 8–10:

| Module | Long-term purpose |
|--------|-------------------|
| admin | Live ops, release waves |
| economy | World ticks, inflation |
| housingMarket | Dynamic rent/pricing |
| business | Ownership and operations |
| stocks | Investments |
| credit | Loans and repayment |
| events | Branching life events |
| risk | Consequences and safety |
| system | Diagnostics, world overview |

**Backend (web):** Firebase Hosting, Firestore, Cloud Functions — **not ported to Roblox**; Roblox uses DataStores / MemoryStore / server scripts instead.

---

## Features intentionally future scope

Do **not** treat these as current Roblox MVP targets:

| Feature | Notes |
|---------|--------|
| Full 20-module parity | Phased delivery over years |
| Stocks & advanced credit | Phase 8+ depth |
| Full housing market simulation | After basic rent/move |
| Business ownership tycoon layer | Mid/late game |
| Firebase / web hosting stack | Web-only; separate repo |
| 100×100 tile Canvas renderer | Web-only tech |
| Mobile PWA | Web Phase 9 |
| Admin live ops / release waves | Production Phase 10 |
| Vehicles | Explicitly out of scope for now |
| Combat | Explicitly out of scope for now |
| Monetization (DevProducts, passes) | Not until core loop is fun |
| Massive 3D open world | Small lane first |
| Generic coin + power multiplier loop | **Not Jones** — prototype only |

---

## Idea pack file index

| File | Contents |
|------|----------|
| `jones_game_idea_pack/README.md` | Package overview |
| `jones_game_idea_pack/docs/GAME_CONCEPT.md` | Fantasy, loop, zones, first actions |
| `jones_game_idea_pack/docs/ARCHITECTURE.md` | Web/Firebase stack |
| `jones_game_idea_pack/docs/MODULES.md` | 20 feature modules |
| `jones_game_idea_pack/docs/ROADMAP.md` | Phases 1–10 |
| `jones_game_idea_pack/docs/CURRENT_PROGRESS.md` | Web prototype status |
| `jones_game_idea_pack/docs/CURSOR_MASTER_PROMPT.md` | Web dev workflow rules |
| `jones_game_idea_pack/docs/FIREBASE_SETUP.md` | Firebase project config |

---

## One-line north star

**Move through the lane → enter a zone → take a meaningful life action → manage money, energy, and reputation → unlock deeper systems over time.**

Anything that does not serve that sentence is probably generic simulator noise.
