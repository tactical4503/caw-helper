extends Node3D
## DS-03 Alterations counter + DS-04 Receiving refuge (Installment 002, Section 6). Safe rooms.
## Condensed demonstration layout, not the final campaign rooms.
##
## Alterations: chalk on the fitting platform, a fan that turns its head, a pincushion in a saucer,
## and a curtained stall where a mannequin tailor has lost a sleeve (Nell spots it on the receiving
## doorknob; whoever hands it back, the tailor thanks Nell, then corrects itself). The east gate's
## crank has snapped: Ren slots Knock sideways into the broad maintenance socket and turns it while
## Mika holds the safety catch (six seconds the first time). The gate opens onto the atrium.
## Receiving: Hesta's first scene, Len's governor news, a biscuit tin and water jug that restock
## the minimum supply. East through the atrium gate leads to the Floor Manager's court.

const B := preload("res://scripts/builders.gd")
const ST := preload("res://scripts/style.gd")
const MAIN := preload("res://scripts/main.gd")
const REN_RIG := preload("res://rigs/ren.tscn")
const Dialogue := preload("res://scripts/dialogue.gd")
const Mover := preload("res://scripts/mover.gd")
const Props := preload("res://scripts/props.gd")
const Glimpse := preload("res://scripts/glimpse.gd")
const Finish := preload("res://scripts/finish.gd")
var gate_needle: Node3D   # the winding station's dial needle
const ShoulderCam := preload("res://scripts/shoulder_cam.gd")
var mover = Mover.new()
const GaugeHud := preload("res://scripts/hud.gd")
const Fade := preload("res://scripts/fade.gd")

# Local coordinates: x east, -z north. Alterations x0–10, y24–34 → x -5..5, z -5..5.
# Receiving x0–12, y34–42 sits north of it → x -5..7, z -13..-5.
const ENTRY := Vector2(0.0, 1.3)          # a few steps in from the south door (Hats), clear of the camera squeeze
const DOOR_X := -2.5                      # alterations ↔ receiving doorway (north wall)
const GATE_Z := 0.5                       # atrium gate in the east wall
const SOCKET := Vector2(4.1, -0.9)        # where Ren stands to use the crank socket
const STALL := Vector2(3.3, -3.4)
const CRANK_FIRST := 6.0
const CRANK_REPEAT := 3.0

var keys_prev := {}
var held := {}
var pressed := {}
var virtual := {}

var ren: Node3D
var ren_anim: AnimationPlayer
var ren_clip := ""
var p_pos := ENTRY
var p_yaw := PI
var speed := 0.0
var time := 0.0
var hp := 6
var biscuits := 2

var gate: Node3D
var socket_disc: Node3D
var curtain: Node3D
var fan_head: Node3D
var sleeve: Node3D
var tailor: Node3D
var crank_t := -1.0                       # < 0: not cranking
var crank_len := CRANK_FIRST
var cranked_once := false
var gate_open := false
var gate_progress := 0.0
var tailor_asked := false
var sleeve_held := false
var sleeve_returned := false
var met_hesta := false
var talked_len := false
var restocked := false
var leaving := false
var next_scene := "res://main.tscn"
var solids: Array = []
var interactables: Array = []             # [Vector2, id]
var used := {}                            # ids already examined (second looks get a second line)

var camera: Camera3D
var sfx
var gauge
var dialogue
var fade


func _ready() -> void:
	for a in MAIN.ACTIONS:
		var action: String = "ab_" + a
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in MAIN.ACTIONS[a]:
				var ev := InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)
	_build_rooms()
	fade = Fade.new()
	add_child(fade)
	ren = REN_RIG.instantiate()
	add_child(ren)
	ren_anim = ren.get_node("AnimationPlayer")
	camera = Camera3D.new()
	camera.fov = 66.0
	add_child(camera)
	camera.current = true
	sfx = B.Sfx.new()
	add_child(sfx)
	sfx.ambience.call_deferred("amb_alterations")
	gauge = GaugeHud.new()
	add_child(gauge)
	gauge.set_combat(false)
	gauge.set_health(hp, 6)
	gauge.set_biscuits(biscuits)
	gauge.set_objective("Open the gate to the atrium")
	_build_hud()
	say("MIKA", "Alterations. The atrium gate's on the east wall — and its crank has snapped.", 3.2)
	if _has_flag("hats_cleared"):
		say("NELL", "Hats is quiet now. Those two looked almost relieved to sit down.", 2.8)
	_place_camera(1.0)
	var game := get_node_or_null("/root/Game")
	if game:
		game.enter_room("res://rooms/alterations.tscn", "Alterations  ·  Receiving")
	B.Atrium.merge_direct(self)   # static architecture into a few meshes per material


