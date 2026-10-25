@tool
extends Node
## Retargets the greybox Ren rig's animation onto the imported Meshy model, every frame.
##
## The AnimationPlayer keeps animating the (hidden) greybox joints, so all the authored clips and
## main.gd's clip selection stay unchanged. For each mapped joint we take its rotation relative to
## the rig root (greybox joints rest with identity rotation, so that is the pose delta) and apply it
## to the matching bone's rest orientation. A per-bone rest correction turns the model's own rest
## direction (Meshy rigs in an A-pose) onto the greybox rest direction (limbs straight down), so
## "arms at the sides" in a clip is arms at the sides on the model too.
##
## Runs after the AnimationPlayer (process_priority) and also previews in the editor.

const MAP := {
	# greybox joint path        : [model bone, greybox rest direction of the segment]
	"Pelvis": ["Hips", Vector3.ZERO],
	"Pelvis/Torso": ["Spine02", Vector3.UP],
	"Pelvis/Torso/Head": ["Head", Vector3.UP],
	"Pelvis/LegL": ["LeftUpLeg", Vector3.DOWN],
	"Pelvis/LegL/KneeL": ["LeftLeg", Vector3.DOWN],
	"Pelvis/LegR": ["RightUpLeg", Vector3.DOWN],
	"Pelvis/LegR/KneeR": ["RightLeg", Vector3.DOWN],
	"Pelvis/Torso/ArmL": ["LeftArm", Vector3.DOWN],
	"Pelvis/Torso/ArmL/ForearmL": ["LeftForeArm", Vector3.DOWN],
	"Pelvis/Torso/ArmR": ["RightArm", Vector3.DOWN],
	"Pelvis/Torso/ArmR/ForearmR": ["RightForeArm", Vector3.DOWN],
}
const HIP_REST_Y := 0.92  # greybox pelvis rest height (metres)

## Motion capture (Mixamo great-sword pack in assets/anim/great_sword/). When the greybox player
## starts a clip listed here, the mocap version plays on a hidden Mixamo skeleton and is retargeted
## onto the model instead; other clips (wind, dodge, eat) stay keyframed. Gameplay timing is kept
## by fitting each one-shot to the length the game expects.
const MOCAP_DIR := "res://assets/anim/great_sword/"
const MOCAP := {
	# game clip: [file, loops, play length in seconds (0 = natural length)]
	"idle": ["great_sword_idle", true, 0.0],
	"run": ["great_sword_run", true, 0.0],
	"guard": ["great_sword_blocking", false, 0.35],
	"reflect": ["great_sword_blocking_2", false, 0.3],
	"light": ["great_sword_slash", false, 0.5],
	"heavy": ["great_sword_attack", false, 0.65],
	"hurt": ["great_sword_impact", false, 0.45],
}
## Mixamo bone -> Meshy bone.
const BONES := {
	"Hips": "Hips", "Spine": "Spine02", "Spine1": "Spine01", "Spine2": "Spine", "Neck": "neck", "Head": "Head",
	"LeftShoulder": "LeftShoulder", "LeftArm": "LeftArm", "LeftForeArm": "LeftForeArm", "LeftHand": "LeftHand",
	"RightShoulder": "RightShoulder", "RightArm": "RightArm", "RightForeArm": "RightForeArm", "RightHand": "RightHand",
	"LeftUpLeg": "LeftUpLeg", "LeftLeg": "LeftLeg", "LeftFoot": "LeftFoot", "LeftToeBase": "LeftToeBase",
	"RightUpLeg": "RightUpLeg", "RightLeg": "RightLeg", "RightFoot": "RightFoot", "RightToeBase": "RightToeBase",
}
## Each bone's rest direction is measured toward this child; bones without one borrow the parent's.
const CHAIN := {
	"Hips": "Spine", "Spine": "Spine1", "Spine1": "Spine2", "Spine2": "Neck", "Neck": "Head",
	"LeftShoulder": "LeftArm", "LeftArm": "LeftForeArm", "LeftForeArm": "LeftHand",
	"RightShoulder": "RightArm", "RightArm": "RightForeArm", "RightForeArm": "RightHand",
	"LeftUpLeg": "LeftLeg", "LeftLeg": "LeftFoot", "LeftFoot": "LeftToeBase",
	"RightUpLeg": "RightLeg", "RightLeg": "RightFoot", "RightFoot": "RightToeBase",
}
const BORROW := {"Head": "Neck", "LeftHand": "LeftForeArm", "RightHand": "RightForeArm", "LeftToeBase": "LeftFoot", "RightToeBase": "RightFoot"}
const MIX_TIME := 0.12
@export var use_mocap := true

