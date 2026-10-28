# AFTERBELL — chapter progress log

Source of truth: the Installment 002 bible (the user's first message in the build session,
"Closing Time: Bellwether's Department Store", canon 0.2), plus this folder's README and code.
Visual target: the user's department-store reference (4:3, golden bell on the MENSWEAR
mezzanine, foreground perfume counters, cream-bordered teal carpet, plum flower table).
Undocumented additions are listed under **Proposals** below, not treated as canon.

## Scope: what this build is
A playable **chapter** (vertical slice of the documented game), not the complete game:
Title → DS-01 Cosmetics → DS-02 Hats → DS-03 Alterations / DS-04 Receiving → the Floor
Manager's court (DS-10, `main.tscn`, inside the atrium) → victory, reward, chapter end → title.
Not built: vestibule (DS-00), shoes (DS-06), upper landing / linens / toys / service passage
(DS-07–DS-09, DS-11), the escalator power drum, the homecoming at the depot.

## Status by area
| Area | State | Verified how |
|---|---|---|
| Title screen (in-engine atrium, New/Continue/Controls/Settings/Quit) | done | Forward+ render via tools/shell_shots.gd |
| Pause menu (Esc): resume, controls, settings, restart checkpoint, quit to title | done | same run, screenshots |
| Settings: master/effects/ambience volume buses, assists, shake | done | screenshot; volume audibility untested (no audio device here) |
| Checkpoint save (user://afterbell_save.json), Continue | done | tests/chapter_test.gd (19 checks: round trip, corrupt and foreign saves, buses, pause, chapter flag) + shell_shots run |
| Chapter end screen (governor, Night Receipt suit) → title | done | shell_shots run, screenshot |
| Atrium / court composition toward the reference | largely done | Forward+ renders (court, atrium_aisle, gallery views) |
| Department stock (leather goods, perfumery, millinery, footwear, gloves, tailoring, outfitters) | done | close-up renders (tools/furniture_shots.gd --only=stock_a,stock_b) |
| Staff figures (Hesta, Len) | done | close-up + Receiving room render |
| Charm beats, objective chain, inspectables | done | headless room tests pass; dialogue not playtested in real time |
| Audio (owned, synthesized: bell, chime, register, steps, ambience) | done | files generated; not heard (no audio device in container) |
| Performance | measured, two passes of reductions | tools/perf_probe.gd (counts below) |
| Export build (Linux, Windows) | done | Linux export boots to the title and loads every gameplay scene with no errors (exported binary run under xvfb, frames recorded); Windows export built but not run (no Windows here) |

## Chapter flow (as implemented)
1. Title → New game: Cosmetics. Opening lines (clock stopped at 5:59, the bell upstairs).
   Objective: return the sale sign to the receiver (timed guard, assist after misses).
   Errand chime + toast; the hats gate opens. The attendant can be watched straightening a tester.
2. Hats: etiquette guards (stability pips, heavy strike during tells), the movable rack,
   optional souvenir pin SV-01 (register sound), the Floor Manager's notice (inspectable).
3. Alterations / Receiving: tailor's sleeve, crank the atrium gate with Knock, Hesta's scene
   (acknowledges the pin), Len's governor news, biscuits restock, cutting table inspectable.
4. Court: arrival establishing shot on the aisle and the mezzanine bell; three bell strikes
   (the great bell answers with a warm flare); victory dialogue; reward → chapter complete.
5. Return to title; Continue resumes from the last room entered.

## Performance (tools/perf_probe.gd, Forward+, 1280x960, lavapipe software Vulkan)
Counts are renderer work per frame, independent of the GPU. Frame times here are CPU software
rendering (~1.2–2.2 s) and say nothing about real hardware; **no fps target is claimed**.

| Scene | Draw calls (start → now) | Triangles (start → now) |
|---|---|---|
| title | 1748 → 1124 | 2.11M → 1.30M |
| cosmetics | 1650 → 1089 | 742k → 653k |
| hats | 1712 → 933 | 739k → 740k |
| alterations | 2228 → 1392 | 623k → 629k |
| main (court) | 4978 → 3285 | 3.59M → 2.22M |

Changes that bought this: two directional shadow splits instead of four on the atrium key;
small stock (price cards, perfume clusters, window stock) no longer casts shadows; door
frames, portals, plaques, door leaves, sconces and glimpses merged per material; each room's
loose static meshes merged (`Atrium.merge_direct`).

## Court matched to the user's in-game reference (layout, not just lighting)
`tools/ref_shot.gd` renders the court's gameplay frame (Ren at the court's north end, facing the bell) beside the reference image.

**Changes**
- Camera:
  - the court follow camera (`COURT_FOV`, `COURT_LIFT`, `COURT_REACH` in main.gd) uses a 54° lens, sits higher, and is set back the reference's distance;
  - the two court columns that blocked the lane are gone;
  - the two chandeliers that hung into the top of the frame are gone, but their light stays.