# ---------------------------------------------------------------- building

func _build_rooms() -> void:
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	add_child(env)
	add_child(ST.sun())
	var cream := B.mat(B.CREAM, 0.5)
	var plaster := ST.textured("plaster_cream", 0.3, B.mat(B.CREAM, 0.7))
	var plum := ST.textured("plaster_cream", 0.3, B.mat(B.CREAM, 0.7))
	var metal := ST.textured("metal_charcoal", 1.5, B.mat(Color("2b2b2e"), 0.4, 0.6), 0.6)
	var wood := ST.plastic(Color("6e4326"), 0.35, 0.0)
	var card := ST.textured("cardboard", 1.2, B.mat(Color("a57a4c"), 0.9))
	# Floors: carpet in Alterations, worn tile in Receiving.
	B.put(B.box(14, 0.1, 20), ST.textured("tile_cream", 0.6, cream), Vector3(1, -0.05, -4), self, false)
	B.put(B.box(9.6, 0.02, 9.6), ST.textured("carpet_forest", 0.5, B.mat(B.CARPET, 0.9)), Vector3(0, 0.01, 0), self, false)
	# Receiving's floor: the same tile, but older and greyer, so the back room sits darker and
	# cooler than the shop floor.
	var worn := ST.textured("tile_cream", 0.6, B.mat(Color("bdb6a8"), 0.8))
	worn.albedo_color = Color(0.7, 0.7, 0.68)
	B.put(B.box(12.0, 0.02, 7.7), worn, Vector3(1.0, 0.005, -9.15), self, false)
	var ceil := B.put(B.box(14, 0.2, 20), B.mat(Color("cbbd9f"), 0.8), Vector3(1, 3.6, -4), self, false)
	ceil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Alterations walls: cream plaster like the rest of the store.
	B.put(B.box(0.3, 3.6, 10), plaster, Vector3(-5.15, 1.8, 0), self)
	B.put(B.box(0.3, 3.6, 5 + GATE_Z - 0.9), plaster, Vector3(5.15, 1.8, (-5 + GATE_Z - 0.9) / 2.0), self)
	B.put(B.box(0.3, 3.6, 5 - GATE_Z - 0.9), plaster, Vector3(5.15, 1.8, (GATE_Z + 0.9 + 5) / 2.0), self)
	B.put(B.box(0.3, 1.2, 1.8), plaster, Vector3(5.15, 3.0, GATE_Z), self)
	for side in [-1.0, 1.0]:
		B.put(B.box(4.1, 3.6, 0.3), plaster, Vector3(side * 2.95, 1.8, 5.15), self)
	B.put(B.box(DOOR_X + 5 - 0.8, 3.6, 0.3), plaster, Vector3((-5 + DOOR_X - 0.8) / 2.0, 1.8, -5.15), self)
	B.put(B.box(5 - DOOR_X - 0.8 + 2, 3.6, 0.3), plaster, Vector3((DOOR_X + 0.8 + 7) / 2.0, 1.8, -5.15), self)
	B.put(B.box(1.6, 1.2, 0.3), plaster, Vector3(DOOR_X, 3.0, -5.15), self)
	# Doorways: Receiving door (cased, its door swung back into Receiving), the south entrance.
	Props.door_frame(self, Vector3(DOOR_X, 0, -5.15), 1.6, Props.DOOR_HEIGHT)
	Props.door_leaf(self, Vector3(DOOR_X - 0.8, 0, -5.3), 1.55, Props.DOOR_HEIGHT, 0.0, PI / 2.0 * 0.92)
	B.put(B.box(1.8, 1.1, 0.3), plaster, Vector3(0, 3.05, 5.15), self)
	Props.door_frame(self, Vector3(0, 0, 5.15), 1.8, 2.5)
	Props.portal(self, Vector3(DOOR_X, 0, -5.15), 1.6, Props.DOOR_HEIGHT, 0.0, 1.0, "RECEIVING")
	Props.portal(self, Vector3(0, 0, 5.15), 1.8, 2.5, 0.0, -1.0, "HATS  &  GLOVES")
	Props.portal(self, Vector3(5.15, 0, GATE_Z), 1.8, 2.4, PI / 2.0, -1.0, "ATRIUM")   # the gate, deeply framed
	Props.portal(self, Vector3(DOOR_X, 0, -5.15), 1.6, Props.DOOR_HEIGHT, 0.0, -1.0, "ALTERATIONS")   # Receiving side
	Glimpse.build(self, Vector3(5.3, 0, GATE_Z), -PI / 2.0, "atrium", 4.0, 5.0, 6.0)   # seen once the gate rolls up
	Props.door_frame(self, Vector3(5.15, 0, GATE_Z), 1.8, 2.4, PI / 2.0)
	B.wainscot(self, Vector3(-4.98, 0, 0), Vector3(0, 0, 10))
	# Finished lower walls round the rest of Alterations and Receiving, clear of every opening,
	# the crank socket, the freight lift and the loading gate.
	for seg in [[Vector3(4.98, 0, -5.0), Vector3(4.98, 0, -1.3)], [Vector3(4.98, 0, 1.86), Vector3(4.98, 0, 5.0)],
			[Vector3(-5.0, 0, 4.98), Vector3(-1.34, 0, 4.98)], [Vector3(1.34, 0, 4.98), Vector3(5.0, 0, 4.98)],
			[Vector3(-5.0, 0, -4.98), Vector3(DOOR_X - 1.24, 0, -4.98)], [Vector3(DOOR_X + 1.24, 0, -4.98), Vector3(5.0, 0, -4.98)],
			[Vector3(-4.98, 0, -13.0), Vector3(-4.98, 0, -10.14)], [Vector3(-4.98, 0, -7.86), Vector3(-4.98, 0, -5.3)],
			[Vector3(6.98, 0, -13.0), Vector3(6.98, 0, -10.04)], [Vector3(6.98, 0, -7.96), Vector3(6.98, 0, -5.3)],
			[Vector3(-5.0, 0, -12.98), Vector3(7.0, 0, -12.98)]]:
		B.wainscot_between(self, seg[0], seg[1])
	# Receiving walls.
	B.put(B.box(0.3, 3.6, 8), plum, Vector3(-5.15, 1.8, -9), self)
	B.put(B.box(0.3, 3.6, 8), plum, Vector3(7.15, 1.8, -9), self)
	B.put(B.box(12, 3.6, 0.3), plum, Vector3(1, 1.8, -13.15), self)
	B.put(B.box(2.0, 1.8, 0.3), plum, Vector3(5.15, 2.7, -5.0), self)
	# The atrium gate (rolls up) and the crank socket beside it.
	gate = Node3D.new()
	gate.position = Vector3(5.1, 0, GATE_Z)
	add_child(gate)
	B.put(B.box(0.1, 2.4, 1.8), metal, Vector3(0, 1.2, 0), gate)
	for i in 6:
		B.put(B.box(0.12, 0.04, 1.8), B.brass(), Vector3(0, 0.25 + i * 0.4, 0), gate)
	Props.pull_handle(gate, Vector3(-0.06, 0.38, 0), 0.7, -PI / 2.0)   # rises with the gate
	socket_disc = Node3D.new()
	socket_disc.position = Vector3(4.9, 1.15, SOCKET.y)
	add_child(socket_disc)
	B.put(B.cyl(0.18, 0.18, 0.04), B.mat(B.BLACK, 0.3), Vector3.ZERO, socket_disc).rotation.z = PI / 2.0
	B.put(B.box(0.05, 0.05, 0.3), B.brass(), Vector3(-0.02, 0, 0), socket_disc)            # the broad slot
	# The cutting table, work laid out on it; triple mirror.
	Props.cutting_table(self, Vector3(-2.6, 0, 1.6))
	solids.append([Vector2(-2.6, 1.6), 0.9])
	for k in 3:
		var m := B.put(B.box(0.04, 1.6, 0.6), ST.plastic(Color("c8d8e0"), 0.02, 0.9), Vector3(-4.85, 0.95, 0.9 + k * 0.62), self)
		m.rotation.y = (k - 1) * 0.25
	# Sewing counter, pincushion in a saucer, a fan that turns its head but doesn't spin.
	Props.counter(self, Vector3(-4.5, 0, -2.2), Vector3(0.8, Props.WAIST, 2.6), "walnut", 0.08, Vector3(1, 0, 0))   # notions drawers face the room
	solids.append(Rect2(Vector2(-4.9, -3.5), Vector2(0.8, 2.6)))
	B.put(B.cyl(0.1, 0.08, 0.02), B.mat(B.CREAM, 0.3), Vector3(-4.5, 1.0, -1.4), self)
	B.put(B.sphere(0.07), B.mat(B.RED, 0.6), Vector3(-4.5, 1.06, -1.4), self)
	B.put(B.cyl(0.06, 0.08, 0.25), B.brass(), Vector3(-4.5, 1.12, -2.9), self)
	fan_head = Node3D.new()
	fan_head.position = Vector3(-4.5, 1.3, -2.9)
	add_child(fan_head)
	B.put(B.cyl(0.16, 0.16, 0.06), B.brass(), Vector3(0.05, 0, 0), fan_head).rotation.z = PI / 2.0
	# The curtained stall, the tailor inside, and the lost sleeve on the receiving doorknob.
	var fin := Finish.begin(self)
	Finish.booth(fin, Vector3(STALL.x, 0, STALL.y))   # framed, panelled fitting booth
	solids.append(Rect2(Vector2(STALL.x - 0.95, STALL.y - 0.95), Vector2(1.9, 1.85)))
	curtain = Node3D.new()
	curtain.position = Vector3(STALL.x, 0, STALL.y + 0.9)
	add_child(curtain)
	Props.curtain(curtain, Vector3.ZERO, 1.7, 2.3)   # pleated burgundy velvet on a brass rod
	tailor = Node3D.new()
	tailor.position = Vector3(STALL.x, 0, STALL.y - 0.2)
	add_child(tailor)
	var ivory := ST.plastic(B.IVORY, 0.3, 0.0)
	B.put(B.cyl(0.19, 0.14, 0.62), ivory, Vector3(0, 1.28, 0), tailor)
	B.put(B.sphere(0.13), ivory, Vector3(0, 1.82, 0), tailor).scale = Vector3(0.9, 1.2, 1.0)
	B.put(B.capsule(0.045, 0.5), ivory, Vector3(0.26, 1.25, 0), tailor)                   # one arm (the other sleeve is missing)
	B.put(B.box(0.42, 0.5, 0.26), ST.textured("linen_cream", 2.0, cream), Vector3(0, 1.3, 0.02), tailor)
	sleeve = Node3D.new()
	sleeve.position = Vector3(DOOR_X + 0.65, 1.0, -4.9)
	add_child(sleeve)
	B.put(B.cyl(0.06, 0.08, 0.45), ST.textured("linen_cream", 2.0, cream), Vector3(0, -0.22, 0), sleeve)
	B.put(B.sphere(0.04), B.brass(), Vector3(0, 0.02, -0.04), sleeve)                       # the doorknob
	# Receiving: carton stacks, a freight lift (latched from above), the loading gate, people.
	for c in [Vector3(-4.3, 0, -12.2), Vector3(-3.2, 0, -12.3), Vector3(-4.4, 0, -10.6), Vector3(6.2, 0, -12.2), Vector3(5.0, 0, -12.4)]:
		for h in 2 + int(absf(c.x)) % 2:
			var bx := B.put(B.box(0.9, 0.7, 0.8), card, c + Vector3(randf_range(-0.05, 0.05), 0.35 + h * 0.7, 0), self)
			bx.rotation.y = randf_range(-0.1, 0.1)
		solids.append(Rect2(Vector2(c.x - 0.5, c.z - 0.45), Vector2(1.0, 0.9)))
	B.put(B.box(0.1, 2.6, 1.8), metal, Vector3(7.0, 1.3, -9.0), self)
	Props.door_frame(self, Vector3(7.15, 0, -9.0), 1.8, 2.6, PI / 2.0)
	Props.pull_handle(self, Vector3(6.95, 1.05, -9.0), 0.7, -PI / 2.0)
	var lift_sign := Label3D.new()
	lift_sign.text = "FREIGHT — LATCHED ABOVE"
	lift_sign.font_size = 40
	lift_sign.pixel_size = 0.004
	lift_sign.modulate = B.CREAM
	lift_sign.rotation.y = -PI / 2.0
	lift_sign.position = Vector3(6.9, 3.15, -9.0)
	add_child(lift_sign)
	B.put(B.box(0.1, 2.6, 2.0), metal, Vector3(-5.0, 1.3, -9.0), self)
	Props.door_frame(self, Vector3(-5.15, 0, -9.0), 2.0, 2.6, PI / 2.0)
	Props.pull_handle(self, Vector3(-4.95, 0.4, -9.0), 0.9, PI / 2.0)
	var load_sign := Label3D.new()
	load_sign.text = "LOADING — LOCKED"
	load_sign.font_size = 40
	load_sign.pixel_size = 0.004
	load_sign.modulate = B.CREAM
	load_sign.rotation.y = PI / 2.0
	load_sign.position = Vector3(-4.9, 3.15, -9.0)
	add_child(load_sign)
	# Biscuit table: red tins with cream sleeves, and the water jug.
	Props.counter(self, Vector3(0.6, 0, -11.9), Vector3(1.4, Props.WAIST, 0.7), "walnut", 0.08, Vector3(0, 0, 1))
	solids.append(Rect2(Vector2(-0.1, -12.25), Vector2(1.4, 0.7)))
	for i in 3:
		B.put(B.cyl(0.07, 0.07, 0.1), B.mat(B.RED, 0.3), Vector3(0.2 + i * 0.18, Props.WAIST + 0.05, -11.9), self)
		B.put(B.cyl(0.072, 0.072, 0.04), B.mat(B.CREAM, 0.4), Vector3(0.2 + i * 0.18, Props.WAIST + 0.05, -11.9), self)
	B.put(B.cyl(0.09, 0.11, 0.3), ST.plastic(Color("cfe3ea"), 0.05, 0.0), Vector3(1.1, Props.WAIST + 0.15, -11.9), self)
	# Hesta: senior stock clerk, grey bun and reading glasses, plum cardigan, arms folded.
	Props.person(self, Vector3(-0.9, 0, -9.6), 0.4, {"skin": Color("d9a77f"), "hair": Color("9a948c"), "top": Color("4e1f3a"),
			"top2": Color("efe6d4"), "legs": Color("4a4648"), "skirt": true, "bun": true, "glasses": true, "pose": "fold"})
	# Len: young porter, cream jacket with brass buttons, plum cap, one hand on his hip.
	Props.person(self, Vector3(2.8, 0, -8.2), -0.5, {"skin": Color("8a5a3c"), "hair": Color("1e1612"), "top": Color("e8dcc2"),
			"top2": Color("f6f1e6"), "legs": Color("2e2a30"), "cap": true, "pose": "hip"})
	solids.append([Vector2(-0.9, -9.6), 0.45])
	solids.append([Vector2(2.8, -8.2), 0.45])
	# Garments waiting for collection, finished pieces on mannequins, the fitting-room sign.
	for p in [["rack", Vector3(3.4, 0, 4.3), 0.0, 0], ["rack", Vector3(0.4, 0, -4.4), 0.0, 1],
			["mannequin", Vector3(-4.25, 0, 4.2), 0.7, 2], ["mannequin", Vector3(-4.3, 0, -4.3), 0.7, 1],
			["rack", Vector3(6.3, 0, -10.8), PI / 2.0, 0]]:
		Props.place(self, p[0], p[1], p[2], p[3])
		solids.append(Props.footprint(p[0], p[1], p[2]))
	Props.place(self, "hanging_sign", Vector3(STALL.x, 2.85, STALL.y + 1.0), 0.0, 0, "FITTING  ROOM").scale = Vector3.ONE * 0.8
	# Lamps.
	for l in [[Vector3(-5.0, 2.2, -1), Vector3(1, 0, 0)], [Vector3(5.0, 2.2, 3), Vector3(-1, 0, 0)]]:
		ST.sconce(self, l[0], l[1], 0.85)
	# Ceiling dishes over the fitting platform and the socket.
	for c in [Vector3(-2.4, 3.2, 1.4), Vector3(3.0, 3.2, -1.0)]:
		ST.ceiling_light(self, c, 0.85, 5.5)
		ST.ceiling_fixture(self, c + Vector3(0, 0.05, 0), 3.5)
	# Receiving is a working room: green enamel pendants over the table and the cartons, neutral
	# light, and one sconce by the loading door.
	# The winding station round the crank socket, with a dial that follows the gate.
	gate_needle = Finish.gate_panel(self, fin, Vector3(5.0, 1.15, SOCKET.y), Vector3(-1, 0, 0))
	# Upper walls, crown mouldings, fabric bolts, ceiling beams; Receiving's steel beams, shelving, signs.
	var top := 3.5
	Finish.upper_wall(fin, Vector3(-5, 0, -5), Vector3(-5, 0, 5), Vector3(1, 0, 0), 2.55, 3.15, top)
	Finish.upper_wall(fin, Vector3(5, 0, -5), Vector3(5, 0, 5), Vector3(-1, 0, 0), 2.55, 3.15, top, [[3.55, 6.9]])
	Finish.upper_wall(fin, Vector3(-5, 0, -5), Vector3(5, 0, -5), Vector3(0, 0, 1), 2.55, 3.15, top, [[1.2, 3.8]])
	Finish.upper_wall(fin, Vector3(-5, 0, 5), Vector3(5, 0, 5), Vector3(0, 0, -1), 2.55, 3.15, top, [[3.6, 6.4]])
	Finish.shelf(fin, Vector3(-5, 0, -3.0), Vector3(1, 0, 0), 1.2, 1.5, "bolts")
	Finish.ceiling_beams(fin, Rect2(-5, -5, 10, 10), top, true, [-3.2, 0.2, 3.2])
	for c in [[Vector3(-5, 0, -13), Vector3(7, 0, -13), Vector3(0, 0, 1)], [Vector3(-5, 0, -13), Vector3(-5, 0, -5.3), Vector3(1, 0, 0)],
			[Vector3(7, 0, -13), Vector3(7, 0, -5.3), Vector3(-1, 0, 0)]]:
		Finish.crown(fin, c[0], c[1], c[2], top)
	Finish.ceiling_beams(fin, Rect2(-5, -13, 12, 7.7), top, true, [-12.0, -10.0, -8.0, -6.2], true)
	Finish.shelf(fin, Vector3(7, 0, -6.5), Vector3(-1, 0, 0), 1.4, 0.9, "cartons")
	Props.plaque(self, Vector3(3.6, 2.45, -13.0), 1.3, "STAFF  ONLY")
	Props.plaque(self, Vector3(-5.0, 2.45, -6.6), 1.4, "DELIVERIES", PI / 2.0)
	ST.pendant(self, Vector3(0.5, 2.75, -10.6), 3.5, 0.7, 5.5)
	ST.pendant(self, Vector3(4.6, 2.75, -11.2), 3.5, 0.45, 4.5)
	ST.pendant(self, Vector3(-3.4, 2.75, -7.0), 3.5, 0.4, 4.5)
	Finish.done(fin)
	ST.sconce(self, Vector3(-5.0, 2.2, -11.4), Vector3(1, 0, 0), 0.6)
	interactables = [
		[Vector2(STALL.x, STALL.y + 1.5), "tailor"], [Vector2(DOOR_X + 0.65, -4.3), "sleeve"],
		[SOCKET, "socket"], [Vector2(0.6, -11.2), "tins"], [Vector2(2.8, -7.5), "len"], [Vector2(-0.9, -8.9), "hesta"],
		[Vector2(-4.0, -1.4), "pincushion"], [Vector2(-2.6, 0.5), "cutting"],
	]