@export var skin_path: NodePath = ^"../Skin"
@export var sword_bone := "RightHand"
## Knock, made with Meshy. Its handle is at +x, the blade runs toward -x, the flat face points
## along z, and it is 1.9 m long; this maps it onto the greybox sword frame (grip at the origin,
## blade along -y, flat face on z) at 1.05 m.
@export var sword_model := "res://assets/props/knock/knock.glb"
## Ren's albedo with the armour paint deepened (tools/deepen_red.py); empty keeps Meshy's own.
@export var armor_albedo := "res://assets/characters/ren/ren_armor_deep.png"
## Ren's metallic-roughness map made matte except on metal (tools/matte_pbr.py).
@export var armor_roughness := "res://assets/characters/ren/ren_mr_matte.png"
const SWORD_FIT := Transform3D(Basis(Vector3(0, 0.55, 0), Vector3(0.55, 0, 0), Vector3(0, 0, -0.55)), Vector3(0, -0.41, 0))

var _rig: Node3D
var _skel: Skeleton3D
var _joint_of_bone := {}      # bone index -> greybox joint Node3D
var _correction := {}         # bone index -> Basis (model rest dir -> greybox rest dir)
var _to_skel := Basis()       # character space -> skeleton space (rotation only)
var _unit := 1.0              # metres -> skeleton units
var _sword_src: Node3D
var _sword_view: Node3D
var _hand := -1
var _left_hand := -1
const HAND_SCALE := 0.8
## Meshy's rig has no finger bones, so the modelled fingers stay flat and splayed. At load we
## add knuckle, mid-finger and thumb bones to each hand, move the finger and thumb vertices'
## weights onto them, and curl them every frame into a fist round the grip. Measurements are in
## the hand bone's local space (centimetres; +y runs out along the fingers, the palm faces the
## thumb side: -x on the right hand, +x on the left).
const KNUCKLE_Y := 12.0      # where the fingers leave the palm
const MID_Y := 17.0          # the middle finger joint
const THUMB_BASE := Vector3(3.0, 6.5, 3.5)   # x is mirrored per hand
const CURL_KNUCKLE := 1.35   # radians: fingers fold across the grip...
const CURL_MID := 1.25       # ...and wrap round it
const CURL_THUMB := 0.75
## Where the grip sits in the closed fist, in hand-local centimetres (x mirrored per hand).
const GRIP_LOCAL := Vector3(3.0, 9.5, 0.0)
var _finger_curl := {}       # bone -> Basis applied on top of its rest every frame

var _grey_anim: AnimationPlayer
var _src_skel: Skeleton3D
var _src_anim: AnimationPlayer
var _src_of := {}             # target bone index -> source bone index
var _mocap_fix := {}          # target bone index -> Basis (target rest dir -> source rest dir, character space)
var _src_hips := -1
var _height_ratio := 1.0
var _src_hand := -1
var _mocap_sword := Basis()   # hand space -> sword frame, measured from the Mixamo rest pose
var _mocap := false
var _cur := ""
var _last_pos := 0.0
var _last_locals: Array = []
var _snapshot: Array = []
var _mix := 1.0
var _last_root := Vector3.ZERO
var _ground_speed := 0.0
const RUN_CLIP_SPEED := 2.7   # m/s the Mixamo run cycle covers at 1x


