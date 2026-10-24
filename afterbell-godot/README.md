# AFTERBELL — Godot 4 greybox

A Godot 4 port of the Installment 002 boss fight: **BS-01, the Floor Manager**, in the Menswear Court (DS-10). The fight logic matches the browser greybox in `../afterbell/`.

Open this folder from the Godot project manager (**Import** → select `project.godot`), then press F5. Built and tested on **Godot 4.3**; other 4.x versions should work.

## Playable flow (demonstration build)
F5 starts in **DS-01 Cosmetics**, continues to **DS-02 Hats**, then the **Floor Manager's court**. This is a condensed slice: Alterations and the atrium are skipped.
- **Cosmetics** (`rooms/cosmetics.tscn`): the safe reflection lesson. Return the attendant's sale sign with a timed guard (K) to the receiver over the west door, which opens the hats gate. The sign can't hurt you here. After three misses, T turns on reflection assist and H asks Mika to hold the catch. E examines the mirror, atomizer and price card.
- **Hats** (`rooms/hats.tscn`): the first etiquette guards (EN-H01). Each has a 0.85 s baton tell and two stability pips: three light hits topple it, or one wound heavy strike during its tell or recovery does. They sit down and are never destroyed. The movable rack runs on a guide with two stops (hold guard at a handle and walk). The east stop opens the north aisle; the west stop opens the alcove with souvenir pin SV-01. The second guard appears once you've moved the rack, and only one guard strikes at a time.
- Checks: `tests/room_test.gd`, `tests/hats_test.gd`, `tests/sim_test.gd` (all headless).
- Sounds: drop files into `assets/sfx/` (see the README there).

## Layout
- `scripts/main.gd`: the fight. Contains the state machine, the timing table constants (Section 11), input, camera, and which clip plays when.
- `scripts/anim_data.gd`: **the keyframe source for every clip** (14 for the Floor Manager, 10 for Ren).
- `rigs/floor_manager.tscn`, `rigs/ren.tscn`: baked rigs with an AnimationPlayer. Open them in Godot to watch or edit the clips in the animation editor.
- `scripts/builders.gd`: stand-in geometry for the rigs and arena, plus the HUD and synthesized sound.
- `scripts/rig_boss.gd`: keeps the held sign between the Manager's two upper hands (it also works in the editor).
- `tests/sim_test.gd`: 30 headless checks (the "bot playtester"), including animation timing.
- `tests/capture.gd`: screenshots of staged moments in the fight.
- `tools/build_rigs.gd`: bakes `anim_data.gd` into the rig scenes.
- `tools/filmstrip.gd`: renders each clip as a contact sheet (front three-quarter and side views) for review.
- `docs/sheets/`: sample contact sheets.

## Asset rules
- **Every model is 20,000 triangles** (remesh AI output to that target before it goes in the game).
- Characters keep the rig joint names, so the clips in `anim_data.gd` drive them.
- Imported models live in `assets/`. The concept art they came from is in `assets/*_ref/`.

## Characters
- **Ren:** `assets/characters/ren/ren_rigged.glb`, made with Meshy from `assets/ren_ref/ren_sheet.png` (cleaned A-pose concept → image-to-3D → remeshed to 20k triangles → auto-rigged, 24 bones). `scripts/ren_skin.gd` retargets all of Ren's greybox clips onto this skeleton every frame, so re-baking or swapping the model keeps the animation. Meshy's rig has no finger bones, so his hands stay open.
- **Knock (sword):** `assets/props/knock/knock.glb`, made with Meshy from the sheet (concept → image-to-3D → 20k triangles). `ren_skin.gd` scales it to 1.05 m and puts the grip in Ren's right hand, oriented by the clips. Frame sheets are in `docs/models/`.

## Visual style
`scripts/style.gd` sets the look of the whole game: mid-90s ray-traced CGI, in the spirit of the era's promo renders.
- Glossy plastic and lacquer with hard white hotspots, saturated colour and densely tessellated round shapes.
- Procedural noise textures with bump on the stone, marble and wood.
- One strong sun with crisp shadows, a vivid blue sky that lights and reflects into the scene, and a mirror-still pool.
- **No tone mapping**: colours stay pure and highlights clip, as those renderers did.

Every material is created through this file, so the look can be retuned (or swapped for real textures) in one place. Samples are in `docs/style/`. Only the style is borrowed, not any existing characters or designs.

## Animation
| Floor Manager | Ren |
|---|---|
| idle, roll, present (1.0 s tell), throw, sweep_tell (1.1 s), sweep, rack_push (1.2 s tell), reflected_impact, exposed, chair_launch, bell_collision, phase_recovery, defeat_settle, counter_idle | idle, run, guard, reflect, wind (0.8 s, three ratchet steps), heavy, light, dodge, hurt, eat |

The clips are keyed poses with eased transitions. They use anticipation (dips before the sign raise and the throw), overshoot and settle (guard snap, sweep, bell collision), overlap (the sash and head trail the body, the arms fold in sequence) and inertia (the body drags behind the launching chair and pitches forward when it hits the lever). The tests require the gameplay-critical clips to stay exactly as long as the timing table says.

**Workflow:** edit `scripts/anim_data.gd`, re-bake, then render sheets and look at them:
```sh
godot --headless --path afterbell-godot -s res://tools/build_rigs.gd
godot --path afterbell-godot -s res://tools/filmstrip.gd -- --rig=boss --clips=present --out=/tmp/sheets
```
Re-baking overwrites edits made to the rig scenes in the editor. Pick one source of truth: either keep using `anim_data.gd` and re-bake, or switch to editing the clips in the editor and stop re-baking.

**Swapping in real animation later:** keep the joint names, or retarget to them. `main.gd` only refers to clips by name (see `BOSS_CLIPS` and `_ren_wanted_clip`), so a Mixamo or Blender clip with the same name drops in as a replacement.

## Status
- Every value is an untested design target, and nothing has been playtested in real time.
- Not ported yet: touch controls. The other rooms in the store have not been built.
