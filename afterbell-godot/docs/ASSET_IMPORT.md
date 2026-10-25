# AFTERBELL asset package import (All Models / Current Textures)

The package had 26 models. All 518 entries in `HASHES.json` matched before import, checked with sha256.

## Licensing and why the files are not in git
The package README says its originals "retain their original rights". The file and folder names point to commercial games:
- `zombi20` and `zombi21`;
- the Japanese stage texture names (`OP_kabe…`);
- "Snowpoint Temple" and "Turnback Cave";
- "Small Suitcase (DR2)".

This repository is public, so `assets/imports/` is gitignored and the models stay in the local working copy only. The code, the staging scene and this ledger are committed. Without the files, every model is simply skipped (`ImportedAssets.make()` returns null).

## Mapping: package asset → project → action
None of the 26 models was already in the project. The game's mannequins, suitcase, pillars and staff (Hesta, Len) are built procedurally in `scripts/props.gd` and `scripts/atrium.gd`. No existing mesh shares these UV layouts, so there was nothing to retexture in place. Every model is imported and staged instead, and **no playable scene was changed**.

| Package asset | Imported to (`assets/imports/…`) | Existing equivalent | Action |
|---|---|---|---|
| Snowpoint Temple Pillar | `environments/snowpoint_temple_pillar/` (OBJ, MTL, `lambert10.png`) | procedural `Atrium.pillar` | staged at 5.0 m tall |
| Turnback Cave Pillar | `environments/turnback_cave_pillar/` | same | staged |
| Mannequin_Female / _Male | `props/mannequin_female/`, `props/mannequin_male/` | procedural posed `mannequin` prop | staged at native size (1.50 m / 1.52 m) |
| Suitcase | `props/suitcase/` (root and `Textures/` copies of `case1.png`, as the MTL needs) | procedural `suitcase` prop | staged at native size (0.52 m) |
| NPC09_Plum_Clerk (npc10) | `characters/plum_clerk_npc10/` (glTF, BIN, PNG) | Hesta and Len are procedural people | staged, rest pose |
| NPC11_Teal_Clerk (npc12) | `characters/teal_clerk_npc12/` | same | staged, rest pose |
| Eric (zombi21) | `characters/eric_zombi21/` | none: the game's only enemies are the Floor Manager rig and the hat guards | staged, rest pose |
| Franklin (zombi20) | `characters/franklin_zombi20/` | none | staged, rest pose |
| Stage 1 (7 sections), Stage 2 (10 sections) | `environments/stage1_*`, `environments/stage2_*` (OBJ, MTL, PNG) | none: a European town, church, sewer and shops, with no department-store match | staged, source origin, scale 1.0 |

Formats copied:
- characters: glTF, BIN and PNG (keeps the skeleton);
- everything else: OBJ, MTL and PNG.

DAE files were not copied, nor were the stages' glTF files. The folders keep the package's file names, so repeated PNG names such as `lambert10.png` and `fine_fabric_white.png` live in separate folders.

## Materials (project-local overrides; the source files are untouched)
`scripts/imported_assets.gd` gives each surface a new `StandardMaterial3D` that uses the imported albedo PNG:
- **Base settings for every surface:** white modulation, metallic 0, repeating UVs, roughness per asset.
- **Pillars:** the MTL's `Tr 1` imports as alpha 0, which made the pillar invisible, so the override is opaque. The mesh is modelled from the front only (a background piece), so the material is two-sided.
- **Mannequins:** fabric roughness is 0.88 and wood 0.42. The package's own `*_local.png` maps are used as normal maps (the MTL's `map_Bump`; their import is set to normal-map compression). The MTL's metallic 0.5 is dropped.
- **Characters:** the source cull mode is kept (double-sided surfaces stay double-sided). Eric's visor surface (`zmt21_4`, blended at alpha 0.48) stays semi-transparent and nothing else is. No palette-swap shader was involved.
- **Stage textures:** a texture with real transparent pixels gets alpha scissor. The others are opaque.

## Files added or changed (rollback ledger)
| File | Status | Rollback |
|---|---|---|
| `../.gitignore` | 4 lines added (`/afterbell-godot/assets/imports/`) | remove those lines |
| `scripts/imported_assets.gd` | new: registry, wrappers, material overrides | delete |
| `scripts/asset_staging.gd`, `rooms/asset_staging.tscn` | new: staging scene | delete |
| `tools/inspect_import.gd`, `tools/staging_shots.gd` | new: inspection and render tools | delete |
| `docs/ASSET_IMPORT.md` | new: this file | delete |
| `assets/imports/**` | new, local only (gitignored), with Godot `.import` files | delete the folder |

Pre-import state: branch `pre-asset-import-baseline` (commit e02a750). That branch exists only in the local clone and was not pushed. Rolling back the integration alone means deleting the files above, or reverting the import commit. No existing file other than `.gitignore` was edited.

## Placed in the playable atrium (user request, after staging)
`Atrium.IMPORTED_PLACES` (scripts/atrium.gd) places 11 wrapped models as static dressing, all where neither Ren nor the Floor Manager walks:

| Model | Placement |
|---|---|
| Plum clerk, teal clerk | behind the glazed MENSWEAR shopfront |
| Two male dress forms | behind the glazed MENSWEAR shopfront |
| Two female dress forms | on the mezzanine |
| Suitcase | by the brass rack next to the lily table |
| Both ivory pillars | against the window wall on the mezzanine |
| Eric, Franklin | as costume figures on plum plinths on the side galleries |

Each one is skipped when its files are absent, so a clean clone builds the same atrium without them.

- **Export:** `export_presets.cfg` now includes `assets/imports/*`, so local builds carry the models.
- **Stage sections:** not placed. They have no fitting location in the store, so they stay in the staging scene.

## Use
- Run `rooms/asset_staging.tscn` (F6). A/D orbit, W/S zoom, Q/E switch row.
- To render one group: `godot --path . -s res://tools/staging_shots.gd -- --group=props|characters|stage1|stage2 --views=front,back,top,close,close_back --out=<dir>`.
- To place a model in a level later: `var w := ImportedAssets.make("mannequin_female")`, then set `w.position` and add it as a child. Collision is not included: these are decorative.

## Verification (Godot 4.3, this container)
- **Import:** `godot --headless --editor --quit` imported everything with no errors. Godot warned that the pillar MTL's ambient terms are ignored.
- **Renders:** Forward+ on lavapipe, viewed for every model.
  - Pillars: front, back and top.
  - Mannequins: front, back and top; fabric and wood are told apart.
  - Suitcase: plum outside, brass trim. The model is closed, so the teal lining can't be seen.
  - Clerks, Eric and Franklin: front, back, and close-ups of neck, collar and sleeves. They match the package's preview sheet.
  - All 17 stage sections from above, with textures bound.
- **Game tests:** all six still pass (room, hats, alterations, sim, paths, chapter). The playable scenes are unchanged.

## Known limits
- The characters have skeletons but **no animation clips**, and bone names (`Bone01`, `kaoN2`…) that don't match Ren's or the Floor Manager's rigs. They can't be used as actors without rigging work, which this task did not authorise.
- The pillar shaft is a half shell seen from behind (source geometry).
- The character textures are visibly low-res and blocky; that is the art itself, not an import fault.
- The stage scale is approximate; see `STAGE_UNIT`.
- Not tested: real-time inspection in the editor window. The in-level placements were checked with a headless count (all 11 placed) and Forward+ renders.
