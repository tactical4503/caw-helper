extends SceneTree
## Close-up of Ren's hands for checking the grip (idle pose; --yaw turns him):
##   godot --path afterbell-godot -s res://tools/hand_shot.gd -- --out=/tmp/hands.png --yaw=0.5
const ST := preload("res://scripts/style.gd")
var out := "user://hands.png"
var frames := 0
var cams := []
var ren: Node3D
var yaw := 0.5

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--yaw="):
			yaw = float(arg.substr(6))
		if arg.begins_with("--out="):
			out = arg.substr(6)
	root.size = Vector2i(1280, 640)
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	w.add_child(env)
	w.add_child(ST.sun())
	ST.ceiling_light(w, Vector3(0, 3.0, 2.0), 1.6, 8.0)
	ren = load("res://rigs/ren.tscn").instantiate()
	w.add_child(ren)
	ren.rotation.y = yaw

func _process(_d: float) -> bool:
	frames += 1
	if frames == 40:
		var cam := Camera3D.new()
		cam.fov = 30
		root.add_child(cam)
		cam.position = Vector3(0.0, 1.15, 2.2)
		cam.look_at(Vector3(0, 1.0, 0), Vector3.UP)
		cam.make_current()
	if frames == 50:
		root.get_texture().get_image().save_png(out)
		print("saved ", out)
		quit()
	return false
