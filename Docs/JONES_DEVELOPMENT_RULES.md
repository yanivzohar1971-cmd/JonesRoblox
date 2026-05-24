# Jones In The Lane — Development Rules (Roblox)

Mandatory rules for all contributors and AI agents working on this repo.

---

## 1. Read spec docs before coding

Before writing or changing gameplay code, read:

1. `Docs/JONES_MASTER_SUMMARY.md`
2. `Docs/JONES_ROBLOX_ADAPTATION.md`
3. `Docs/jones_game_idea_pack/docs/GAME_CONCEPT.md`
4. Relevant module notes in `Docs/jones_game_idea_pack/docs/MODULES.md`

If a change is not justified by the spec, do not implement it.

---

## 2. No generic simulator systems unless mapped to Jones

**Forbidden patterns** (unless explicitly approved and mapped in adaptation doc):

- Touch coins with escalating multipliers
- Abstract "power" upgrades that only increase pickup rates
- Idle clicker loops with no zone or life context
- Grind-for-number mechanics with no energy / reputation / risk tradeoff

**Allowed patterns:**

- Zone-bound actions (work shift, rest, buy food)
- Server-validated economy changes
- Cooldowns, energy costs, reputation gates

When in doubt, ask: *"Would this fit RimWorld / Sims / lane life-sim?"* If not, skip it.

---

## 3. Keep systems modular

- One concern per ModuleScript or service script
- Name with `Jones` prefix for game-specific code (e.g. `JonesCareer`, `JonesZones`)
- Shared config in `ReplicatedStorage/Config` (when introduced)
- Avoid monolithic "GameManager" that knows everything

Target module alignment (long-term): career, health, housing, economy, zones — add only when needed.

---

## 4. Prefer server authority

- Clients **request** actions; servers **decide** outcomes
- Never accept client-sent money amounts, damage, or rewards
- Replicate state via `leaderstats`, attributes, or Value objects
- Validate zone presence on server before applying action effects

---

## 5. Avoid premature complexity

- No DataStore until Phase 1 loop works in Play mode
- No 20 modules at once — vertical slice first
- No abstraction layers without two real use cases
- Prefer boring, readable Lua over clever metatables

---

## 6. No massive map yet

- Build a **small lane** in Studio: Home, Market, Industrial (+ Downtown/School later)
- Do not procedural-generate a city
- Do not add Workspace to Rojo `default.project.json`

---

## 7. No monetization yet

- No Developer Products
- No Game Passes
- No paid currency
- Fun core loop first

---

## 8. No vehicles yet

- Walking / default Roblox character only
- No car systems, mounts, or drive scripts

---

## 9. No combat yet

- No weapons, damage, PvP, or enemy AI
- Risk module (future) is economic/social, not shooters

---

## 10. Rojo vs Studio ownership

| Owns | What |
|------|------|
| **Rojo** | Scripts, remotes, modules, UI logic |
| **Studio** | Map, terrain, models, zone parts, spawn, lighting |

Never sync Workspace through Rojo unless the team explicitly changes this rule in writing.

---

## 11. Prototype code retired

The generic coin/CollectPower/upgrade prototype was removed after Phase 1. Do not reintroduce touch-coin or power-multiplier mechanics.

---

## 12. Documentation updates

After each milestone:

- Update `Docs/JONES_ROBLOX_ADAPTATION.md` phase checkboxes if scope shifts
- Update root `README.md` only for player-facing run/test changes
- Do not duplicate the full spec — link to `Docs/`

---

## 13. Commit discipline

- Small, focused changes
- One feature or doc set per commit when possible
- No secrets in repo (Firebase keys stay in web repo `.env`, not here)

---

## Quick checklist before opening a PR

- [ ] Read spec docs
- [ ] Change maps to a Jones zone/action/economy concept
- [ ] Server validates outcomes
- [ ] No new coin/multiplier mechanics
- [ ] Workspace untouched by Rojo
- [ ] No vehicles / combat / monetization
- [ ] Docs updated if behavior or architecture changed
