# CAW Helper — ChatGPT Image Generation Prompts

Generated from `data/art-manifest.json` by `node scripts/build-prompts.mjs`. Do not edit by hand; edit the manifest and rebuild.

Workflow for every asset: **generate → inspect against the QC checklist in ASSET_PIPELINE.md → revise → ingest** with
`node scripts/ingest-art.mjs <key> <downloaded.png> --reviewed`.

## Checklist

### World art (0/12 approved)

- [ ] needs generation `world:home` — HOME — The Arena Concourse
- [ ] needs generation `world:create` — CREATE — The Character Drafting Table
- [ ] needs generation `world:mask-archive` — MASK ARCHIVE — The Mask Wall
- [ ] needs generation `world:mask-workbench` — MASK MAKER — The Mask Construction Bench
- [ ] needs generation `world:body-lab` — BODY LAB — The Physique Laboratory
- [ ] needs generation `world:attire-workshop` — LEGS / ATTIRE WORKSHOP — The Gear Tailor
- [ ] needs generation `world:boot-workshop` — SHOE WORKSHOP — The Boot Maker
- [ ] needs generation `world:dressing-room` — ACCESSORIES — The Dressing Room
- [ ] needs generation `world:explore-hall` — EXPLORE — The Collection Gallery
- [ ] needs generation `world:learn-classroom` — LEARN — The Design Classroom
- [ ] needs generation `world:study-room` — STUDY MODE — The Inspection Room
- [ ] needs generation `world:library-vault` — LIBRARY — The Personal Vault

### Masks (0/100 views approved)

- **Ember Dragon**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Frost Phoenix**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Jungle Spirit**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Sol Invictus**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Void Walker**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Crimson Skull**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Ocean King**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Shadow Fox**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Iron Serpent**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Celestial Guardian**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Night Blossom**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Blood Moon**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Paper Tiger**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Glass Wraith**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Sun Eater**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Velvet Jester**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Storm Ram**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Moon Viper**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **Cinder Owl**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back
- **White Noise**: ☐ front · ☐ three-quarter · ☐ side · ☐ three-quarter-back · ☐ back

---

## World art prompts

### `world:home` — HOME — The Arena Concourse

| | |
|---|---|
| What is it? | The empty backstage tunnel of a historic wrestling arena moments before doors open. |
| Why does it exist? | Establishes the CAW Helper universe in one image: wrestling history, craft and anticipation. |
| Where is it used? | HOME world: full-bleed background layer `.home-art` behind the CAW HELPER title (title sits on the left 45% of the frame). |
| What does it communicate? | You are about to walk out and build a character. Grand, theatrical, physical. |
| How does it differ? | The only world that shows the ring/arena itself; every other world is a workroom. |
| Files | `assets/art/worlds/world-home-640.webp`, `assets/art/worlds/world-home-1024.webp`, `assets/art/worlds/world-home-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
HOME world: full-bleed background layer `.home-art` behind the CAW HELPER title (title sits on the left 45% of the frame).

Subject:
A long, high-ceilinged entrance tunnel of an old municipal wrestling arena, looking out toward a single empty ring bathed in a pale spotlight at the far end. On a steamer trunk in the right foreground rests one folded original wrestling mask (crimson leather with gold trim, no symbols) beside taped boots and a coiled rope.

Composition:
Camera low (knee height) in the tunnel, 28mm lens, one-point perspective. Foreground right: trunk with folded mask and boots, sharp. Middle ground: tunnel walls of painted brick with faded, wordless poster frames and cable runs. Background: the lit ring and dark tiered seating. Keep the left 45% of the frame calm and dark for the UI title.

Physical construction:
Worn painted brick, scuffed concrete floor with taped markings, riveted steel tunnel beams, canvas ring apron, hemp-wrapped ropes, scratched steamer trunk with brass corners.

Lighting:
Key: cold white spotlight on the ring far away producing volumetric beams. Fill: weak tungsten work lamps along the tunnel. Rim: warm amber kicker on the trunk and mask. Deep shadows on the left.

Color:
Near-black and smoked brown base, warm bone and restrained gold accents, a single muted red note on the mask. No neon.

Atmosphere:
Light haze and floating dust in the beams; slight depth fog toward the ring.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:create` — CREATE — The Character Drafting Table

| | |
|---|---|
| What is it? | A top-down view of a character designer's drafting table mid-project. |
| Why does it exist? | CREATE connects body, attire, moves and entrance into one project; a planning table shows all pieces together. |
| Where is it used? | CREATE world: background layer behind the light "BUILD THE WHOLE THING" layout; the world uses a warm paper palette, so this image is shown light and slightly desaturated. |
| What does it communicate? | Planning, drafting and assembling an entire wrestler, not just one item. |
| How does it differ? | Only light, overhead, paper-dominant image in the set; shot from directly above. |
| Files | `assets/art/worlds/world-create-640.webp`, `assets/art/worlds/world-create-1024.webp`, `assets/art/worlds/world-create-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
CREATE world: background layer behind the light "BUILD THE WHOLE THING" layout; the world uses a warm paper palette, so this image is shown light and slightly desaturated.

Subject:
Directly overhead view of a large oak drafting table covered with loose sheets of heavy cream paper bearing pencil figure sketches of an original wrestler (front/back turnaround poses), fabric swatches pinned with brass pins, a small leather boot sample, a measuring tape, graphite pencils, a pencil sharpener, and a folded original mask swatch. Absolutely no readable text, no logos.

Composition:
Flat lay, camera perpendicular to the table. Objects arranged in a loose asymmetric cluster along the right and bottom edges; the upper-left 50% stays mostly clean cream paper for UI copy.

Physical construction:
Oak with visible grain, toothy cream paper with soft graphite lines and smudges, satin and lycra swatches, brass pins, cloth measuring tape, a cut leather boot vamp with visible stitching.

Lighting:
Large soft window key from the upper left, gentle fill, soft contact shadows under every object; no harsh specular.

Color:
Warm paper (#dcd6ca range), oak brown, graphite grey, one muted red and one gold swatch.

Atmosphere:
Calm, tactile, studio quiet; very fine paper texture.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:mask-archive` — MASK ARCHIVE — The Mask Wall

| | |
|---|---|
| What is it? | A vast, old archive hall where hundreds of original wrestling masks hang on display. |
| Why does it exist? | Flagship world. The archive is the place you study masks before making one. |
| Where is it used? | MASK MAKER world (mask wall): full-bleed `.mask-bg` layer behind the mask grid and inspector; darkened to ~68% brightness under UI. |
| What does it communicate? | Scale, history and reverence for the craft; masks as real objects, not icons. |
| How does it differ? | The only world with many masks at multiple depths; architectural and museum-like. |
| Files | `assets/art/worlds/world-mask-archive-640.webp`, `assets/art/worlds/world-mask-archive-1024.webp`, `assets/art/worlds/world-mask-archive-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
MASK MAKER world (mask wall): full-bleed `.mask-bg` layer behind the mask grid and inspector; darkened to ~68% brightness under UI.

Subject:
A cavernous archive hall with tall aged plaster walls lined floor to ceiling with dark wooden display shelving and wall-mounted head forms, each holding a different original wrestling mask (varied silhouettes: horned, crested, smooth, winged; leather, satin, metallic). Rolling library ladders, glass vitrines on wooden plinths in the middle ground, brass inventory tags hanging from string (tags blank).

Composition:
Camera at standing eye height, 35mm, two-point perspective looking down the hall. Foreground: a vitrine edge and one mask on a head form, slightly out of focus at frame right. Middle ground: rows of shelving receding. Background: an arched end wall dissolving into haze. Masks at clearly different distances.

Physical construction:
Aged lime plaster with water stains, dark stained walnut shelving, brass rails and tag hooks, worn parquet floor, glass vitrines with bevelled edges, linen-covered head forms.

Lighting:
Key: high clerestory windows casting slanted shafts. Fill: low warm picture lights over shelving. Rim: thin gold edge light on foreground mask. Strong falloff into dark corners.

Color:
Deep umber, black, aged ivory plaster, restrained gold; masks provide scattered muted reds, blues and silvers.

Atmosphere:
Visible dust motes in light shafts, soft fog toward the back wall.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:mask-workbench` — MASK MAKER — The Mask Construction Bench

