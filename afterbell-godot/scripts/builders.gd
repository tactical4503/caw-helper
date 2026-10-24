extends RefCounted
## Primitive greybox builders for AFTERBELL Installment 002. Stand-in shapes only:
## final assets replace these nodes without changing the fight logic in main.gd.

const CREAM := Color("efe3c8")
const IVORY := Color("e6dccb")
const PLUM := Color("5b2a4a")
const PLUM_DEEP := Color("3a1a2f")
const CARPET := Color("2f4a3a")
const CARPET_LIGHT := Color("3d5e4a")
const BRASS := Color("b58d3f")
const RED := Color("b0302a")
const BLACK := Color("17161b")
const GRAY := Color("8c8378")
const WOOD := Color("8a6440")
const TILE := Color("d8ccb0")
const STEEL := Color("9aa0a6")
const DARK := Color("0c0a0d")

const ST := preload("res://scripts/style.gd")
const Atrium := preload("res://scripts/atrium.gd")

const RACK_HOME := [Vector2(-4.9, 0.6), Vector2(4.9, 0.6)]
const BELL_POS := Vector3(0, 0, -7.0)

class SignData:
	var node: Node3D
	var pos := Vector2.ZERO
	var y := 1.45
	var vel := Vector2.ZERO
	var state := "out"
	var t := 0.0


class Rack:
	var node: Node3D
	var cloth: Node3D
	var pos := Vector2.ZERO
	var target := Vector2.ZERO
	var state := "park"
	var dir := 1
	var hit := false


class Arena:
	var plinths: Array = []  # Rect2 footprints in (x, z)
	var tabs: Array = []
	var cabinet_door: Node3D
	var lever: Node3D
	var bell_dome: MeshInstance3D
	var lane_marks: Node3D
	var aim_arrow: Node3D


class Hud:
	var root: Control
	var health: Label
	var biscuits: Label
	var tabs: Label
	var prompt: Label
	var subtitle_who: Label
	var subtitle: Label
	var title: Control
	var start_button: Button
	var options := {}
	var end: Control
	var end_eyebrow: Label
	var end_title: Label
	var end_body: Label
	var again_button: Button

	func set_health(hp: int, biscuit_count: int) -> void:
		health.text = "■ ".repeat(hp) + "□ ".repeat(6 - hp)
		biscuits.text = "biscuits " + "▬ ".repeat(biscuit_count)

	func set_tabs(gone: int) -> void:
		tabs.text = "□ ".repeat(gone) + "▮ ".repeat(3 - gone)


# ---------------------------------------------------------------- mesh helpers

static var _mats := {}


static func mat(color: Color, rough := 0.7, metal := 0.0) -> StandardMaterial3D:
	var key := "%s:%s:%s" % [color.to_html(), rough, metal]
	if not _mats.has(key):
		_mats[key] = ST.plastic(color, rough, metal)
	return _mats[key]


static var _brass: StandardMaterial3D


static func brass() -> StandardMaterial3D:
	if _brass == null:
		_brass = ST.textured("brass", 2.0, mat(BRASS, 0.35, 0.85), 0.85)
	return _brass


