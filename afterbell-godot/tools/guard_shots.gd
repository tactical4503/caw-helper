extends SceneTree
## Renders the Hats room's etiquette guards (the supplied staff figures) in each pose:
## at their post, raising the baton (tell), striking, walking, and seated.
##   godot --path afterbell-godot -s res://tools/guard_shots.gd -- --out=/tmp/guards

const STATES := ["post", "tell", "strike", "approach", "seated"]

var out_dir := "user://guards"
var room: Node
var index := -1
var wait := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
	DirAccess.make_dir_recursive_absolute(out_dir)
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(1280, 960)
	room = load("res://rooms/hats.tscn").instantiate()
	root.add_child(room)


func _process(_d: float) -> bool:
	if index == -1:
		room.set_process(false)
		if room.get("fade"):
			room.fade.visible = false
		index = 0
		_setup()
		return false
	wait -= 1
	if wait == 0:
		var path: String = out_dir.path_join(STATES[index] + ".png")
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
		index += 1
		if index >= STATES.size():
			quit()
			return true
		_setup()
	return false


func _setup() -> void:
	room.p_pos = Vector2(0.0, 2.6)
	for k in room.guards.size():
		var g = room.guards[k]
		g.node.visible = true
		g.pos = Vector2(-1.0 + k * 2.0, 0.4)
		g.last = g.pos
		g.yaw = 0.0
		g.state = STATES[index]
	for i in 40:
		for k in room.guards.size():
			var g = room.guards[k]
			g.state = STATES[index]
			if STATES[index] == "approach":
				g.pos = Vector2(-1.0 + k * 2.0, 0.4 + 0.03 * i)   # walking toward the camera
		room._render_actors(1.0 / 30.0)
	room.camera.position = Vector3(0.0, 1.5, 4.6)
	room.camera.look_at(Vector3(0.0, 1.0, 0.6), Vector3.UP)
	wait = 12
