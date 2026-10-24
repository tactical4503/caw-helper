# Great Sword Pack (Mixamo)

Supplied by the project owner (Great_Sword_Pack.zip): Adobe Mixamo motion-capture animations on the
X Bot skeleton. Mixamo animations are royalty-free for use in games; do not redistribute them as a
standalone animation pack. Only the clips the game uses (plus a few likely candidates) are copied in,
with spaces replaced by underscores.

Used by `scripts/ren_skin.gd` (see `MOCAP` there): idle, run, blocking (guard), blocking 2
(reflect), slash (light), attack (heavy), impact (hurt). Retargeted onto Ren's Meshy skeleton at
runtime; the hips' sideways and forward travel is stripped so the game keeps control of movement.
