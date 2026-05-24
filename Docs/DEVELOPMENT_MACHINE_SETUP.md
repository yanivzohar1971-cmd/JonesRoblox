# Jones Roblox — Development Machine Setup (Windows)

> **Purpose:** Install and verify everything needed to develop **Jones In The Lane** safely on a new Windows machine.  
> **Scope:** Local tooling only — no gameplay changes.

**Related:** [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md) · [STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md) · [README.md](../README.md)

---

## Overview

| Layer | Owner |
|-------|--------|
| **Scripts, remotes, UI logic** | Rojo repo (`src/`) |
| **Map, zones, models, lighting** | Roblox Studio (place file) |

This project uses **scripts-only Rojo**. Workspace is **not** in `default.project.json`.

---

## 1. Required tools

Install these before your first Play test.

### Roblox Studio

- **What:** The Roblox place editor and Play-test runtime.
- **Install:** [Create on Roblox](https://create.roblox.com/) → download **Roblox Studio**.
- **Project place:** Open your **Jones In The Lane** experience (the place linked to this repo).
- **Verify:** Studio launches and opens your place without errors.

### Cursor

- **What:** IDE for editing the Rojo repo and running AI-assisted development.
- **Install:** [cursor.com](https://cursor.com/) → download for Windows.
- **Verify:** Open the repo folder (see [Verification flow](#6-verification-flow)).

### Git

- **What:** Version control for the JonesRoblox repo.
- **Install:** [git-scm.com](https://git-scm.com/download/win) or:

  ```powershell
  winget install Git.Git
  ```

- **Verify:**

  ```powershell
  git --version
  ```

  Expected: `git version 2.x.x` (or newer).

### Rojo CLI

- **What:** Syncs `src/` scripts into Studio while you develop.
- **Install (pick one):**

  **Option A — GitHub release (recommended if you do not use Rust):**

  1. Download the latest Windows `.zip` from [Rojo releases](https://github.com/rojo-rbx/rojo/releases).
  2. Extract `rojo.exe` to a folder on your PATH (e.g. `C:\Tools\rojo\`).
  3. Add that folder to **System Environment Variables → Path**.

  **Option B — Rust/cargo (if you already have Rust):**

  ```powershell
  cargo install rojo --version ^7
  ```

- **Verify:**

  ```powershell
  rojo --version
  ```

  Expected: `Rojo 7.x.x` (or compatible 7.x).

### Rojo Studio Plugin

- **What:** Connects Studio to `rojo serve` for live sync.
- **Install:** After Rojo CLI is on PATH:

  ```powershell
  rojo plugin install
  ```

  This installs the official Rojo plugin into Roblox Studio.

- **Verify:** In Studio → **Plugins** tab → **Rojo** appears. Click **Rojo** → you can enter `localhost:34872`.

> **Do not install random Roblox plugins** for this project. The **Rojo** plugin is the only Studio plugin required for day-to-day development.

### Blender

- **What:** 3D modeling for lane assets, buildings, and props (Studio imports `.fbx` / `.obj`).
- **Install:** [blender.org/download](https://www.blender.org/download/) → Windows installer.
- **Optional CLI:** During install, enable **Add Blender to PATH** if offered; otherwise Blender is used as a GUI app only.
- **Verify (if on PATH):**

  ```powershell
  blender --version
  ```

  Expected: `Blender 3.x` or `4.x`. If the command is not found, open Blender from the Start menu — that is fine for this project.

---

## 2. Optional tools (later)

Use only when the team decides they add value. Not required for MVP development.

| Tool | Purpose |
|------|---------|
| **[Rokit](https://github.com/rojo-rbx/rokit)** | Pin Rojo/tool versions per repo (`rokit.toml`) |
| **[Roblox LSP](https://github.com/JohnnyMorganz/luau-lsp)** | Luau autocomplete and diagnostics in Cursor/VS Code |
| **[StyLua](https://github.com/JohnnyMorganz/StyLua)** | Luau formatter (CI or pre-commit) |
| **[Selene](https://github.com/Kampfkarren/selene)** | Luau linter |
| **AI 3D asset tools** | Concept meshes or textures — always review before importing to Studio |

If you add optional tools, document versions in team notes; do not change gameplay behavior without an approved task.

---

## 3. What we do **not** recommend

- **Random Roblox Studio plugins** (admin, “easy UI”, uncatalogued toolbox helpers, etc.).
- **Adding Workspace to Rojo** — breaks the scripts-only rule.
- **Importing free Toolbox models with scripts** without reading every Script inside.
- **Third-party “sync” or “auto-build” plugins** that duplicate Rojo’s job.

Stick to: **Studio + Cursor + Git + Rojo (+ Blender for art)**.

---

## 4. Install commands (quick reference)

Run in **PowerShell** after installing:

```powershell
git --version
rojo --version
rojo plugin install
blender --version
```

`blender --version` may fail if Blender was not added to PATH — that is OK if Blender opens from the Start menu.

Clone or open the repo:

```powershell
cd C:\Users\YourName\source\repos\JonesRoblox
rojo build
```

`rojo build` should succeed with no errors.

---

## 5. First-time repo setup

1. Clone or copy the **JonesRoblox** repository.
2. Open the folder in **Cursor**.
3. Read (in order):
   - [JONES_MASTER_SUMMARY.md](JONES_MASTER_SUMMARY.md)
   - [JONES_ROBLOX_ADAPTATION.md](JONES_ROBLOX_ADAPTATION.md)
   - [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md)
4. Confirm `default.project.json` does **not** include `Workspace`.
5. For DataStore tests in Studio: **Game Settings → Security → Studio Access to API Services** → enable.

---

## 6. Verification flow

Complete this once on a new machine to confirm everything works.

### Terminal (Cursor)

1. Open the **JonesRoblox** folder in Cursor.
2. Open a terminal in the repo root.
3. Run:

   ```powershell
   rojo serve
   ```

4. Leave it running. Expected output includes:

   ```
   Rojo server listening:
     Address: localhost
     Port:    34872
   ```

### Roblox Studio

5. Open **Jones In The Lane** in Roblox Studio.
6. **Plugins → Rojo → Connect** → address `localhost:34872` → **Connect**.
7. Click **Sync** (sync scripts from repo into the place).
8. Press **Play** (F5).

### In-game checks

9. **HUD appears** (top-left): Day/Clock, Wallet, Bank, Energy, Hunger, zone label, objectives.
10. Walk to **Market** (zone Part required — see [STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md)).
11. Click **Open Food Shop** → centered **card-grid modal** opens; **Buy** buttons fully visible.
12. Buy an item (e.g. **Apple**) → Wallet decreases; **Owned** count updates.
13. Click **Food Inventory** → inventory modal opens; **Eat** works on owned food.
14. Click **Stop** (Shift+F5).

If all steps pass, the machine is ready for development.

---

## 7. Safety rules

| Rule | Why |
|------|-----|
| **Studio owns Workspace** | Map, terrain, zone Parts, and models live in the place file — not in Git via Rojo. |
| **Rojo owns scripts only** | `src/` → ServerScriptService, ReplicatedStorage, StarterPlayer, StarterGui. |
| **Do not add Workspace to `default.project.json`** | Prevents accidental map sync conflicts and publish surprises. |
| **Do not install unknown plugins** | Reduces exploit/backdoor risk and inconsistent team environments. |
| **Inspect Toolbox models before use** | Free models may contain hidden Scripts, require malware, or break zone logic. |
| **No secrets in the repo** | API keys stay out of JonesRoblox; DataStore is Roblox-native. |
| **Keep `TEST_FAST_DAY = false` in repo** | Fast-day flag is for local testing only ([README.md](../README.md)). |

Full mandatory rules: [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md).

---

## 8. Troubleshooting

| Problem | Fix |
|---------|-----|
| `rojo` not recognized | Add Rojo folder to PATH; restart terminal. |
| Rojo plugin missing in Studio | Run `rojo plugin install` again; restart Studio. |
| Sync does nothing | Confirm `rojo serve` is running; Connect to `localhost:34872`. |
| HUD missing on Play | Sync again; check **ServerScriptService** for Jones scripts. |
| No zone buttons | Zone Parts missing or misnamed — [STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md](STUDIO_ZONE_SETUP_CLICK_BY_CLICK.md). |
| DataStore not saving | Enable **Studio Access to API Services** in Game Settings. |

---

## 9. New machine checklist

- [ ] Roblox Studio installed; **Jones In The Lane** place opens
- [ ] Cursor installed; repo folder opened
- [ ] Git installed — `git --version` works
- [ ] Rojo CLI installed — `rojo --version` works
- [ ] Rojo Studio plugin — `rojo plugin install`; plugin visible in Studio
- [ ] Blender installed (for 3D work; GUI OK if CLI not on PATH)
- [ ] `rojo build` succeeds in repo root
- [ ] `rojo serve` → Studio Connect → Sync → Play
- [ ] HUD visible; Food Shop + Food Inventory modals work at Market
- [ ] Read [JONES_DEVELOPMENT_RULES.md](JONES_DEVELOPMENT_RULES.md)
- [ ] Confirmed `default.project.json` has **no Workspace**

---

## One-line summary

**Install Studio, Cursor, Git, Rojo (+ plugin), and Blender → open JonesRoblox → `rojo serve` → Studio Sync → Play → verify HUD and food modals → never sync Workspace through Rojo.**
