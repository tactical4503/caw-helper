extends Node3D
## Asset staging: one labelled, wrapped instance of each imported package model (see
## imported_assets.gd) on a plain floor under the game's interior lighting, with Ren and a
## doorway for scale. Not part of the chapter and not exported; open rooms/asset_staging.tscn
## and run it (F6). Arrow keys / WASD orbit and zoom, Q/E switch row.
## Pass `--group=<props|characters|stage1|stage2>` after `--` to show one group.

const Imp := preload("res://scripts/imported_assets.gd")
const Style := preload("res://scripts/style.gd")
const Atrium := preload("res://scripts/atrium.gd")
const Props := preload("res://scripts/props.gd")

const SPACING := 4.0
const STAGE_GAP := 12.0

## Rows of the staging floor, front to back. Stage sections get their own rows, side by side
## with a gap, each at its source origin (their floors sit at y = 0 in the source files).
const ROWS := [
	["props", ["pillar_snowpoint", "pillar_turnback", "mannequin_female", "mannequin_male", "suitcase"]],
	["characters", ["clerk_plum", "clerk_teal", "eric", "franklin"]],
	["stage1", ["stage1_1_1_a", "stage1_1_1_b", "stage1_1_1_c", "stage1_1_2_a", "stage1_1_2_b",
		"stage1_1_2_c", "stage1_1_3"]],
	["stage2", ["stage2_2_1_a", "stage2_2_1_b", "stage2_2_1_c", "stage2_2_2_a", "stage2_2_2_b",
		"stage2_2_2_c", "stage2_2_2_c_tes", "stage2_2_3_a", "stage2_2_3_b", "stage2_2_3_c"]],
]

var placed := {}         # id -> wrapper
var row_centres: Array[Vector3] = []
var camera: Camera3D
var focus := 0
var yaw := 0.6
var dist := 9.0


func _ready() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--group="):
			only = a.get_slice("=", 1)
	_light()
	var z := 0.0
	for row in ROWS:
		var group: String = row[0]
		var ids: Array = row[1]
		if only != "" and only != group:
			continue
		var stage := group.begins_with("stage")
		var wrappers := []
		for id in ids:
			var w := Imp.make(id)
			if w == null:
				push_warning("staging: %s is not in assets/imports/" % id)
				continue
			wrappers.append(w)
		if wrappers.is_empty():
			continue
		if stage:
			# Lay sections left to right by their footprints; the row is as deep as its deepest.
			var x := 0.0
			var depth := 0.0
			for w in wrappers:
				var b := Imp._bounds(w, Transform3D.IDENTITY)
				w.position = Vector3(x - b.position.x, 0, z - b.end.z)
				x += b.size.x + STAGE_GAP
				depth = maxf(depth, b.size.z)
			for w in wrappers:
				w.position.x -= (x - STAGE_GAP) / 2.0
			row_centres.append(Vector3(0, 4.0, z - depth / 2.0))
			z -= depth + STAGE_GAP * 2.0
		else:
			var x0 := -SPACING * (wrappers.size() - 1) / 2.0
			for i in wrappers.size():
				wrappers[i].position = Vector3(x0 + SPACING * i, 0, z)
			# Scale references at the start of each prop/character row, on a plain floor.
			_references(Vector3(x0 - SPACING, 0, z))
			_floor(Vector3(0, 0, z), Vector2(SPACING * (wrappers.size() + 3), SPACING * 2.5))
			row_centres.append(Vector3(0, 1.2, z))
			z -= SPACING * 2.5
		for w in wrappers:
			add_child(w)
			placed[w.get_meta("import_id")] = w
			if stage:
				_stage_label(w, Imp.ASSETS[w.get_meta("import_id")].label)
			else:
				_label(w, Imp.ASSETS[w.get_meta("import_id")].label)
	camera = Camera3D.new()
	camera.fov = 50.0
	camera.far = 1000.0
	add_child(camera)
	camera.current = true
	if row_centres.is_empty():
		row_centres.append(Vector3(0, 1.2, 0))
	_place_camera()


func _floor(at: Vector3, size: Vector2) -> void:
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	floor_mesh.mesh = plane
	floor_mesh.position = at
	floor_mesh.material_override = Style.plastic(Color("6f6a66"), 0.85, 0.0)
	add_child(floor_mesh)


## Stage sections are big: their label floats above the section's front edge, large.
func _stage_label(w: Node3D, text: String) -> void:
	var b := Imp._bounds(w, Transform3D.IDENTITY)
	var l := Label3D.new()
	l.text = text
	l.font_size = 96
	l.pixel_size = 0.03
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.position = b.get_center() - w.position + Vector3(0, b.size.y / 2.0 + 3.0, b.size.z / 2.0)
	l.modulate = Color("f3e7cf")
	l.outline_size = 16
	w.add_child(l)


func _light() -> void:
	var env := WorldEnvironment.new()
	env.environment = Style.environment()
	add_child(env)
	var key := Style.sun()
	Atrium.light_environment(env.environment, key)
	add_child(key)
	var warm := OmniLight3D.new()
	warm.light_color = Color("ffd9b0")
	warm.light_energy = 1.2
	warm.omni_range = 30.0
	warm.position = Vector3(-4, 7, 6)
	add_child(warm)


## Ren (the game's own model) and a door frame, for scale.
func _references(at: Vector3) -> void:
	var ren_scene := load("res://assets/characters/ren/ren_rigged.glb") as PackedScene
	if ren_scene:
		var ren := ren_scene.instantiate() as Node3D
		ren.position = at
		add_child(ren)
		_label(ren, "Ren (game model, scale)")
	Props.place(self, "door_frame", at + Vector3(-1.6, 0, 0))


func _label(n: Node3D, text: String) -> void:
	var l := Label3D.new()
	l.text = text
	l.font_size = 48
	l.pixel_size = 0.004
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.position = Vector3(0, -0.25, 1.6)
	l.modulate = Color("f3e7cf")
	l.outline_size = 10
	n.add_child(l)


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		yaw -= delta * 1.2
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		yaw += delta * 1.2
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		dist = maxf(2.0, dist - delta * 8.0)
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		dist = minf(160.0, dist + delta * 8.0)
	_place_camera()


func _unhandled_key_input(e: InputEvent) -> void:
	if e.is_pressed() and not e.is_echo():
		if e.keycode == KEY_Q:
			focus = (focus + row_centres.size() - 1) % row_centres.size()
		elif e.keycode == KEY_E:
			focus = (focus + 1) % row_centres.size()


func _place_camera() -> void:
	var c := row_centres[focus]
	camera.position = c + Vector3(sin(yaw), 0.35, cos(yaw)) * dist
	camera.look_at(c, Vector3.UP)


## Point the camera at one placed asset from a direction (for tools/staging_shots.gd).
func frame(id: String, from_yaw: float, distance: float, height := 0.5) -> void:
	var w: Node3D = placed[id]
	var box := Imp._bounds(w, Transform3D.IDENTITY)   # includes the wrapper's own position
	var c := box.position + box.size * Vector3(0.5, height, 0.5)
	camera.position = c + Vector3(sin(from_yaw), 0.25, cos(from_yaw)) * distance
	camera.look_at(c, Vector3.UP)
	set_process(false)
