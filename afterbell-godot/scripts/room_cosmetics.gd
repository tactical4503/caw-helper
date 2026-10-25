extends Node3D
## DS-01 Cosmetics and directory — the safe reflection demonstration (Installment 002, Section 4).
## Condensed demonstration layout, not the final campaign room.
##
## A nonhostile display attendant flips a sale placard across the aisle into a padded catcher every
## 6 s (shoulder pullback, two-note chime, slow cream-and-red placard). Mika asks Ren to return it
## with the flat of Knock to the hanging receiver above the west exit. A timed guard (or held guard
## with reflection assist) sends the placard along a short authored arc; the receiver tilts, its
## linkage rises and the hats gate rolls into the wall. The placard can never hurt Ren here.
## After three misses, a hint offers reflection assist (T) or Mika's manual release (H).
## Walking out of the open west gate continues to the Floor Manager fight (main.tscn).

const B := preload("res://scripts/builders.gd")
const ST := preload("res://scripts/style.gd")
const MAIN := preload("res://scripts/main.gd")
const REN_RIG := preload("res://rigs/ren.tscn")

# Local room coordinates: x east, -z north. DS-01 is building x10–26, y6–14 (16 m × 8 m).
const HALF_W := 8.0
const HALF_D := 4.0
const ENTRY := Vector2(0.0, 0.9)             # a few steps in from the south door, so the follow camera has its full distance
const THROW_FROM := Vector2(5.4, -1.4)       # attendant behind the east counter
const CATCH_AT := Vector2(-5.4, -1.4)        # padded catcher on the west counter
const GATE_Z := 1.8                          # hats gate in the west wall
const RECEIVER := Vector3(-7.55, 2.9, GATE_Z)
const CYCLE := 6.0
const TELL := 1.0
const PLACARD_SPEED := 2.6                   # slow enough to track
const REFLECT_WINDOW := 0.25                 # a little kinder than combat's 0.18 s
const ARC_TIME := 0.9

var keys_prev := {}
var held := {}
var pressed := {}
var virtual := {}

var ren: Node3D
var ren_anim: AnimationPlayer
var ren_clip := ""
var p_pos := ENTRY
var p_yaw := PI
var guard := false
var guard_press_t := -9.0
var reflect_t := 0.0
var time := 0.0

var attendant: Node3D
var attendant_arm: Node3D
var cycle_t := 2.0
var chimed := false
var placard: Node3D
var placard_state := ""       # "", "fly", "bounce", "arc"
var placard_pos := Vector3.ZERO
var placard_t := 0.0
var arc_from := Vector3.ZERO
var misses := 0
var hinted := false
var gate_open := false
var gate: Node3D
var receiver: Node3D
var linkage: Node3D
var gate_progress := 0.0
var leaving := false
var next_scene := "res://rooms/hats.tscn"
var interactables := []       # [Vector2 pos, name]
var used := {}

var camera: Camera3D
var sfx
var subtitle: Label
var who: Label
var prompt: Label
const Dialogue := preload("res://scripts/dialogue.gd")
const Mover := preload("res://scripts/mover.gd")
const Props := preload("res://scripts/props.gd")
const Glimpse := preload("res://scripts/glimpse.gd")
const Finish := preload("res://scripts/finish.gd")
var prop_solids: Array = []   # Rect2 footprints of floor props
const ShoulderCam := preload("res://scripts/shoulder_cam.gd")
var mover = Mover.new()
const GaugeHud := preload("res://scripts/hud.gd")
const Fade := preload("res://scripts/fade.gd")
var fade
var gauge
var dialogue
var settings := {"reflect_assist": false}
var intro_t := 0.0   # opening: a held view of the counters and the atrium gate, then the follow camera


