# Studio Zone Setup — Click by Click

> **For beginners.** Create invisible zone boxes in Roblox Studio so **Work Shift** and **Rest** buttons appear.  
> Rojo does **not** create these — you build them in Studio.

**Related:** [JONES_ZONE_TAGS.md](JONES_ZONE_TAGS.md) (technical reference)

---

## What you are building

Two invisible boxes (Parts) in your map:

| Part name (exact for fallback) | Tag (optional, preferred) | HUD shows | Button appears |
|----------------------------------|---------------------------|-----------|----------------|
| `Zone_Industrial` | `JonesZone_Industrial` | `Current Zone: Industrial` | **Work Shift** |
| `Zone_Home` | `JonesZone_Home` | `Current Zone: Home` | **Rest** |

**Industrial at spawn (temporary):** A Rojo script may move `Zone_Industrial` to your spawn for testing. **Home is never auto-placed** — you put `Zone_Home` around an existing house in the map.

**Name fallback:** If Tag Editor does not work, rename the Part to `Zone_Industrial` or `Zone_Home` — no tag required.

While learning, set **Transparency = 0.5** so you can *see* the box. Later you can set it to **1** (invisible).

---

## Before you start in Studio

1. Open **Roblox Studio** with your place **Jones In The Lane**.
2. In a terminal (Cursor or PowerShell):

   ```powershell
   cd C:\Users\Yaniv\source\repos\JonesRoblox
   rojo serve
   ```

3. In Studio: **Rojo plugin** → **Connect** → address `localhost:34872` → **Sync**.
4. Leave **Edit** mode (do **not** press Play yet).

---

## Part 1 — Create the Industrial zone

### Step 1: Insert a Part

1. Look at the **top ribbon** (menu bar).
2. Click the **Home** tab (if not already selected).
3. Click **Part** (small dropdown arrow next to it).
4. Choose **Block** (a normal cube).

A gray cube appears in the world and is selected (blue outline).

### Step 2: Rename it

1. Open **Explorer** (usually right side). If missing: **View** → **Explorer**.
2. Find **Workspace** → click the small arrow to expand.
3. Click the new part (named `Part`).
4. Press **F2** (or slow double-click the name).
5. Type: `Zone_Industrial` → **Enter**.

### Step 3: Move the Part

**Easiest method — Move tool:**

1. Click the **Move** tool in the toolbar (four-way arrow icon), or press **Ctrl + 2**.
2. Drag the **colored arrows** on the Part to position it where you want the Industrial area.
3. Tip: place it on the ground where your character will stand for “work”.

**Alternative — Properties panel:**

1. With the Part selected, open **Properties** (**View** → **Properties** if hidden).
2. Find **Position** → change X, Y, Z numbers.

### Step 4: Resize the Part

1. Click the **Scale** tool (cube with arrows), or press **Ctrl + 3**.
2. Drag the **small balls** on the Part to make it **big enough to stand inside**.
3. Recommended minimum feel: about **20 × 10 × 20** studs (Width × Height × Depth). Bigger is safer while learning.

The player’s **feet/torso** must be **inside** the box when standing in the zone.

### Step 5: Set properties (Industrial)

With `Zone_Industrial` selected, in **Properties**:

| Property | Value | How |
|----------|-------|-----|
| **Anchored** | ✅ checked (true) | Click the checkbox so it is **on** |
| **CanCollide** | ☐ unchecked (false) | Click so it is **off** — you walk through it |
| **Transparency** | `0.5` | Type `0.5` while testing (semi-visible) |

Leave other properties as default.

### Step 6: Add tag `JonesZone_Industrial` (optional)

> **Tags not working?** Skip this step. If the Part is already named `Zone_Industrial`, zones will still work via name fallback.

1. Menu **View** → **Tag Editor** (opens a panel).
2. In **Explorer**, click `Zone_Industrial` to select it.
3. In **Tag Editor**, click **+** or **Add tag**.
4. Type exactly: `JonesZone_Industrial`  
   - Capital **J**, **Z**, **I**  
   - Underscores `_` not spaces  
   - No extra spaces before/after