func _ready() -> void:
	process_priority = 100
	_rig = get_parent() as Node3D
	var skin := get_node_or_null(skin_path)
	if skin == null:
		return
	var found := skin.find_children("*", "Skeleton3D", true, false)
	if found.is_empty():
		return
	_skel = found[0]
	_add_finger_bones(skin)
	# The skeleton may sit under a scaled/rotated Armature node (Meshy exports centimetres).
	var rel := _relative_transform(_skel, _rig)
	_unit = 1.0 / rel.basis.get_scale().y
	_to_skel = rel.basis.orthonormalized().inverse()
	for path in MAP:
		var bone := _skel.find_bone(MAP[path][0])
		var joint := _rig.get_node_or_null(NodePath(path)) as Node3D
		if bone < 0 or joint == null:
			push_warning("ren_skin: cannot map %s -> %s" % [path, MAP[path][0]])
			continue
		_joint_of_bone[bone] = joint
		var want: Vector3 = MAP[path][1]
		_correction[bone] = Basis()
		if want != Vector3.ZERO:
			var child := _first_child_bone(bone)
			if child >= 0:
				var from := (_skel.get_bone_global_rest(child).origin - _skel.get_bone_global_rest(bone).origin).normalized()
				var to := (_to_skel * want).normalized()
				_correction[bone] = Basis(_shortest_arc(from, to))
	# Hide the greybox body, keep its joints animating. The sword is shown as a copy that
	# follows the model's hand.
	for mi in _rig.get_node("Pelvis").find_children("*", "MeshInstance3D", true, false):
		mi.visible = false
	_hand = _skel.find_bone(sword_bone)
	_left_hand = _skel.find_bone("LeftHand")
	_grey_anim = _rig.get_node_or_null("AnimationPlayer")
	_setup_mocap()
	_restyle(skin)
	_sword_src = _rig.get_node_or_null("Pelvis/Torso/ArmR/ForearmR/Sword")
	if _sword_src and _hand >= 0:
		_sword_view = Node3D.new()
		_sword_view.name = "SwordView"
		_sword_view.top_level = true
		add_child(_sword_view)
		if ResourceLoader.exists(sword_model):
			var knock: Node3D = load(sword_model).instantiate()
			knock.transform = SWORD_FIT
			_sword_view.add_child(knock)
		else:  # fall back to the greybox blade
			var copy := _sword_src.duplicate() as Node3D
			copy.transform = Transform3D()
			_sword_view.add_child(copy)
			for mi in copy.find_children("*", "MeshInstance3D", true, false):
				mi.visible = true


## Satin finish: Meshy's textures with a matte paint layer (tools/matte_pbr.py) so the armour
## reads as painted plates; only the metal parts keep tight reflections.
func _restyle(skin: Node) -> void:
	for mi in skin.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		for i in m3.mesh.get_surface_count():
			var src := m3.get_active_material(i) as StandardMaterial3D
			if src == null:
				continue
			var m := src.duplicate() as StandardMaterial3D
			if m.albedo_texture and armor_albedo != "" and ResourceLoader.exists(armor_albedo):
				m.albedo_texture = load(armor_albedo)
			if armor_roughness != "" and ResourceLoader.exists(armor_roughness):
				m.roughness_texture = load(armor_roughness)
				m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
				m.roughness = 1.0
			m.clearcoat_enabled = false
			m.metallic_specular = 0.25   # no bright streaks across his back from overhead lights
			if preload("res://scripts/style.gd").CG:
				# The promo-render look: lacquered plates under a clear coat, so the key leaves a
				# hard white hotspot on each rounded plate while the paint underneath stays satin.
				m.roughness = 0.6
				m.metallic_specular = 0.55
				m.clearcoat_enabled = true
				m.clearcoat = 0.7
				m.clearcoat_roughness = 0.12
			m3.set_surface_override_material(i, m)