## Placeholder person (staff, not a mannequin): clothes colour, skin tone, optional porter cap.
func _person(at: Vector2, clothes: Color, skin: Color, cap: bool) -> void:
	var n := Node3D.new()
	n.position = Vector3(at.x, 0, at.y)
	n.rotation.y = 0.4
	add_child(n)
	var cloth := ST.plastic(clothes, 0.6, 0.0)
	for side in [-1.0, 1.0]:
		B.put(B.capsule(0.08, 0.42), B.mat(Color("3a3236"), 0.6), Vector3(side * 0.1, 0.42, 0), n)
	B.put(B.capsule(0.21, 0.42), cloth, Vector3(0, 1.15, 0), n)
	for side in [-1.0, 1.0]:
		B.put(B.capsule(0.06, 0.45), cloth, Vector3(side * 0.27, 1.12, 0), n)
	B.put(B.sphere(0.14), ST.plastic(skin, 0.5, 0.0), Vector3(0, 1.66, 0), n)
	if cap:
		B.put(B.cyl(0.13, 0.14, 0.08), ST.plastic(B.PLUM, 0.4, 0.0), Vector3(0, 1.8, 0), n)
		B.put(B.box(0.2, 0.02, 0.1), ST.plastic(B.PLUM, 0.4, 0.0), Vector3(0, 1.77, 0.13), n)
	else:
		B.put(B.sphere(0.15), ST.plastic(Color("3b2a26"), 0.6, 0.0), Vector3(0, 1.72, -0.03), n)   # hair


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	# Controls live in the pause menu (Esc) and in context prompts; no development labels.
	var bottom := VBoxContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -120
	bottom.offset_bottom = -24
	bottom.alignment = BoxContainer.ALIGNMENT_END
	layer.add_child(bottom)
	var who := B._label("", 13, B.BRASS)
	var line := B._label("", 20)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for l in [who, line]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bottom.add_child(l)
	dialogue = Dialogue.new(sfx, who, line)