5. Press **Enter**.

You should see `JonesZone_Industrial` listed on that Part.

**Fallback:** If tags fail, ensure the Part name is exactly **`Zone_Industrial`** — that alone is enough.

---

## Part 2 — Create the Home zone (around an existing house)

> **Do not put Home at spawn.** Use a **house or building already in your map** as Home. Walk there in the game world — that is where `Zone_Home` belongs.

### Step 1: Find your house in the map

1. Stay in **Edit** mode (not Play).
2. In the **3D viewport**, **scroll/zoom** and look around the map for a house or building.
3. Use **Explorer** → **Workspace** → expand folders/models to find building names (e.g. `House`, `Home`, `Building`).
4. Click building parts in Explorer or in the viewport until you can see the structure in the world.
5. Remember where the **door / front yard / walkable area** is — the zone box should cover where the player stands **inside or at** the home.

**Tip:** Press **F** while selecting a building part to **focus the camera** on it.

### Step 2: Insert a Part for the Home zone

1. **Home** tab → **Part** → **Block**.
2. A new cube appears. In **Explorer**, rename it to exactly: **`Zone_Home`** (F2).

### Step 3: Move the Part over the house area

1. Select **`Zone_Home`**.
2. **Move** tool (**Ctrl + 2**) → drag the Part so it sits **over the house walkable area** (yard, doorway, interior floor — not at spawn).
3. The box center should be roughly over where you want “Home” to feel — cover the space where the player will stand to **Rest**.

### Step 4: Scale the Part to cover the home area

1. **Scale** tool (**Ctrl + 3**).
2. Make the box **large enough** to walk around inside or on the porch:
   - Suggested starting size: about **30 × 15 × 30** studs or bigger for a whole house footprint.
   - Include walls, yard, or rooms you want counted as “Home”.
3. The character’s **torso/feet** must be **inside** the box when standing at home.

### Step 5: Set properties (Home)

With `Zone_Home` selected, in **Properties**:

| Property | Value |
|----------|-------|
| **Anchored** | ✅ true |
| **CanCollide** | ☐ false |
| **Transparency** | `0.5` (see the box while testing) |

### Step 6: Add tag `JonesZone_Home` (optional)

> **Tags not working?** Skip this. Name **`Zone_Home`** alone is enough.

1. **View** → **Tag Editor**.
2. Select `Zone_Home` → **Add tag** → `JonesZone_Home` → Enter.

### Step 7: Save

**File** → **Save to Roblox** so the Home zone stays in your place.

You should now have:
- **`Zone_Industrial`** — often at/near spawn (temporary helper may position it for testing).
- **`Zone_Home`** — around your **existing house**, away from spawn.

---

## Part 3 — Save (optional but recommended)

1. **File** → **Save to Roblox** (or **Save** if local copy).  
   This saves the zone Parts in your place — they are **not** in the Rojo folder.

---

## Part 4 — Test in Play mode

### Setup

1. Confirm `rojo serve` is still running in the terminal.
2. In Studio Rojo plugin: **Connect** → **Sync** (sync again after any script changes).
3. Click the big green **Play** button (top center), or press **F5**.

### Test Industrial + Work Shift

1. Move your character **into** the `Zone_Industrial` box (walk with WASD or click to move).
2. Look at the **HUD** (top-left):
   - Should change from `Current Zone: None` → **`Current Zone: Industrial`**
3. A blue **Work Shift** button should appear.
4. Click **Work Shift**.
5. You should see a status message like:  
   `Work shift complete! +25 Money, -20 Energy, +1 Reputation.`
6. Confirm **Money**, **Energy**, and **Reputation** updated on the HUD.

### Test Home + Rest (at your house — not spawn)

1. **Stop** Play if still running from Industrial test.
2. Press **Play** again.
3. **Walk from spawn to your house** (WASD or click-to-move).
4. Enter the semi-visible **`Zone_Home`** box around the building.
5. HUD: **`Current Zone: Home`**
6. Green **Rest** button appears.
7. Click **Rest**.
8. Status: `Rest complete! +30 Energy.`
9. **Energy** should go up (max 100).

