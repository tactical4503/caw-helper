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
