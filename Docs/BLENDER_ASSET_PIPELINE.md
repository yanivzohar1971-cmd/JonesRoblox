# Jones Roblox — Blender Asset Pipeline

> **Purpose:** AI-assisted / scripted 3D asset generation for **Jones In The Lane** without touching Rojo gameplay code or Workspace in Git.  
> **Scope:** Local Blender automation only — exports are reviewed manually before Roblox Studio import.  
> **Checkpoint:** Pipeline scripts are in Git; **export binaries are local/generated and gitignored by default.**

**Related:** [DEVELOPMENT_MACHINE_SETUP.md](DEVELOPMENT_MACHINE_SETUP.md) · [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md)

---

## Important safety rule

**Do not use generated assets in the live place before manual review.**

All GLB/FBX/BLEND files under `Assets/Blender/exports/` are **local build output** unless explicitly promoted after review. Never auto-import into Studio or publish without inspection.

---

## Overview

| Layer | Owner |
|-------|--------|
| **Scripts & game logic** | Rojo (`src/`) |
| **Map / Workspace** | Roblox Studio (not in Rojo) |
| **Source 3D assets** | Blender → `Assets/Blender/` |
| **In-game models** | Imported manually in Studio after review |

Generated GLB files are **not** synced through Rojo. Studio owns imported meshes.

---

## Installed Blender (this machine)

| Setting | Value |
|---------|--------|
| **Executable** | `C:\Program Files\Blender Foundation\Blender 5.1\blender.exe` |
| **Version** | Blender 5.1.2 (verified via CLI) |

Override path with environment variable:

```powershell
$env:BLENDER_EXE = "C:\Path\To\blender.exe"
```

---

## Folder layout

```
Assets/Blender/
├── create_test_asset.py    ← test script (low-poly apple → GLB)
├── run-test-export.ps1     ← headless runner (PowerShell)
└── exports/                ← local output (gitignored *.glb / *.fbx / *.blend)
    ├── .gitkeep            ← keeps folder in repo
    └── apple_test.glb      ← TEST ONLY — regenerate locally, not for live place
```

### `apple_test.glb` — test asset only

| Item | Rule |
|------|------|
| **Purpose** | Verify Blender CLI + glTF export works on your machine |
| **Git** | **Ignored** (see `.gitignore`) — regenerate with `run-test-export.ps1` |
| **Studio** | Optional manual import for pipeline testing — **not** a shipped game asset |
| **Live place** | **Do not use** until replaced by a reviewed production asset |

---

## Run Blender from CLI

### Verify install

```powershell
& "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe" --version
```

If `blender` is on PATH:

```powershell
blender --version
```

### Headless test export (from repo root)

```powershell
cd C:\Users\Yaniv\source\repos\JonesRoblox

& "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe" --background --python Assets\Blender\create_test_asset.py
```

Or use the helper script:

```powershell
powershell -ExecutionPolicy Bypass -File Assets\Blender\run-test-export.ps1
```

**Expected output file:**

`Assets\Blender\exports\apple_test.glb`

Console should print:

```
Exported test asset: ...\Assets\Blender\exports\apple_test.glb
```

---

## Test script behavior (`create_test_asset.py`)

1. Clears the default scene
2. Creates a low-poly **apple body** (UV sphere, slightly squashed)
3. Adds a simple **stem** (cylinder)
4. Assigns basic **Principled BSDF** materials (red + green)
5. Exports **GLB** to `Assets/Blender/exports/apple_test.glb`

No gameplay code is modified. Safe to run repeatedly (overwrites the test GLB).

---

## Roblox import checklist (manual only)

Complete **every step** before saving the place. **Do not use generated assets in the live place before manual review.**

