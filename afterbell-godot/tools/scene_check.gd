extends SceneTree
## Loads every playable scene with a real renderer, runs it for a second and fails on any script
## error or missing resource. Run with a renderer (not --headless) so materials and shaders build.
##   godot --path afterbell-godot -s res://tools/scene_check.gd

const SCENES := ["res://rooms/title.tscn", "res://rooms/cosmetics.tscn", "res://rooms/hats.tscn",
	"res://rooms/alterations.tscn", "res://main.tscn", "res://rooms/asset_staging.tscn"]

var i := -1
var frames := 0
var node: Node


func _initialize() -> void:
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(640, 480)
	_next()


func _next() -> void:
	if node:
		node.queue_free()
	i += 1
	if i >= SCENES.size():
		print("SCENE CHECK: all %d scenes ran" % SCENES.size())
		quit()
		return
	var packed := load(SCENES[i]) as PackedScene
	if packed == null:
		printerr("SCENE CHECK FAIL: cannot load ", SCENES[i])
		quit(1)
		return
	node = packed.instantiate()
	root.add_child(node)
	frames = 0
	print("scene ", SCENES[i])


func _process(_d: float) -> bool:
	frames += 1
	if frames >= 30:
		_next()
	return false