If you never leave Industrial at spawn, do Work Shift first (−20 Energy), then walk to the house to Rest (+30 Energy).

### Test leaving a zone

1. Walk **out** of both boxes.
2. HUD should show **`Current Zone: None`**
3. **Work Shift** and **Rest** buttons should **hide**.

### Stop Play

Click **Stop** (red square) or press **Shift + F5**.

---

## Quick checklist

- [ ] `rojo serve` running  
- [ ] Rojo **Sync** done  
- [ ] `Zone_Industrial` exists under Workspace (name exact)
- [ ] Tag `JonesZone_Industrial` on that Part *(optional if name fallback used)*
- [ ] `Zone_Home` exists under Workspace — **around an existing house**, not at spawn
- [ ] Tag `JonesZone_Home` on that Part *(optional if name fallback used)*
- [ ] Both Parts: Anchored ✅, CanCollide ❌, big enough to stand inside  
- [ ] Play → walk in → zone name changes → buttons appear  

---

## Troubleshooting

### HUD works but `Current Zone` stays `None`

| Cause | Fix |
|-------|-----|
| **Part name wrong** | Must be exactly `Zone_Industrial` or `Zone_Home` (name fallback — no tag needed) |
| Tag not added | Optional — use exact Part name instead, or add tag in Tag Editor |
| Wrong tag spelling | Must be exactly `JonesZone_Home` or `JonesZone_Industrial` if using tags |
| Part too small | Scale bigger — must cover character **feet/body** (HumanoidRootPart) |
| Part too high/low | Move Part so player stands **inside** the volume, not under/over it |
| Part in wrong place | Industrial: spawn/work area. **Home: around house building — not spawn** |
| Forgot **Sync** | Rojo plugin → **Connect** → **Sync**, then Play again |
| Testing in wrong place | Open **Jones In The Lane**, not another experience |

Check **Output** window after Play — you should see lines like:
```
[JonesZoneService] Found named zone fallback: Zone_Industrial -> Industrial
```
If you see nothing, the Part name or size is wrong.

### Tag typo examples (wrong → right)

| Wrong | Right |
|-------|-------|
| `JonesZone_Industrial ` (space) | `JonesZone_Industrial` |
| `joneszone_industrial` | `JonesZone_Industrial` |
| `JonesZone Industrial` | `JonesZone_Industrial` |
| `JonesZone_Home` on Industrial part | Each part gets **one** correct:
 matching tag |

### Part not covering player

- Stand inside the semi-visible box (`Transparency = 0.5`).
- If your head is outside but feet inside, it usually still works — detection uses the character’s **HumanoidRootPart** (near the torso/waist).
- When in doubt: make the box **taller** (increase Size Y).

### Buttons never appear

| Symptom | Fix |
|---------|-----|
| Zone shows `None` | Fix tags/size first (see above) |
| Zone shows `Industrial` but no button | Rojo **Sync** again; confirm scripts synced |
| Zone shows `Market` | Market has no actions yet — use **Industrial** or **Home** |

### Use Transparency 0.5 while testing

- **0.5** = you see the zone box (recommended for setup).
- **1** = invisible in game (use after everything works).

### Rojo not connected

Terminal must show:

```
Rojo server listening:
  Address: localhost
  Port:    34872
```

Studio plugin → **Connect** → `localhost:34872`.

---

## After everything works

1. Select each zone Part → set **Transparency** to `1` (invisible in Play).
2. **File** → **Save to Roblox**.

---

## What NOT to do

- Do **not** add zone Parts in the Rojo `src/` folder — Studio only.
- Do **not** add Workspace to `default.project.json`.
- Do **not** typo the tags — copy-paste from this doc.

---

## One-line summary

**Industrial:** `Zone_Industrial` at work/spawn area. **Home:** find house → insert Part → rename `Zone_Home` → scale over house → Anchored on, CanCollide off → Sync → Play → walk to house → Rest.**