func say(speaker: String, text: String, dur := 2.6) -> void:
	dialogue.say(speaker, text, dur)


# ---------------------------------------------------------------- loop

func _process(delta: float) -> void:
	step(minf(delta, 0.05))
	_place_camera(delta)


func step(dt: float) -> void:
	for a in MAIN.ACTIONS:
		var h: bool = Input.is_action_pressed("ab_" + a) or bool(virtual.get(a, false))
		pressed[a] = h and not bool(keys_prev.get(a, false))
		keys_prev[a] = h
		held[a] = h
	time += dt
	if crank_t >= 0.0:
		_update_crank(dt)
	else:
		_update_player(dt)
	_update_world(dt)
	dialogue.update(dt)
	sfx.track(p_pos)


func _update_player(dt: float) -> void:
	var input := Vector2(float(held.get("right", false)) - float(held.get("left", false)),
		float(held.get("down", false)) - float(held.get("up", false)))
	if input.length() > 1.0:
		input = input.normalized()
	input = Mover.to_world(input, camera)
	var vel: Vector2 = mover.step(input, 4.2, dt)
	p_pos += vel * dt
	_collide()
	if input.length() > 0.1:
		p_yaw = Mover.turn(p_yaw, input, dt)
	speed = vel.length()
	if not met_hesta and p_pos.y < -5.8:
		_hesta_scene()
	var near := ""
	var best := 1.1
	for it in interactables:
		var d: float = p_pos.distance_to(it[0])
		if d < best and _available(it[1]):
			best = d
			near = it[1]
	if gate_open and p_pos.x > 4.3 and absf(p_pos.y - GATE_Z) < 0.9:
		gauge.show_prompt("go", "East — through the atrium to the service bell")
		if p_pos.x > 5.4 and not leaving:
			_leave()
	elif near != "":
		gauge.show_prompt("interact", _prompt_for(near))
		if pressed.get("eat", false):
			_use(near)
	else:
		gauge.hide_prompt()


