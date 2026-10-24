extends RefCounted
## Shared movement feel for Ren in every room.
##
## * Camera-relative input: "up" moves away from the camera on screen, whichever way it faces.
## * Momentum: speed builds over ~0.15 s and bleeds off over ~0.12 s; reversing brakes harder,
##   so direction changes feel snappy without the old instant start/stop.
## * Turning: a capped turn rate (about two full turns a second) instead of an exponential slide,
##   so Ren pivots crisply and never spins in place.
## Tuning lives in the constants below.

const ACCEL := 30.0          # m/s² toward the wanted speed
const DECEL := 38.0          # m/s² when slowing down
const REVERSE_DECEL := 60.0  # m/s² when input points against current motion
const TURN_RATE := 13.0      # rad/s
const DEADZONE := 0.15
const AXIS_SNAP := deg_to_rad(12.0)  # cameras within this of a room axis count as on it

var vel := Vector2.ZERO


## Keyboard/stick input (x right, y down) → world XZ direction relative to the camera.
static func to_world(input: Vector2, cam: Camera3D) -> Vector2:
	if input.length() < DEADZONE:
		return Vector2.ZERO
	if cam == null or not cam.is_inside_tree():
		return input
	var f := -cam.global_basis.z
	var forward := Vector2(f.x, f.z)
	if forward.length() < 0.01:
		return input
	forward = forward.normalized()
	# The room cameras pan a few degrees to frame Ren; snap that away so "up" walks
	# straight down an aisle instead of drifting sideways into the shelves.
	var ang := atan2(forward.y, forward.x)
	var axis := snappedf(ang, PI / 2.0)
	if absf(angle_difference(ang, axis)) < AXIS_SNAP:
		forward = Vector2.from_angle(axis)
	var right := Vector2(-forward.y, forward.x)
	var world := right * input.x + forward * -input.y
	return world.limit_length(1.0)


## Advance velocity toward `dir * max_speed` with acceleration, braking and quick reversals.
func step(dir: Vector2, max_speed: float, dt: float) -> Vector2:
	var target := dir * max_speed
	var rate := ACCEL
	if target.length() < vel.length() - 0.01:
		rate = DECEL
	if target.length() > 0.1 and vel.length() > 0.5 and target.normalized().dot(vel.normalized()) < -0.2:
		rate = REVERSE_DECEL
	vel = vel.move_toward(target, rate * dt)
	return vel


## Turn yaw toward a movement direction at the capped rate.
static func turn(yaw: float, dir: Vector2, dt: float, rate := TURN_RATE) -> float:
	if dir.length() < 0.1:
		return yaw
	return rotate_toward(yaw, atan2(dir.x, dir.y), rate * dt)
