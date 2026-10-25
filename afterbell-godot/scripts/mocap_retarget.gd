extends RefCounted
## Motion capture for the supplied staff figures (npc10 / npc12): plays Mixamo clips from the
## great-sword pack (assets/anim/great_sword/) on a hidden Mixamo skeleton and copies each
## mapped bone's motion onto the figure's own skeleton, the same way scripts/ren_skin.gd drives
## Ren. Each bone takes the source bone's rotation away from its rest pose, applied to the
## figure's rest pose after a correction that turns the figure's rest limb direction onto the
## source's (both rigs stand with arms down here, so the correction is small). Hips height
## follows the source, scaled to the figure; hips travel is stripped (the game moves the figure).
##
## Clips crossfade on the source player (`play(name, blend)`), and the result can itself be
## blended per bone toward a procedural pose (`overlay`), for poses with no clip (sitting).

const DIR := "res://assets/anim/great_sword/"
## Mixamo bone -> figure bone, per model, and the child that sets each bone's rest direction.
const RIGS := {
	"npc10": {"Hips": "Bone01", "Spine2": "Bone02", "Head": "Bone03",
		"RightArm": "Bone12", "RightForeArm": "Bone13", "RightHand": "Bone14",
		"LeftArm": "Bone15", "LeftForeArm": "Bone16", "LeftHand": "Bone17",
		"RightUpLeg": "Bone04", "RightLeg": "Bone05", "RightFoot": "Bone08",
		"LeftUpLeg": "Bone18", "LeftLeg": "Bone19", "LeftFoot": "Bone20"},
	"npc12": {"Hips": "Bone04", "Spine2": "Bone05", "Head": "Bone08",
		"RightArm": "Bone01", "RightForeArm": "Bone02", "RightHand": "Bone03",
		"LeftArm": "Bone21", "LeftForeArm": "Bone22", "LeftHand": "Bone23",
		"RightUpLeg": "Bone06", "RightLeg": "Bone07", "RightFoot": "Bone09",
		"LeftUpLeg": "Bone18", "LeftLeg": "Bone19", "LeftFoot": "Bone20"},
}
const CHAIN := {"Hips": "Spine2", "Spine2": "Head", "RightArm": "RightForeArm", "RightForeArm": "RightHand",
	"LeftArm": "LeftForeArm", "LeftForeArm": "LeftHand", "RightUpLeg": "RightLeg", "RightLeg": "RightFoot",
	"LeftUpLeg": "LeftLeg", "LeftLeg": "LeftFoot"}
const BORROW := {"Head": "Spine2", "RightHand": "RightForeArm", "LeftHand": "LeftForeArm",
	"RightFoot": "RightLeg", "LeftFoot": "LeftLeg"}

var skel: Skeleton3D
var src_skel: Skeleton3D
var player: AnimationPlayer
var src_of := {}       # figure bone -> source bone
var fix := {}          # figure bone -> Basis (figure rest dir -> source rest dir)
var order: Array = []  # figure bones, parents first
var src_hips := -1
var hips := -1
var height_ratio := 1.0
var hand := -1
var last := {}         # figure bone -> Quaternion from the last update
## Foot planting: per leg [thigh, shin, foot] bone indices, the ankle's rest height above the
## floor, and the lock state (world position the foot is pinned to, and its blend weight).
var legs: Array = []
var ankle_h := {}
var lock_at := {}
var lock_w := {}
var last_foot := {}
var releasing := {}
const LOCK_SPEED := 0.35   # m/s: slower than this near the floor counts as a planted foot
const LIFT := 0.035        # m above its rest height and the foot is swinging
const BLEND := 14.0        # how fast a lock takes hold (1/s)...
const RELEASE := 6.0       # ...and how gently it lets go, so the foot glides off instead of popping
const RELEASE_DIST := 0.2  # m: the body has moved this far from a pinned foot, let it go
const CONTACT := 0.07      # m: within this of the floor the foot is pressed down onto it