func _available(id: String) -> bool:
	match id:
		"sleeve":
			return tailor_asked and not sleeve_held and not sleeve_returned
		"socket":
			return not gate_open
		"tins":
			return not restocked
		"len":
			return met_hesta and not talked_len
		"hesta":
			return met_hesta
		"tailor":
			return not sleeve_returned
	return true


func _prompt_for(id: String) -> String:
	return {
		"tailor": "Hand back the sleeve" if sleeve_held else "Talk to the tailor",
		"sleeve": "Take the sleeve off the doorknob",
		"socket": "Slot Knock into the socket" if not cranked_once else "Turn the socket again",
		"tins": "Take a biscuit tin and some water",
		"len": "Talk to Len",
		"hesta": "Talk to Hesta",
		"pincushion": "Look at the pincushion",
	}.get(id, "Use")


func _use(id: String) -> void:
	match id:
		"tailor":
			if sleeve_held:
				sleeve_held = false
				sleeve_returned = true
				say("TAILOR", "Oh — thank you, miss.", 1.8)
				say("TAILOR", "…Thank you, sir. Both of you.", 2.2)
				say("", "The tailor fits the sleeve and draws the curtain closed.", 2.4)
			else:
				tailor_asked = true
				say("TAILOR", "Has anybody seen my other sleeve?", 2.4)
				say("NELL", "It's on the doorknob. The receiving door — there.", 2.4)
		"sleeve":
			sleeve_held = true
			sleeve.visible = false
			sfx.click()
		"socket":
			_start_crank()
		"tins":
			restocked = true
			biscuits = 2
			hp = 6
			gauge.set_biscuits(biscuits)
			gauge.set_health(hp, 6)
			sfx.pip()
			say("", "A red tin, cream paper sleeve: butter biscuits. Supplies back to two. Water from the jug.", 3.0)
		"len":
			talked_len = true
			say("LEN", "The Floor Manager took the brass governor out of the freight controls.", 3.0)
			say("LEN", "Put it behind the service bell, upstairs. Pella and Anil just came down the back stairs — Toys is clear.", 3.6)
			gauge.set_objective("Reach the service bell" if gate_open else "Open the gate to the atrium")
		"hesta":
			say("HESTA", "Count them first. Then promise.", 2.2)
		"pincushion":
			say("", "A pincushion in a saucer. Someone left in a hurry mid-hem.", 2.4)
		"cutting":
			say("", "The cutting table: a waistcoat pattern pinned to plum wool, the chalk line stopped halfway along the hem.", 3.2)
			if used.has("cutting"):
				say("TAILOR", "Leave the chalk. I know where I was.", 2.0)
	used[id] = true


