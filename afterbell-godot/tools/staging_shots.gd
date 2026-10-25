extends SceneTree
## Renders each asset in the staging scene from the front, back and a high three-quarter view.
##   godot --path afterbell-godot -s res://tools/staging_shots.gd -- --group=props --out=/tmp/staging
## Optional --ids=a,b to limit, --views=front,back,top to choose views.

const Imp := preload("res://scripts/imported_assets.gd")

## yaw, aim height (fraction of the model), distance factor
const VIEWS := {"front": [0.35, 0.5, 1.0], "back": [PI + 0.35, 0.5, 1.0], "top": [-0.8, 0.8, 1.0],
		"close": [0.5, 0.82, 0.38], "close_back": [PI - 0.5, 0.82, 0.38]}

var out_dir := "user://staging"
var stage: Node3D
var shots := []   # [id, view]
var index := 0
var frames := 0


func _initialize() -> void:
	var ids := []
	var views := ["front", "back", "top"]
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--ids="):
			ids = Array(arg.substr(6).split(","))
		elif arg.begins_with("--views="):
			views = Array(arg.substr(8).split(","))
	DirAccess.make_dir_recursive_absolute(out_dir)
	root.size = Vector2i(1280, 960)
	stage = load("res://rooms/asset_staging.tscn").instantiate()
	root.add_child(stage)   # _ready builds the rows (it reads --group itself)
	_ids = ids
	_views = views


var _ids := []
var _views := []


func _collect() -> void:
	var ids := _ids
	var views := _views
	for id in stage.placed:
		if ids.is_empty() or id in ids:
			for v in views:
				shots.append([id, v])
	if shots.is_empty():
		print("staging_shots: nothing placed")
		quit(1)
		return
	_aim()


func _aim() -> void:
	var id: String = shots[index][0]
	var v: Array = VIEWS[shots[index][1]]
	var box := Imp._bounds(stage.placed[id], Transform3D.IDENTITY)
	var reach := maxf(box.size.y * 1.15, maxf(box.size.x, box.size.z) * 0.95) + 0.8
	stage.frame(id, v[0], reach * 1.25 * v[2], v[1])
	frames = 0


func _process(_d: float) -> bool:
	if index == 0 and frames == 0 and shots.is_empty():
		_collect()
		frames = 0
		return shots.is_empty()
	frames += 1
	if frames == 10:
		var path: String = "%s/%s_%s.png" % [out_dir, shots[index][0], shots[index][1]]
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
		index += 1
		if index >= shots.size():
			quit()
			return true
		_aim()
	return false