func _ready() -> void:
	for a in MAIN.ACTIONS:
		var action: String = "ab_" + a
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in MAIN.ACTIONS[a]:
				var ev := InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)
	for extra in [["help", KEY_H]]:
		var action: String = "ab_" + extra[0]
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var ev := InputEventKey.new()
			ev.physical_keycode = extra[1]
			InputMap.action_add_event(action, ev)
	_build_room()
	fade = Fade.new()
	add_child(fade)
	ren = REN_RIG.instantiate()
	add_child(ren)
	ren_anim = ren.get_node("AnimationPlayer")
	camera = Camera3D.new()
	camera.fov = 68.0
	add_child(camera)
	camera.current = true
	sfx = B.Sfx.new()
	add_child(sfx)
	sfx.ambience.call_deferred("amb_cosmetics")
	gauge = GaugeHud.new()
	add_child(gauge)
	gauge.set_combat(false)          # safe room: the health panel fades back when quiet
	gauge.set_health(6, 6)
	gauge.set_biscuits(2)
	gauge.set_objective("Return the sale sign to the receiver")
	_build_hud()
	var shell := get_node_or_null("/root/Game")
	if shell == null or not shell.flag("opened"):
		# The chapter's opening (Installment 002, section 1): the stopped clock, the goal in view.
		say("", "Bellwether's Department Store. Outside, the tower clock has stopped at 5:59.", 3.2)
		say("MIKA", "The store thinks it closes at six. So we have a minute — forever.", 3.0)
		say("NELL", "The service bell's up past the atrium. Through that gate.", 2.8)
		if shell:
			shell.set_flag("opened")
		intro_t = 5.5
	say("NELL", "It keeps doing that. Over and over.", 2.6)
	say("MIKA", "It's feeding the gate release. Catch the sign with the flat of Knock — send it to the receiver over the west door.", 4.2)
	say("", "Tap guard (K) just as the bordered sign reaches you.", 3.0)
	_place_camera(1.0)
	var game := get_node_or_null("/root/Game")
	if game:
		game.enter_room("res://rooms/cosmetics.tscn", "Cosmetics & Directory")
		settings.reflect_assist = game.settings.reflect_assist
	B.Atrium.merge_direct(self)   # static architecture into a few meshes per material


# ---------------------------------------------------------------- building

## Walls, counters and floor props are solid (tests/paths_test.gd walks the room with this).
func _collide_player() -> void:
	p_pos.x = clampf(p_pos.x, -HALF_W + 0.4 if not gate_open else -HALF_W - 1.0, HALF_W - 0.4)
	p_pos.y = clampf(p_pos.y, -HALF_D + 0.4, HALF_D - 0.4)
	for s in [-1.0, 1.0]:
		var r := Rect2(Vector2(s * 4.6 - 1.7 - 0.3, -2.65 - 0.3), Vector2(3.4 + 0.6, 3.6 + 0.6))
		if r.has_point(p_pos):
			var dx := minf(absf(p_pos.x - r.position.x), absf(r.end.x - p_pos.x))
			var dz := minf(absf(p_pos.y - r.position.y), absf(r.end.y - p_pos.y))
			if dx < dz:
				p_pos.x = r.position.x if absf(p_pos.x - r.position.x) < absf(r.end.x - p_pos.x) else r.end.x
			else:
				p_pos.y = r.position.y if absf(p_pos.y - r.position.y) < absf(r.end.y - p_pos.y) else r.end.y
	p_pos = Props.push_out(p_pos, prop_solids)


## Upper walls, crown mouldings, ceiling beams and perfume shelving.
func _finish_walls() -> void:
	var fin := Finish.begin(self)
	var top := 4.2
	Finish.upper_wall(fin, Vector3(-HALF_W, 0, -HALF_D), Vector3(HALF_W, 0, -HALF_D), Vector3(0, 0, 1), 2.75, 3.8, top, [[5.3, 10.7]])
	Finish.upper_wall(fin, Vector3(HALF_W, 0, -HALF_D), Vector3(HALF_W, 0, HALF_D), Vector3(-1, 0, 0), 2.75, 3.8, top, [[1.85, 3.75]])
	Finish.upper_wall(fin, Vector3(-HALF_W, 0, -HALF_D), Vector3(-HALF_W, 0, HALF_D), Vector3(1, 0, 0), 2.75, 3.8, top, [[4.5, 8.0]])
	Finish.upper_wall(fin, Vector3(-HALF_W, 0, HALF_D), Vector3(HALF_W, 0, HALF_D), Vector3(0, 0, -1), 2.75, 3.8, top, [[6.25, 9.75]])
	for x in [-5.3, 5.3]:
		Finish.shelf(fin, Vector3(x, 0, -HALF_D), Vector3(0, 0, 1), 1.5, 1.45, "perfume")
	Finish.shelf(fin, Vector3(HALF_W, 0, -3.1), Vector3(-1, 0, 0), 1.1, 1.45, "perfume")
	Finish.ceiling_beams(fin, Rect2(-HALF_W, -HALF_D, HALF_W * 2.0, HALF_D * 2.0), top, false, [-6.8, -2.3, 2.3, 6.8])
	Finish.done(fin)


