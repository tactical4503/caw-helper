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

const RACK_HOME := [Vector2(-4.9, 0.6), Vector2(4.9, 0.6)]
const BELL_POS := Vector3(0, 0, -7.0)

## Arm poses [raise, spread, elbow] for [upper, middle, lower]; mirrored per rail.
const POSES := {
	"idle": [[-1.0, 0.15, -1.1], [-0.3, 0.35, -0.8], [-0.2, 0.25, -1.3]],
	"present": [[-2.75, 0.12, -0.2], [-0.4, 0.4, -0.9], [-0.2, 0.25, -1.3]],
	"throw": [[-1.2, 0.1, 0.0], [-0.4, 0.4, -0.9], [-0.2, 0.25, -1.3]],
	"sweep_tell": [[-1.0, 0.15, -1.1], [-0.1, 1.5, 0.0], [-0.2, 0.25, -1.3]],
	"sweep_active": [[-1.0, 0.15, -1.1], [-1.5, 0.3, 0.0], [-0.2, 0.25, -1.3]],
	"rack": [[-1.0, 0.15, -1.1], [-1.35, 0.5, -0.2], [-0.2, 0.25, -1.3]],
	"exposed": [[-2.9, 0.6, -0.5], [-2.6, 0.9, -0.6], [-2.3, 1.0, -0.4]],
	"parked": [[0.05, 0.06, -2.5], [0.05, 0.06, -2.5], [0.05, 0.06, -2.5]],
}


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


class Arm:
	var shoulder: Node3D
	var elbow: Node3D
	var side := 1.0
	var level := 0
	var rx := 0.0
	var rz := 0.0
	var ex := 0.0


class Arena:
	var plinths: Array = []  # Rect2 footprints in (x, z)
	var tabs: Array = []
	var cabinet_door: Node3D
	var lever: Node3D
	var bell_dome: MeshInstance3D
	var lane_marks: Node3D
	var aim_arrow: Node3D


class Boss:
	var root: Node3D
	var chair: Node3D
	var upper: Node3D
	var body: Node3D
	var paddle: MeshInstance3D
	var paddle_mat: StandardMaterial3D
	var held: Node3D
	var arms: Array = []


class Ren:
	var root: Node3D
	var legs: Array = []
	var arm_l: Node3D
	var arm_r: Node3D
	var ring_mat: StandardMaterial3D


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
		var m := StandardMaterial3D.new()
		m.albedo_color = color
		m.roughness = rough
		m.metallic = metal
		_mats[key] = m
	return _mats[key]


static func brass() -> StandardMaterial3D:
	return mat(BRASS, 0.35, 0.85)


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


static func cyl(top: float, bottom: float, h: float, segments := 16) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = segments
	return c