func _hesta_scene() -> void:
	met_hesta = true
	say("HESTA", "You're Sumi's boy.", 1.8)
	say("REN", "Ren.", 1.2)
	say("HESTA", "I know. She writes it on everything you forget.", 2.6)
	say("", "Ren checks the inside of his glove, reflexively. There is no label there.", 2.8)
	say("MIKA", "We need the upper service access.", 2.0)
	say("HESTA", "So do I. My people are upstairs.", 2.2)
	say("REN", "We'll get them.", 1.6)
	say("HESTA", "Ask how many before you promise.", 2.4)
	say("REN", "How many?", 1.4)
	say("HESTA", "Two. In Toys. And the fitter won't leave her counter. I don't know whether she counts as one of mine yet.", 4.4)
	if _has_flag("souvenir_sv01"):
		say("HESTA", "That pin on your collar is from the rooftop lunchroom. Keep it. Nobody's eating up there tonight.", 3.6)


func _start_crank() -> void:
	crank_t = 0.0
	crank_len = CRANK_REPEAT if cranked_once else CRANK_FIRST
	p_pos = SOCKET
	p_yaw = PI / 2.0
	if not cranked_once:
		say("MIKA", "Sideways — the flat goes in. I'll hold the safety catch.", 2.6)
		say("MIKA", "Steady torque. Don't jerk it.", 2.2)
	sfx.click()