## Dressing that fills the corners without touching the demonstration: a perfume tower and
## lilies by the vestibule, mannequins at the back, a sale easel, the department sign.
func _place_props() -> void:
	for p in [["perfume_tower", Vector3(6.7, 0, 3.1), 0.0, 0], ["flower_display", Vector3(-6.9, 0, 3.25), 0.0, 0],
			["mannequin", Vector3(7.2, 0, -3.35), -0.8, 1], ["mannequin", Vector3(-7.2, 0, -3.35), 0.8, 3],
			["easel", Vector3(-3.6, 0, -3.35), 0.3, 1]]:
		Props.place(self, p[0], p[1], p[2], p[3], "SALE")
		prop_solids.append(Props.footprint(p[0], p[1], p[2]))


func _build_room() -> void:
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	add_child(env)
	var sun := ST.sun()
	add_child(sun)
	var cream := B.mat(B.CREAM, 0.5)
	var wall := ST.textured("plaster_cream", 0.3, B.mat(B.CREAM, 0.7))
	var laminate := ST.textured("laminate_plum", 1.0, B.mat(B.PLUM, 0.3))
	B.put(B.box(HALF_W * 2 + 2, 0.1, HALF_D * 2 + 2), ST.textured("tile_cream", 0.6, cream), Vector3(0, -0.05, 0), self, false)
	B.put(B.box(HALF_W * 2 - 1, 0.02, HALF_D * 2 - 1), ST.textured("carpet_forest", 0.5, B.mat(B.CARPET, 0.95)), Vector3(0, 0.01, 0), self, false)
	var ceil := B.put(B.box(HALF_W * 2 + 2, 0.2, HALF_D * 2 + 2), B.mat(Color("cbbd9f"), 0.8), Vector3(0, 4.3, 0), self, false)
	ceil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Walls: south (vestibule, with an opening), north (atrium, closed shutter), east, west (hats gate).
	for side in [-1.0, 1.0]:
		B.put(B.box(HALF_W - 1.2, 4.3, 0.3), wall, Vector3(side * (HALF_W + 1.2) / 2.0, 2.15, HALF_D + 0.15), self)
	# North wall, open where the locked lattice gate shows the atrium beyond.
	for side in [-1.0, 1.0]:
		B.put(B.box(HALF_W - 1.5, 4.3, 0.3), wall, Vector3(side * (HALF_W + 1.5) / 2.0, 2.15, -HALF_D - 0.15), self)
	B.put(B.box(3.0, 1.7, 0.3), wall, Vector3(0, 3.45, -HALF_D - 0.15), self)
	Props.lattice_gate(self, Vector3(0, 0, -HALF_D - 0.04), 3.0, 2.6)
	Glimpse.build(self, Vector3(0, 0, -HALF_D - 0.3), 0.0, "atrium", 7.0, 6.0, 7.0)
	B.put(B.box(0.3, 4.3, HALF_D * 2), wall, Vector3(HALF_W + 0.15, 2.15, 0), self)
	B.put(B.box(0.3, 4.3, HALF_D + GATE_Z - 0.9), wall, Vector3(-HALF_W - 0.15, 2.15, (-HALF_D + GATE_Z - 0.9) / 2.0), self)
	B.put(B.box(0.3, 4.3, HALF_D - GATE_Z - 0.9), wall, Vector3(-HALF_W - 0.15, 2.15, (GATE_Z + 0.9 + HALF_D) / 2.0), self)
	B.put(B.box(0.3, 1.9, 1.8), wall, Vector3(-HALF_W - 0.15, 3.35, GATE_Z), self)  # lintel
	# Hats gate: rolls up into the wall when the receiver is struck.
	gate = Node3D.new()
	gate.name = "HatsGate"
	gate.position = Vector3(-HALF_W - 0.05, 0, GATE_Z)
	add_child(gate)
	B.put(B.box(0.1, 2.4, 1.8), ST.textured("metal_charcoal", 1.5, B.mat(Color("2b2b2e"), 0.4, 0.6), 0.6), Vector3(0, 1.2, 0), gate)
	for i in 6:
		B.put(B.box(0.12, 0.04, 1.8), B.brass(), Vector3(0, 0.25 + i * 0.4, 0), gate)
	Props.pull_handle(gate, Vector3(0.06, 0.38, 0), 0.7, PI / 2.0)   # rises with the gate
	# Receiver above the west exit, with the linkage down to the gate.
	receiver = Node3D.new()
	receiver.position = RECEIVER
	add_child(receiver)
	B.put(B.box(0.12, 0.7, 0.9), B.mat(B.CREAM, 0.5), Vector3.ZERO, receiver)
	B.put(B.box(0.14, 0.76, 0.96), B.mat(B.RED, 0.5), Vector3(-0.02, 0, 0), receiver)
	linkage = Node3D.new()
	linkage.position = Vector3(-HALF_W + 0.05, 2.5, GATE_Z + 1.1)
	add_child(linkage)
	B.put(B.box(0.05, 1.0, 0.05), B.brass(), Vector3.ZERO, linkage)
	# Brass maintenance plate: a reflected arrow returning to a socket.
	var plate := B.put(B.box(0.04, 0.5, 0.7), B.brass(), Vector3(-HALF_W + 0.02, 1.5, GATE_Z + 1.45), self)
	plate.name = "MaintenancePlate"
	var arrow := Label3D.new()
	arrow.text = "↶  ●"
	arrow.font_size = 64
	arrow.pixel_size = 0.004
	arrow.modulate = B.PLUM
	arrow.rotation.y = PI / 2.0
	arrow.position = Vector3(-HALF_W + 0.05, 1.5, GATE_Z + 1.45)
	add_child(arrow)
	# Panelled walls, columns at the corners of the aisle, the shutter framed in brass.
	# Finished lower walls, stopping at the shutter's portal, the gate and the vestibule portal.
	var n_face := -HALF_D + 0.02
	var s_face := HALF_D - 0.02
	for side in [-1.0, 1.0]:
		B.wainscot_between(self, Vector3(side * 1.92, 0, n_face), Vector3(side * HALF_W, 0, n_face))
		B.wainscot_between(self, Vector3(side * 1.62, 0, s_face), Vector3(side * HALF_W, 0, s_face))
	B.wainscot_between(self, Vector3(HALF_W - 0.02, 0, -HALF_D), Vector3(HALF_W - 0.02, 0, HALF_D))
	B.wainscot_between(self, Vector3(-HALF_W + 0.02, 0, -HALF_D), Vector3(-HALF_W + 0.02, 0, GATE_Z - 1.04))
	B.wainscot_between(self, Vector3(-HALF_W + 0.02, 0, GATE_Z + 1.04), Vector3(-HALF_W + 0.02, 0, HALF_D))
	for c in [Vector2(-2.3, -HALF_D + 0.4), Vector2(2.3, -HALF_D + 0.4), Vector2(-2.3, HALF_D - 0.4), Vector2(2.3, HALF_D - 0.4)]:
		B.put(B.box(0.6, 4.3, 0.6), cream, Vector3(c.x, 2.15, c.y), self)
		B.put(B.box(0.7, 0.16, 0.7), B.brass(), Vector3(c.x, 4.1, c.y), self)
		B.put(B.box(0.7, 0.16, 0.7), B.brass(), Vector3(c.x, 0.08, c.y), self)
	# Doorways: cased frames on the shutter, the hats gate and the vestibule opening.
	Props.door_frame(self, Vector3(0, 0, -HALF_D - 0.15), 3.0, 2.6)
	Props.door_frame(self, Vector3(-HALF_W - 0.15, 0, GATE_Z), 1.8, 2.4, PI / 2.0)
	B.put(B.box(2.4, 1.5, 0.3), wall, Vector3(0, 3.55, HALF_D + 0.15), self)   # header over the vestibule
	Props.door_frame(self, Vector3(0, 0, HALF_D + 0.15), 2.4, 2.8)
	Props.portal(self, Vector3(0, 0, -HALF_D - 0.15), 3.0, 2.6, 0.0, 1.0, "ATRIUM")
	Props.portal(self, Vector3(0, 0, HALF_D + 0.15), 2.4, 2.8, 0.0, -1.0, "VESTIBULE  ·  STREET")
	Props.plaque(self, Vector3(-HALF_W, 3.75, GATE_Z), 1.4, "HATS  &  GLOVES", PI / 2.0)   # above the receiver
	Props.plaque(self, Vector3(HALF_W, 2.9, -1.2), 1.6, "COSMETICS  ·  FRAGRANCE", -PI / 2.0)
	# Two horseshoe counters, one each side of the central aisle.
	for s in [-1.0, 1.0]:
		var cx: float = s * 4.6
		# Each run's staff side faces into the horseshoe, where the attendant works.
		for part in [[Vector3(cx, 0.5, -2.3), Vector3(3.4, 1.0, 0.7), Vector3(0, 0, 1)], [Vector3(cx, 0.5, 0.6), Vector3(3.4, 1.0, 0.7), Vector3(0, 0, -1)],
				[Vector3(cx + s * 1.35, 0.5, -0.85), Vector3(0.7, 1.0, 2.2), Vector3(-s, 0, 0)]]:
			var pos: Vector3 = part[0]
			var size: Vector3 = part[1]
			Props.counter(self, Vector3(pos.x, 0, pos.z), size, "cream", 0.08, part[2])   # panelled outside, drawers and stock shelf inside
			var glass := StandardMaterial3D.new()
			glass.albedo_color = Color(0.85, 0.95, 0.92, 0.25)
			glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			glass.roughness = 0.03
			B.put(B.box(size.x - 0.1, 0.03, size.z - 0.1), glass, Vector3(pos.x, 1.017, pos.z), self, false)   # 2 mm proud of the top: no shared face
			# Perfume boxes and testers along the long runs.
			if size.x > 1:
				for k in [-0.85, 0.85]:
					Props.place(self, "perfume_boxes", Vector3(pos.x + k, 1.055, pos.z), 0.0, int(pos.z * 3.0 + k + s * 4.0) & 3)
	# Padded catcher on the west counter.
	var catcher := B.put(B.box(0.2, 0.9, 1.1), B.mat(Color("6b2620"), 0.85), Vector3(CATCH_AT.x - 0.4, 1.45, CATCH_AT.y), self)
	catcher.name = "Catcher"
	# Wall sconces: brass mounts, frosted tulip shades, a soft wash on the ivory walls.
	for l in [[Vector3(-4, 2.2, -HALF_D), Vector3(0, 0, 1)], [Vector3(4, 2.2, -HALF_D), Vector3(0, 0, 1)],
			[Vector3(HALF_W, 2.2, 0.6), Vector3(-1, 0, 0)], [Vector3(-HALF_W, 2.2, -2), Vector3(1, 0, 0)]]:
		ST.sconce(self, l[0], l[1], 0.85)
	_place_props()
	# Ceiling fixtures over each counter and the aisle.
	for x in [-4.6, 0.0, 4.6]:
		ST.ceiling_light(self, Vector3(x, 3.9, -0.6), 0.75, 6.0)
		ST.ceiling_fixture(self, Vector3(x, 3.95, -0.6), 4.2)
	_finish_walls()
	# The attendant (placeholder figure until the Meshy staff mannequin arrives).
	attendant = Node3D.new()
	attendant.name = "Attendant"
	attendant.position = Vector3(THROW_FROM.x + 0.4, 0, THROW_FROM.y)
	attendant.rotation.y = -PI / 2.0
	add_child(attendant)
	# Placeholder display mannequin (sale herald): glossy ivory, brass ball joints, on a stand.
	var ivory := ST.plastic(B.IVORY, 0.3, 0.0)
	var joint := B.brass()
	B.put(B.cyl(0.22, 0.26, 0.06), B.mat(B.BLACK, 0.3), Vector3(0, 0.03, 0), attendant)       # stand base
	B.put(B.cyl(0.025, 0.025, 0.5), joint, Vector3(0, 0.3, 0), attendant)                      # stand rod
	for side in [-1.0, 1.0]:
		B.put(B.capsule(0.07, 0.38), ivory, Vector3(side * 0.1, 0.75, 0), attendant)          # thighs
		B.put(B.sphere(0.06), joint, Vector3(side * 0.1, 0.55, 0), attendant)                  # knees
		B.put(B.capsule(0.06, 0.34), ivory, Vector3(side * 0.1, 0.33, 0), attendant)          # shins
	var torso := B.put(B.cyl(0.19, 0.14, 0.62), ivory, Vector3(0, 1.28, 0), attendant)
	torso.scale = Vector3(1.0, 1.0, 0.7)
	B.put(B.sphere(0.15), ivory, Vector3(0, 0.98, 0), attendant).scale = Vector3(1.1, 0.8, 0.8)   # hips
	B.put(B.cyl(0.055, 0.06, 0.12), ivory, Vector3(0, 1.64, 0), attendant)                     # neck
	B.put(B.sphere(0.13), ivory, Vector3(0, 1.82, 0), attendant).scale = Vector3(0.9, 1.2, 1.0)   # egg head
	B.put(B.cyl(0.14, 0.14, 0.05), B.mat(B.RED, 0.3), Vector3(0, 1.94, 0), attendant)           # sale visor crown
	B.put(B.box(0.26, 0.02, 0.14), B.mat(B.RED, 0.3), Vector3(0, 1.92, 0.15), attendant)        # visor brim
	for side in [-1.0, 1.0]:
		B.put(B.sphere(0.065), joint, Vector3(side * 0.24, 1.55, 0), attendant)                # shoulders
	var left_arm := Node3D.new()
	left_arm.position = Vector3(0.24, 1.55, 0)
	attendant.add_child(left_arm)
	B.put(B.capsule(0.045, 0.5), ivory, Vector3(0, -0.3, 0), left_arm)
	left_arm.rotation.z = 0.12
	attendant_arm = Node3D.new()
	attendant_arm.position = Vector3(-0.24, 1.55, 0)
	attendant.add_child(attendant_arm)
	B.put(B.capsule(0.045, 0.5), ivory, Vector3(0, -0.3, 0), attendant_arm)
	B.put(B.sphere(0.05), ivory, Vector3(0, -0.6, 0), attendant_arm)                          # hand
	# A warm spotlight picks out the attendant so the demonstration reads at a glance.
	var spot := SpotLight3D.new()
	spot.light_color = Color("ffd9a0")
	spot.light_energy = 2.5
	spot.light_specular = 0.3
	spot.spot_range = 6.0
	spot.spot_angle = 22.0
	spot.position = Vector3(THROW_FROM.x - 0.5, 4.0, THROW_FROM.y + 1.0)
	add_child(spot)
	spot.look_at(Vector3(THROW_FROM.x + 0.4, 1.4, THROW_FROM.y), Vector3.UP)
	# Interactables: mirror, atomizer, price card.
	var mirror := B.put(B.box(0.04, 0.4, 0.3), ST.plastic(Color("c8d8e0"), 0.02, 0.9), Vector3(-3.2, 1.35, -2.3), self)
	mirror.name = "Mirror"
	B.put(B.cyl(0.06, 0.07, 0.2), ST.plastic(Color("d4b0e0"), 0.1, 0.0), Vector3(3.2, 1.15, 0.6), self)
	B.put(B.box(0.25, 0.16, 0.02), B.mat(B.CREAM, 0.5), Vector3(-3.2, 1.12, 0.6), self)
	interactables = [[Vector2(-3.2, -1.7), "mirror"], [Vector2(3.2, 1.3), "atomizer"], [Vector2(-3.2, 1.3), "price"],
			[Vector2(3.5, -0.85), "attendant"]]


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	# Controls live in the pause menu (Esc) and in context prompts; no development labels.
	var bottom := VBoxContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -150
	bottom.offset_bottom = -24
	bottom.alignment = BoxContainer.ALIGNMENT_END
	layer.add_child(bottom)
	prompt = B._label("", 15, B.IVORY)
	who = B._label("", 13, B.BRASS)
	subtitle = B._label("", 20)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for l in [prompt, who, subtitle]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bottom.add_child(l)
	dialogue = Dialogue.new(sfx, who, subtitle)


