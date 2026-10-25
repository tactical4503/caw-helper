extends SceneTree
## Close-up renders of the furniture for review: a counter's panelled front and its staff side,
## the cutting table, a hat stand, the store rack and the moving gameplay rack, with Ren's
## height marked by a 1.83 m post beside each piece.
##   godot --path afterbell-godot -s res://tools/furniture_shots.gd -- --out=/tmp/furniture

const ST := preload("res://scripts/style.gd")
const Props := preload("res://scripts/props.gd")
const B := preload("res://scripts/builders.gd")

const VIEWS := [
	# [name, camera position, look at]
	["counter_front", Vector3(0.6, 1.6, 3.6), Vector3(0, 0.6, 0)],
	["counter_staff", Vector3(0.4, 1.35, -2.6), Vector3(0, 0.6, 0)],
	["cutting_table", Vector3(5.2, 1.85, 2.2), Vector3(5.0, 0.75, 0)],
	["hat_stand", Vector3(-3.6, 1.55, 2.6), Vector3(-4.0, 1.15, 0)],
	["racks", Vector3(9.6, 1.4, 3.6), Vector3(9.6, 0.9, 0)],
	["rack_joint", Vector3(8.2, 0.55, 1.0), Vector3(8.75, 0.35, 0)],
	["hangers", Vector3(9.1, 1.75, 0.6), Vector3(9.4, 1.5, -0.6)],
	["poses", Vector3(-14.5, 1.5, 3.4), Vector3(-14.5, 1.1, 0)],
	["shelves", Vector3(-21.2, 1.4, 3.6), Vector3(-21.2, 1.1, -1.0)],
	["plants", Vector3(-27.0, 2.1, 3.6), Vector3(-27.0, 1.3, -0.6)],
	["stock_a", Vector3(19.4, 1.5, 2.6), Vector3(19.4, 0.6, -0.6)],
	["stock_b", Vector3(24.4, 1.5, 2.6), Vector3(24.4, 0.6, -0.6)],
]

var out_dir := "user://furniture"
var cam: Camera3D
var index := 0
var frames := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
	DirAccess.make_dir_recursive_absolute(out_dir)
	root.size = Vector2i(1280, 960)
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	w.add_child(env)
	w.add_child(ST.sun())
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(80, 20)
	floor.mesh = plane
	floor.material_override = ST.textured("carpet_forest", 0.5, ST.plastic(Color("23443f"), 0.9, 0.0))
	w.add_child(floor)
	for z in [-3.6, 3.9]:
		var wall := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(80, 4, 0.2)
		wall.mesh = box
		wall.position = Vector3(0, 2, z)
		wall.material_override = ST.textured("plaster_cream", 0.3, ST.plastic(Color("eee6d4"), 0.7, 0.0))
		w.add_child(wall)
	Props.counter(w, Vector3.ZERO, Vector3(2.4, Props.WAIST, 0.7), "cream", 0.08, Vector3(0, 0, -1))
	Props.place(w, "perfume_boxes", Vector3(-0.6, Props.WAIST, 0), 0.0, 1)
	Props.cutting_table(w, Vector3(5.0, 0, 0))
	for k in 2:
		Props.hat_stand(w, Vector3(-4.0 + k * 1.1, 0, 0), k)
	Props.place(w, "rack", Vector3(9.6, 0, -0.6), 0.0, 1)
	var moving := B.build_rack(0)
	moving.node.position = Vector3(11.2, 0, 1.0)
	w.add_child(moving.node)
	for k in 4:   # the four poses
		Props.place(w, "mannequin", Vector3(-16.2 + k * 1.1, 0, 0), 0.0, [0, 1, 2, 3][k] + 4 * k)
	for k in 4:   # the four shelf stocks, a price card on the end table
		Props.place(w, "shelf_unit", Vector3(-23.1 + k * 1.28, 0, -1.2), 0.0, k)
	Props.place(w, "folded_table", Vector3(-21.2, 0, 0.6), 0.0, 1)
	Props.place(w, "price_card", Vector3(-20.7, Props.WAIST * 0.82, 0.8), 0.0, 0, "12.50")
	Props.place(w, "planter", Vector3(-29.0, 0, 0), 0.0, 0)
	Props.place(w, "centrepiece", Vector3(-27.0, 0, -1.0))
	Props.place(w, "planter", Vector3(-25.0, 0, 0), 0.0, 1)
	for k in 7:   # each department's window stock on a plum plinth, and the leather table
		var x := 17.0 + k * 1.65
		var plinth := MeshInstance3D.new()
		var pb := BoxMesh.new()
		pb.size = Vector3(1.5, 0.5, 0.9)
		plinth.mesh = pb
		plinth.material_override = Props._m("plum")
		plinth.position = Vector3(x, 0.25, -0.4)
		w.add_child(plinth)
		Props.place(w, "window_stock", Vector3(x, 0.5, -0.4), 0.0, k)
	Props.place(w, "leather_table", Vector3(23.6, 0, 1.0), 0.0, 0)
	for x in [1.5, 6.1, -4.8, 8.2, -17.2, -28.2]:   # Ren's height
		var post := MeshInstance3D.new()
		var c := CylinderMesh.new()
		c.top_radius = 0.012
		c.bottom_radius = 0.012
		c.height = Props.REN_HEIGHT
		post.mesh = c
		post.position = Vector3(x, Props.REN_HEIGHT * 0.5, 0.6)
		post.material_override = ST.plastic(Color("b0302a"), 0.6, 0.0)
		w.add_child(post)
	for lx in [-27.0, -21.0, -15.0, -4.0, 0.0, 5.0, 10.0, 19.0, 25.0]:
		ST.ceiling_light(w, Vector3(lx, 3.6, 1.2), 1.2, 9.0)
	cam = Camera3D.new()
	cam.fov = 45
	w.add_child(cam)
	_aim()


func _aim() -> void:
	var v: Array = VIEWS[index]
	cam.position = v[1]
	cam.look_at(v[2], Vector3.UP)
	frames = 0


func _process(_d: float) -> bool:
	frames += 1
	if frames == 12:
		var path: String = out_dir + "/" + VIEWS[index][0] + ".png"
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
		index += 1
		if index >= VIEWS.size():
			quit()
			return true
		_aim()
	return false