static func sphere(r: float, segments := 16) -> SphereMesh:
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
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("1a1218")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("6b5560")
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	e.fog_enabled = true
	e.fog_light_color = Color("1a1218")
	e.fog_density = 0.012
	env.environment = e
	root.add_child(env)

	# Lighting: warm store interior; the bell is the brightest brass object (Section 3).
	var key := DirectionalLight3D.new()
	key.light_color = Color("fff0d6")
	key.light_energy = 1.3
	key.shadow_enabled = true
	key.rotation = Vector3(deg_to_rad(-55), deg_to_rad(-35), 0)
	root.add_child(key)
	var bell_light := SpotLight3D.new()
	bell_light.light_color = Color("ffd59a")
	bell_light.light_energy = 6.0
	bell_light.spot_range = 9.0
	bell_light.spot_angle = 30.0
	bell_light.position = Vector3(0, 5.2, BELL_POS.z + 1.6)
	root.add_child(bell_light)
	bell_light.look_at(Vector3(0, 1.2, BELL_POS.z), Vector3.FORWARD)
	for p in [Vector3(-5, 3.6, 1), Vector3(5, 3.6, 1), Vector3(0, 3.6, 5)]:
		var o := OmniLight3D.new()
		o.light_color = Color("ffc98a")
		o.light_energy = 1.2
		o.omni_range = 9.0
		o.position = p
		root.add_child(o)

	put(box(18, 0.1, 20), mat(TILE, 0.8), Vector3(0, -0.05, 0), root, false)
	put(box(16, 0.02, 18), mat(CARPET, 0.95), Vector3(0, 0.01, 0), root, false)
	# Three carpet inlays fan toward the bell: decoration that also reads as approach lanes.
	var lever_z := -6.1
	put(box(4, 0.02, 12), mat(PLUM, 0.9), Vector3(0, 0.025, lever_z + 6.2), root, false)
	for s in [-1.0, 1.0]:
		var strip := put(box(1.4, 0.02, 10), mat(CARPET_LIGHT, 0.9), Vector3(s * 4.2, 0.022, lever_z + 5.4), root, false)
		strip.rotation.y = s * 0.33
		put(box(0.08, 0.021, 12), mat(CREAM, 0.9), Vector3(s * 2.04, 0.03, lever_z + 6.2), root, false)
	# North wall, display platform split around the bell recess.
	var wall := mat(PLUM_DEEP, 0.85)
	put(box(16, 4.2, 0.3), wall, Vector3(0, 2.1, -9.15), root)
	put(box(16, 0.18, 0.34), mat(CREAM, 0.6), Vector3(0, 0.09, -8.98), root)
	for s in [-1.0, 1.0]:
		put(box(4.4, 0.32, 1.6), mat(WOOD, 0.6), Vector3(s * 4.6, 0.16, -8.15), root)
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
	put(box(10, 0.1, 30), mat(Color("24161f"), 1.0), Vector3(14, -4.2, 0), root, false)
	# Six low shoe plinths form the outer edge.
	for p in [Vector2(-7.0, -3.6), Vector2(-7.0, 2.4), Vector2(7.0, -3.6), Vector2(7.0, 2.4), Vector2(-3.6, 8.0), Vector2(3.6, 8.0)]:
		put(box(1.1, 0.5, 1.1), mat(CREAM, 0.6), Vector3(p.x, 0.25, p.y), root)
		put(box(1.14, 0.06, 1.14), mat(PLUM, 0.6), Vector3(p.x, 0.52, p.y), root)
		put(box(0.34, 0.14, 0.14), mat(RED, 0.5), Vector3(p.x, 0.62, p.y), root)
		a.plinths.append(Rect2(p - Vector2(0.6, 0.6), Vector2(1.2, 1.2)))

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
	put(box(3.2, 0.6, 0.06), mat(CREAM, 0.6), Vector3(0, 3.95, -0.3), bell)
	var sign_text := Label3D.new()
	sign_text.text = "S E R V I C E"
	sign_text.font_size = 72
	sign_text.pixel_size = 0.004
	sign_text.modulate = PLUM
	sign_text.outline_size = 0
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


static func build_rack(index: int) -> Rack:
	var r := Rack.new()
	r.node = Node3D.new()
	var frame := mat(Color("2b2b2e"), 0.4, 0.7)
	for z in [-0.8, 0.8]:
		put(box(0.05, 1.6, 0.05), frame, Vector3(0, 0.85, z), r.node)
		put(box(0.6, 0.05, 0.05), frame, Vector3(0, 0.08, z), r.node)
		for x in [-0.27, 0.27]:
			put(sphere(0.05, 8), mat(BLACK, 0.6), Vector3(x, 0.05, z), r.node)
	put(box(0.05, 0.05, 1.7), frame, Vector3(0, 1.65, 0), r.node)
	r.cloth = Node3D.new()
	r.cloth.position.y = 1.62
	r.node.add_child(r.cloth)
	var colors := [GRAY, CREAM, PLUM, GRAY, CREAM] if index == 1 else [PLUM, CREAM, GRAY, PLUM, RED]
	for i in colors.size():
		put(box(0.42, 0.95, 0.12), mat(colors[i], 0.95), Vector3(0, -0.5, -0.6 + i * 0.3), r.cloth)
	put(box(0.08, 0.14, 0.3), mat(CREAM, 0.5), Vector3(0, 1.05, 0.86), r.node)  # padded handle
	r.pos = RACK_HOME[index]
	r.target = r.pos
	return r


