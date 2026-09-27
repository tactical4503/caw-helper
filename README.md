# CAW Helper — Original Creator World

CAW Helper is an unofficial fan-made wrestling CAW creation, study and design platform.

## Current production foundation
- Cinematic game-world home screen.
- Mask Maker archive with 20 distinct local physical-object mask assets.
- Search, filters, selection, favorites and inspection.
- Drag-to-rotate / wheel-to-zoom inspection.
- Mask Builder with construction, material, palette, pattern, finish, depth and scale controls.
- Local project/version persistence and JSON export.
- Create, Body, Attire, Accessories, Explore, Learn and Library worlds.
- Responsive layouts and reduced-motion support.

## Physical asset standard
Masks and other gear shown as objects must read as physically constructed wrestling equipment: believable volume, seams/panels, eye openings, material response, edge thickness, lighting and shadows. Flat icons, logos, abstract symbols and placeholder imagery are not acceptable primary object art.

The initial mask collection lives in:
`assets/objects/masks/`

All primary mask references are local repository assets. The app does not depend on `/mnt/data`, temporary generation URLs, or local-only files.

## Architecture
The current production artifact is deliberately portable HTML/CSS/JS. Data and presentation remain separable so the experience can later move into React/TypeScript/Three.js without discarding the design.

## Run locally
Serve the repository with any static HTTP server. For example:
```bash
npx serve .
```
Then open the local address printed by the server.

## Quality rule
A feature is not considered complete until its assets, paths, interactions and runtime behavior have been verified.