func say(speaker: String, text: String, dur := 2.6) -> void:
	dialogue.say(speaker, text, dur)


# ---------------------------------------------------------------- loop

func _process(delta: float) -> void:
	step(minf(delta, 0.05))
	_place_camera(delta)


## One simulation tick (public so tests can drive the room deterministically).
func step(dt: float) -> void:
	for a in MAIN.ACTIONS.keys() + ["help"]:
		var h: bool = Input.is_action_pressed("ab_" + a) or bool(virtual.get(a, false))
		pressed[a] = h and not bool(keys_prev.get(a, false))
		keys_prev[a] = h
		held[a] = h
	time += dt
	_update_player(dt)
	_update_attendant(dt)
	_update_placard(dt)
	_update_gate(dt)
	_update_subs(dt)
	sfx.track(p_pos)


func _update_player(dt: float) -> void:
	var input := Vector2(float(held.get("right", false)) - float(held.get("left", false)),
		float(held.get("down", false)) - float(held.get("up", false)))
	if input.length() > 1.0:
		input = input.normalized()
	input = Mover.to_world(input, camera)
	var was := guard
	guard = held.get("guard", false)
	if guard and not was:
		guard_press_t = time
	if pressed.get("assist", false):
		settings.reflect_assist = not settings.reflect_assist
		say("", "Reflection assist %s." % ("on: hold guard and the sign returns itself" if settings.reflect_assist else "off"), 2.2)
	if pressed.get("help", false) and hinted and not gate_open:
		say("MIKA", "Hold the catch. Got it.", 2.0)
		_open_gate()
	var speed := 1.6 if guard else 4.5
	p_pos += mover.step(input, speed, dt) * dt
	_collide_player()
	if guard and placard_state == "fly":
		p_yaw = lerp_angle(p_yaw, atan2(placard_pos.x - p_pos.x, placard_pos.z - p_pos.y), 1.0 - exp(-14.0 * dt))
	elif input.length() > 0.1:
		p_yaw = Mover.turn(p_yaw, input, dt)
	ren.position = Vector3(p_pos.x, 0, p_pos.y)
	ren.rotation.y = p_yaw
	reflect_t = maxf(0.0, reflect_t - dt)
	var clip := "reflect" if reflect_t > 0.0 else ("guard" if guard else ("run" if input.length() > 0.1 else "idle"))
	if clip != ren_clip:
		ren_anim.play(clip, 0.08 if clip in ["guard", "reflect"] else 0.15)
		ren_clip = clip
	# Interactions.
	var near := ""
	for it in interactables:
		if p_pos.distance_to(it[0]) < 1.1:
			near = it[1]
	if gate_open and p_pos.x < -HALF_W + 0.9 and absf(p_pos.y - GATE_Z) < 0.9:
		gauge.show_prompt("go", "West — to Hats and the court")
		if p_pos.x < -HALF_W - 0.6 and not leaving:
			_leave()
	elif near != "":
		gauge.show_prompt("interact", {"mirror": "Look in the mirror", "atomizer": "Try the atomizer", "price": "Read the price card", "attendant": "Watch the attendant"}[near])
		if pressed.get("eat", false):
			_interact(near)
	elif hinted and not gate_open:
		gauge.show_prompt("assist", "Reflection assist   ·   H: ask Mika")
	else:
		gauge.hide_prompt()