| | |
|---|---|
| What is it? | The workbench where masks are physically patterned, cut and stitched. |
| Why does it exist? | The builder is about construction choices; the backdrop should show how masks are actually made. |
| Where is it used? | MASK BUILDER world: `.builder-backdrop` layer behind the builder controls and live preview stage (darkened to ~42%). |
| What does it communicate? | Craft and construction: patterns, panels, stitching, materials. |
| How does it differ? | Archive = finished masks on display; this = unfinished masks in pieces on a bench. |
| Files | `assets/art/worlds/world-mask-workbench-640.webp`, `assets/art/worlds/world-mask-workbench-1024.webp`, `assets/art/worlds/world-mask-workbench-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
MASK BUILDER world: `.builder-backdrop` layer behind the builder controls and live preview stage (darkened to ~42%).

Subject:
A heavy wooden mask-maker's workbench beneath a pegboard wall. A canvas-covered head form in the centre wears a half-finished original mask (one panel pinned, unstitched). Around it: paper pattern pieces for mask panels, cut leather and stretch-satin panels, an industrial sewing machine at frame left, spools of heavy thread, an awl, leather shears, grommet setter, lace, eyelets in a tin.

Composition:
Camera at bench height, 3/4 angle, 40mm. Foreground: scattered eyelets and thread, shallow focus. Middle ground: head form and panels (focal). Background: pegboard with hanging tools and pattern templates. Keep the right-centre area (where the live preview renders) relatively dark and uncluttered.

Physical construction:
Scarred maple bench, perforated pegboard, steel tools with worn handles, cut leather edges showing thickness, satin with sheen, waxed thread, brass eyelets.

Lighting:
Key: a single articulated task lamp above the head form (warm). Fill: very low cool ambient. Rim: lamp spill on tool edges. Deep shadow in the corners.

Color:
Dark wood brown, black, warm lamp gold, a muted red leather panel, steel grey.

Atmosphere:
Faint thread lint and dust in the lamp cone; intimate, focused.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:body-lab` — BODY LAB — The Physique Laboratory

| | |
|---|---|
| What is it? | An athletic anatomy and proportion laboratory. |
| Why does it exist? | BODY is about proportion, stance and physical presence before attire. |
| Where is it used? | BODY world: `.generic-art` layer of the BODY workshop (dimmed to ~36% under the three study cards). |
| What does it communicate? | Measurement, structure, honest study of the human form. |
| How does it differ? | Clinical and clean; the only cool-lit world. No masks or gear. |
| Files | `assets/art/worlds/world-body-lab-640.webp`, `assets/art/worlds/world-body-lab-1024.webp`, `assets/art/worlds/world-body-lab-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
BODY world: `.generic-art` layer of the BODY workshop (dimmed to ~36% under the three study cards).

Subject:
A clean, high-ceilinged physique study room. Centre: a full-size articulated neutral grey mannequin (featureless head, athletic heavyweight wrestler build) standing on a turntable platform in front of a large measurement grid wall. Around it: a vintage height rod, a wall-mounted calliper, a balance scale, plaster anatomy casts (shoulder, forearm, torso) on shelves, posture reference silhouettes on frosted glass panels (no text).

Composition:
Camera at chest height, frontal-left 3/4, 35mm. Foreground: edge of an equipment cart with callipers and tape, softly blurred. Middle ground: mannequin on turntable (focal, right of centre). Background: grid wall and shelves of casts.

Physical construction:
Matte grey mannequin with visible joint segments, painted steel grid wall, white plaster casts, chrome measurement tools, terrazzo floor, frosted glass.

Lighting:
Controlled studio lighting: large overhead softbox key, cool fill from the left, crisp white rim on the mannequin silhouette. Clean shadows.

Color:
Cool greys and off-white, steel blue shadows, a single thin gold measurement line accent.

Atmosphere:
Very slight clean haze; precise, quiet.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:attire-workshop` — LEGS / ATTIRE WORKSHOP — The Gear Tailor

| | |
|---|---|
| What is it? | A wrestling-gear tailor's workroom focused on tights, trunks and kneepads. |
| Why does it exist? | ATTIRE is about lower-body gear layers and material coordination. |
| Where is it used? | ATTIRE world: `.generic-art` layer of the ATTIRE workshop. |
| What does it communicate? | Garments as built objects: patterns, fabrics, padding. |
| How does it differ? | Fabric-dominant; hanging garments and a dress form, unlike the boot bench or mask bench. |
| Files | `assets/art/worlds/world-attire-workshop-640.webp`, `assets/art/worlds/world-attire-workshop-1024.webp`, `assets/art/worlds/world-attire-workshop-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
ATTIRE world: `.generic-art` layer of the ATTIRE workshop.

Subject:
A tailor's workroom: a lower-body dress form wearing original long wrestling tights with contrasting side panels and quilted kneepads; a rolling garment rail holding trunks and tights in several fabrics; a cutting table with chalk-marked stretch fabric, rotary cutter, pattern weights; bolts of lycra, metallic spandex and velvet on a wall rack.

Composition:
Camera at hip height, 35mm, slight 3/4. Foreground: cutting table edge with chalk and pins. Middle ground: dress form (focal, centre-right). Background: fabric bolt wall and garment rail receding.

Physical construction:
Stretch lycra with sheen, metallic spandex, velvet nap, quilted vinyl kneepads with visible stitch lines, painted wood rack, steel garment rail.

Lighting:
Key: warm overhead pendant over the cutting table. Fill: soft window light from the right. Rim: sheen highlights along the tights panels.

Color:
Black and charcoal base, deep oxblood and teal fabrics, cream chalk, small gold accents.

Atmosphere:
Light fabric dust; lived-in workshop warmth.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:boot-workshop` — SHOE WORKSHOP — The Boot Maker

| | |
|---|---|
| What is it? | A wrestling boot-maker's cobbler bench. |
| Why does it exist? | Boots are their own craft: lasts, soles, lacing, padding. |
| Where is it used? | SHOES world: `.generic-art` layer of the SHOES workshop. |
| What does it communicate? | Leather, stitching, soles and tools, real footwear construction. |
| How does it differ? | Leather and tool dominant, lowest and closest camera of the set. |
| Files | `assets/art/worlds/world-boot-workshop-640.webp`, `assets/art/worlds/world-boot-workshop-1024.webp`, `assets/art/worlds/world-boot-workshop-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
SHOES world: `.generic-art` layer of the SHOES workshop.

Subject:
A cobbler's bench holding an unfinished tall original wrestling boot on a wooden last (knee-high, lace-up front, padded collar, contrasting toe cap). Around it: cut leather vamp and quarter pieces, a stack of rubber soles, a cast-iron last stand, hammers, awls, edge bevelers, a pot of contact cement, waxed laces, a tray of brass eyelets, a finished pair of boots on a shelf behind.

Composition:
Camera low at bench height, close, 50mm. Foreground: tools and eyelets, shallow focus. Middle ground: boot on last (focal, left-centre). Background: shelves of lasts and finished boots fading into shadow.

Physical construction:
Full-grain leather showing pores and cut edges, heavy saddle stitching, black gum rubber soles with tread, beech lasts, cast iron, waxed thread.

Lighting:
Key: warm low-angle lamp raking across the leather to show texture. Fill: very low. Rim: cool back light outlining the boot shaft.

Color:
Dark leather browns and black, oxblood, brass, bone thread.

Atmosphere:
Fine leather dust in the light; dense, crafted, close.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:dressing-room` — ACCESSORIES — The Dressing Room