static func put(mesh: Mesh, material: Material, pos: Vector3, parent: Node3D, cast := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


static func box(w: float, h: float, d: float) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3(w, h, d)
	return b


static func cyl(top: float, bottom: float, h: float, segments := ST.SEGMENTS) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = segments
	return c


static func sphere(r: float, segments := ST.SEGMENTS) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = segments
	s.rings = segments / 2
	return s


static func capsule(r: float, length: float) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = r
	c.height = length + r * 2.0
	return c


# ---------------------------------------------------------------- arena DS-10

static func build_arena(parent: Node3D) -> Arena:
	var a := Arena.new()
	var root := Node3D.new()
	root.name = "Arena"
	parent.add_child(root)

	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	root.add_child(env)

	# Lighting: warm store interior; the bell is the brightest brass object (Section 3).
	var key := ST.sun()
	root.add_child(key)
	var bell_light := SpotLight3D.new()
	bell_light.light_color = Color("ffd59a")
	bell_light.light_energy = 6.0
	bell_light.spot_range = 9.0
	bell_light.spot_angle = 30.0
	bell_light.position = Vector3(0, 5.2, BELL_POS.z + 1.6)
	root.add_child(bell_light)
	bell_light.look_at(Vector3(0, 1.2, BELL_POS.z), Vector3.FORWARD)

	put(box(18, 0.1, 20), ST.textured("tile_cream", 0.6, ST.procedural(Color("b9a98a"), TILE, "marble")), Vector3(0, -0.05, 0), root, false)
	put(box(16, 0.02, 18), ST.textured("carpet_forest", 0.5, ST.procedural(Color("1f3a2a"), CARPET_LIGHT, "carpet", 1.5)), Vector3(0, 0.01, 0), root, false)
	# Three carpet inlays fan toward the bell: decoration that also reads as approach lanes.
	var lever_z := -6.1
	put(box(4, 0.02, 12), ST.textured("carpet_forest", 0.5, mat(CARPET, 0.9)), Vector3(0, 0.025, lever_z + 6.2), root, false)
	for s in [-1.0, 1.0]:
		var strip := put(box(1.4, 0.02, 10), ST.textured("carpet_sage", 0.5, mat(CARPET_LIGHT, 0.9)), Vector3(s * 4.2, 0.022, lever_z + 5.4), root, false)
		strip.rotation.y = s * 0.33
		put(box(0.08, 0.021, 12), mat(CREAM, 0.9), Vector3(s * 2.04, 0.03, lever_z + 6.2), root, false)
	# Bell partition (the rest of the north side opens onto the atrium), display platforms either side.
	var wall := ST.textured("plaster_cream", 0.3, mat(CREAM, 0.7))
	put(box(3.8, 4.3, 0.3), wall, Vector3(0, 2.15, -9.15), root)
	put(box(4.1, 0.26, 0.5), mat(CREAM, 0.6), Vector3(0, 4.4, -9.15), root)
	put(box(4.16, 0.06, 0.54), brass(), Vector3(0, 4.24, -9.15), root)
	put(box(3.8, 0.18, 0.34), mat(CREAM, 0.6), Vector3(0, 0.09, -8.98), root)
	for s in [-1.0, 1.0]:
		put(box(4.4, 0.32, 1.6), ST.textured("laminate_plum", 1.2, mat(PLUM, 0.5)), Vector3(s * 4.6, 0.16, -8.15), root)
		put(box(4.44, 0.04, 1.64), brass(), Vector3(s * 4.6, 0.33, -8.15), root)
	# West wall with the service door; waist-high east barrier over the atrium; low south wall and gate.
	put(box(0.3, 2.6, 15.2), wall, Vector3(-8.15, 1.3, -1.4), root)
	put(box(0.3, 2.6, 0.6), wall, Vector3(-8.15, 1.3, 8.7), root)
	put(box(0.08, 2.2, 1.7), mat(WOOD, 0.5), Vector3(-8.05, 1.1, 7.4), root)
	put(box(0.06, 0.06, 0.4), brass(), Vector3(-7.98, 1.0, 7.0), root)
	put(box(0.25, 1.05, 18), mat(CREAM, 0.6), Vector3(8.12, 0.52, 0), root)
	put(box(0.3, 0.08, 18), brass(), Vector3(8.12, 1.07, 0), root)
	put(box(16, 1.0, 0.25), mat(CREAM, 0.6), Vector3(0, 0.5, 9.1), root)
	for i in range(-2, 3):
		put(box(0.05, 1.6, 0.05), brass(), Vector3(i * 0.45, 1.3, 9.1), root)
	wainscot(root, Vector3(0, 0, -8.98), Vector3(3.8, 0, 0))     # bell partition
	wainscot(root, Vector3(-7.98, 0, -1.4), Vector3(0, 0, 15.2))  # west wall
	_build_hall(root)
	# Six low shoe plinths form the outer edge.
	for p in [Vector2(-7.0, -3.6), Vector2(-7.0, 2.4), Vector2(7.0, -3.6), Vector2(7.0, 2.4), Vector2(-3.6, 8.0), Vector2(3.6, 8.0)]:
		put(box(1.1, 0.5, 1.1), ST.textured("laminate_plum", 1.2, mat(PLUM, 0.6)), Vector3(p.x, 0.25, p.y), root)   # plum base
		put(box(1.16, 0.06, 1.16), mat(CREAM, 0.5), Vector3(p.x, 0.53, p.y), root)                                  # cream top
		put(box(1.14, 0.04, 1.14), brass(), Vector3(p.x, 0.48, p.y), root)                                          # brass band
		put(box(0.34, 0.14, 0.14), mat(RED, 0.5), Vector3(p.x, 0.62, p.y), root)
		a.plinths.append(Rect2(p - Vector2(0.6, 0.6), Vector2(1.2, 1.2)))
		Atrium.Props.place(root, "sale_card", Vector3(p.x, 0.555, p.y + 0.2), 0.0 if p.y < 7.0 else PI)

	# Bell stand, low lever, governor cabinet, SERVICE sign.
	var bell := Node3D.new()
	bell.position = BELL_POS
	root.add_child(bell)
	put(cyl(0.5, 0.6, 0.12, 24), mat(BLACK, 0.4), Vector3(0, 0.06, 0), bell)
	put(cyl(0.09, 0.11, 1.25, 12), mat(Color("3b3430"), 0.5, 0.4), Vector3(0, 0.68, 0), bell)
	var dome := SphereMesh.new()
	dome.radius = 0.72
	dome.height = 0.62
	dome.is_hemisphere = true
	dome.radial_segments = 40
	var dome_mat := StandardMaterial3D.new()
	dome_mat.albedo_color = Color("d9ae55")
	dome_mat.roughness = 0.22
	dome_mat.metallic = 1.0
	dome_mat.emission_enabled = true
	dome_mat.emission = Color("3a2508")
	a.bell_dome = put(dome, dome_mat, Vector3(0, 1.32, 0), bell)
	put(cyl(0.06, 0.06, 0.12), brass(), Vector3(0, 1.98, 0), bell)
	a.lever = Node3D.new()
	a.lever.position = Vector3(0, 0.42, 0.25)
	bell.add_child(a.lever)
	put(box(0.1, 0.08, 0.75), mat(Color("3b3430"), 0.5, 0.5), Vector3(0, 0, 0.35), a.lever)
	put(box(0.5, 0.36, 0.12), mat(RED, 0.8), Vector3(0, 0, 0.75), a.lever)  # padded striking plate faces south
	put(box(0.05, 0.9, 0.05), brass(), Vector3(0.14, 0.42, 0.06), a.lever)   # linkage rod to plunger
	var cabinet := Node3D.new()
	cabinet.position = Vector3(0, 2.85, -0.25)
	bell.add_child(cabinet)
	put(box(1.5, 1.1, 0.5), mat(CREAM, 0.55), Vector3.ZERO, cabinet)
	a.cabinet_door = Node3D.new()
	a.cabinet_door.position = Vector3(-0.7, 0, 0.26)
	cabinet.add_child(a.cabinet_door)
	put(box(1.4, 1.0, 0.04), mat(CREAM, 0.45), Vector3(0.7, 0, 0), a.cabinet_door)
	put(box(0.06, 0.2, 0.05), brass(), Vector3(1.25, 0, 0.03), a.cabinet_door)
	var governor := put(cyl(0.07, 0.07, 0.3), brass(), Vector3(0, 0, 0.02), cabinet)
	governor.rotation.z = PI / 2.0
	for x in [-0.4, 0.0, 0.4]:
		a.tabs.append(put(box(0.2, 0.28, 0.04), brass(), Vector3(x, -0.42, 0.3), cabinet))
	put(box(3.3, 0.66, 0.06), mat(PLUM, 0.6), Vector3(0, 3.95, -0.3), bell)  # enamel sign backing
	var face := ST.sign_face("service")
	if face:
		var quad := QuadMesh.new()
		quad.size = Vector2(3.2, 3.2 * 342.0 / 1922.0)
		put(quad, face, Vector3(0, 3.95, -0.265), bell, false)
	else:
		var sign_text := Label3D.new()
		sign_text.text = "S E R V I C E"
		sign_text.font_size = 72
		sign_text.pixel_size = 0.004
		sign_text.modulate = PLUM
		sign_text.position = Vector3(0, 3.95, -0.26)
		bell.add_child(sign_text)

	# Lateral rack channel, painted in once phase two begins.
	a.lane_marks = Node3D.new()
	a.lane_marks.visible = false
	root.add_child(a.lane_marks)
	var x := -7.2
	while x <= 7.2:
		for dz in [-0.95, 0.95]:
			put(box(0.5, 0.012, 0.08), mat(CREAM, 0.9), Vector3(x, 0.03, 3.6 + dz), a.lane_marks, false)
		x += 0.9

	# Optional floor arrow (contextual aiming help).
	a.aim_arrow = Node3D.new()
	a.aim_arrow.visible = false
	parent.add_child(a.aim_arrow)
	var arrow_mat := StandardMaterial3D.new()
	arrow_mat.albedo_color = Color(CREAM, 0.75)
	arrow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	arrow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	put(box(0.25, 0.01, 1.6), arrow_mat, Vector3(0, 0.05, 0.8), a.aim_arrow, false)
	var head := put(box(0.6, 0.01, 0.6), arrow_mat, Vector3(0, 0.05, 1.7), a.aim_arrow, false)
	head.rotation.y = PI / 4.0
	return a


## Plum lower wall panelling with a brass dado rail and brass kick, along a wall from its centre.
## `span` runs along the wall (x or z); the panel sits 2 cm proud of the wall face.
static func wainscot(root: Node3D, centre: Vector3, span: Vector3) -> void:
	var along_x := absf(span.x) > absf(span.z)
	var length := span.length()
	var panel := ST.textured("laminate_plum", 1.0, mat(PLUM, 0.5))   # plum lower wall under cream plaster
	var size := Vector3(length, 1.05, 0.04) if along_x else Vector3(0.04, 1.05, length)
	put(box(size.x, size.y, size.z), panel, centre + Vector3(0, 0.6, 0), root)
	var rail := Vector3(length, 0.07, 0.08) if along_x else Vector3(0.08, 0.07, length)
	put(box(rail.x, rail.y, rail.z), brass(), centre + Vector3(0, 1.14, 0), root)
	var kick := Vector3(length, 0.14, 0.06) if along_x else Vector3(0.06, 0.14, length)
	put(box(kick.x, kick.y, kick.z), brass(), centre + Vector3(0, 0.07, 0), root)


## Interior dressing: full-height columns with plum banners and brass lamps, chandeliers on long
## drops from the atrium roof, and the atrium itself (scripts/atrium.gd) rising three floors
## around the court.
static func _build_hall(arena_root: Node3D) -> void:
	var cream := mat(CREAM, 0.5)
	Atrium.build(arena_root)
	var root := Node3D.new()
	root.name = "Hall"
	arena_root.add_child(root)
	# Columns along the court, each running up past both galleries to the roof.
	var banner := ST.textured("plaster_plum", 0.8, mat(PLUM, 0.6))
	for spot in [Vector2(-7.75, -6), Vector2(-7.75, -1), Vector2(-7.75, 4), Vector2(7.95, -6), Vector2(7.95, -1), Vector2(7.95, 4),
			Vector2(-4, -8.85), Vector2(4, -8.85)]:
		var on_side: bool = absf(spot.x) > 7.0
		var face := Vector3(-signf(spot.x), 0, 0) if on_side else Vector3(0, 0, 1)
		put(box(0.7, Atrium.ROOF, 0.7), cream, Vector3(spot.x, Atrium.ROOF * 0.5, spot.y), root)
		put(box(0.8, 0.18, 0.8), brass(), Vector3(spot.x, 0.09, spot.y), root)
		for level in Atrium.LEVELS:
			put(box(0.8, 0.18, 0.8), brass(), Vector3(spot.x, level - 0.5, spot.y), root)
		put(box(0.9, 0.3, 0.9), cream, Vector3(spot.x, Atrium.ROOF - 0.6, spot.y), root)
		# Lower banner, and a long one between the galleries.
		for b in [[3.9, 2.0], [7.7, 3.4]]:
			var bb := put(box(0.75 if not on_side else 0.06, b[1], 0.06 if not on_side else 0.75), banner, Vector3(spot.x, b[0], spot.y) + face * 0.4, root)
			put(box(0.79 if not on_side else 0.07, 0.08, 0.07 if not on_side else 0.79), brass(), bb.position + Vector3(0, b[1] * 0.5, 0), root)
			Atrium.fleur(root, bb.position + Vector3(0, b[1] * 0.12, 0) + face * 0.05, face, 0.36)
		var lamp_pos := Vector3(spot.x, 2.6, spot.y) + face * 0.55
		put(sphere(0.06), brass(), lamp_pos - face * 0.15, root)
		ST.lamp(root, lamp_pos, 0.8, 5.5, face * 0.5)
		ST.globe(root, Vector3(spot.x, 12.6, spot.y) + face * 0.55)
	# Chandeliers on long drops from the roof: pools of light down the court and over the bell.
	for z in [5.0, 0.0, -5.0]:
		put(cyl(0.02, 0.02, Atrium.ROOF - 5.6, 6), brass(), Vector3(0, (Atrium.ROOF + 5.6) * 0.5, z), root, false)
		put(cyl(0.5, 0.15, 0.25, 16), brass(), Vector3(0, 5.5, z), root, false)
		for i in 6:
			var ang := TAU * i / 6.0
			ST.globe(root, Vector3(cos(ang) * 0.5, 5.25, z + sin(ang) * 0.5), 0.11)
		ST.ceiling_light(root, Vector3(0, 5.0, z), 0.9, 8.0)
	Atrium.merge(root)


static func build_rack(index: int) -> Rack:
	var r := Rack.new()
	r.node = Node3D.new()
	var frame := ST.textured("metal_charcoal", 2.0, mat(Color("2b2b2e"), 0.4, 0.7), 0.6)
	for z in [-0.8, 0.8]:
		put(box(0.05, 1.6, 0.05), frame, Vector3(0, 0.85, z), r.node)
		put(box(0.6, 0.05, 0.05), frame, Vector3(0, 0.08, z), r.node)
		for x in [-0.27, 0.27]:
			put(sphere(0.05, 8), mat(BLACK, 0.6), Vector3(x, 0.05, z), r.node)
	put(box(0.05, 0.05, 1.7), frame, Vector3(0, 1.65, 0), r.node)
	r.cloth = Node3D.new()
	r.cloth.position.y = 1.62
	r.node.add_child(r.cloth)
	# The same tailored coats as every store rack, hung across the rail.
	var colors := [GRAY, CREAM, PLUM, GRAY, CREAM] if index == 1 else [PLUM, CREAM, GRAY, PLUM, RED]
	for i in colors.size():
		var cloth_mat: StandardMaterial3D = ST.textured("linen_cream", 2.0, mat(colors[i], 0.95)) if colors[i] == CREAM else mat(colors[i], 0.95)
		Atrium.Props.coat(r.cloth, Vector3(0, 0.0, -0.6 + i * 0.3), cloth_mat, false, PI / 2.0)
	Atrium.merge(r.cloth)   # the coats swing as one piece; bake them into a few meshes
	put(box(0.08, 0.14, 0.3), mat(CREAM, 0.5), Vector3(0, 1.05, 0.86), r.node)  # padded handle
	r.pos = RACK_HOME[index]
	r.target = r.pos
	return r


# ---------------------------------------------------------------- the Floor Manager rig

static func build_placard() -> Node3D:
	var g := Node3D.new()
	g.name = "Placard"
	put(box(0.92, 0.62, 0.035), mat(RED, 0.6), Vector3(0, 0, -0.005), g)
	put(box(0.78, 0.48, 0.04), mat(CREAM, 0.6), Vector3.ZERO, g)
	put(box(0.5, 0.07, 0.042), mat(RED, 0.6), Vector3(0, 0.08, 0), g)
	put(box(0.36, 0.05, 0.042), mat(PLUM, 0.6), Vector3(0, -0.08, 0), g)
	return g


static func _joint(name: String, pos: Vector3, parent: Node3D) -> Node3D:
	var n := Node3D.new()
	n.name = name
	n.position = pos
	parent.add_child(n)
	return n


## Hierarchy (animated nodes in caps):
## FloorManager / Chair / Paddle
##              / Upper (yaw, code) / LIFT (telescoping) / Flinch (code) / BODY / HEAD, SASH, PLACARD,
##                                                                         Arm{1,2,3}{L,R} / ELBOW
## Arm 1 = upper rail (signs), 2 = middle (hangers/displays), 3 = lower (chair). L = his left (+x).
static func build_boss_rig() -> Node3D:
	var root := Node3D.new()
	root.name = "FloorManager"
	var chair := _joint("Chair", Vector3.ZERO, root)
	var metal := mat(Color("2d2a2c"), 0.4, 0.6)
	for i in 5:  # five-star base, five casters
		var leg := _joint("Leg%d" % i, Vector3.ZERO, chair)
		leg.rotation.y = i * TAU / 5.0
		put(box(0.06, 0.05, 0.36), metal, Vector3(0, 0.12, 0.18), leg)
		put(sphere(0.055, 10), mat(BLACK, 0.5), Vector3(0, 0.055, 0.36), leg)
	put(cyl(0.05, 0.05, 0.32), metal, Vector3(0, 0.28, 0), chair)
	put(cyl(0.34, 0.32, 0.12, 20), mat(GRAY, 0.95), Vector3(0, 0.5, 0), chair)
	for s in [-1.0, 1.0]:
		put(box(0.05, 0.16, 0.05), metal, Vector3(s * 0.3, 0.62, 0), chair)
		put(box(0.07, 0.04, 0.3), mat(BLACK, 0.6), Vector3(s * 0.3, 0.71, 0), chair)
	put(box(0.52, 0.16, 0.08), mat(Color("6b2620"), 0.85), Vector3(0, 0.22, 0.38), chair)  # padded front bumper
	var paddle_mat := StandardMaterial3D.new()
	paddle_mat.albedo_color = RED
	paddle_mat.roughness = 0.5
	paddle_mat.emission_enabled = true
	paddle_mat.emission = Color("ff3020")
	paddle_mat.emission_energy_multiplier = 0.0
	var paddle := put(box(0.3, 0.18, 0.04), paddle_mat, Vector3(0, 0.44, -0.18), chair)
	paddle.name = "Paddle"

	var upper := _joint("Upper", Vector3.ZERO, root)
	var lift := _joint("Lift", Vector3.ZERO, upper)
	var flinch := _joint("Flinch", Vector3(0, 1.45, 0), lift)  # pivot at the waist disc
	var body := _joint("Body", Vector3.ZERO, flinch)
	var ivory := mat(IVORY, 0.45)
	var y0 := -1.45  # body-local offset: geometry authored in standing heights
	put(cyl(0.065, 0.065, 0.95, 12), brass(), Vector3(0, 1.03 + y0, 0), body)
	put(cyl(0.16, 0.2, 0.08), brass(), Vector3(0, 1.5 + y0, 0), body)
	put(box(0.62, 0.95, 0.34), mat(CREAM, 0.6), Vector3(0, 2.0 + y0, 0), body)
	for s in [-1.0, 1.0]:
		put(box(0.025, 0.95, 0.36), mat(PLUM, 0.6), Vector3(s * 0.17, 2.0 + y0, 0.005), body)
		put(box(0.06, 0.9, 0.08), brass(), Vector3(s * 0.42, 2.02 + y0, 0), body)  # shoulder rails
	put(box(0.64, 0.025, 0.36), mat(PLUM, 0.6), Vector3(0, 1.53 + y0, 0), body)
	put(cyl(0.07, 0.08, 0.16, 10), ivory, Vector3(0, 2.53 + y0, 0), body)
	var head := _joint("Head", Vector3(0, 2.6 + y0, 0), body)  # pivot at the neck
	var skull := put(sphere(1.0, 24), ivory, Vector3(0, 0.22, 0), head)
	skull.scale = Vector3(0.18, 0.29, 0.2)
	for s in [-1.0, 1.0]:
		put(box(0.07, 0.025, 0.02), mat(DARK, 0.9), Vector3(s * 0.07, 0.27, 0.185), head)
	put(box(0.1, 0.008, 0.02), mat(DARK, 0.9), Vector3(0, 0.09, 0.17), head)
	put(cyl(0.15, 0.16, 0.06, 20), brass(), Vector3(0, 0.43, 0), head)  # crown band
	for x in [-0.08, 0.0, 0.08]:  # three nested hanger hooks
		var hook := put(box(0.012, 0.09, 0.012), brass(), Vector3(x, 0.5, 0), head)
		hook.rotation.z = 0.3
	# Price-tag sash: a short rigid chain hung from his left shoulder.
	var sash := _joint("Sash", Vector3(-0.26, 2.4 + y0, 0.185), body)
	for i in 6:
		var tag := put(box(0.09, 0.12, 0.01), mat(CREAM, 0.7), Vector3(0.02 + i * 0.1, -0.08 - i * 0.14, 0), sash)
		tag.rotation.z = -0.55
		if i > 0:
			put(box(0.06, 0.006, 0.006), mat(RED, 0.7), Vector3(-0.03 + i * 0.1, -0.01 - i * 0.14, 0.005), sash)
	# Six arms: three per rail (upper signs, middle hangers/displays, lower chair).
	for s in [1.0, -1.0]:
		var level := 1
		for y in [2.38, 2.06, 1.74]:
			var sh := _joint("Arm%d%s" % [level, "L" if s > 0 else "R"], Vector3(s * 0.47, y + y0, 0), body)
			put(sphere(0.055, 10), brass(), Vector3.ZERO, sh)
			put(cyl(0.035, 0.03, 0.5, 10), ivory, Vector3(0, -0.25, 0), sh)
			var el := _joint("Elbow", Vector3(0, -0.5, 0), sh)
			put(sphere(0.04, 8), brass(), Vector3.ZERO, el)
			put(cyl(0.03, 0.026, 0.46, 10), ivory, Vector3(0, -0.23, 0), el)
			put(sphere(0.05, 10), ivory, Vector3(0, -0.5, 0), el)
			_joint("Hand", Vector3(0, -0.5, 0), el)
			level += 1
	body.add_child(build_placard())
	root.set_script(load("res://scripts/rig_boss.gd"))
	return root


# ---------------------------------------------------------------- Ren rig (SU-01 stand-in)

## Hierarchy: Ren / PELVIS / LEG{L,R} / KNEE{L,R}
##                         / TORSO / HEAD, ARM{L,R} / FOREARM{L,R}; FOREARMR / SWORD
## L is Ren's left (+x). Knock is in his right hand.
static func build_ren_rig() -> Node3D:
	var root := Node3D.new()
	root.name = "Ren"
	var black := mat(BLACK, 0.6)
	var lacquer := mat(Color("111014"), 0.25, 0.3)
	var pelvis := _joint("Pelvis", Vector3(0, 0.92, 0), root)
	put(box(0.36, 0.07, 0.24), mat(Color("3a3a3e"), 0.4, 0.7), Vector3(0, 0.0, 0), pelvis)  # belt
	put(box(0.1, 0.08, 0.05), brass(), Vector3(0, 0.0, 0.13), pelvis)
	put(box(0.3, 0.14, 0.2), black, Vector3(0, -0.06, 0), pelvis)
	for side in ["L", "R"]:
		var s := 1.0 if side == "L" else -1.0
		var hip := _joint("Leg" + side, Vector3(s * 0.11, -0.04, 0), pelvis)
		put(capsule(0.075, 0.3), black, Vector3(0, -0.21, 0), hip)
		var knee := _joint("Knee" + side, Vector3(0, -0.43, 0), hip)
		put(capsule(0.065, 0.28), black, Vector3(0, -0.18, 0), knee)
		put(box(0.15, 0.13, 0.28), mat(RED, 0.5), Vector3(0, -0.38, 0.04), knee)
		put(box(0.16, 0.04, 0.3), mat(CREAM, 0.6), Vector3(0, -0.45, 0.04), knee)
	var torso := _joint("Torso", Vector3(0, 0.03, 0), pelvis)
	put(capsule(0.17, 0.3), black, Vector3(0, 0.3, 0), torso)
	put(box(0.34, 0.3, 0.06), lacquer, Vector3(0, 0.36, 0.14), torso)
	var head := _joint("Head", Vector3(0, 0.66, 0), torso)  # pivot at the neck
	put(sphere(0.15, 18), lacquer, Vector3(0, 0.1, 0), head)
	put(box(0.24, 0.07, 0.06), mat(Color("060608"), 0.08, 0.6), Vector3(0, 0.12, 0.12), head)  # visor
	put(box(0.02, 0.1, 0.03), mat(STEEL, 0.3, 0.9), Vector3(0, 0.09, 0.15), head)            # nose divider
	put(box(0.14, 0.06, 0.06), mat(CREAM, 0.6), Vector3(0, -0.01, 0.1), head)                # chin plate
	for s in [-1.0, 1.0]:
		var fin := put(box(0.02, 0.07, 0.18), lacquer, Vector3(s * 0.08, 0.2, -0.13), head)
		fin.rotation.x = -0.4
	for side in ["L", "R"]:
		var s := 1.0 if side == "L" else -1.0
		var arm := _joint("Arm" + side, Vector3(s * 0.24, 0.5, 0), torso)
		put(capsule(0.055, 0.18), black, Vector3(0, -0.14, 0), arm)
		var fore := _joint("Forearm" + side, Vector3(0, -0.28, 0), arm)
		put(capsule(0.05, 0.16), black, Vector3(0, -0.13, 0), fore)
		put(sphere(0.07, 10), mat(CREAM, 0.6), Vector3(0, -0.27, 0), fore)
		if side == "R":
			# Knock: a broad, blunt blade with a usable flat face. Blade runs along -y from the grip.
			var sword := _joint("Sword", Vector3(0, -0.28, 0), fore)
			put(box(0.05, 0.14, 0.05), mat(Color("3b2a20"), 0.7), Vector3.ZERO, sword)
			put(box(0.26, 0.04, 0.06), brass(), Vector3(0, -0.08, 0), sword)
			put(box(0.17, 0.9, 0.035), mat(STEEL, 0.35, 0.85), Vector3(0, -0.53, 0), sword)
			put(box(0.17, 0.06, 0.036), mat(CREAM, 0.5), Vector3(0, -0.98, 0), sword)
	return root


# ---------------------------------------------------------------- HUD and menus

static func _label(text: String, size: int, color := CREAM) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l


static func _panel_card() -> Array:
	var shade := ColorRect.new()
	shade.color = Color(0.09, 0.07, 0.1, 0.9)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.165, 0.075, 0.133, 0.95)
	style.border_color = Color(BRASS, 0.7)
	style.set_border_width_all(1)
	style.set_content_margin_all(28)
	card.add_theme_stylebox_override("panel", style)
	card.custom_minimum_size = Vector2(520, 0)
	center.add_child(card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	card.add_child(col)
	return [shade, col]


static func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 18)
	var normal := StyleBoxFlat.new()
	normal.bg_color = RED
	normal.border_color = CREAM
	normal.set_border_width_all(1)
	normal.set_content_margin_all(12)
	b.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("c63c34")
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", CREAM)
	return b


