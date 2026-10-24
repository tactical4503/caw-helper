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

@export var skin_path: NodePath = ^"../Skin"
@export var sword_bone := "RightHand"

var _rig: Node3D
var _skel: Skeleton3D
var _joint_of_bone := {}      # bone index -> greybox joint Node3D
var _correction := {}         # bone index -> Basis (model rest dir -> greybox rest dir)
var _to_skel := Basis()       # character space -> skeleton space (rotation only)
var _unit := 1.0              # metres -> skeleton units
var _sword_src: Node3D
var _sword_view: Node3D
var _hand := -1


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
	_sword_src = _rig.get_node_or_null("Pelvis/Torso/ArmR/ForearmR/Sword")
	if _sword_src and _hand >= 0:
		_sword_view = _sword_src.duplicate() as Node3D
		_sword_view.name = "SwordView"
		_sword_view.top_level = true
		add_child(_sword_view)
		for mi in _sword_view.find_children("*", "MeshInstance3D", true, false):
			mi.visible = true


func _process(_delta: float) -> void:
	if _skel == null:
		return
	var root_inv := _rig.global_basis.orthonormalized().inverse()
	var globals: Array[Transform3D] = []
	globals.resize(_skel.get_bone_count())
	for i in _skel.get_bone_count():
		var parent := _skel.get_bone_parent(i)
		var rest_local := _skel.get_bone_rest(i)
		var local := rest_local
		if _joint_of_bone.has(i):
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
		globals[i] = (globals[parent] * local) if parent >= 0 else local
		_skel.set_bone_pose_rotation(i, local.basis.get_rotation_quaternion())
		_skel.set_bone_pose_position(i, local.origin)
	if _sword_view and _hand >= 0:
		var forearm := _sword_src.get_parent() as Node3D
		var hand_world := _skel.global_transform * globals[_hand].origin
		_sword_view.global_transform = Transform3D(forearm.global_basis.orthonormalized() * _sword_src.basis, hand_world)


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