func _interact(what: String) -> void:
	match what:
		"mirror":
			say("", "The hand mirror tilts. Ren, side-on: helmet, collar, a smudge on the visor.", 2.6)
		"atomizer":
			say("", "Pff. A harmless mist. Ren turns his helmet away, a little late.", 2.4)
			sfx.noise(0.25, 0.12)
		"price":
			say("", "\"Travel flask: keeps soup warm; lid sold with flask.\"", 2.8)
		"attendant":
			if gate_open:
				# Its errand is done, so it tends the counter: one tester, set exactly square.
				attendant_arm.rotation.x = -1.3
				say("", "The attendant sets a toppled tester upright, turns its label to face the aisle, and bows a fraction.", 3.2)
				if used.has("attendant"):
					say("NELL", "It did that one already. It's doing it again, better.", 2.4)
			else:
				say("", "Its head follows the placard, not you. The sale sign is the only customer it can see.", 3.0)
	if not used.has(what):
		used[what] = true


func _update_attendant(dt: float) -> void:
	var to_ren := atan2(p_pos.x - attendant.position.x, p_pos.y - attendant.position.z)
	if gate_open:
		# Demonstration over: it turns to Ren and gives a small, satisfied bow.
		attendant_arm.rotation.x = lerpf(attendant_arm.rotation.x, 0.0, 1.0 - exp(-4.0 * dt))
		attendant.rotation.y = lerp_angle(attendant.rotation.y, to_ren, 1.0 - exp(-3.0 * dt))
		attendant.rotation.x = 0.25 * sin(clampf(gate_progress * PI, 0.0, PI))
		return
	var throwing := cycle_t > CYCLE - TELL - 0.4 or cycle_t < 0.4
	attendant.rotation.y = lerp_angle(attendant.rotation.y, -PI / 2.0 if throwing else lerp_angle(-PI / 2.0, to_ren, 0.6), 1.0 - exp(-5.0 * dt))
	cycle_t += dt
	if cycle_t >= CYCLE:
		cycle_t -= CYCLE
		chimed = false
	var tell_start := CYCLE - TELL
	if cycle_t > tell_start and not chimed and placard_state == "":
		chimed = true
		sfx.chime()
	# Shoulder pullback during the tell, snap forward on the throw.
	var target := 0.0
	if cycle_t > tell_start:
		target = -2.6 + (cycle_t - tell_start) * 0.6
	elif cycle_t < 0.25:
		target = -0.9
	attendant_arm.rotation.x = lerpf(attendant_arm.rotation.x, target, 1.0 - exp(-12.0 * dt))
	if cycle_t < dt and placard_state == "":
		_throw()


