extends SceneTree
## Bakes the greybox rigs and their keyframed clips into editable scenes:
##   rigs/floor_manager.tscn, rigs/ren.tscn  (each with an AnimationPlayer holding every clip)
## Run after changing scripts/anim_data.gd or the rig builders:
##   godot --headless --path afterbell-godot -s res://tools/build_rigs.gd
## Note: re-running overwrites edits made to those scenes in the Godot editor.

const B := preload("res://scripts/builders.gd")
const A := preload("res://scripts/anim_data.gd")


func _initialize() -> void:
	var ok := _bake(B.build_boss_rig(), A.boss_clips(), A.boss_rest(), "res://rigs/floor_manager.tscn")
	ok = _bake(B.build_ren_rig(), A.ren_clips(), A.ren_rest(), "res://rigs/ren.tscn") and ok
	quit(0 if ok else 1)


func _bake(rig: Node3D, clips: Dictionary, rest: Dictionary, path: String) -> bool:
	var player := AnimationPlayer.new()
	player.name = "AnimationPlayer"
	rig.add_child(player)
	player.add_animation_library("", A.build_library(clips, rest))
	player.autoplay = "idle"
	# Every animated path must resolve on the rig, or the clip silently does nothing.
	for p in rest:
		var np := NodePath(p)
		var node := rig.get_node_or_null(NodePath(np.get_concatenated_names()))
		if node == null:
			push_error("%s: animated node missing: %s" % [path, p])
			return false
	_own(rig, rig)
	var scene := PackedScene.new()
	scene.pack(rig)
	var err := ResourceSaver.save(scene, path)
	print("%s: %d clips -> %s (%s)" % [rig.name, clips.size(), path, error_string(err)])
	rig.free()
	return err == OK


func _own(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_own(child, owner)