func _setup_mocap() -> void:
	if not use_mocap or not ResourceLoader.exists(MOCAP_DIR + "great_sword_idle.fbx"):
		return
	var src_root: Node3D = load(MOCAP_DIR + "great_sword_idle.fbx").instantiate()
	src_root.name = "MocapSource"
	add_child(src_root)
	_src_skel = src_root.find_children("*", "Skeleton3D", true, false)[0]
	_src_anim = src_root.find_children("*", "AnimationPlayer", true, false)[0]
	var lib := AnimationLibrary.new()
	for clip in MOCAP:
		var path: String = MOCAP_DIR + MOCAP[clip][0] + ".fbx"
		if not ResourceLoader.exists(path):
			continue
		var scene: Node = load(path).instantiate()
		var ap: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
		var anim: Animation = ap.get_animation(ap.get_animation_list()[0]).duplicate()
		anim.loop_mode = Animation.LOOP_LINEAR if MOCAP[clip][1] else Animation.LOOP_NONE
		_strip_root_travel(anim)
		lib.add_animation(clip, anim)
		scene.free()
	_src_anim.add_animation_library("m", lib)
	var to_char := _to_skel.inverse()
	for mixamo in BONES:
		var sb := _src_skel.find_bone("mixamorig_" + mixamo)
		var tb := _skel.find_bone(BONES[mixamo])
		if sb < 0 or tb < 0:
			continue
		_src_of[tb] = sb
		_mocap_fix[tb] = Basis()
		if CHAIN.has(mixamo):
			var sc := _src_skel.find_bone("mixamorig_" + CHAIN[mixamo])
			var tc := _skel.find_bone(BONES[CHAIN[mixamo]])
			if sc >= 0 and tc >= 0:
				var src_dir := (_src_skel.get_bone_global_rest(sc).origin - _src_skel.get_bone_global_rest(sb).origin).normalized()
				var tgt_dir := (to_char * (_skel.get_bone_global_rest(tc).origin - _skel.get_bone_global_rest(tb).origin)).normalized()
				_mocap_fix[tb] = Basis(_shortest_arc(tgt_dir, src_dir))
	for mixamo in BORROW:
		var tb := _skel.find_bone(BONES[mixamo])
		var pb := _skel.find_bone(BONES[BORROW[mixamo]])
		if tb >= 0 and pb >= 0 and _mocap_fix.has(pb):
			_mocap_fix[tb] = _mocap_fix[pb]
	_src_hips = _src_skel.find_bone("mixamorig_Hips")
	_src_hand = _src_skel.find_bone("mixamorig_" + ("RightHand" if sword_bone == "RightHand" else "LeftHand"))
	# Knock in a mocap hand. In Mixamo's T-pose the palm faces down and the thumb forward, so a
	# held grip runs front-to-back across the palm: blade toward +Z (out past the thumb), flat face
	# along the palm normal (-Y). The sword frame has its blade on -Y and its flat face normal on Z.
	if _src_hand >= 0:
		var hand_rest := _src_skel.get_bone_global_rest(_src_hand).basis.orthonormalized().inverse()
		var blade := (hand_rest * Vector3(0, 0, 1)).normalized()
		var face := (hand_rest * Vector3(0, -1, 0)).normalized()
		var y := -blade
		var x := y.cross(face).normalized()
		_mocap_sword = Basis(x, y, x.cross(y).normalized())
	var tgt_hips := _skel.find_bone("Hips")
	var tgt_h := (to_char * _skel.get_bone_global_rest(tgt_hips).origin).y / _unit
	_height_ratio = tgt_h / maxf(_src_skel.get_bone_global_rest(_src_hips).origin.y, 0.01)


## Keep the clip in place: the game moves Ren, so drop the hips' sideways/forward travel.
static func _strip_root_travel(anim: Animation) -> void:
	var t := anim.find_track(NodePath("Skeleton3D:mixamorig_Hips"), Animation.TYPE_POSITION_3D)
	if t < 0:
		return
	var first: Vector3 = anim.track_get_key_value(t, 0)
	for k in anim.track_get_key_count(t):
		var v: Vector3 = anim.track_get_key_value(t, k)
		anim.track_set_key_value(t, k, Vector3(first.x, v.y, first.z))