- Court floor and centre:
  - the white court lines are replaced by teal carpet with cream / dark-teal / cream border bands;
  - the striking stand is a round plum lily table, and the lever still comes out of its south face;
  - the governor cabinet, with the B on its door, is now the front of the great bell's pedestal on the mezzanine.
- Counters and figures:
  - a long perfume counter runs down each side of the court's north end; they are solid for Ren and the Manager;
  - the clerk mannequins are a white uniform with a peaked cap and an arm held out, and a cream dress with a red SALE cap and a raised SALE card;
  - past the table: suit mannequins in fedoras and a brass jacket rack.
- Lighting and finishes:
  - globe lanterns on brass brackets on the court columns and under the mezzanine;
  - plum fleur-de-lis banners on the court columns' ground storey;
  - walnut balustrades;
  - warmer cream plaster;
  - a larger MENSWEAR sign.
- HUD:
  - octagonal brass-framed portrait, a brass rim on the health plate, and no "REN" label;
  - biscuits are shown only while Ren is hurt;
  - the objective plaque has a quatrefoil icon and an inner rule;
  - the boss bar appears only once the Floor Manager speaks;
  - an "Examine" prompt appears at the perfume counters (E examines there instead of eating a biscuit).
- Ren:
  - idle uses the keyframed clip (sword held low in the right hand, as in the reference) instead of the Mixamo great-sword idle, which carries the sword up over the shoulder.

**Polish pass:**
- Camera:
  - matched by solving the reference's projection (Ren about 46% of the frame height, his boots at 87%, horizon at 38%);
  - result: 54° lens, eye at 1.95 m, about 3.9 m back, with 6.5° of carpet below his boots (`COURT_FEET`).
- Hall, from the window forward:
  - square-grid arched window, plus a window terrace with a balustrade and palms;
  - the great bell at 62% scale on a plum dais, so the B shows over the rail;
  - blue-grey escalator treads;
  - a lit MENSWEAR floor under the mezzanine: a pendant, warm light and stocked shelving;
  - the north court columns moved in to (±5.2, −7.0), beyond the play area, with banners and globe lanterns that frame the view.
- Counters and stock:
  - plain cream counter fronts with a broad brass band;
  - gift-box heaps alternating with perfume risers;
  - a full lily bouquet on the table.
- Ren: a soft contact shadow under him.
- HUD:
  - smaller and lower, in the corners;
  - controller glyphs follow the active device.
- Grade: exposure 0.94, contrast 1.2.

**Haze and shade pass:**
- Grey haze: fog 0.011, warm grey, aerial perspective 0.35.
- Shade: the atrium key drops to 0.45 and ambient to 0.24, so the upper storeys fall into warm shade.
- Ceiling: deeper cream plaster, walnut ceiling beams and ribs, and a dimmer skylight.
- MENSWEAR floor: brighter, with display tables, suit forms, racks and two more pendants.
- Carpet: tinted further toward blue-teal.
- `ref_shot`: Ren is turned three-quarters up the aisle, as in the reference.

**Layout pass:**
- Escalators: they form a V, feet at (±2.9, −10.1) by the lily table and tops at ±4.6 on the mezzanine.
- Mezzanine and window:
  - a raised terrace (1.85 m) with a balustrade and palms behind the bell;
  - a smaller, higher window (6.4 m wide, sill 7.0);
  - suits, fedoras and navy racks flank the bell, which sits on a 0.95 m dais so the B door clears the rail.
- North court columns: their banners face the camera and their lanterns face the aisle.
- Removed: the bell-partition balustrades; the shop front under the mezzanine is replaced by stocked shelving all along the back wall.
- Haze: thicker (density 0.016).

**Shopfront pass:**
- Lily table: moved 2.3 m north, between the escalator feet. The striking lever stays where the fight needs it, on a slim brass post with a plum pad.
- Escalators: 1.45 m wide, with lighter blue-grey treads.
- MENSWEAR floor: a walnut-framed glazed shopfront with an open centre doorway under the mezzanine.

- MENSWEAR floor, continued:
  - walnut panelling on its back wall and soffit;
  - frosted globe pendants in place of the enamel shades.
- Past the table: suit forms in dark suits, and the brass jacket rack turned to the aisle.

**Checks:** all six test suites pass; the court costs 3272 draws.

**Not identical:** the reference is a painting. The atrium is deeper than it shows, the court's side columns sit outside the frame, the shop under the mezzanine is less lit, and Ren is the game's model.

**Checks:** all six test suites pass, and the fight and door views were re-rendered.

## Look: golden-hour department store (current, user's in-game reference)
`Style.LOOK = "deco"`:
- warm amber ambient instead of the blue sky fill;
- a soft honey key;
- satin materials;
- frosted globe lamps that glow into the bloom;
- filmic tone mapping, saturation 1.12 and contrast 1.16.

