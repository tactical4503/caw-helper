# CAW Helper — Generated Art Pipeline

All world and object artwork for CAW Helper is original art created specifically for this project with **ChatGPT image generation**. This file describes how an asset goes from brief to the running UI.

```
DESIGN BRIEF (data/art-manifest.json)
      ↓  npm run prompts  → ASSET_PROMPTS.md
CHATGPT IMAGE GENERATION
      ↓
REVIEW against the QC checklist below → revise / regenerate until it passes
      ↓
npm run ingest -- <key> <file.png> --reviewed   (optimizes, writes sizes, marks approved)
      ↓
npm run validate   (paths, manifest, placeholder ban)
      ↓
commit → the UI picks it up automatically
```

## Current status

The generated art itself has **not been made yet**: the coding environment that built this pipeline had no image-generation tool, so no image was generated or committed. Every entry in `data/art-manifest.json` is `needs-generation`. The checklist at the top of `ASSET_PROMPTS.md` and the summary from `npm run validate` show what is outstanding.

Until an entry is approved, the UI keeps showing the authored SVG study art already in `assets/` (the `current` field in the manifest). That art is project-owned, but the backgrounds are reused across worlds, and Create, Library and Study Mode have no world art at all. Treat those as gaps to close, not as the final design.

## Files

| Path | Role |
|---|---|
| `data/art-manifest.json` | Source of truth: every asset's brief, purpose, UI location, sizes, status. |
| `ASSET_PROMPTS.md` | Copy-paste ChatGPT prompts, generated from the manifest. Never edit by hand. |
| `scripts/build-prompts.mjs` | Rebuilds `ASSET_PROMPTS.md`. |
| `scripts/ingest-art.mjs` | Converts a reviewed PNG into the WebP sizes and marks the entry `approved`. Needs ImageMagick with WebP. |
| `scripts/validate-assets.mjs` | Fails on missing paths, approved-but-missing files, remote images or placeholder terms. Runs in CI. |
| `assets/art/worlds/` | `world-<id>-<width>.webp` |
| `assets/art/masks/<id>/` | `mask-<id>-<angle>-<width>.webp` |

## Keys

- World art: `world:<id>`, e.g. `world:mask-archive`.
- Mask views: `mask:<id>:<angle>`, where angle is `front`, `three-quarter`, `side`, `three-quarter-back` or `back`.

## Sizes

| Kind | Generate at | Ingested widths | Format |
|---|---|---|---|
| World (3:2) | 1536×1024 | 1536 / 1024 / 640 | WebP q82 (q78 for the smallest) |
| Study room (1:1) | 1024×1024 | 1536 / 1024 / 640 (never upscaled) | WebP |
| Mask view (1:1) | 1024×1024 transparent PNG | 1024 / 640 / 320 | WebP with alpha |

The app picks the smallest file at least as wide as the viewport × device pixel ratio. Wall cards load the 320 px mask, the inspector loads 640 px and the study modal loads 1024 px.

## Mask angles and honesty

Generate the **front** first. After it passes review, attach it as the reference image for the other four angles so they show the same object.

The inspector states what it is actually showing:

| Approved views | Badge | Interaction |
|---|---|---|
| none (authored SVG) | `SINGLE VIEW • STUDY ILLUSTRATION` | scroll to zoom |
| 1 | `SINGLE VIEW • STUDY ILLUSTRATION` | scroll to zoom |
| 2–5 | `MULTI-ANGLE / PSEUDO-3D • n VIEWS` | angle buttons, drag steps between real views |
| `model3d` set | `REAL 3D MODEL` | reserved for a future GLB viewer |

A flat image is never rotated in CSS and presented as 3D.

## QC checklist (reject and regenerate if any fail)

- [ ] Physically believable object or space; a mask has head volume, panels, seams, eye openings, edge thickness and shadows.
- [ ] Matches its brief: silhouette, eyes, mouth, materials and palette as specified.
- [ ] No broken anatomy, impossible geometry, melted or duplicated objects.
- [ ] No text, pseudo-text, logos, watermarks or real-world branding.
- [ ] Not a copy of a real wrestler's mask, character or game asset.
- [ ] Consistent perspective and lighting; composition leaves room for the UI where the brief says so.
- [ ] Not generic AI fantasy art; it belongs to the CAW Helper visual language (see ART_DIRECTION.md).
- [ ] For extra mask angles: the same object as the approved front, with nothing redesigned.
- [ ] It is not a picture of a user interface. The UI is always real HTML/CSS/JS.

Only ingest with `--reviewed` after the checklist passes.