# ---------------------------------------------------------------- the Floor Manager

static func build_placard() -> Node3D:
	var g := Node3D.new()
	put(box(0.92, 0.62, 0.035), mat(RED, 0.6), Vector3(0, 0, -0.005), g)
	put(box(0.78, 0.48, 0.04), mat(CREAM, 0.6), Vector3.ZERO, g)
	put(box(0.5, 0.07, 0.042), mat(RED, 0.6), Vector3(0, 0.08, 0), g)
	put(box(0.36, 0.05, 0.042), mat(PLUM, 0.6), Vector3(0, -0.08, 0), g)
	return g


static func build_boss() -> Boss:
	var b := Boss.new()
	b.root = Node3D.new()
	b.root.name = "FloorManager"
	b.chair = Node3D.new()
	b.root.add_child(b.chair)
	var metal := mat(Color("2d2a2c"), 0.4, 0.6)
	for i in 5:  # five-star base, five casters
		var leg := Node3D.new()
		leg.rotation.y = i * TAU / 5.0
		b.chair.add_child(leg)
		put(box(0.06, 0.05, 0.36), metal, Vector3(0, 0.12, 0.18), leg)
		put(sphere(0.055, 10), mat(BLACK, 0.5), Vector3(0, 0.055, 0.36), leg)
	put(cyl(0.05, 0.05, 0.32), metal, Vector3(0, 0.28, 0), b.chair)
	put(cyl(0.34, 0.32, 0.12, 20), mat(GRAY, 0.95), Vector3(0, 0.5, 0), b.chair)
	for s in [-1.0, 1.0]:
		put(box(0.05, 0.16, 0.05), metal, Vector3(s * 0.3, 0.62, 0), b.chair)
		put(box(0.07, 0.04, 0.3), mat(BLACK, 0.6), Vector3(s * 0.3, 0.71, 0), b.chair)
	put(box(0.52, 0.16, 0.08), mat(Color("6b2620"), 0.85), Vector3(0, 0.22, 0.38), b.chair)  # padded front bumper
	b.paddle_mat = StandardMaterial3D.new()
	b.paddle_mat.albedo_color = RED
	b.paddle_mat.roughness = 0.5
	b.paddle_mat.emission_enabled = true
	b.paddle_mat.emission = Color("ff3020")
	b.paddle_mat.emission_energy_multiplier = 0.0
	b.paddle = put(box(0.3, 0.18, 0.04), b.paddle_mat, Vector3(0, 0.44, -0.18), b.chair)

	b.upper = Node3D.new()
	b.root.add_child(b.upper)
	b.body = Node3D.new()
	b.upper.add_child(b.body)
	var ivory := mat(IVORY, 0.45)
	put(cyl(0.065, 0.065, 0.95, 12), brass(), Vector3(0, 1.03, 0), b.body)
	put(cyl(0.16, 0.2, 0.08), brass(), Vector3(0, 1.5, 0), b.body)
	put(box(0.62, 0.95, 0.34), mat(CREAM, 0.6), Vector3(0, 2.0, 0), b.body)
	for s in [-1.0, 1.0]:
		put(box(0.025, 0.95, 0.36), mat(PLUM, 0.6), Vector3(s * 0.17, 2.0, 0.005), b.body)
		put(box(0.06, 0.9, 0.08), brass(), Vector3(s * 0.42, 2.02, 0), b.body)  # shoulder rails
	put(box(0.64, 0.025, 0.36), mat(PLUM, 0.6), Vector3(0, 1.53, 0), b.body)
	put(cyl(0.07, 0.08, 0.16, 10), ivory, Vector3(0, 2.53, 0), b.body)
	var head := Node3D.new()
	head.position.y = 2.82
	b.body.add_child(head)
	var skull := put(sphere(1.0, 24), ivory, Vector3.ZERO, head)
	skull.scale = Vector3(0.18, 0.29, 0.2)
	for s in [-1.0, 1.0]:
		put(box(0.07, 0.025, 0.02), mat(DARK, 0.9), Vector3(s * 0.07, 0.05, 0.185), head)
	put(box(0.1, 0.008, 0.02), mat(DARK, 0.9), Vector3(0, -0.13, 0.17), head)
	put(cyl(0.15, 0.16, 0.06, 20), brass(), Vector3(0, 0.21, 0), head)  # crown band
	for x in [-0.08, 0.0, 0.08]:  # three nested hanger hooks
		var hook := put(box(0.012, 0.09, 0.012), brass(), Vector3(x, 0.28, 0), head)
		hook.rotation.z = 0.3
	# Price-tag sash: a short rigid chain.
	for i in 6:
		var tag := put(box(0.09, 0.12, 0.01), mat(CREAM, 0.7), Vector3(-0.24 + i * 0.1, 2.32 - i * 0.14, 0.185), b.body)
		tag.rotation.z = -0.55
		if i > 0:
			put(box(0.06, 0.006, 0.006), mat(RED, 0.7), Vector3(-0.29 + i * 0.1, 2.39 - i * 0.14, 0.19), b.body)
	# Six arms: three per rail (upper signs, middle hangers/displays, lower chair).
	for s in [1.0, -1.0]:
		var level := 0
		for y in [2.38, 2.06, 1.74]:
			var arm := Arm.new()
			arm.side = s
			arm.level = level
			arm.shoulder = Node3D.new()
			arm.shoulder.position = Vector3(s * 0.47, y, 0)
			b.body.add_child(arm.shoulder)
			put(sphere(0.055, 10), brass(), Vector3.ZERO, arm.shoulder)
			put(cyl(0.035, 0.03, 0.5, 10), ivory, Vector3(0, -0.25, 0), arm.shoulder)
			arm.elbow = Node3D.new()
			arm.elbow.position.y = -0.5
			arm.shoulder.add_child(arm.elbow)
			put(sphere(0.04, 8), brass(), Vector3.ZERO, arm.elbow)
			put(cyl(0.03, 0.026, 0.46, 10), ivory, Vector3(0, -0.23, 0), arm.elbow)
			put(sphere(0.05, 10), ivory, Vector3(0, -0.5, 0), arm.elbow)
			b.arms.append(arm)
			level += 1
	b.held = build_placard()
	b.body.add_child(b.held)
	return b