Checked with Forward+ renders of Cosmetics, the court, the aisle and the east gallery; all six test suites pass. The "cg95" grade below is kept as an option.

## Look: 90s promo render (user request, reference image)
`Style.LOOK = "cg95"` (style.gd) restyles the game toward the 90s promo render the user picked:
- no tone mapping, so highlights clip;
- saturated blue sky fill in the shade;
- a crisp warm-white key at full specular;
- glossy lacquer materials;
- normal maps at 1.7x;
- saturation 1.38 and contrast 1.3;
- bloom on the hotspots and a light blue haze.

The atrium keeps its sun direction and reach; Ren gets a clear coat. To revert, set it to `"store"`.

How it was checked: Forward+ renders of Cosmetics, Hats, Alterations, the court and the counters; all six test suites pass; draw calls unchanged (perf_probe). Not seen in real time.

## Release gate
`tools/release_check.sh [--export]` must pass before a build ships. It runs:
- the six test suites;
- an asset-path check (`tools/asset_paths.py`);
- every scene run with a real renderer (`tools/scene_check.gd`);
- with `--export`: the Linux and Windows exports, and the Linux build booting the title and the court.

Latest polish pass:
- Settings checkboxes are now brass boxes that show on the plum card.
- The title's controls line is readable.
- The camera rises over Ren in tight rooms (Receiving no longer crops him).
- The Floor Manager has been re-dressed: frock coat, waistcoat, gloved hands, leather chair.
- His sign is lettered "THE STORE IS CLOSED".
- The guards and mannequins use the supplied models.
- Ren's idle is balanced.

## Current task
Delivery: builds exported and the Linux build verified. Remaining polish is listed under
known defects.

## Next exact action
Optional: further court draw-call work (remaining draws are many baked prop instances, one
per material surface); a real-hardware fps measurement by the user.

## Room entry points
Ren now enters each room a few steps in from its door (Cosmetics, Hats, Alterations), because
at the doors the follow camera was squeezed against the wall and opened on a cramped close-up.
Cosmetics also opens on a held establishing view on a new game.

## Changed files and asset paths (this build session)
- New: `scripts/game.gd` (autoload Game), `scripts/title.gd`, `rooms/title.tscn`,
  `tools/make_sfx.py`, `tools/make_emblem.py`, `tools/shell_shots.gd`, `tools/perf_probe.gd`,
  `assets/sfx/*.wav` (generated), `assets/fonts/LiberationSerif-*.ttf` (+ OFL licence),
  `assets/textures/signs/emblem_b*.png`.
- Changed: `project.godot` (main scene = title, autoload, 1280x960 4:3 letterbox, UI font),
  `scripts/builders.gd` (court north edge, striking stand, mezzanine bell, cream borders,
  stocked counters, banners, Sfx buses/cues/footsteps), `scripts/atrium.gd` (one balcony
  storey, roof 12 m, window, lighting placement, shop window stock, merges),
  `scripts/props.gd` (stock props, person builder, shadows), `scripts/main.gd` (shell hooks,
  arrival shot, bell glow, Manager start position), the three room scripts (shell hooks,
  beats, flags, merges), `scripts/style.gd`, `scripts/glimpse.gd`.

## Meshy jobs
- None submitted this session. Login expired; a device login (code shown in chat) was not
  approved within its window and the CLI exited with code 8. Staff figures and all stock
  were built locally instead. Earlier jobs (Ren, Knock) are recorded in
  `assets/meshy_output/history.json` (gitignored).

## Known defects and blockers
- **Export**: `export_presets.cfg` has Linux and Windows presets (scenes + runtime-loaded
  folders; unused source GLBs excluded). Builds go to `../build/` (gitignored, ~134 MB Linux,
  ~152 MB Windows). The Windows build is untested.
- **Meshy**: blocked on login approval (see above).
- The four-image comparison sheet mentioned in the brief was not attached; the department
  store reference image was used as the target.
- The court sits on the ground floor of the atrium while the bible puts DS-10 upstairs; the
  great bell is upstairs on the mezzanine and wired to the court's stand (proposal below).
- Real-time feel, audio levels and controller support are untested (no display/audio device;
  only automated tests and rendered stills).

## Proposals (not canon)
- The great service bell stands on the MENSWEAR mezzanine (as in the reference) and is rung by
  cable from a low striking stand at the court's north edge; the governor cabinet hangs under
  the bell ("behind the service bell, upstairs").
- Opening narration ("Outside, the tower clock has stopped at 5:59…") condenses the bible's
  vestibule scene into Cosmetics, since the vestibule is not built.
- Inspectable lines (the Floor Manager's notice, the attendant's tester, the cutting table,
  Hesta on the lunchroom pin, Nell on the pin in the court) are new writing.
- One balcony storey instead of two, to match the reference's composition.