func _update_crank(dt: float) -> void:
	crank_t += dt
	var k := clampf(crank_t / crank_len, 0.0, 1.0)
	socket_disc.rotation.x = -k * PI * 1.5
	gate_progress = k
	if int(crank_t * 3.0) != int((crank_t - dt) * 3.0):
		sfx.click()
	if k >= 1.0:
		crank_t = -1.0
		cranked_once = true
		gate_open = true
		sfx.spring()
		sfx.chime_errand()
		_toast("Errand complete  ·  the atrium gate is open")
		gauge.set_objective("Reach the service bell")
		say("MIKA", "There. The cable runs from here to the escalators — east, through the atrium.", 3.2)


func _update_world(dt: float) -> void:
	ren.position = Vector3(p_pos.x, 0, p_pos.y)
	ren.rotation.y = p_yaw
	var clip := "guard" if crank_t >= 0.0 else ("run" if speed > 0.5 else "idle")
	if clip != ren_clip:
		ren_anim.play(clip, 0.15)
		ren_clip = clip
	gate.position.y = lerpf(gate.position.y, gate_progress * 2.3, 1.0 - exp(-8.0 * dt))
	if gate_needle:   # the winding station's dial: SHUT .. OPEN as the gate rises
		gate_needle.rotation.z = lerpf(1.2, -1.2, clampf(gate.position.y / 2.3, 0.0, 1.0))
	fan_head.rotation.y = sin(time * 0.8) * 0.8
	var open_curtain := tailor_asked and not sleeve_returned
	curtain.position.x = lerpf(curtain.position.x, STALL.x + (1.4 if open_curtain else 0.0), 1.0 - exp(-4.0 * dt))
	tailor.visible = curtain.position.x > STALL.x + 0.3
	if sleeve_returned and tailor.get_child_count() == 4:
		B.put(B.capsule(0.045, 0.5), ST.textured("linen_cream", 2.0, B.mat(B.CREAM, 0.5)), Vector3(-0.26, 1.25, 0), tailor)