| | |
|---|---|
| What is it? | A wrestler's backstage dressing room before a show. |
| Why does it exist? | Accessories finish a character: gloves, belts, jewellery, glasses, robes, props. |
| Where is it used? | ACCESSORIES world: `.generic-art` layer of the ACCESSORIES workshop. |
| What does it communicate? | Personal identity objects laid out ready to wear. |
| How does it differ? | The only world with mirrors and bulb lighting; personal and theatrical. |
| Files | `assets/art/worlds/world-dressing-room-640.webp`, `assets/art/worlds/world-dressing-room-1024.webp`, `assets/art/worlds/world-dressing-room-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
ACCESSORIES world: `.generic-art` layer of the ACCESSORIES workshop.

Subject:
A backstage dressing room: a long counter beneath a row of bulb-framed mirrors. On the counter: fingerless leather gloves, wrist tape rolls, sunglasses, a heavy chain, rings, an open jewellery case. A generic championship-style belt with an original, wordless, abstract metal plate hangs on a hook. An original sequinned entrance robe on a rail, metal lockers, a folding chair with a towel.

Composition:
Camera at seated eye height, 3/4 down the counter, 35mm. Foreground: gloves and tape sharp. Middle ground: mirrors reflecting the room (no people in reflections). Background: robe rail and lockers.

Physical construction:
Glossy mirror glass with slight desilvering at the edges, bulb sockets, chrome and brass, worn leather gloves, sequins, painted steel lockers, linoleum floor.

Lighting:
Key: warm vanity bulbs. Fill: cool fluorescent spill from an open door. Rim: specular glints on chain and belt plate.

Color:
Warm amber, black, gold and chrome, one deep purple robe accent.

Atmosphere:
Slight haze and a lived-in, pre-show tension.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:explore-hall` — EXPLORE — The Collection Gallery

| | |
|---|---|
| What is it? | A curated gallery of complete character looks. |
| Why does it exist? | EXPLORE is discovery across categories, not only masks. |
| Where is it used? | EXPLORE world: `.generic-art` layer behind ORIGINALS / COLLECTIONS / CREATOR NOTES. |
| What does it communicate? | Breadth and curation: many finished original characters to browse. |
| How does it differ? | Shows whole-character outfits on mannequins in a gallery, not single objects. |
| Files | `assets/art/worlds/world-explore-hall-640.webp`, `assets/art/worlds/world-explore-hall-1024.webp`, `assets/art/worlds/world-explore-hall-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
EXPLORE world: `.generic-art` layer behind ORIGINALS / COLLECTIONS / CREATOR NOTES.

Subject:
A long gallery corridor with polished dark floors and a row of illuminated display alcoves, each holding a faceless mannequin dressed in a different complete original wrestler look (masked luchador style, brawler in jacket and jeans, high-flyer in long tights, monster-heel in coat). Wordless brass plaques below each alcove.

Composition:
Camera at standing height, looking down the corridor, 24mm, strong depth. Foreground: first alcove at frame right, close. Middle ground: alcoves recede left-to-right. Background: corridor end in deep shadow.

Physical construction:
Polished black terrazzo, dark wood alcove frames, brass plaques and rails, mixed garment materials on mannequins.

Lighting:
Each alcove lit from above by a warm spot, pools of light in a dark corridor; reflections on the floor.

Color:
Black and walnut with warm gold pools; outfits supply varied but muted colours.

Atmosphere:
Light haze in each spot cone; museum hush.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:learn-classroom` — LEARN — The Design Classroom

| | |
|---|---|
| What is it? | A wrestling-design classroom with study materials on display. |
| Why does it exist? | LEARN teaches silhouette, material and composition through exercises. |
| Where is it used? | LEARN world: `.generic-art` layer behind SILHOUETTE / MATERIAL / COMPOSITION lessons. |
| What does it communicate? | Teaching and study: structured, hands-on, approachable. |
| How does it differ? | Classroom with silhouette cut-outs and material swatch boards, not a workshop or gallery. |
| Files | `assets/art/worlds/world-learn-classroom-640.webp`, `assets/art/worlds/world-learn-classroom-1024.webp`, `assets/art/worlds/world-learn-classroom-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
LEARN world: `.generic-art` layer behind SILHOUETTE / MATERIAL / COMPOSITION lessons.

Subject:
A daylit classroom with a large slate chalkboard covered in chalk sketches of mask silhouettes and proportion diagrams (no words), a row of black cardboard silhouette cut-outs of wrestler shapes pinned on a cork wall, framed material swatch boards (leather, satin, rubber, metal mesh) and wooden student tables with sketchbooks and colour chips.

Composition:
Camera from the back of the room at seated height, 35mm. Foreground: a table edge with an open sketchbook and colour chips. Middle ground: chalkboard (focal). Background: cork wall and window light.

Physical construction:
Slate with chalk dust, cork board, cardboard cut-outs, framed swatches, scuffed wooden tables, paper.

Lighting:
Key: tall side windows (soft daylight from the left). Fill: warm ceiling globe lights. Gentle rim on chalkboard frame.

Color:
Slate black, chalk white, warm wood, muted swatch colours, a gold frame accent.

Atmosphere:
Chalk dust in the window light; calm.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

### `world:study-room` — STUDY MODE — The Inspection Room

| | |
|---|---|
| What is it? | A close-up conservation/inspection station where a single object is examined. |
| Why does it exist? | Study mode isolates one mask to read its construction. |
| Where is it used? | STUDY MODE: background of the mask inspection modal `.modal-visual` behind the selected mask (the mask image sits centred on top, so the centre must be empty). |
| What does it communicate? | Focus, scrutiny, close reading of an object. |
| How does it differ? | Intentionally empty centre: the stage for one object, not an environment to browse. |
| Files | `assets/art/worlds/world-study-room-640.webp`, `assets/art/worlds/world-study-room-1024.webp`, `assets/art/worlds/world-study-room-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
STUDY MODE: background of the mask inspection modal `.modal-visual` behind the selected mask (the mask image sits centred on top, so the centre must be empty).

Subject:
A conservation inspection table seen at a low angle: black felt table surface, an empty central area, an articulated magnifier lamp at the left edge, a measuring scale ruler, white cotton conservator gloves, a small brush, a loupe, a grey card at the right edge, a dark curtain behind.

Composition:
Camera at table height, 50mm, symmetrical. Foreground: felt surface edge. Middle ground: completely empty centre (the UI places the mask here). Tools only at far left and right edges. Background: dark velvet curtain with soft falloff.

Physical construction:
Black felt with fibres visible, brushed aluminium lamp arm, glass lens, steel ruler, white cotton gloves, velvet.

Lighting:
Key: a single focused overhead pool on the empty centre. Faint warm fill from the magnifier lamp. Everything else falls off to near black.

