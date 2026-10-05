# CAW Helper Art Direction

CAW Helper is a creator's world, not a generic dashboard.

Every major visual should have:
- its own composition
- its own lighting logic
- its own environment
- its own material language
- a clear focal object
- deliberate depth and foreground/midground/background separation

The Mask Maker is the flagship visual world. Masks are original study objects and should be presented as physical objects with believable volume, shadows, material response, inspection states, and creator-focused metadata.

Avoid:
- generic SaaS cards
- copied wrestling-game assets
- fake historical photography
- stock imagery
- repetitive page templates
- decorative effects without UX purpose
- flattened screenshot-only interfaces

Generated artwork follows ASSET_PIPELINE.md: every asset has a written brief in `data/art-manifest.json`, is generated with ChatGPT image generation, passes the QC checklist, and is ingested with `scripts/ingest-art.mjs`. Never substitute an external, stock or placeholder image. Until an asset is approved, the authored SVG study art is shown. That is a stopgap, and it is listed as outstanding work.