func _throw() -> void:
	placard = B.build_placard()
	placard.scale = Vector3.ONE * 0.8
	add_child(placard)
	placard_pos = Vector3(THROW_FROM.x, 1.45, THROW_FROM.y)
	placard_state = "fly"
	placard_t = 0.0
	sfx.swing()


func _update_placard(dt: float) -> void:
	if placard_state == "":
		return
	placard_t += dt
	match placard_state:
		"fly":
			placard_pos.x -= PLACARD_SPEED * dt
			placard.rotation.y = PI / 2.0
			var flat := Vector2(placard_pos.x, placard_pos.z)
			if flat.distance_to(p_pos) < 0.75:
				var timed := time - guard_press_t <= REFLECT_WINDOW
				if guard and (timed or settings.reflect_assist):
					placard_state = "arc"
					placard_t = 0.0
					arc_from = placard_pos
					reflect_t = 0.3
					sfx.reflect()
				else:
					placard_state = "bounce"   # harmless here: it taps Ren and drops
					placard_t = 0.0
					sfx.thud()
					_miss()
			elif placard_pos.x <= CATCH_AT.x:
				sfx.knock()
				_remove_placard()
		"bounce":
			placard_pos.y = maxf(0.05, placard_pos.y - dt * 3.0)
			placard.rotation.x = lerpf(placard.rotation.x, -PI / 2.0, 1.0 - exp(-8.0 * dt))
			if placard_t > 1.5:
				_remove_placard()
		"arc":
			# Authored arc from the guard to the receiver.
			var k := minf(1.0, placard_t / ARC_TIME)
			var mid := (arc_from + RECEIVER) * 0.5 + Vector3(0, 1.2, 0)
			placard_pos = arc_from.lerp(mid, k).lerp(mid.lerp(RECEIVER, k), k)
			placard.rotation.y += dt * 10.0
			if k >= 1.0:
				_remove_placard()
				_open_gate()
	if placard:
		placard.position = placard_pos


