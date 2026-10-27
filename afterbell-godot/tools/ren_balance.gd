extends SceneTree
## Measures Ren's standing balance over his idle: how far (cm) his head and chest sit in front of
## his hips, and the hips in front of the midpoint between his feet (the base of support), with
## the left-right weight shift. Front = the way he faces. Used to tune the idle.
##   godot --headless --path afterbell-godot -s res://tools/ren_balance.gd -- [--capture=great_sword_idle|none]
var ren: Node3D
var f := 0
var capture := "great_sword_idle"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			capture = arg.substr(10)
			if capture == "none":
				capture = ""
	ren = load("res://rigs/ren.tscn").instantiate()
	ren.get_node("SkinDriver").idle_capture = capture
	root.add_child(ren)
	(ren.get_node("AnimationPlayer") as AnimationPlayer).play("idle")
func _process(_d: float) -> bool:
	f += 1
	if f % 15 == 0:
		var sk: Skeleton3D = ren.find_children("*", "Skeleton3D", true, false)[0]
		var w := func(b: String) -> Vector3: return sk.global_transform * sk.get_bone_global_pose(sk.find_bone(b)).origin
		var fwd := ren.global_basis.z   # Ren faces +z in his rig
		var side := ren.global_basis.x
		var feet: Vector3 = (w.call("LeftFoot") + w.call("RightFoot")) * 0.5
		var hips: Vector3 = w.call("Hips")
		var head: Vector3 = w.call("Head")
		var chest: Vector3 = w.call("Spine")
		print("t=%.1f  head-hips fwd %+.1f cm  chest-hips %+.1f  hips-feet fwd %+.1f  side %+.1f  hips h %.2f" % [f / 60.0,
			(head - hips).dot(fwd) * 100, (chest - hips).dot(fwd) * 100, (hips - feet).dot(fwd) * 100, (hips - feet).dot(side) * 100, hips.y])
	if f > 240:
		quit()
		return true
	return false
