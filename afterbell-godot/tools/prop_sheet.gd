extends SceneTree
## Renders the prop library in a row for review:
##   godot --path afterbell-godot -s res://tools/prop_sheet.gd -- --out=/tmp/props.png

const ST := preload("res://scripts/style.gd")
const Props := preload("res://scripts/props.gd")

var out := "user://props.png"
var frames := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	root.size = Vector2i(1600, 700)
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	w.add_child(env)
	w.add_child(ST.sun())
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 12)
	floor.mesh = plane
	floor.material_override = ST.textured("carpet_forest", 0.5, ST.plastic(Color("1f3a2a"), 0.9, 0.0))
	w.add_child(floor)
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(30, 4, 0.2)
	wall.mesh = box
	wall.position = Vector3(0, 2, -1.6)
	wall.material_override = ST.textured("plaster_cream", 0.3, ST.plastic(Color("efe3c8"), 0.7, 0.0))
	w.add_child(wall)
	var row := [["rack", 0, ""], ["rack", 1, ""], ["mannequin", 0, ""], ["mannequin", 1, ""], ["mannequin", 2, ""], ["mannequin", 3, ""],
			["perfume_counter", 0, ""], ["perfume_tower", 0, ""], ["flower_display", 0, ""], ["easel", 0, "FRAGRANCE"], ["easel", 1, "SALE"]]
	var widths := {"rack": 2.0, "mannequin": 0.8, "perfume_counter": 2.0, "perfume_tower": 1.4, "flower_display": 1.5, "easel": 0.9}
	var x := 0.0
	var total := 0.0
	for r in row:
		total += widths[r[0]]
	x = -total * 0.5
	for r in row:
		x += widths[r[0]] * 0.5
		Props.place(w, r[0], Vector3(x, 0, 0), 0.0, r[1], r[2])
		x += widths[r[0]] * 0.5
	Props.place(w, "sale_card", Vector3(x + 0.3, 0, 0.3))
	# Doorways: a framed door pair in the back wall, and a counter run with rounded corners.
	Props.door_frame(w, Vector3(-4.0, 0, -1.3), 2.2, 2.2, 0.0, 0.2)
	Props.door_leaf(w, Vector3(-5.1, 0, -1.3), 1.1, 2.2)
	Props.door_leaf(w, Vector3(-2.9, 0, -1.3), 1.1, 2.2, PI, -0.6, true)
	Props.pull_handle(w, Vector3(3.5, 1.0, -1.5), 0.6)
	Props.place(w, "hanging_sign", Vector3(0, 3.2, -1.4), 0.0, 0, "COSMETICS  ·  FRAGRANCE")
	for lx in [-6.0, 0.0, 6.0]:
		ST.ceiling_light(w, Vector3(lx, 3.8, 1.5), 1.2, 9.0)
	var cam := Camera3D.new()
	cam.fov = 40
	w.add_child(cam)
	cam.position = Vector3(0, 1.6, 9.0)
	cam.look_at(Vector3(0, 1.0, 0), Vector3.UP)


func _process(_d: float) -> bool:
	frames += 1
	if frames == 20:
		root.get_texture().get_image().save_png(out)
		print("saved ", out)
		quit()
	return false