func _remove_placard() -> void:
	if placard:
		placard.queue_free()
	placard = null
	placard_state = ""


func _miss() -> void:
	misses += 1
	if misses == 1:
		say("NELL", "It repeats itself. Wait for the chime, then guard as it reaches you.", 3.0)
	if misses >= 3 and not hinted:
		hinted = true
		say("MIKA", "No shame in help. T keeps your guard ready for it — or H and I'll hold the catch myself.", 4.0)


func _open_gate() -> void:
	if gate_open:
		return
	gate_open = true
	gauge.set_objective("Head west through Hats")
	sfx.spring()
	sfx.chime_errand()
	_toast("Errand complete  ·  the hats gate is open")
	_flag("cosmetics_done")
	say("", "The receiver tilts. Its linkage rises. The hats gate rolls into the wall.", 2.6)
	say("", "Notebook: \"Return marked signs with the flat of the blade.\"", 3.0)
	say("MIKA", "That cable runs to the escalators. West, through Hats.", 2.8)


func _update_gate(dt: float) -> void:
	if not gate_open:
		return
	gate_progress = minf(1.0, gate_progress + dt / 1.2)
	receiver.rotation.z = lerpf(0.0, -0.5, minf(1.0, gate_progress * 3.0))
	linkage.position.y = 2.5 + gate_progress * 0.6
	gate.position.y = gate_progress * 2.35


