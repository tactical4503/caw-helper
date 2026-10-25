extends RefCounted
## Poses one of the supplied skinned figures (the plum and teal clerks, npc10 / npc12) from code:
## their glTFs carry a 32-bone skeleton but no animation clips, so the game turns joints itself.
## Each joint takes a rotation in the figure's own rest frame (x = its left-right axis, so a
## negative angle swings a hanging arm or leg forward), applied relative to its parent: turning
## the shoulder carries the forearm and hand with it. Bones are found by role, per model.

## Role -> bone name, per source model (from the skeletons: npc10 and npc12 name them differently).
const RIGS := {
	"npc10": {"spine": "Bone02", "head": "Bone03", "r_arm": "Bone12", "r_fore": "Bone13", "r_hand": "Bone14",
		"l_arm": "Bone15", "l_fore": "Bone16", "l_hand": "Bone17",
		"r_thigh": "Bone04", "r_shin": "Bone05", "l_thigh": "Bone18", "l_shin": "Bone19"},
	"npc12": {"spine": "Bone05", "head": "Bone08", "r_arm": "Bone01", "r_fore": "Bone02", "r_hand": "Bone03",
		"l_arm": "Bone21", "l_fore": "Bone22", "l_hand": "Bone23",
		"r_thigh": "Bone06", "r_shin": "Bone07", "l_thigh": "Bone18", "l_shin": "Bone19"},
}

var skel: Skeleton3D
var idx := {}            # role -> bone index
var rest_local := {}     # bone index -> rest Transform3D (local)
var parent_rest := {}    # bone index -> parent's global rest Basis


## `root` is the instanced figure (any node above its Skeleton3D); `rig` is "npc10" or "npc12".
func _init(root: Node, rig: String) -> void:
	var found := root.find_children("*", "Skeleton3D", true, false)
	if found.is_empty():
		return
	skel = found[0]
	var map: Dictionary = RIGS.get(rig, {})
	for role in map:
		var i := skel.find_bone(map[role])
		if i < 0:
			continue
		idx[role] = i
		rest_local[i] = skel.get_bone_rest(i)
		var p := skel.get_bone_parent(i)
		parent_rest[i] = skel.get_bone_global_rest(p).basis if p >= 0 else Basis()


func ok() -> bool:
	return skel != null and idx.has("r_arm") and idx.has("l_arm")


## Sets each listed role to its angle (radians, about the figure's x axis); others return to rest.
## `twist` optionally turns a role about the figure's z axis (arms out to the side). A role's
## value may instead be a Vector3 (pitch about x, yaw about y, roll about z), for heads and spines.
func apply(angles: Dictionary, twist := {}) -> void:
	var q := compute(angles, twist)
	for i in q:
		skel.set_bone_pose_rotation(i, q[i])


## The same pose as local bone rotations {bone index: Quaternion}, without applying it (for
## blending over motion capture).
func compute(angles: Dictionary, twist := {}, only: Array = []) -> Dictionary:
	var out := {}
	if not ok():
		return out
	for role in idx:
		if not only.is_empty() and not role in only:
			continue
		var i: int = idx[role]
		var v = angles.get(role, 0.0)
		var r: Basis
		if v is Vector3:
			r = Basis(Vector3.UP, v.y) * Basis(Vector3.RIGHT, v.x) * Basis(Vector3.BACK, v.z)
		else:
			r = Basis(Vector3.RIGHT, float(v)) * Basis(Vector3.BACK, float(twist.get(role, 0.0)))
		var p: Basis = parent_rest[i]
		var rest: Transform3D = rest_local[i]
		var b: Basis = p.inverse() * r * p * rest.basis
		out[i] = b.orthonormalized().get_rotation_quaternion()
	return out


## The hand's position in the figure's space (for props held in it).
func hand(role := "r_hand") -> Vector3:
	if not ok() or not idx.has(role):
		return Vector3.ZERO
	return skel.get_bone_global_pose(idx[role]).origin
