# CAW Helper — AI Engineering Rules

CAW Helper is a fan-made wrestling CAW creation, study, and design platform.

## Non-negotiables
- Preserve the cinematic, game-like identity.
- Do not replace distinctive ideas with generic SaaS UI.
- Do not use fake controls that imply functionality that does not exist.
- Keep content, assets, and presentation separable.
- Prefer real local assets over missing/external placeholders.
- Make changes incrementally and keep the project runnable.
- Test changed JavaScript with `node --check` where applicable.
- Never claim a feature was tested when it was not.
- Mobile is an intentional layout, not a shrunken desktop page.

## Visual direction
Grand, tactile, archival, theatrical, wrestling-history inspired. Avoid generic cyberpunk, excessive glassmorphism, generic gradients, and empty dashboard layouts.

## Current architecture
The root `index.html` is the zero-build runnable experience. `app.js` contains interaction logic. `styles.css` contains presentation. `assets/` contains local visual content.

The architecture can later migrate into React/Next.js without discarding the current experience.