static func build_hud(parent: Node) -> Hud:
	var h := Hud.new()
	var layer := CanvasLayer.new()
	parent.add_child(layer)

	h.root = Control.new()
	h.root.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.root.visible = false
	layer.add_child(h.root)
	var left := VBoxContainer.new()
	left.position = Vector2(16, 12)
	h.root.add_child(left)
	left.add_child(_label("REN", 12, BRASS))
	h.health = _label("", 22, RED)
	left.add_child(h.health)
	h.biscuits = _label("", 14)
	left.add_child(h.biscuits)
	var right := VBoxContainer.new()
	right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	right.position = Vector2(-180, 12)
	right.alignment = BoxContainer.ALIGNMENT_END
	h.root.add_child(right)
	right.add_child(_label("SERVICE TABS", 12, BRASS))
	h.tabs = _label("", 24, BRASS)
	right.add_child(h.tabs)
	var bottom := VBoxContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -170
	bottom.offset_bottom = -24
	bottom.alignment = BoxContainer.ALIGNMENT_END
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.root.add_child(bottom)
	h.prompt = _label("", 15, IVORY)
	h.subtitle_who = _label("", 13, BRASS)
	h.subtitle = _label("", 20)
	h.subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for l in [h.prompt, h.subtitle_who, h.subtitle]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bottom.add_child(l)

	var t := _panel_card()
	h.title = t[0]
	layer.add_child(h.title)
	var col: VBoxContainer = t[1]
	col.add_child(_label("AFTERBELL · INSTALLMENT 002 · BS-01", 12, BRASS))
	col.add_child(_label("Closing Time", 48))
	col.add_child(_label("The Floor Manager, Menswear Court, Bellwether's Department Store", 15, IVORY))
	var note := _label("Greybox demonstration build. Primitive stand-in shapes, untested tuning values from the design table. Not final art, not the final layout.", 13, Color(IVORY, 0.7))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(note)
	for opt in [["easy", "Easy assist — 8 s opening, wider steering"], ["reflect_assist", "Reflection assist — held guard always reflects"],
			["aim_help", "Contextual aiming help — floor arrow during the opening"], ["keep_progress", "Keep boss progress after defeat"],
			["shake", "Camera shake (small)"]]:
		var cb := CheckBox.new()
		cb.text = opt[1]
		col.add_child(cb)
		h.options[opt[0]] = cb
	h.start_button = _button("ENTER THE COURT")
	col.add_child(h.start_button)
	var controls := _label("Move WASD/arrows · Attack J or left click (hold 0.8 s to wind) · Guard K or right click (tap as the sign arrives) · Dodge Space · Biscuit E · Retreat R by the west door · Esc pause", 13, Color(IVORY, 0.8))
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(controls)

	var e := _panel_card()
	h.end = e[0]
	h.end.visible = false
	layer.add_child(h.end)
	var ecol: VBoxContainer = e[1]
	h.end_eyebrow = _label("", 12, BRASS)
	h.end_title = _label("", 44)
	h.end_body = _label("", 15, IVORY)
	h.end_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.again_button = _button("Again")
	for c in [h.end_eyebrow, h.end_title, h.end_body, h.again_button]:
		ecol.add_child(c)
	return h