## Follow the greybox player's clip choice: start the mocap version when there is one.
func _follow_clip() -> void:
	if _grey_anim == null or _src_anim == null:
		return
	# assigned_animation stays set while paused (current_animation does not).
	var cur := _grey_anim.assigned_animation
	var pos := _grey_anim.current_animation_position if cur != "" else 0.0
	var restarted := cur == _cur and pos < _last_pos - 0.05
	if cur != _cur or restarted:
		_cur = cur
		var want_mocap := MOCAP.has(cur) and _src_anim.has_animation("m/" + cur)
		if want_mocap:
			_src_anim.play("m/" + cur, MIX_TIME if _grey_anim.is_playing() else 0.0, _mocap_speed(cur))
			if restarted:
				_src_anim.seek(0.0, true)
		if want_mocap != _mocap:
			_snapshot = _last_locals.duplicate()
			_mix = 0.0
		_mocap = want_mocap
	# A paused player (editor scrubbing, frame sheets) drives the mocap clock directly.
	if _mocap and not _grey_anim.is_playing():
		var anim := _src_anim.get_animation("m/" + cur)
		var t := pos * _mocap_speed(cur)
		if anim.loop_mode != Animation.LOOP_NONE:
			t = fmod(t, anim.length)
		_src_anim.seek(minf(t, anim.length), true)
		_src_anim.pause()
		_mix = 1.0
	_last_pos = pos


func _mocap_speed(clip: String) -> float:
	var length := _src_anim.get_animation("m/" + clip).length
	var fit: float = MOCAP[clip][2]
	return length / fit if fit > 0.0 else 1.0


func _process(dt: float) -> void:
	if _skel == null:
		return
	_follow_clip()
	_mix = minf(1.0, _mix + dt / MIX_TIME)
	# Match the run cycle to how fast Ren actually moves, so feet don't skate.
	var root_now := _rig.global_position
	if dt > 0.0:
		var flat := Vector2(root_now.x - _last_root.x, root_now.z - _last_root.z).length() / dt
		_ground_speed = lerpf(_ground_speed, minf(flat, 12.0), 1.0 - exp(-10.0 * dt))
	_last_root = root_now
	if _mocap and _cur == "run" and _src_anim and _grey_anim.is_playing():
		_src_anim.speed_scale = clampf(_ground_speed / RUN_CLIP_SPEED, 0.6, 1.9)
	elif _src_anim:
		_src_anim.speed_scale = 1.0
	if _last_locals.size() != _skel.get_bone_count():
		_last_locals.resize(_skel.get_bone_count())
	var to_char := _to_skel.inverse()
	var root_inv := _rig.global_basis.orthonormalized().inverse()
	var globals: Array[Transform3D] = []
	globals.resize(_skel.get_bone_count())
	for i in _skel.get_bone_count():
		var parent := _skel.get_bone_parent(i)
		var rest_local := _skel.get_bone_rest(i)
		var local := rest_local
		if _mocap and _src_of.has(i):
			var sb: int = _src_of[i]
			var delta_c := _src_skel.get_bone_global_pose(sb).basis.orthonormalized() * _src_skel.get_bone_global_rest(sb).basis.orthonormalized().inverse()
			var rest_c := to_char * _skel.get_bone_global_rest(i).basis.orthonormalized()
			var want: Basis = _to_skel * (delta_c * (_mocap_fix[i] as Basis) * rest_c)
			var parent_b := globals[parent].basis if parent >= 0 else Basis()
			local.basis = parent_b.inverse() * want
			if sb == _src_hips:
				var offset := (_src_skel.get_bone_global_pose(sb).origin - _src_skel.get_bone_global_rest(sb).origin) * _height_ratio
				offset.x = 0.0
				offset.z = 0.0
				local.origin = rest_local.origin + _to_skel * offset * _unit
		elif _joint_of_bone.has(i) and not _mocap:
			var joint: Node3D = _joint_of_bone[i]
			# Joint rotation relative to the rig root == the clip's pose delta for this segment.
			var delta := root_inv * joint.global_basis.orthonormalized()
			var delta_skel := _to_skel * delta * _to_skel.inverse()
			var rest_global := _skel.get_bone_global_rest(i).basis.orthonormalized()
			var want_global: Basis = delta_skel * _correction[i] * rest_global
			var parent_basis := globals[parent].basis if parent >= 0 else Basis()
			local.basis = parent_basis.inverse() * want_global
			if MAP[_path_of(joint)][0] == "Hips":
				var offset := joint.position - Vector3(0, HIP_REST_Y, 0)
				local.origin = rest_local.origin + _to_skel * offset * _unit
		if _finger_curl.has(i):
			local.basis = rest_local.basis * (_finger_curl[i] as Basis)
		var q := local.basis.get_rotation_quaternion()
		if _mix < 1.0 and i < _snapshot.size() and _snapshot[i] != null:
			q = (_snapshot[i] as Quaternion).slerp(q, _mix)   # blend across a mocap/keyframe switch
			local.basis = Basis(q)
		_last_locals[i] = q
		globals[i] = (globals[parent] * local) if parent >= 0 else local
		_skel.set_bone_pose_rotation(i, q)
		_skel.set_bone_pose_position(i, local.origin)
		if i == _hand or i == _left_hand:
			_skel.set_bone_pose_scale(i, Vector3.ONE * HAND_SCALE)
	if _sword_view and _hand >= 0:
		var forearm := _sword_src.get_parent() as Node3D
		var grip := GRIP_LOCAL * Vector3(-1.0 if sword_bone == "RightHand" else 1.0, 1.0, 1.0) * HAND_SCALE
		var hand_world := _skel.global_transform * (globals[_hand] * grip)
		var basis := forearm.global_basis.orthonormalized() * _sword_src.basis
		if _mocap and _src_hand >= 0:
			basis = _rig.global_basis.orthonormalized() * _src_skel.get_bone_global_pose(_src_hand).basis.orthonormalized() * _mocap_sword
		_sword_view.global_transform = Transform3D(basis, hand_world)