Color:
Black and charcoal, a soft neutral pool of light, small warm brass and steel accents.

Atmosphere:
Very faint dust in the light pool; silent and focused.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
1:1 square (generate at 1024×1024).
```

### `world:library-vault` — LIBRARY — The Personal Vault

| | |
|---|---|
| What is it? | A private storage vault for the user's own saved designs. |
| Why does it exist? | LIBRARY holds the user's versions; it should feel like personal archived work. |
| Where is it used? | LIBRARY world: background layer behind "YOUR WORLD" and the saved project versions list. |
| What does it communicate? | Ownership, safekeeping and versioned progress. |
| How does it differ? | Storage drawers and garment boxes, private and compact rather than a public archive. |
| Files | `assets/art/worlds/world-library-vault-640.webp`, `assets/art/worlds/world-library-vault-1024.webp`, `assets/art/worlds/world-library-vault-1536.webp` |

```text
Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
LIBRARY world: background layer behind "YOUR WORLD" and the saved project versions list.

Subject:
A compact private vault room: walls of flat-file steel drawers and labelled-but-wordless archival garment boxes, one drawer pulled open showing tissue-wrapped folded mask and gear pieces, a reading table with a closed leather portfolio and a lamp, a heavy vault door ajar at frame left.

Composition:
Camera at standing height, 35mm, slight 3/4. Foreground: open drawer with tissue-wrapped pieces (right). Middle ground: reading table. Background: drawer walls. Keep the left 50% darker for the UI list.

Physical construction:
Powder-coated steel drawers with brass label holders (empty), acid-free grey boxes, tissue paper, leather portfolio, thick steel vault door with bolt work.

Lighting:
Key: warm reading lamp. Fill: dim cool overhead. Rim: highlight along drawer edges.

Color:
Graphite, warm brass, archival grey, muted red accent on one wrapped piece.

Atmosphere:
Still air, slight haze, safe and private.

Design language:
CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements. Photoreal cinematic still, no people.

Output:
3:2 landscape (generate at 1536×1024).
```

---

## Mask prompts

Generate the FRONT first. After it passes review, attach it to each of the other four prompts so all angles stay the same object.

### Ember Dragon (`mask:ember-dragon:<angle>`)

A dragon-fire full-head mask built like armour from overlapping leather scales that rise into a swept-back crest. — *Aggressive, regal, a heavyweight champion's armour.*

#### FRONT — `mask:ember-dragon:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Ember Dragon" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A dragon-fire full-head mask built like armour from overlapping leather scales that rise into a swept-back crest. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Angular full hood; a central ridge of three tall overlapping leather fins runs from forehead to crown and sweeps backward; cheek panels flare slightly into jaw points.

Physical construction:
Black stretch base hood; layered crimson leather scale panels stitched in rows from brow to cheeks; gold metallic vinyl trim piping along every scale edge; rear black lacing with brass eyelets.

Eye openings:
Sharp angular eye openings trimmed in gold piping, pointed outer corners sweeping upward toward the temples.

Mouth treatment:
Closed: the mouth area is covered by a jaw panel of small crimson scales.

Surface and materials:
Slightly aged leather with burnished highlights on scale tips, raised stitching, metallic trim catching light. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Deep crimson, burnished gold, black. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Aggressive, regal, a heavyweight champion's armour.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:ember-dragon:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ember Dragon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black stretch base hood; layered crimson leather scale panels stitched in rows from brow to cheeks; gold metallic vinyl trim piping along every scale edge; rear black lacing with brass eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:ember-dragon:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ember Dragon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black stretch base hood; layered crimson leather scale panels stitched in rows from brow to cheeks; gold metallic vinyl trim piping along every scale edge; rear black lacing with brass eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:ember-dragon:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ember Dragon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black stretch base hood; layered crimson leather scale panels stitched in rows from brow to cheeks; gold metallic vinyl trim piping along every scale edge; rear black lacing with brass eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:ember-dragon:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ember Dragon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black stretch base hood; layered crimson leather scale panels stitched in rows from brow to cheeks; gold metallic vinyl trim piping along every scale edge; rear black lacing with brass eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Frost Phoenix (`mask:frost-phoenix:<angle>`)

A phoenix mask rendered in cold materials: white satin wings frozen into the brow. — *Graceful, aerial, a high-flyer.*

#### FRONT — `mask:frost-phoenix:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Frost Phoenix" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A phoenix mask rendered in cold materials: white satin wings frozen into the brow. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Tapered hood with two wide feathered wing shapes extending from the temples back over the ears, tips slightly beyond the head outline.

Physical construction:
White satin base; ice-blue leather feather panels appliquéd in layers on the brow and wings; silver metallic edge piping; tapered chin; white lacing at the back.

Eye openings:
Winged eye openings with long silver-trimmed tails that flow into the wing feathers.

Mouth treatment:
Closed: smooth white satin over the mouth with a subtle silver centre seam.

Surface and materials:
Satin sheen with soft blue reflected light, crisp feather edges, slightly frosted metallic trim. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
White, ice blue, silver. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Graceful, aerial, a high-flyer.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:frost-phoenix:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Frost Phoenix" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; ice-blue leather feather panels appliquéd in layers on the brow and wings; silver metallic edge piping; tapered chin; white lacing at the back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:frost-phoenix:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Frost Phoenix" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; ice-blue leather feather panels appliquéd in layers on the brow and wings; silver metallic edge piping; tapered chin; white lacing at the back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:frost-phoenix:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Frost Phoenix" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; ice-blue leather feather panels appliquéd in layers on the brow and wings; silver metallic edge piping; tapered chin; white lacing at the back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:frost-phoenix:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Frost Phoenix" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; ice-blue leather feather panels appliquéd in layers on the brow and wings; silver metallic edge piping; tapered chin; white lacing at the back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Jungle Spirit (`mask:jungle-spirit:<angle>`)

A forest-spirit mask in embossed suede with organic leaf-vein panels. — *Wild, earthy, a striker connected to nature.*

#### FRONT — `mask:jungle-spirit:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Jungle Spirit" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A forest-spirit mask in embossed suede with organic leaf-vein panels. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Rounded organic hood, broad at the cheeks, with three short leaf-shaped tabs at the top of the crown.

Physical construction:
Deep green suede base; embossed leaf-vein patterning; black leather leaf panels at the cheeks with gold-thread veining embroidery; open mouth with a stitched suede rim; side lacing behind the ears.

Eye openings:
Wide, slightly rounded eye openings framed by overlapping black leaf panels.

Mouth treatment:
Open oval mouth with a reinforced, hand-stitched suede rim.

Surface and materials:
Matte suede nap with directional texture, embossing catching raking light, gold thread glints. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Forest green, black, antique gold. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Wild, earthy, a striker connected to nature.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:jungle-spirit:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Jungle Spirit" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Deep green suede base; embossed leaf-vein patterning; black leather leaf panels at the cheeks with gold-thread veining embroidery; open mouth with a stitched suede rim; side lacing behind the ears.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:jungle-spirit:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Jungle Spirit" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Deep green suede base; embossed leaf-vein patterning; black leather leaf panels at the cheeks with gold-thread veining embroidery; open mouth with a stitched suede rim; side lacing behind the ears.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:jungle-spirit:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Jungle Spirit" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Deep green suede base; embossed leaf-vein patterning; black leather leaf panels at the cheeks with gold-thread veining embroidery; open mouth with a stitched suede rim; side lacing behind the ears.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:jungle-spirit:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Jungle Spirit" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Deep green suede base; embossed leaf-vein patterning; black leather leaf panels at the cheeks with gold-thread veining embroidery; open mouth with a stitched suede rim; side lacing behind the ears.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Sol Invictus (`mask:sol-invictus:<angle>`)

