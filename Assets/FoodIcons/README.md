# Jones Food Icons — Source PNGs

These PNG files are the **source art** for Food Shop and Food Inventory UI thumbnails in **Jones In The Lane**.

## Important

- **Roblox UI cannot use local PNG files directly** in a published game.
- Each PNG must be **uploaded manually** to the [Roblox Creator Dashboard](https://create.roblox.com/dashboard/creations) as an **Image** (or Decal, depending on your workflow).
- After upload, copy each **Roblox asset ID** into `src/ServerScriptService/JonesFoodItems.lua` as `ImageAssetId = "rbxassetid://..."`.
- Keep `EmojiFallback` on each item as a safety fallback if preload fails.

## Files

| FoodId | Local PNG |
|--------|-----------|
| Water | `water.png` |
| Apple | `apple.png` |
| Bread | `bread.png` |
| Sandwich | `sandwich.png` |
| HotMeal | `hot_meal.png` |
| FamilyMeal | `family_meal.png` |

## Manual upload workflow

1. Open **Creator Dashboard** → **Development Items** → **Images**.
2. Upload each PNG from this folder (one upload per food item).
3. Copy each asset ID from the upload result.
4. Update `ImageAssetId` in `JonesFoodItems.lua` for the matching food id.
5. Sync with Rojo and play-test Food Shop / Food Inventory cards in Studio.

**Do not** commit Roblox asset IDs until you have verified thumbnails load in-game.

## Related docs

- [Docs/JONES_FOOD_SHOP.md](../../Docs/JONES_FOOD_SHOP.md) — catalog, upload status table, and UI notes