func _collide() -> void:
	var in_receiving := p_pos.y < -5.0
	var at_door := absf(p_pos.x - DOOR_X) < 0.5
	if in_receiving:
		p_pos.x = clampf(p_pos.x, -4.65, 6.65)
		p_pos.y = clampf(p_pos.y, -12.65, -4.6 if at_door else -5.35)
	else:
		var east := 5.8 if (gate_open and absf(p_pos.y - GATE_Z) < 0.6) else 4.65
		p_pos.x = clampf(p_pos.x, -4.65, east)
		p_pos.y = clampf(p_pos.y, -5.4 if at_door else -4.65, 4.65)
	for s in solids:
		if s is Rect2:
			var g: Rect2 = (s as Rect2).grow(0.3)
			if g.has_point(p_pos):
				var m := minf(minf(p_pos.x - g.position.x, g.end.x - p_pos.x), minf(p_pos.y - g.position.y, g.end.y - p_pos.y))
				if m == p_pos.x - g.position.x:
					p_pos.x = g.position.x
				elif m == g.end.x - p_pos.x:
					p_pos.x = g.end.x
				elif m == p_pos.y - g.position.y:
					p_pos.y = g.position.y
				else:
					p_pos.y = g.end.y
		else:
			var c: Vector2 = s[0]
			var r: float = s[1] + 0.3
			var d := p_pos.distance_to(c)
			if d < r and d > 0.001:
				p_pos = c + (p_pos - c) / d * r


func _leave() -> void:
	leaving = true
	Engine.set_meta("afterbell_skip_title", true)
	fade.go_to(next_scene)


func _place_camera(delta: float) -> void:
	# Alterations (south) and receiving (north) each keep the camera inside their own walls.
	var walls := Rect2(-4.65, -4.65, 9.3, 9.3) if p_pos.y > -5.0 else Rect2(-4.65, -12.65, 11.3, 7.25)
	ShoulderCam.place(camera, p_pos, Vector2(0, -1), delta, walls, 62.0)


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