A classical radial sun mask: a sunburst that frames the face like a halo. — *Heroic, classical, a traditional técnico.*

#### FRONT — `mask:sol-invictus:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Sol Invictus" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A classical radial sun mask: a sunburst that frames the face like a halo. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Smooth full hood with a sunburst of stiffened leather rays rising around the forehead and temples (rays stay close to the head, not a giant headdress).

Physical construction:
Ivory leather base face; gold metallic leather sunburst rays individually stitched; red leather centre medallion (plain, no symbol) on the forehead; red edge piping; black back panel with red lacing.

Eye openings:
Almond eye openings outlined in red piping with a thin gold border.

Mouth treatment:
Closed: ivory panel with a stitched horizontal seam.

Surface and materials:
Polished leather sheen, metallic rays with slight wear at the tips, visible thread. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Gold, ivory, deep red. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Heroic, classical, a traditional técnico.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:sol-invictus:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sol Invictus" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Ivory leather base face; gold metallic leather sunburst rays individually stitched; red leather centre medallion (plain, no symbol) on the forehead; red edge piping; black back panel with red lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:sol-invictus:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sol Invictus" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Ivory leather base face; gold metallic leather sunburst rays individually stitched; red leather centre medallion (plain, no symbol) on the forehead; red edge piping; black back panel with red lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:sol-invictus:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sol Invictus" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Ivory leather base face; gold metallic leather sunburst rays individually stitched; red leather centre medallion (plain, no symbol) on the forehead; red edge piping; black back panel with red lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:sol-invictus:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sol Invictus" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Ivory leather base face; gold metallic leather sunburst rays individually stitched; red leather centre medallion (plain, no symbol) on the forehead; red edge piping; black back panel with red lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Void Walker (`mask:void-walker:<angle>`)

An unsettling, near-featureless mask of dark rubber and mesh that compresses the face. — *Cold, alien, a silent menace.*

#### FRONT — `mask:void-walker:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Void Walker" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
An unsettling, near-featureless mask of dark rubber and mesh that compresses the face. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Compressed, slightly narrow hood that pulls tight to the skull; smooth with no protrusions.

Physical construction:
Matte black rubberised panels; a violet-tinted fine mesh panel over the lower face; thin silver seams dividing the face into vertical strips; rear zipper with a covered placket instead of lacing.

Eye openings:
Narrow horizontal eye slits backed with dark mesh so the eyes are barely visible.

Mouth treatment:
Closed: covered by the violet mesh panel.

Surface and materials:
Dull rubber with soft sheen at the cheekbones, mesh with fine grid texture, silver seams catching thin highlights. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Black, deep violet, silver. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Cold, alien, a silent menace.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:void-walker:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Void Walker" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black rubberised panels; a violet-tinted fine mesh panel over the lower face; thin silver seams dividing the face into vertical strips; rear zipper with a covered placket instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:void-walker:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Void Walker" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black rubberised panels; a violet-tinted fine mesh panel over the lower face; thin silver seams dividing the face into vertical strips; rear zipper with a covered placket instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:void-walker:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Void Walker" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black rubberised panels; a violet-tinted fine mesh panel over the lower face; thin silver seams dividing the face into vertical strips; rear zipper with a covered placket instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:void-walker:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Void Walker" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black rubberised panels; a violet-tinted fine mesh panel over the lower face; thin silver seams dividing the face into vertical strips; rear zipper with a covered placket instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Crimson Skull (`mask:crimson-skull:<angle>`)

A punk-horror skull mask made of patchworked latex and leather, more DIY than polished. — *Chaotic, violent, a hardcore brawler.*

#### FRONT — `mask:crimson-skull:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Crimson Skull" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A punk-horror skull mask made of patchworked latex and leather, more DIY than polished. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Jagged hood with an irregular row of short leather spikes along the crown and a squared jaw.

Physical construction:
Red latex base; bone-coloured leather skull-plate panels (brow, cheekbones, jaw) stitched with heavy black cross-stitching; riveted metal studs; open mouth with stitched teeth-shaped leather tabs; black lacing at back.

Eye openings:
Deep sunken eye openings ringed with black leather panels.

Mouth treatment:
Open mouth with bone leather tooth tabs stitched around the rim.

Surface and materials:
Glossy latex highlights, scuffed leather, heavy visible stitches, slightly tarnished rivets. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Blood red, bone, black. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Chaotic, violent, a hardcore brawler.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:crimson-skull:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Crimson Skull" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Red latex base; bone-coloured leather skull-plate panels (brow, cheekbones, jaw) stitched with heavy black cross-stitching; riveted metal studs; open mouth with stitched teeth-shaped leather tabs; black lacing at back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:crimson-skull:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Crimson Skull" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Red latex base; bone-coloured leather skull-plate panels (brow, cheekbones, jaw) stitched with heavy black cross-stitching; riveted metal studs; open mouth with stitched teeth-shaped leather tabs; black lacing at back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:crimson-skull:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Crimson Skull" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Red latex base; bone-coloured leather skull-plate panels (brow, cheekbones, jaw) stitched with heavy black cross-stitching; riveted metal studs; open mouth with stitched teeth-shaped leather tabs; black lacing at back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:crimson-skull:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Crimson Skull" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Red latex base; bone-coloured leather skull-plate panels (brow, cheekbones, jaw) stitched with heavy black cross-stitching; riveted metal studs; open mouth with stitched teeth-shaped leather tabs; black lacing at back.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Ocean King (`mask:ocean-king:<angle>`)

A regal sea-monarch mask whose panels flow like waves. — *Noble, commanding, a champion from the coast.*

#### FRONT — `mask:ocean-king:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Ocean King" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A regal sea-monarch mask whose panels flow like waves. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Flowing hood with a low three-point crown at the forehead and wave-shaped panels sweeping back over the ears.

Physical construction:
Royal blue satin base; white leather wave appliqués curving from the eyes back to the ears; gold metallic crown panel with stitched edge; gold piping on the waves; white lacing.

Eye openings:
Sharp, slightly elongated eye openings trimmed in white leather.

Mouth treatment:
Closed: blue satin mouth panel with a gold piped chin line.

Surface and materials:
Satin sheen with flowing highlights, matte white leather, polished metallic crown. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Royal blue, white, gold. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Noble, commanding, a champion from the coast.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:ocean-king:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ocean King" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Royal blue satin base; white leather wave appliqués curving from the eyes back to the ears; gold metallic crown panel with stitched edge; gold piping on the waves; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:ocean-king:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ocean King" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Royal blue satin base; white leather wave appliqués curving from the eyes back to the ears; gold metallic crown panel with stitched edge; gold piping on the waves; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:ocean-king:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ocean King" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Royal blue satin base; white leather wave appliqués curving from the eyes back to the ears; gold metallic crown panel with stitched edge; gold piping on the waves; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:ocean-king:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Ocean King" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Royal blue satin base; white leather wave appliqués curving from the eyes back to the ears; gold metallic crown panel with stitched edge; gold piping on the waves; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Shadow Fox (`mask:shadow-fox:<angle>`)

A trickster fox mask influenced by theatrical fox masks but built as a wrestling hood. — *Cunning, fast, a trickster.*