- [ ] **Import 3D manually** — Studio → Import 3D → select GLB from `Assets/Blender/exports/` (after local review)
- [ ] **Inspect hierarchy** — expand Model; rename parts clearly (`AppleProp`, not `Mesh.001`)
- [ ] **Confirm no Scripts** — no Script, LocalScript, or ModuleScript under imported model
- [ ] **Check scale** — compare next to avatar; adjust Size/Scale (Blender units ≠ studs)
- [ ] **Check material count** — reasonable for mobile; simplify if Studio created excess SurfaceAppearances
- [ ] **Check triangle count** — keep lane props low-poly (test apple should stay minimal)
- [ ] **Anchored / CanCollide** — set for decorative props (usually Anchored, CanCollide off)
- [ ] **Save to Roblox only after review** — File → Save to Roblox once all checks pass

---

## Import GLB into Roblox Studio (reference steps)

1. Open **Jones In The Lane** in Roblox Studio.
2. In **Explorer**, choose a folder (e.g. `ReplicatedStorage` or a Studio-only `Assets` folder) — **not** Rojo-managed script paths for logic.
3. **Avatar tab → Import 3D** (or **Home → Import 3D**, depending on Studio version).
4. Select `Assets\Blender\exports\apple_test.glb` from disk.
5. Adjust **scale** (Blender units ≠ studs; start ~0.5–2.0 scale in Studio).
6. Set **Anchored** / **CanCollide** as needed for props (food props are usually non-colliding decorations).
7. **Do not** parent unexpected **Scripts** from imports — inspect the model hierarchy.
8. **File → Save to Roblox** after placing the asset.

Roblox supports GLB/glTF import; materials may simplify. Re-texture in Studio if needed.

---

## Manual review required (important)

Before using any generated or AI-assisted asset in the live place:

| Check | Why |
|-------|-----|
| **No hidden Scripts** | Toolbox/import malware pattern |
| **Triangle count** | Keep lane props low-poly for mobile |
| **Scale & origin** | Feet on ground, sensible size next to avatar |
| **Materials** | Studio may differ from Blender preview |
| **Naming** | Clear names (`AppleProp`, not `Mesh.001`) |
| **Collision** | Disable for pure visuals |
| **Game fit** | Matches Jones lane art direction |

**Never** auto-import GLB into published places without opening the file in Studio first.

---

## AI / MCP workflow (next steps)

This repo setup supports:

1. **Cursor + human** — edit `Assets/Blender/*.py` scripts
2. **Headless Blender** — batch export via `--background --python`
3. **Future MCP** — point an MCP server at `BLENDER_EXE` and repo scripts (not configured in this step)

Suggested workflow:

```
Prompt / script change → run run-test-export.ps1 → review GLB → Studio import → play test
```

Gameplay remains in `src/`; assets stay under `Assets/Blender/`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `blender` not recognized | Use full path or set `BLENDER_EXE` |
| Export path missing | Run from repo root; script creates `exports/` |
| GLB empty / errors | Open Blender GUI → run script from Scripting tab for full traceback |
| Studio import fails | Try re-export; check Blender 5.x glTF exporter enabled |
| Wrong scale in game | Rescale in Studio; adjust script units |

---

## Git and exports

| Path | In Git? |
|------|---------|
| `Assets/Blender/*.py`, `run-test-export.ps1` | Yes (when committed) |
| `Assets/Blender/exports/.gitkeep` | Yes |
| `Assets/Blender/exports/*.glb` | **No** — gitignored |
| `Assets/Blender/exports/*.fbx` | **No** — gitignored |
| `Assets/Blender/exports/*.blend` | **No** — gitignored |

Regenerate test output anytime:

```powershell
powershell -ExecutionPolicy Bypass -File Assets\Blender\run-test-export.ps1
```

---

## Safety rules (project)

- **Do not** add Workspace to `default.project.json`
- **Do not** commit unreviewed Toolbox models with scripts
- **Do not** change gameplay remotes/DataStore for asset tests
- **Do** keep exports in `Assets/Blender/exports/` until manually approved for Studio

---

## One-line summary

**Edit Python in `Assets/Blender/` → run headless Blender → collect GLB from `exports/` → manually review → Import 3D in Studio.**
