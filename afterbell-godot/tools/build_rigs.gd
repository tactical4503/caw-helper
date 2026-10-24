extends SceneTree
## Bakes the greybox rigs and their keyframed clips into editable scenes:
##   rigs/floor_manager.tscn, rigs/ren.tscn  (each with an AnimationPlayer holding every clip)
## Run after changing scripts/anim_data.gd or the rig builders:
##   godot --headless --path afterbell-godot -s res://tools/build_rigs.gd
## Note: re-running overwrites edits made to those scenes in the Godot editor.

const B := preload("res://scripts/builders.gd")
const A := preload("res://scripts/anim_data.gd")
## Imported character models. When present, the model is skinned onto the greybox rig
## (scripts/ren_skin.gd retargets the clips every frame) and the greybox body is hidden.
const REN_MODEL := "res://assets/characters/ren/ren_rigged.glb"


func _initialize() -> void:
	var ok := _bake(B.build_boss_rig(), A.boss_clips(), A.boss_rest(), "res://rigs/floor_manager.tscn")
	var ren := B.build_ren_rig()
	if ResourceLoader.exists(REN_MODEL):
		var skin: Node3D = load(REN_MODEL).instantiate()
		skin.name = "Skin"
		ren.add_child(skin)
		var driver := Node.new()
		driver.name = "SkinDriver"
		driver.set_script(load("res://scripts/ren_skin.gd"))
		ren.add_child(driver)
		print("Ren: using model ", REN_MODEL)
	ok = _bake(ren, A.ren_clips(), A.ren_rest(), "res://rigs/ren.tscn") and ok
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
		if child.scene_file_path.is_empty():  # don't flatten an instanced model into the rig scene
			_own(child, owner)