## `figure` is the instanced model, `rig` its key in RIGS, `clips` {name: [file, loops]}.
## `holder` keeps the hidden source skeleton in the tree.
func _init(figure: Node, rig: String, clips: Dictionary, holder: Node) -> void:
	var found := figure.find_children("*", "Skeleton3D", true, false)
	if found.is_empty() or not ResourceLoader.exists(DIR + "great_sword_idle.fbx"):
		return
	skel = found[0]
	var src: Node3D = load(DIR + "great_sword_idle.fbx").instantiate()
	src.visible = false
	holder.add_child(src)
	src_skel = src.find_children("*", "Skeleton3D", true, false)[0]
	player = src.find_children("*", "AnimationPlayer", true, false)[0]
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var lib := AnimationLibrary.new()
	for name in clips:
		var path: String = DIR + clips[name][0] + ".fbx"
		if not ResourceLoader.exists(path):
			continue
		var scene: Node = load(path).instantiate()
		var ap: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
		var anim: Animation = ap.get_animation(ap.get_animation_list()[0]).duplicate()
		anim.loop_mode = Animation.LOOP_LINEAR if clips[name][1] else Animation.LOOP_NONE
		_strip_travel(anim)
		lib.add_animation(name, anim)
		scene.free()
	player.add_animation_library("g", lib)
	var map: Dictionary = RIGS[rig]
	for m in map:
		var sb := src_skel.find_bone("mixamorig_" + m)
		var tb := skel.find_bone(map[m])
		if sb < 0 or tb < 0:
			continue
		src_of[tb] = sb
		fix[tb] = Basis()
		if CHAIN.has(m):
			var sc := src_skel.find_bone("mixamorig_" + CHAIN[m])
			var tc := skel.find_bone(map[CHAIN[m]])
			if sc >= 0 and tc >= 0:
				var sd := (src_skel.get_bone_global_rest(sc).origin - src_skel.get_bone_global_rest(sb).origin).normalized()
				var td := (skel.get_bone_global_rest(tc).origin - skel.get_bone_global_rest(tb).origin).normalized()
				fix[tb] = Basis(_arc(td, sd))
	for m in BORROW:
		var tb := skel.find_bone(map.get(m, ""))
		var pb := skel.find_bone(map.get(BORROW[m], ""))
		if tb >= 0 and pb >= 0 and fix.has(pb):
			fix[tb] = fix[pb]
	for i in skel.get_bone_count():
		order.append(i)
	src_hips = src_skel.find_bone("mixamorig_Hips")
	hips = skel.find_bone(map["Hips"])
	hand = skel.find_bone(map["RightHand"])
	for side in ["Left", "Right"]:
		var leg := [skel.find_bone(map[side + "UpLeg"]), skel.find_bone(map[side + "Leg"]), skel.find_bone(map[side + "Foot"])]
		if leg.min() >= 0:
			legs.append(leg)
			ankle_h[leg[2]] = skel.get_bone_global_rest(leg[2]).origin.y
	var tgt_h := skel.get_bone_global_rest(hips).origin.y
	height_ratio = tgt_h / maxf(src_skel.get_bone_global_rest(src_hips).origin.y, 0.01)


func ok() -> bool:
	return skel != null and player != null


func play(clip: String, blend := 0.25, speed := 1.0) -> void:
	if ok() and player.has_animation("g/" + clip):
		player.play("g/" + clip, blend, speed)


func length(clip: String) -> float:
	return player.get_animation("g/" + clip).length if ok() and player.has_animation("g/" + clip) else 0.0


## Advances the clip and writes the figure's pose. `overlay` {bone index: Quaternion (local)}
## with weight `w` blends chosen bones toward a procedural pose (0 = pure capture).
func update(dt: float, overlay := {}, w := 0.0) -> void:
	if not ok():
		return
	player.advance(dt)
	var globals := {}
	for i in order:
		var parent := skel.get_bone_parent(i)
		var rest_local := skel.get_bone_rest(i)
		var local := rest_local
		if src_of.has(i):
			var sb: int = src_of[i]
			var delta := src_skel.get_bone_global_pose(sb).basis.orthonormalized() * src_skel.get_bone_global_rest(sb).basis.orthonormalized().inverse()
			var want: Basis = delta * (fix[i] as Basis) * skel.get_bone_global_rest(i).basis.orthonormalized()
			var pb: Basis = (globals[parent] as Transform3D).basis if globals.has(parent) else (skel.get_bone_global_rest(parent).basis if parent >= 0 else Basis())
			local.basis = pb.orthonormalized().inverse() * want
			if sb == src_hips:
				var off := (src_skel.get_bone_global_pose(sb).origin - src_skel.get_bone_global_rest(sb).origin) * height_ratio
				local.origin = rest_local.origin + Vector3(0.0, off.y, 0.0)
		var q := local.basis.orthonormalized().get_rotation_quaternion()
		if w > 0.0 and overlay.has(i):
			q = q.slerp(overlay[i], w)
			local.basis = Basis(q)
		last[i] = q
		var g := Transform3D(local.basis.orthonormalized(), local.origin)
		globals[i] = (globals[parent] * g) if globals.has(parent) else ((Transform3D(skel.get_bone_global_rest(parent).basis, skel.get_bone_global_rest(parent).origin) * g) if parent >= 0 else g)
		skel.set_bone_pose_rotation(i, q)
		skel.set_bone_pose_position(i, local.origin)