## Adds knuckle, mid and thumb bones to both hands of the skinned mesh and re-weights the
## finger and thumb vertices onto them (smoothly across each joint, so there's no crease).
func _add_finger_bones(skin_root: Node) -> void:
	var mi: MeshInstance3D = null
	for m in skin_root.find_children("*", "MeshInstance3D", true, false):
		if (m as MeshInstance3D).skin != null:
			mi = m
			break
	if mi == null or mi.mesh == null or mi.mesh.get_surface_count() != 1:
		return
	var skin: Skin = mi.skin.duplicate()
	var arrays: Array = mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	if bones.size() != verts.size() * 4:
		return
	for side in ["Right", "Left"]:
		var hand := _skel.find_bone(side + "Hand")
		var hand_bind := -1
		for b in skin.get_bind_count():
			if skin.get_bind_name(b) == side + "Hand" or skin.get_bind_bone(b) == hand:
				hand_bind = b
		if hand < 0 or hand_bind < 0:
			continue
		var sx := -1.0 if side == "Right" else 1.0      # palm / thumb side along local x
		var tb := Vector3(sx * THUMB_BASE.x, THUMB_BASE.y, THUMB_BASE.z)
		var made := {}
		for spec in [["Knuckles", hand, Vector3(0, KNUCKLE_Y, 0)], ["Fingertips", -1, Vector3(0, MID_Y - KNUCKLE_Y, 0)], ["Thumb", hand, tb]]:
			var bone := _skel.add_bone(side + str(spec[0]))
			var parent: int = spec[1] if spec[1] >= 0 else made["Knuckles"]
			_skel.set_bone_parent(bone, parent)
			_skel.set_bone_rest(bone, Transform3D(Basis(), spec[2]))
			_skel.set_bone_pose_position(bone, spec[2])
			made[spec[0]] = bone
		# Bind poses: the new bone's frame relative to the hand's bind.
		var hand_pose := skin.get_bind_pose(hand_bind)
		var knuckle_local := Transform3D(Basis(), Vector3(0, KNUCKLE_Y, 0))
		var binds := {
			"Knuckles": knuckle_local.affine_inverse() * hand_pose,
			"Fingertips": Transform3D(Basis(), Vector3(0, MID_Y, 0)).affine_inverse() * hand_pose,
			"Thumb": Transform3D(Basis(), tb).affine_inverse() * hand_pose,
		}
		var bind_of := {}
		for key in binds:
			skin.add_named_bind(side + key, binds[key])
			bind_of[key] = skin.get_bind_count() - 1
		# Curl: fingers fold toward the palm about the hand's width axis (z); the thumb closes
		# over them about the finger axis.
		_finger_curl[made["Knuckles"]] = Basis(Vector3(0, 0, 1), -sx * CURL_KNUCKLE)
		_finger_curl[made["Fingertips"]] = Basis(Vector3(0, 0, 1), -sx * CURL_MID)
		_finger_curl[made["Thumb"]] = Basis(Vector3(0, 1, 0), sx * CURL_THUMB) * Basis(Vector3(0, 0, 1), -sx * 0.35)
		# Re-weight: anything mostly on the hand that lies past the knuckles moves to the finger
		# bones; the thumb (out on the palm side, below the knuckles) moves to the thumb bone.
		for i in verts.size():
			var slot := -1
			for k in 4:
				if bones[i * 4 + k] == hand_bind and weights[i * 4 + k] > 0.0:
					slot = k
			if slot < 0:
				continue
			var w := weights[i * 4 + slot]
			var l: Vector3 = hand_pose * verts[i]
			var thumb := _smooth(2.5, 4.5, l.x * sx) * _smooth(4.0, 6.0, l.y) * (1.0 - _smooth(KNUCKLE_Y + 3.0, KNUCKLE_Y + 5.0, l.y))
			var f1 := _smooth(KNUCKLE_Y - 1.5, KNUCKLE_Y + 1.0, l.y) * (1.0 - thumb)
			var f2 := _smooth(MID_Y - 1.0, MID_Y + 1.0, l.y) * f1
			var shares := [[hand_bind, w * (1.0 - f1 - thumb)], [bind_of["Knuckles"], w * (f1 - f2)],
					[bind_of["Fingertips"], w * f2], [bind_of["Thumb"], w * thumb]]
			var all := []
			for k in 4:
				if k != slot and weights[i * 4 + k] > 0.0:
					all.append([bones[i * 4 + k], weights[i * 4 + k]])
			for sh in shares:
				if sh[1] > 0.0001:
					all.append(sh)
			all.sort_custom(func(a, b): return a[1] > b[1])
			var total := 0.0
			for k in mini(4, all.size()):
				total += all[k][1]
			for k in 4:
				bones[i * 4 + k] = all[k][0] if k < all.size() else 0
				weights[i * 4 + k] = (all[k][1] / total) if k < all.size() and total > 0.0 else 0.0
	arrays[Mesh.ARRAY_BONES] = bones
	arrays[Mesh.ARRAY_WEIGHTS] = weights
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, mi.mesh.surface_get_material(0))
	mi.mesh = mesh
	mi.skin = skin


static func _smooth(e0: float, e1: float, v: float) -> float:
	var t := clampf((v - e0) / (e1 - e0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _path_of(joint: Node3D) -> String:
	return str(_rig.get_path_to(joint))


func _first_child_bone(bone: int) -> int:
	var kids := _skel.get_bone_children(bone)
	return kids[0] if kids.size() > 0 else -1


static func _shortest_arc(from: Vector3, to: Vector3) -> Quaternion:
	var d := from.dot(to)
	if d > 0.9999:
		return Quaternion()
	if d < -0.9999:
		var axis := Vector3.RIGHT if absf(from.x) < 0.9 else Vector3.UP
		return Quaternion(from.cross(axis).normalized(), PI)
	return Quaternion(from.cross(to).normalized(), acos(clampf(d, -1.0, 1.0)))


static func _relative_transform(node: Node3D, ancestor: Node3D) -> Transform3D:
	var t := Transform3D()
	var n: Node = node
	while n != null and n != ancestor:
		if n is Node3D:
			t = (n as Node3D).transform * t
		n = n.get_parent()
	return t