func _leave() -> void:
	leaving = true
	fade.go_to(next_scene)


func _update_subs(dt: float) -> void:
	dialogue.update(dt)


func _place_camera(delta: float) -> void:
	var walls := Rect2(-HALF_W + 0.35, -HALF_D + 0.35, HALF_W * 2.0 - 0.7, HALF_D * 2.0 - 0.7)
	ShoulderCam.place(camera, p_pos, Vector2(0, -1), delta, walls, 62.0)
	if intro_t > 0.0:
		intro_t = maxf(0.0, intro_t - delta)
		var k := smoothstep(0.0, 1.0, clampf(intro_t / 2.0, 0.0, 1.0))
		var est := Transform3D(Basis.IDENTITY, Vector3(-1.2, 2.5, HALF_D - 0.4)).looking_at(Vector3(0.0, 1.3, -HALF_D), Vector3.UP)
		camera.global_transform = camera.global_transform.interpolate_with(est, k)
		camera.fov = lerpf(camera.fov, 66.0, k)


## A short line from the chapter shell (errand complete, item found); quiet without it.
func _toast(text: String) -> void:
	var game := get_node_or_null("/root/Game")
	if game:
		game.toast(text)


func _flag(key: String) -> void:
	var game := get_node_or_null("/root/Game")
	if game:
		game.set_flag(key)


func _has_flag(key: String) -> bool:
	var game := get_node_or_null("/root/Game")
	return game != null and bool(game.flag(key))