#### FRONT — `mask:shadow-fox:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Shadow Fox" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A trickster fox mask influenced by theatrical fox masks but built as a wrestling hood. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Pointed: two upright stiffened leather fox ears on the crown and a slightly tapered muzzle shape at the nose.

Physical construction:
White leather face; black suede ears and back of head; red leather flame-shaped markings sweeping from the eyes to the ears; black lacing.

Eye openings:
Narrow slit eyes angled upward, backed with black mesh.

Mouth treatment:
Closed: white leather muzzle panel with a fine red stitched centre line.

Surface and materials:
Smooth white leather with soft sheen, velvety suede ears, crisp red edges. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
White, black, red. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Cunning, fast, a trickster.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:shadow-fox:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Shadow Fox" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White leather face; black suede ears and back of head; red leather flame-shaped markings sweeping from the eyes to the ears; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:shadow-fox:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Shadow Fox" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White leather face; black suede ears and back of head; red leather flame-shaped markings sweeping from the eyes to the ears; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:shadow-fox:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Shadow Fox" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White leather face; black suede ears and back of head; red leather flame-shaped markings sweeping from the eyes to the ears; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:shadow-fox:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Shadow Fox" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White leather face; black suede ears and back of head; red leather flame-shaped markings sweeping from the eyes to the ears; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Iron Serpent (`mask:iron-serpent:<angle>`)

An armoured serpent mask combining brushed metal plates and leather. — *Cold, methodical, a technical grappler.*

#### FRONT — `mask:iron-serpent:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Iron Serpent" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
An armoured serpent mask combining brushed metal plates and leather. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Layered hood with overlapping horizontal plates like snake scales, a slight ridge along the centre line.

Physical construction:
Gunmetal brushed metal-look plates riveted onto a dark green leather base; plates overlap from crown to cheeks; leather gussets between plates for flexibility; rear lacing with steel eyelets.

Eye openings:
Slanted eye openings with metal plate edges as frames.

Mouth treatment:
Closed: segmented dark green leather jaw guard.

Surface and materials:
Brushed metal with directional scratches and subtle edge wear, oiled leather, rivets with highlights. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Gunmetal, dark green, black. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Cold, methodical, a technical grappler.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:iron-serpent:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Iron Serpent" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Gunmetal brushed metal-look plates riveted onto a dark green leather base; plates overlap from crown to cheeks; leather gussets between plates for flexibility; rear lacing with steel eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:iron-serpent:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Iron Serpent" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Gunmetal brushed metal-look plates riveted onto a dark green leather base; plates overlap from crown to cheeks; leather gussets between plates for flexibility; rear lacing with steel eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:iron-serpent:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Iron Serpent" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Gunmetal brushed metal-look plates riveted onto a dark green leather base; plates overlap from crown to cheeks; leather gussets between plates for flexibility; rear lacing with steel eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:iron-serpent:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Iron Serpent" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Gunmetal brushed metal-look plates riveted onto a dark green leather base; plates overlap from crown to cheeks; leather gussets between plates for flexibility; rear lacing with steel eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Celestial Guardian (`mask:celestial-guardian:<angle>`)

A mythic guardian mask with a low crown and celestial panelling. — *Protective, heroic, mythic.*

#### FRONT — `mask:celestial-guardian:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Celestial Guardian" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A mythic guardian mask with a low crown and celestial panelling. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Crowned: a short structured crown band of metallic leather around the forehead with five gentle points; otherwise smooth rounded hood.

Physical construction:
White satin base; gold metallic leather crown band; azure leather panels framing the eyes and cheeks in symmetrical arcs; small embroidered star-points along the panels; gold piping; white lacing.

Eye openings:
Round eye openings framed by azure panels with gold piping.

Mouth treatment:
Closed: white satin with a gold piped chin arc.

Surface and materials:
Satin sheen, polished metallic crown, fine embroidery texture. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Gold, white, azure. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Protective, heroic, mythic.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:celestial-guardian:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Celestial Guardian" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; gold metallic leather crown band; azure leather panels framing the eyes and cheeks in symmetrical arcs; small embroidered star-points along the panels; gold piping; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:celestial-guardian:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Celestial Guardian" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; gold metallic leather crown band; azure leather panels framing the eyes and cheeks in symmetrical arcs; small embroidered star-points along the panels; gold piping; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:celestial-guardian:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Celestial Guardian" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; gold metallic leather crown band; azure leather panels framing the eyes and cheeks in symmetrical arcs; small embroidered star-points along the panels; gold piping; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:celestial-guardian:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Celestial Guardian" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White satin base; gold metallic leather crown band; azure leather panels framing the eyes and cheeks in symmetrical arcs; small embroidered star-points along the panels; gold piping; white lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Night Blossom (`mask:night-blossom:<angle>`)

A floral night mask in velvet whose petals frame the face. — *Elegant, mysterious, dangerous beauty.*

#### FRONT — `mask:night-blossom:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Night Blossom" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A floral night mask in velvet whose petals frame the face. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Petaled: layered velvet petal shapes around the face perimeter, forming a soft scalloped outline.

Physical construction:
Black velvet base; magenta leather petals stitched in two overlapping layers around the face; violet satin inner panel around the eyes; black lacing with magenta laces.

Eye openings:
Tapered eye openings shaped like petals, edged in violet satin.

Mouth treatment:
Closed: smooth black velvet with no seam visible.

Surface and materials:
Deep velvet nap absorbing light, glossy leather petal edges, satin shimmer. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Magenta, black, violet. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Elegant, mysterious, dangerous beauty.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:night-blossom:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Night Blossom" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black velvet base; magenta leather petals stitched in two overlapping layers around the face; violet satin inner panel around the eyes; black lacing with magenta laces.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:night-blossom:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Night Blossom" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black velvet base; magenta leather petals stitched in two overlapping layers around the face; violet satin inner panel around the eyes; black lacing with magenta laces.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:night-blossom:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Night Blossom" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black velvet base; magenta leather petals stitched in two overlapping layers around the face; violet satin inner panel around the eyes; black lacing with magenta laces.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:night-blossom:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Night Blossom" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black velvet base; magenta leather petals stitched in two overlapping layers around the face; violet satin inner panel around the eyes; black lacing with magenta laces.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Blood Moon (`mask:blood-moon:<angle>`)

A ritual crescent-moon mask with a stark horror edge. — *Ritualistic, ominous, a cult leader.*

#### FRONT — `mask:blood-moon:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Blood Moon" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A ritual crescent-moon mask with a stark horror edge. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Crescent: a large crescent-moon shaped panel wraps from one temple over the forehead to the other, its tips curving down toward the cheeks.

Physical construction:
Black leather base; red latex crescent panel raised slightly with padding; silver metallic stitching outlining the crescent; open mouth with silver-trimmed rim; black lacing.

Eye openings:
Deep, heavy-lidded eye openings sunk into black leather with silver trim.

Mouth treatment:
Open mouth with silver trim.

Surface and materials:
Matte black leather, glossy red latex with sharp reflections, bright silver thread. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Black, blood red, silver. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Ritualistic, ominous, a cult leader.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:blood-moon:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Blood Moon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black leather base; red latex crescent panel raised slightly with padding; silver metallic stitching outlining the crescent; open mouth with silver-trimmed rim; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:blood-moon:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Blood Moon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black leather base; red latex crescent panel raised slightly with padding; silver metallic stitching outlining the crescent; open mouth with silver-trimmed rim; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:blood-moon:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Blood Moon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black leather base; red latex crescent panel raised slightly with padding; silver metallic stitching outlining the crescent; open mouth with silver-trimmed rim; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:blood-moon:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Blood Moon" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black leather base; red latex crescent panel raised slightly with padding; silver metallic stitching outlining the crescent; open mouth with silver-trimmed rim; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Paper Tiger (`mask:paper-tiger:<angle>`)

