# AFTERBELL — Godot 4 greybox

A Godot 4 port of the Installment 002 boss fight: **BS-01, the Floor Manager**, in the Menswear Court (DS-10). The fight logic matches the browser greybox in `../afterbell/`.

Open this folder from the Godot project manager (**Import** → select `project.godot`), then press F5. Built and tested on **Godot 4.3**; other 4.x versions should work.

## Layout
- `scripts/main.gd`: the fight. Contains the state machine, the timing table constants (Section 11), input, camera and flow.
- `scripts/builders.gd`: primitive stand-in geometry, the HUD and synthesized sound cues. Replace these nodes with real art later without touching `main.gd`.
- `tests/sim_test.gd`: headless fight checks (the "bot playtester").
- `tests/capture.gd`: renders staged moments of the fight to PNG for visual review.

## Tools
```sh
# 23 automated checks: timed reflect, three bells, victory, wrong side, locked chair, sweep, rack shove, defeat
godot --headless --path afterbell-godot -s res://tests/sim_test.gd

# screenshots of approach / present / exposed / launch / victory (needs a renderer, not --headless)
godot --path afterbell-godot -s res://tests/capture.gd -- --out=/tmp/shots [--size=390x844]
```
In headless mode Godot prints `Parameter "m" is null` from its dummy renderer. This is harmless.

## Status
- Every value is an untested design target, and nothing has been playtested in real time.
- Not ported yet: touch controls. The other rooms in the store have not been built.
