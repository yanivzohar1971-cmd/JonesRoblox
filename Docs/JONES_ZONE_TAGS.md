# Jones Zone Tags

Studio-owned zone volumes for **Jones In The Lane**. Rojo does **not** create or sync these parts — build them manually in Roblox Studio.

See also: [JONES_ROBLOX_ADAPTATION.md](JONES_ROBLOX_ADAPTATION.md) · [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md)

---

## How zone detection works

1. You create **Part** volumes in **Workspace** in Studio.
2. Each zone Part gets a **CollectionService tag** (see table below).
3. `JonesZoneService.server.lua` polls player positions on the server.
4. If a player's `HumanoidRootPart` is inside a tagged Part's bounds, `leaderstats.CurrentZone` updates.
5. The HUD shows `Current Zone: Home` (etc.).

Default when outside all zones: **`None`**.

---

## Supported zone tags

| CollectionService tag | HUD display | Typical use |
|-----------------------|-------------|-------------|
| `JonesZone_Home` | Home | Rest, sleep (future) |
| `JonesZone_Market` | Market | Buy food, browse items (future) |
| `JonesZone_Industrial` | Industrial | Work shifts (future) |

**Tag spelling must be exact** (case-sensitive).

One Part should have **one** Jones zone tag. If a player is inside overlapping zones, the **smallest volume** wins (most specific zone).

---

## Create a zone Part in Studio

1. Open your Jones place in **Roblox Studio**.
2. In **Workspace**, insert a **Part** (`HomePlate` or `Part`).
3. Rename it clearly (e.g. `Zone_Home`, `Zone_Market`).
4. **Resize and position** so it covers the walkable area for that zone.
5. Set recommended properties:

| Property | Value | Why |
|----------|-------|-----|
| **Anchored** | `true` | Zone stays fixed |
| **CanCollide** | `false` | Players walk through it |
| **Transparency** | `1` | Invisible in Play mode |
| **Size** | Large enough to cover the area | Detection uses Part bounds |

6. Open **View → Tag Editor**.
7. Select the Part → **Add tag** → enter the exact tag (e.g. `JonesZone_Home`).
8. Repeat for Market and Industrial when ready.

---

## Example layout (small lane)

```
Workspace
├── Map (your buildings/terrain — Studio built)
├── Zone_Home          [tag: JonesZone_Home]
├── Zone_Market        [tag: JonesZone_Market]
└── Zone_Industrial    [tag: JonesZone_Industrial]
```

Zones can overlap slightly at boundaries; smallest zone volume takes priority.

---

## Testing checklist

1. `rojo serve` → Sync in Studio.
2. Create at least one zone Part with tag `JonesZone_Home`.
3. Press **Play**.
4. Stand **outside** the zone → HUD: `Current Zone: None`.
5. Walk **inside** the zone Part bounds → HUD: `Current Zone: Home`.
6. Walk out again → back to `None`.
7. In Explorer: `Players → YourName → leaderstats → CurrentZone` matches the HUD.

---

## What not to do

- Do **not** add Workspace to `default.project.json`.
- Do **not** spawn zone Parts from Rojo scripts.
- Do **not** use `JonesCoin` tags (retired prototype — safe to delete any leftover Parts in Studio).
- Do **not** expect zone actions yet — detection only until Phase 1 Step 4.

---

## Future zones (not implemented yet)

When the lane grows, add tags following the same pattern:

- `JonesZone_Downtown`
- `JonesZone_School`

These require a code update in `JonesZoneService.server.lua` before they will be detected.
