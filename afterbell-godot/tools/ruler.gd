extends SceneTree
## Proportion check: Ren (idle) beside a counter, the shelving and a doorway, side-on with an
## orthographic camera and a line every 10 cm (brighter every 50 cm).
##   godot --path afterbell-godot -s res://tools/ruler.gd -- --out=/tmp/ruler.png

const ST := preload("res://scripts/style.gd")
const Props := preload("res://scripts/props.gd")

var out := "user://ruler.png"
var frames := 0
var ren: Node3D


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	root.size = Vector2i(1280, 720)
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	w.add_child(env)
	w.add_child(ST.sun())
	ST.ceiling_light(w, Vector3(0, 3.5, 2.0), 1.5, 10.0)
	var line := StandardMaterial3D.new()
	line.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line.albedo_color = Color(0.2, 0.2, 0.25)
	var bold := line.duplicate()
	bold.albedo_color = Color(0.85, 0.2, 0.2)
	for i in 31:
		var mi := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3(9.0, 0.006 if i % 5 else 0.012, 0.01)
		mi.mesh = b
		mi.material_override = bold if i % 5 == 0 else line
		mi.position = Vector3(0, i * 0.1, -1.0)
		w.add_child(mi)
		if i % 5 == 0:
			var l := Label3D.new()
			l.text = "%.1f m" % (i * 0.1)
			l.font_size = 32
			l.pixel_size = 0.004
			l.position = Vector3(-4.1, i * 0.1 + 0.05, -0.9)
			w.add_child(l)
	ren = load("res://rigs/ren.tscn").instantiate()
	w.add_child(ren)
	ren.position = Vector3(-2.3, 0, 0)
	ren.rotation.y = PI / 2.0
	Props.counter(w, Vector3(-1.2, 0, 0), Vector3(1.4, 1.0, 0.6))
	Props.place(w, "perfume_counter", Vector3(0.6, 0, 0))
	Props.place(w, "mannequin", Vector3(1.9, 0, 0))
	Props.door_frame(w, Vector3(3.3, 0, -0.4), 1.0, Props.DOOR_HEIGHT, 0.0, 0.1)
	var ren2: Node3D = load("res://rigs/ren.tscn").instantiate()   # standing in the doorway
	w.add_child(ren2)
	ren2.position = Vector3(3.3, 0, -0.2)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 3.3
	w.add_child(cam)
	cam.position = Vector3(0.5, 1.5, 8.0)


func _process(_d: float) -> bool:
	frames += 1
	if frames == 30:
		root.get_texture().get_image().save_png(out)
		print("saved ", out)
		quit()
	return false