An experimental tiger mask that looks folded from stiff fabric like origami. — *Playful, clever, deceptively tough.*

#### FRONT — `mask:paper-tiger:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Paper Tiger" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
An experimental tiger mask that looks folded from stiff fabric like origami. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Folded/faceted: the hood is built from flat triangular fabric planes with crisp creases, two folded ear points on top.

Physical construction:
Orange heavy cotton canvas panels stiffened and folded; ink-black stripe panels inset between planes; ivory muzzle and brow panels; visible topstitching along every fold; ivory lacing.

Eye openings:
Round eye openings with folded ivory canvas rims.

Mouth treatment:
Open: a folded diamond-shaped opening.

Surface and materials:
Matte canvas weave texture, crisp fold highlights, slight fraying on raw edges. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Orange, ivory, ink black. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Playful, clever, deceptively tough.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:paper-tiger:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Paper Tiger" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Orange heavy cotton canvas panels stiffened and folded; ink-black stripe panels inset between planes; ivory muzzle and brow panels; visible topstitching along every fold; ivory lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:paper-tiger:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Paper Tiger" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Orange heavy cotton canvas panels stiffened and folded; ink-black stripe panels inset between planes; ivory muzzle and brow panels; visible topstitching along every fold; ivory lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:paper-tiger:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Paper Tiger" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Orange heavy cotton canvas panels stiffened and folded; ink-black stripe panels inset between planes; ivory muzzle and brow panels; visible topstitching along every fold; ivory lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:paper-tiger:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Paper Tiger" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Orange heavy cotton canvas panels stiffened and folded; ink-black stripe panels inset between planes; ivory muzzle and brow panels; visible topstitching along every fold; ivory lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Glass Wraith (`mask:glass-wraith:<angle>`)

A future-era spectre mask with translucent polymer panels over dark mesh. — *Ethereal, futuristic, untouchable.*

#### FRONT — `mask:glass-wraith:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Glass Wraith" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A future-era spectre mask with translucent polymer panels over dark mesh. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Faceted elongated hood; a long, slightly pointed chin and angular cheek facets.

Physical construction:
Black mesh base hood; smoky translucent polymer facet panels bonded over it, edges sealed with silver piping; faint cyan inner lining visible through the polymer; rear magnetic closure strip instead of lacing.

Eye openings:
Long narrow eye openings that extend along the facets, edged in silver.

Mouth treatment:
Closed: a smoky polymer panel.

Surface and materials:
Translucent polymer with internal reflections and refraction, mesh visible beneath, sharp specular edges. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Smoke grey, cyan, silver. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Ethereal, futuristic, untouchable.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:glass-wraith:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Glass Wraith" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black mesh base hood; smoky translucent polymer facet panels bonded over it, edges sealed with silver piping; faint cyan inner lining visible through the polymer; rear magnetic closure strip instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:glass-wraith:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Glass Wraith" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black mesh base hood; smoky translucent polymer facet panels bonded over it, edges sealed with silver piping; faint cyan inner lining visible through the polymer; rear magnetic closure strip instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:glass-wraith:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Glass Wraith" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black mesh base hood; smoky translucent polymer facet panels bonded over it, edges sealed with silver piping; faint cyan inner lining visible through the polymer; rear magnetic closure strip instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:glass-wraith:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Glass Wraith" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Black mesh base hood; smoky translucent polymer facet panels bonded over it, edges sealed with silver piping; faint cyan inner lining visible through the polymer; rear magnetic closure strip instead of lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Sun Eater (`mask:sun-eater:<angle>`)

A predatory solar mask in leather and brass with fanged jaw detailing. — *Hungry, dominant, a monster heel.*

#### FRONT — `mask:sun-eater:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Sun Eater" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A predatory solar mask in leather and brass with fanged jaw detailing. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Fanged: a pronounced brow ridge and a lower jaw panel ending in two short downward brass-tipped fang points at the chin.

Physical construction:
Amber leather base; black leather brow and jaw panels; brass studs and brass fang caps; a partial brass ring around the face perimeter; black lacing.

Eye openings:
Sharp, angled eye openings under a heavy black leather brow.

Mouth treatment:
Covered: a black leather jaw panel over the mouth with stitched vertical lines.

Surface and materials:
Burnished amber leather, aged brass with patina, matte black leather. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Amber, black, brass. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Hungry, dominant, a monster heel.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:sun-eater:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sun Eater" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Amber leather base; black leather brow and jaw panels; brass studs and brass fang caps; a partial brass ring around the face perimeter; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:sun-eater:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sun Eater" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Amber leather base; black leather brow and jaw panels; brass studs and brass fang caps; a partial brass ring around the face perimeter; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:sun-eater:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sun Eater" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Amber leather base; black leather brow and jaw panels; brass studs and brass fang caps; a partial brass ring around the face perimeter; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:sun-eater:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Sun Eater" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Amber leather base; black leather brow and jaw panels; brass studs and brass fang caps; a partial brass ring around the face perimeter; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Velvet Jester (`mask:velvet-jester:<angle>`)

A theatrical jester mask in velvet with embroidered detail, comedic but well made. — *Mischievous, theatrical, crowd-pleasing.*

#### FRONT — `mask:velvet-jester:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Velvet Jester" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A theatrical jester mask in velvet with embroidered detail, comedic but well made. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Soft rounded hood with three short soft velvet points flopping at the crown (no bells), cheeks slightly puffed.

Physical construction:
Plum velvet base; cream satin diamond panels on the cheeks; gold embroidered scrollwork around the eyes; grinning mouth opening trimmed in gold cord; plum lacing.

Eye openings:
Round eye openings with gold embroidered surrounds.

Mouth treatment:
Grinning: a wide crescent-smile opening edged in gold cord.

Surface and materials:
Velvet nap with soft highlights, satin sheen, raised embroidery. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Plum, cream, gold. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Mischievous, theatrical, crowd-pleasing.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:velvet-jester:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Velvet Jester" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Plum velvet base; cream satin diamond panels on the cheeks; gold embroidered scrollwork around the eyes; grinning mouth opening trimmed in gold cord; plum lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:velvet-jester:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Velvet Jester" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Plum velvet base; cream satin diamond panels on the cheeks; gold embroidered scrollwork around the eyes; grinning mouth opening trimmed in gold cord; plum lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:velvet-jester:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Velvet Jester" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Plum velvet base; cream satin diamond panels on the cheeks; gold embroidered scrollwork around the eyes; grinning mouth opening trimmed in gold cord; plum lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:velvet-jester:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Velvet Jester" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Plum velvet base; cream satin diamond panels on the cheeks; gold embroidered scrollwork around the eyes; grinning mouth opening trimmed in gold cord; plum lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Storm Ram (`mask:storm-ram:<angle>`)

A heavy ram mask with curled horns, built for a powerhouse. — *Relentless power, a battering ram.*

#### FRONT — `mask:storm-ram:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Storm Ram" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A heavy ram mask with curled horns, built for a powerhouse. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Horned: two thick curled horns of moulded rubber spiral from the temples, close to the head; heavy brow.