# ---------------------------------------------------------------- Ren (SU-01 stand-in)

static func build_ren() -> Ren:
	var r := Ren.new()
	r.root = Node3D.new()
	r.root.name = "Ren"
	var black := mat(BLACK, 0.6)
	var lacquer := mat(Color("111014"), 0.25, 0.3)
	for s in [-1.0, 1.0]:
		var hip := Node3D.new()
		hip.position = Vector3(s * 0.12, 0.85, 0)
		r.root.add_child(hip)
		put(capsule(0.075, 0.6), black, Vector3(0, -0.38, 0), hip)
		put(box(0.15, 0.13, 0.28), mat(RED, 0.5), Vector3(0, -0.78, 0.04), hip)
		put(box(0.16, 0.04, 0.3), mat(CREAM, 0.6), Vector3(0, -0.85, 0.04), hip)
		r.legs.append(hip)
	put(capsule(0.17, 0.42), black, Vector3(0, 1.18, 0), r.root)
	put(box(0.34, 0.3, 0.06), lacquer, Vector3(0, 1.28, 0.14), r.root)
	put(box(0.36, 0.07, 0.24), mat(Color("3a3a3e"), 0.4, 0.7), Vector3(0, 0.92, 0), r.root)  # belt
	put(box(0.1, 0.08, 0.05), brass(), Vector3(0, 0.92, 0.13), r.root)
	var head := Node3D.new()
	head.position.y = 1.68
	r.root.add_child(head)
	put(sphere(0.15, 18), lacquer, Vector3.ZERO, head)
	put(box(0.24, 0.07, 0.06), mat(Color("060608"), 0.08, 0.6), Vector3(0, 0.02, 0.12), head)  # visor
	put(box(0.02, 0.1, 0.03), mat(STEEL, 0.3, 0.9), Vector3(0, -0.01, 0.15), head)            # nose divider
	put(box(0.14, 0.06, 0.06), mat(CREAM, 0.6), Vector3(0, -0.11, 0.1), head)                 # chin plate
	for s in [-1.0, 1.0]:
		var fin := put(box(0.02, 0.07, 0.18), lacquer, Vector3(s * 0.08, 0.1, -0.13), head)
		fin.rotation.x = -0.4
	r.arm_l = Node3D.new()
	r.arm_l.position = Vector3(-0.24, 1.42, 0)
	r.root.add_child(r.arm_l)
	r.arm_r = Node3D.new()
	r.arm_r.position = Vector3(0.24, 1.42, 0)
	r.root.add_child(r.arm_r)
	for arm in [r.arm_l, r.arm_r]:
		put(capsule(0.055, 0.42), black, Vector3(0, -0.25, 0), arm)
		put(sphere(0.07, 10), mat(CREAM, 0.6), Vector3(0, -0.52, 0), arm)
	# Knock: a broad, blunt blade with a usable flat face.
	var sword := Node3D.new()
	sword.position.y = -0.54
	r.arm_r.add_child(sword)
	put(box(0.05, 0.14, 0.05), mat(Color("3b2a20"), 0.7), Vector3.ZERO, sword)
	put(box(0.26, 0.04, 0.06), brass(), Vector3(0, -0.08, 0), sword)
	put(box(0.17, 0.9, 0.035), mat(STEEL, 0.35, 0.85), Vector3(0, -0.53, 0), sword)
	put(box(0.17, 0.06, 0.036), mat(CREAM, 0.5), Vector3(0, -0.98, 0), sword)
	r.ring_mat = StandardMaterial3D.new()
	r.ring_mat.albedo_color = Color(CREAM, 0.0)
	r.ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	r.ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ring := TorusMesh.new()
	ring.inner_radius = 0.55
	ring.outer_radius = 0.62
	var ring_mi := put(ring, r.ring_mat, Vector3(0, 0.04, 0), r.root, false)
	ring_mi.scale.y = 0.05
	return r


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

	func chime() -> void: tone(880, 0.35, 0.22, 0.0, -1, "tri"); tone(1175, 0.5, 0.22, 0.15, -1, "tri")
	func reflect() -> void: tone(1175, 0.18, 0.25, 0.0, -1, "tri"); tone(1568, 0.3, 0.2, 0.06, -1, "tri"); noise(0.05, 0.15)
	func thud() -> void: tone(120, 0.2, 0.35); noise(0.06, 0.1)
	func knock() -> void: tone(210, 0.1, 0.2, 0.0, -1, "tri"); noise(0.04, 0.15)
	func click() -> void: noise(0.02, 0.25)
	func swing() -> void: noise(0.12, 0.08)
	func heavy() -> void: noise(0.18, 0.15); tone(90, 0.25, 0.4)
	func hurt() -> void: tone(180, 0.22, 0.15, 0.0, 90)
	func squeak() -> void: tone(1900, 0.09, 0.05, 0.0, 2300)
	func rattle() -> void:
		for i in 8:
			noise(0.03, 0.15, i * 0.13)
	func spring() -> void: tone(300, 0.35, 0.15, 0.0, 1200, "tri")
	func pip() -> void: tone(1568, 0.11, 0.15, 0.05); tone(2093, 0.16, 0.15, 0.2)
	func bell() -> void:
		for p in [[1.0, 0.22, 2.2], [2.0, 0.09, 1.4], [2.76, 0.07, 1.0], [5.4, 0.04, 0.5]]:
			tone(523.0 * p[0], p[2], p[1])
