# CAW Helper — AI Engineering Rules

CAW Helper is a fan-made wrestling CAW creation, study, and design platform.

## Non-negotiables
- Preserve the cinematic, game-like identity.
- Do not replace distinctive ideas with generic SaaS UI.
- Do not use fake controls that imply functionality that does not exist.
- Keep content, assets, and presentation separable.
- Mobile is an intentional layout, not a shrunken desktop page.
- Test changed JavaScript with `node --check app.js` where applicable.
- Never claim a feature was tested when it was not.
- Never reference generated files outside the repository.
- Before shipping, verify every local asset path exists.
- Do not replace a physical object with an icon, logo, flat symbol, or generic placeholder.

## Physical-object visual standard
When the product shows a mask, boot, garment, glove, belt, accessory, mannequin or other gear, it must read as a real physical object. A wrestling mask needs believable head volume, construction, panels/seams, eye openings, material response, edge transitions, shadows and a coherent silhouette.

## Visual direction
Grand, tactile, archival, theatrical, wrestling-history inspired. Avoid generic cyberpunk, excessive glassmorphism, generic gradients, empty dashboard layouts and fake 3D.

## Current architecture
The root `index.html` is the zero-build runnable experience. `app.js` contains interaction logic. `styles.css` contains presentation. `assets/` contains local visual content.

The architecture can later migrate into React/Next.js/Three.js without discarding the current experience.