Physical construction:
Steel-grey rubberised base; dark blue leather panels at brow and cheeks; white lightning-bolt shaped piping lines (abstract, not a logo) across the brow panels; horns with ridged texture; metal eyelets and heavy lacing.

Eye openings:
Heavy, low eye openings under a thick padded brow.

Mouth treatment:
Closed: grey panel with a reinforced chin cup.

Surface and materials:
Satin-matte rubber with ridges catching light, leather sheen, metal eyelets. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Steel grey, deep blue, white. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Relentless power, a battering ram.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:storm-ram:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Storm Ram" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Steel-grey rubberised base; dark blue leather panels at brow and cheeks; white lightning-bolt shaped piping lines (abstract, not a logo) across the brow panels; horns with ridged texture; metal eyelets and heavy lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:storm-ram:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Storm Ram" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Steel-grey rubberised base; dark blue leather panels at brow and cheeks; white lightning-bolt shaped piping lines (abstract, not a logo) across the brow panels; horns with ridged texture; metal eyelets and heavy lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:storm-ram:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Storm Ram" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Steel-grey rubberised base; dark blue leather panels at brow and cheeks; white lightning-bolt shaped piping lines (abstract, not a logo) across the brow panels; horns with ridged texture; metal eyelets and heavy lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:storm-ram:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Storm Ram" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Steel-grey rubberised base; dark blue leather panels at brow and cheeks; white lightning-bolt shaped piping lines (abstract, not a logo) across the brow panels; horns with ridged texture; metal eyelets and heavy lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Moon Viper (`mask:moon-viper:<angle>`)

A serpentine horror mask with a viper-head shape and moon-silver accents. — *Patient, venomous, a submission specialist.*

#### FRONT — `mask:moon-viper:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Moon Viper" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
A serpentine horror mask with a viper-head shape and moon-silver accents. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Serpentine: a smooth, slightly elongated head with a viper-like flattened crown that tapers backward, and subtle scale-shaped brow ridges.

Physical construction:
Matte black leather base; violet satin side panels; silver metallic leather crescent shapes above each eye; fine scale-texture embossing on the crown; black lacing with silver eyelets.

Eye openings:
Narrow vertical-slit-shaped eye openings framed in silver.

Mouth treatment:
Closed: matte black panel with a thin silver seam.

Surface and materials:
Matte leather with subtle embossed scales, satin sheen, bright silver. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Silver, violet, black. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Patient, venomous, a submission specialist.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:moon-viper:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Moon Viper" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black leather base; violet satin side panels; silver metallic leather crescent shapes above each eye; fine scale-texture embossing on the crown; black lacing with silver eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:moon-viper:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Moon Viper" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black leather base; violet satin side panels; silver metallic leather crescent shapes above each eye; fine scale-texture embossing on the crown; black lacing with silver eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:moon-viper:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Moon Viper" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black leather base; violet satin side panels; silver metallic leather crescent shapes above each eye; fine scale-texture embossing on the crown; black lacing with silver eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:moon-viper:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Moon Viper" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Matte black leather base; violet satin side panels; silver metallic leather crescent shapes above each eye; fine scale-texture embossing on the crown; black lacing with silver eyelets.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### Cinder Owl (`mask:cinder-owl:<angle>`)

An ash-coloured owl mask with feathered suede panels and copper detail. — *Wise, watchful, a veteran tactician.*

#### FRONT — `mask:cinder-owl:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "Cinder Owl" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
An ash-coloured owl mask with feathered suede panels and copper detail. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Feathered: rounded broad hood with two short feather tufts at the brow corners and a layered feather ruff at the cheeks.

Physical construction:
Charcoal suede base; layered suede feather panels in charcoal and ash grey; copper metal-look disc frames around the eyes; ivory leather beak-shaped nose bridge; charcoal lacing.

Eye openings:
Large round eye openings framed with copper rings.

Mouth treatment:
Closed: charcoal suede with a small ivory beak tip above.

Surface and materials:
Soft suede nap, feather edges with slight fraying, aged copper. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
Charcoal, copper, ivory. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Wise, watchful, a veteran tactician.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:cinder-owl:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Cinder Owl" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Charcoal suede base; layered suede feather panels in charcoal and ash grey; copper metal-look disc frames around the eyes; ivory leather beak-shaped nose bridge; charcoal lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:cinder-owl:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Cinder Owl" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Charcoal suede base; layered suede feather panels in charcoal and ash grey; copper metal-look disc frames around the eyes; ivory leather beak-shaped nose bridge; charcoal lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:cinder-owl:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Cinder Owl" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Charcoal suede base; layered suede feather panels in charcoal and ash grey; copper metal-look disc frames around the eyes; ivory leather beak-shaped nose bridge; charcoal lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:cinder-owl:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "Cinder Owl" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: Charcoal suede base; layered suede feather panels in charcoal and ash grey; copper metal-look disc frames around the eyes; ivory leather beak-shaped nose bridge; charcoal lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

### White Noise (`mask:white-noise:<angle>`)

An abstract signal-interference mask with deliberately broken asymmetric panelling. — *Disruptive, enigmatic, an anti-hero.*

#### FRONT — `mask:white-noise:front`

```text
Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "White Noise" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
An abstract signal-interference mask with deliberately broken asymmetric panelling. It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
Asymmetric: one side smooth, the other side broken into offset rectangular panels that step outward slightly.

Physical construction:
White stretch fabric base; offset rectangular panels of black and grey rubber on the left half only, as if the face is glitching; a grey rubber strip covers the mouth; black lacing.

Eye openings:
Broken: one clean oval eye opening and one eye opening interrupted by a horizontal grey bar.

Mouth treatment:
Covered by a grey rubber strip.

Surface and materials:
Matte white fabric with fine knit texture, slightly glossy rubber panels with crisp edges. Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
White, black, grey. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
Disruptive, enigmatic, an anti-hero.

Originality:
Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.

Quality:
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output:
1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 FRONT — `mask:white-noise:three-quarter` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "White Noise" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 FRONT
Camera: Camera rotated 40 degrees to the mask's left, at eye level; the near cheek panel foreshortens, the far eye opening narrows, the nose bridge breaks the far contour.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White stretch fabric base; offset rectangular panels of black and grey rubber on the left half only, as if the face is glitching; a grey rubber strip covers the mouth; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### SIDE — `mask:white-noise:side` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "White Noise" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: SIDE
Camera: True 90-degree profile facing frame left, at eye level; shows brow projection, nose/mouth relief depth, the ear opening (if any) and where the face panel meets the crown and back panels.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White stretch fabric base; offset rectangular panels of black and grey rubber on the left half only, as if the face is glitching; a grey rubber strip covers the mouth; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### 3/4 BACK — `mask:white-noise:three-quarter-back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "White Noise" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: 3/4 BACK
Camera: Camera 135 degrees around, slightly behind the mask's right ear; reveals the crown seam, the start of the rear lacing channel and how the side panels wrap.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White stretch fabric base; offset rectangular panels of black and grey rubber on the left half only, as if the face is glitching; a grey rubber strip covers the mouth; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```

#### BACK — `mask:white-noise:back` (attach the approved front image)

```text
Using the attached approved FRONT image of the CAW Helper "White Noise" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: BACK
Camera: Camera directly behind at eye level; full rear lacing (eyelets, laces, tongue/gusset), the back-of-head panel layout and the neck edge finishing.

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: White stretch fabric base; offset rectangular panels of black and grey rubber on the left half only, as if the face is glitching; a grey rubber strip covers the mouth; black lacing.

Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.
Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.

Output: 1:1 square, 1024×1024, transparent PNG.
```