# ---------------------------------------------------------------- synthesized cues

class Sfx extends Node:
	const RATE := 22050.0
	var _player: AudioStreamPlayer
	var _playback: AudioStreamGeneratorPlayback
	var _voices: Array = []  # [freq, freq_end, dur, t, vol, kind, delay, phase]

	func _ready() -> void:
		var gen := AudioStreamGenerator.new()
		gen.mix_rate = RATE
		gen.buffer_length = 0.15
		_player = AudioStreamPlayer.new()
		_player.stream = gen
		_player.volume_db = -6.0
		add_child(_player)
		_player.play()
		_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback

	func tone(f: float, dur: float, vol := 0.25, delay := 0.0, f_end := -1.0, kind := "sine") -> void:
		_voices.append([f, f if f_end < 0.0 else f_end, dur, 0.0, vol, kind, delay, 0.0])

	func noise(dur: float, vol := 0.2, delay := 0.0) -> void:
		_voices.append([0.0, 0.0, dur, 0.0, vol, "noise", delay, 0.0])

	func _process(_delta: float) -> void:
		if _playback == null:
			return
		var frames := _playback.get_frames_available()
		var dt := 1.0 / RATE
		for i in frames:
			var s := 0.0
			for v in _voices:
				if v[6] > 0.0:
					v[6] -= dt
					continue
				var k: float = v[3] / v[2]
				var env: float = v[4] * (1.0 - k) * (1.0 - k)
				if v[5] == "noise":
					s += (randf() * 2.0 - 1.0) * env
				else:
					var f: float = lerpf(v[0], v[1], k)
					v[7] = fmod(v[7] + f * dt, 1.0)
					var ph: float = v[7]
					s += (sin(ph * TAU) if v[5] == "sine" else (1.0 - 4.0 * absf(ph - 0.5))) * env
				v[3] += dt
			_playback.push_frame(Vector2(s, s).clamp(Vector2(-1, -1), Vector2(1, 1)))
			if i % 256 == 0:
				_voices = _voices.filter(func(v): return v[3] < v[2])

	# Each cue first looks for a recorded file in assets/sfx/<name>.(ogg|wav|mp3); if there is
	# one it plays that instead of the synthesized version. Drop files in to upgrade sounds.
	func chime() -> void:
		if not play_file("chime"): tone(880, 0.35, 0.22, 0.0, -1, "tri"); tone(1175, 0.5, 0.22, 0.15, -1, "tri")
	func reflect() -> void:
		if not play_file("reflect"): tone(1175, 0.18, 0.25, 0.0, -1, "tri"); tone(1568, 0.3, 0.2, 0.06, -1, "tri"); noise(0.05, 0.15)
	func thud() -> void:
		if not play_file("thud"): tone(120, 0.2, 0.35); noise(0.06, 0.1)
	func knock() -> void:
		if not play_file("knock"): tone(210, 0.1, 0.2, 0.0, -1, "tri"); noise(0.04, 0.15)
	func click() -> void:
		if not play_file("click"): noise(0.02, 0.25)
	func swing() -> void:
		if not play_file("swing"): noise(0.12, 0.08)
	func heavy() -> void:
		if not play_file("heavy"): noise(0.18, 0.15); tone(90, 0.25, 0.4)
	func hurt() -> void:
		if not play_file("hurt"): tone(180, 0.22, 0.15, 0.0, 90)
	func squeak() -> void:
		if not play_file("squeak"): tone(1900, 0.09, 0.05, 0.0, 2300)
	func rattle() -> void:
		if play_file("rattle"):
			return
		for i in 8:
			noise(0.03, 0.15, i * 0.13)
	func spring() -> void:
		if not play_file("spring"): tone(300, 0.35, 0.15, 0.0, 1200, "tri")
	func pip() -> void:
		if not play_file("pip"): tone(1568, 0.11, 0.15, 0.05); tone(2093, 0.16, 0.15, 0.2)
	func bell() -> void:
		if play_file("bell"):
			return
		for p in [[1.0, 0.22, 2.2], [2.0, 0.09, 1.4], [2.76, 0.07, 1.0], [5.4, 0.04, 0.5]]:
			tone(523.0 * p[0], p[2], p[1])

	# ------------------------------------------------ recorded sounds

	const SFX_DIR := "res://assets/sfx/"
	var _files := {}          # name -> AudioStream or null (cached lookups)
	var _players: Array = []
	var _ambience: AudioStreamPlayer

	func _stream(name: String) -> AudioStream:
		if not _files.has(name):
			_files[name] = null
			for ext in ["ogg", "wav", "mp3"]:
				var path: String = SFX_DIR + name + "." + ext
				if ResourceLoader.exists(path):
					_files[name] = load(path)
					break
		return _files[name]

	## Plays assets/sfx/<name>.* if it exists (slight pitch variety so repeats don't grate).
	func play_file(name: String, volume_db := 0.0) -> bool:
		var stream := _stream(name)
		if stream == null:
			return false
		var player: AudioStreamPlayer = null
		for p in _players:
			if not p.playing:
				player = p
				break
		if player == null:
			if _players.size() >= 12:
				player = _players[0]
			else:
				player = AudioStreamPlayer.new()
				add_child(player)
				_players.append(player)
		player.stream = stream
		player.volume_db = volume_db
		player.pitch_scale = randf_range(0.96, 1.04)
		player.play()
		return true

	## Looping room tone from assets/sfx/<name>.* (e.g. amb_cosmetics); silent if absent.
	func ambience(name: String, volume_db := -12.0) -> bool:
		var stream := _stream(name)
		if stream == null:
			return false
		if _ambience == null:
			_ambience = AudioStreamPlayer.new()
			add_child(_ambience)
		if stream is AudioStreamOggVorbis:
			stream.loop = true
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_end = int(stream.get_length() * stream.mix_rate)
		elif stream is AudioStreamMP3:
			stream.loop = true
		_ambience.stream = stream
		_ambience.volume_db = volume_db
		_ambience.play()
		return true