## Plants the feet on the floor (world y = 0 under the figure). A foot that is near the floor and
## barely moving in the world locks where it is, so it doesn't skate while the body moves over it;
## when the capture lifts it, the lock fades out. No foot goes through the floor. Each leg is a
## two-bone IK solve (thigh, shin) that keeps the knee bending the way the capture bent it, and
## the foot keeps the capture's orientation. `weight` scales it all (0 while sitting).
func plant_feet(dt: float, weight := 1.0) -> void:
	if not ok() or legs.is_empty():
		return
	var to_world := skel.global_transform
	var to_skel := to_world.affine_inverse()
	for leg in legs:
		var f: int = leg[2]
		var anim_w: Vector3 = to_world * skel.get_bone_global_pose(f).origin
		var floor_y: float = ankle_h[f] * to_world.basis.get_scale().y   # ankle height above the floor (y = 0)
		var prev: Vector3 = last_foot.get(f, anim_w)
		var spd := Vector2(anim_w.x - prev.x, anim_w.z - prev.z).length() / maxf(dt, 0.0001)
		last_foot[f] = anim_w
		var low := anim_w.y < floor_y + LIFT
		var w: float = lock_w.get(f, 0.0)
		var held: bool = lock_at.has(f) and not releasing.get(f, false)
		if held and (not low or Vector2(anim_w.x - lock_at[f].x, anim_w.z - lock_at[f].z).length() > RELEASE_DIST):
			releasing[f] = true   # the capture has lifted the foot (or the body moved on): glide off
			held = false
		if not lock_at.has(f) and low and spd < LOCK_SPEED:
			lock_at[f] = Vector3(anim_w.x, floor_y, anim_w.z)
			releasing[f] = false
			held = true
		w = move_toward(w, 1.0 if held else 0.0, (BLEND if held else RELEASE) * dt)
		if w <= 0.0 and not held:
			lock_at.erase(f)
			releasing.erase(f)
		lock_w[f] = w
		var target := anim_w
		if lock_at.has(f):
			var e := smoothstep(0.0, 1.0, w)
			target = anim_w.lerp(lock_at[f], e)
		# Contact: a foot the capture holds just above the floor is set down on it.
		if anim_w.y < floor_y + CONTACT:
			target.y = lerpf(floor_y, target.y, clampf((anim_w.y - floor_y) / CONTACT, 0.0, 1.0) * 0.4)
		target.y = maxf(target.y, floor_y)
		target = anim_w.lerp(target, weight)
		if target.distance_to(anim_w) > 0.002:
			_two_bone(leg, to_skel * target)


func _two_bone(leg: Array, t: Vector3) -> void:
	var ti: int = leg[0]
	var si: int = leg[1]
	var fi: int = leg[2]
	var gt := skel.get_bone_global_pose(ti)
	var gs := skel.get_bone_global_pose(si)
	var gf := skel.get_bone_global_pose(fi)
	var a := gt.origin
	var b := gs.origin
	var c := gf.origin
	var la := a.distance_to(b)
	var lb := b.distance_to(c)
	var d := clampf(a.distance_to(t), absf(la - lb) + 0.001, la + lb - 0.001)
	# Knee: open or close it to the angle that puts the foot at distance d from the hip.
	var axis := (a - b).cross(c - b)
	if axis.length() < 1e-5:
		axis = gt.basis.x   # straight leg: bend about the thigh's own side axis
	axis = axis.normalized()
	var cur := (a - b).angle_to(c - b)
	var want := acos(clampf((la * la + lb * lb - d * d) / (2.0 * la * lb), -1.0, 1.0))
	var r1 := Basis(axis, cur - want)
	if absf((a - b).angle_to(r1 * (c - b)) - want) > 0.01:
		r1 = Basis(axis, want - cur)
	var shin_b := r1 * gs.basis
	var c2 := b + r1 * (c - b)
	# Hip: swing the whole leg so the foot lands on the target.
	var r2 := Basis(_arc((c2 - a).normalized(), (t - a).normalized()))
	var thigh_b := r2 * gt.basis
	shin_b = r2 * shin_b
	var parent := skel.get_bone_parent(ti)
	var pb := skel.get_bone_global_pose(parent).basis if parent >= 0 else Basis()
	skel.set_bone_pose_rotation(ti, (pb.inverse() * thigh_b).orthonormalized().get_rotation_quaternion())
	skel.set_bone_pose_rotation(si, (thigh_b.inverse() * shin_b).orthonormalized().get_rotation_quaternion())
	skel.set_bone_pose_rotation(fi, (shin_b.inverse() * gf.basis).orthonormalized().get_rotation_quaternion())


static func _strip_travel(anim: Animation) -> void:
	var t := anim.find_track(NodePath("Skeleton3D:mixamorig_Hips"), Animation.TYPE_POSITION_3D)
	if t < 0:
		return
	var first: Vector3 = anim.track_get_key_value(t, 0)
	for k in anim.track_get_key_count(t):
		var v: Vector3 = anim.track_get_key_value(t, k)
		anim.track_set_key_value(t, k, Vector3(first.x, v.y, first.z))


static func _arc(a: Vector3, b: Vector3) -> Quaternion:
	var c := a.cross(b)
	var d := a.dot(b)
	if c.length() < 1e-6:
		return Quaternion() if d > 0.0 else Quaternion(Vector3.UP if absf(a.y) < 0.9 else Vector3.RIGHT, PI)
	return Quaternion(c.normalized(), acos(clampf(d, -1.0, 1.0)))
