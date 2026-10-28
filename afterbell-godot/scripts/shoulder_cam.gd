extends RefCounted
## Shared over-the-shoulder follow camera.
##
## Sits just above and behind Ren's right shoulder and looks almost level, a little down, at a
## point well ahead of him: his whole body is in frame and you can see across the room.
## Near a wall it widens its lens, rises a little, and tips down only as far as needed to
## keep his feet in frame, instead of going top-down.

const HEIGHT := 1.75       # camera eye height, m (about Ren's shoulder line)
const BACK := 3.4          # distance behind Ren
const SIDE := 0.55         # offset to Ren's right, for the over-the-shoulder framing
const AIM_AHEAD := 8.0     # looks at a point this far ahead of Ren...
const AIM_HEIGHT := 1.15   # ...at this height, so the view only tips down a few degrees
const SQUEEZE_RISE := 1.4  # extra height when a wall stops the pull-back: it looks down over Ren instead of crowding him
const SQUEEZE_FOV := 18.0  # extra lens width (degrees) when a wall stops the pull-back
const FOLLOW := 6.0
const FEET_MARGIN := 4.0   # degrees of floor kept below Ren's feet


## Places `cam` behind `p` facing `forward` (world XZ). `bounds` keeps the camera inside the room.
## `lift` scales height and distance (wide shots). `shake` jitters the aim point. `reach`
## scales the distance alone: with a narrower lens it keeps Ren the same size while the far
## end of the room comes forward (the long-lens look of the court).
static func place(cam: Camera3D, p: Vector2, forward: Vector2, dt: float, bounds: Rect2,
		base_fov: float, lift := 1.0, shake := 0.0, reach := 1.0, feet_margin := FEET_MARGIN) -> void:
	forward = forward.normalized() if forward.length() > 0.01 else Vector2(0, -1)
	var right := Vector2(-forward.y, forward.x)
	var want := p - forward * BACK * lift * reach + right * SIDE * reach
	var at := Vector2(clampf(want.x, bounds.position.x, bounds.end.x),
			clampf(want.y, bounds.position.y, bounds.end.y))
	var squeeze := clampf(want.distance_to(at) / (BACK * reach), 0.0, 1.0)   # how much a wall cut the pull-back
	var k := 1.0 - exp(-FOLLOW * dt) if dt > 0.0 else 1.0
	cam.position = cam.position.lerp(Vector3(at.x, HEIGHT * lift + squeeze * SQUEEZE_RISE, at.y), k)
	cam.fov = lerpf(cam.fov, base_fov + squeeze * SQUEEZE_FOV, k)

	# Aim ahead and nearly level, but tip down just enough that Ren's feet stay in frame.
	var aim := p + forward * AIM_AHEAD
	var eye := Vector2(cam.position.x, cam.position.z)
	var to_aim := maxf(eye.distance_to(aim), 0.5)
	var to_feet := maxf(eye.distance_to(p), 0.3)
	var need := atan(cam.position.y / to_feet) - deg_to_rad(cam.fov * 0.5 - feet_margin)
	var aim_h := minf(AIM_HEIGHT, cam.position.y - to_aim * tan(maxf(need, 0.0)))
	var j := Vector3((randf() - 0.5) * shake, (randf() - 0.5) * shake, 0.0) if shake > 0.0 else Vector3.ZERO
	cam.look_at(Vector3(aim.x, aim_h, aim.y) + j, Vector3.UP)
