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
const GaugeHud := preload("res://scripts/hud.gd")
const Fade := preload("res://scripts/fade.gd")

# Local coordinates: x east, -z north. Alterations x0–10, y24–34 → x -5..5, z -5..5.
# Receiving x0–12, y34–42 sits north of it → x -5..7, z -13..-5.
const ENTRY := Vector2(0.0, 4.2)          # from Hats, south
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
	_place_camera(1.0)


# ---------------------------------------------------------------- building

func _build_rooms() -> void:
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	add_child(env)
	add_child(ST.sun())
	var cream := B.mat(B.CREAM, 0.5)
	var plaster := ST.textured("plaster_sage", 0.3, B.mat(Color("8fa58c"), 0.8))
	var plum := ST.textured("plaster_plum", 0.3, B.mat(B.PLUM_DEEP, 0.85))
	var metal := ST.textured("metal_charcoal", 1.5, B.mat(Color("2b2b2e"), 0.4, 0.6), 0.6)
	var wood := ST.plastic(Color("6e4326"), 0.35, 0.0)
	var card := ST.textured("cardboard", 1.2, B.mat(Color("a57a4c"), 0.9))
	# Floors: carpet in Alterations, worn tile in Receiving.
	B.put(B.box(14, 0.1, 20), ST.textured("tile_cream", 0.6, cream), Vector3(1, -0.05, -4), self, false)
	B.put(B.box(9.6, 0.02, 9.6), ST.textured("carpet_plum", 0.5, B.mat(B.PLUM, 0.9)), Vector3(0, 0.01, 0), self, false)
	var ceil := B.put(B.box(14, 0.2, 20), B.mat(Color("cbbd9f"), 0.8), Vector3(1, 3.6, -4), self, false)
	ceil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Alterations walls: sage plaster (a working room), plum outside the doorways.
	B.put(B.box(0.3, 3.6, 10), plaster, Vector3(-5.15, 1.8, 0), self)
	B.put(B.box(0.3, 3.6, 5 + GATE_Z - 0.9), plaster, Vector3(5.15, 1.8, (-5 + GATE_Z - 0.9) / 2.0), self)
	B.put(B.box(0.3, 3.6, 5 - GATE_Z - 0.9), plaster, Vector3(5.15, 1.8, (GATE_Z + 0.9 + 5) / 2.0), self)
	B.put(B.box(0.3, 1.2, 1.8), plaster, Vector3(5.15, 3.0, GATE_Z), self)
	for side in [-1.0, 1.0]:
		B.put(B.box(4.1, 3.6, 0.3), plaster, Vector3(side * 2.95, 1.8, 5.15), self)
	B.put(B.box(DOOR_X + 5 - 0.8, 3.6, 0.3), plaster, Vector3((-5 + DOOR_X - 0.8) / 2.0, 1.8, -5.15), self)
	B.put(B.box(5 - DOOR_X - 0.8 + 2, 3.6, 0.3), plaster, Vector3((DOOR_X + 0.8 + 7) / 2.0, 1.8, -5.15), self)
	B.put(B.box(1.6, 1.2, 0.3), plaster, Vector3(DOOR_X, 3.0, -5.15), self)
	B.wainscot(self, Vector3(-4.98, 0, 0), Vector3(0, 0, 10))
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
	B.put(B.box(0.04, 0.5, 0.5), B.brass(), Vector3(4.98, 1.15, SOCKET.y), self)          # socket plate
	socket_disc = Node3D.new()
	socket_disc.position = Vector3(4.95, 1.15, SOCKET.y)
	add_child(socket_disc)
	B.put(B.cyl(0.18, 0.18, 0.04), B.mat(B.BLACK, 0.3), Vector3.ZERO, socket_disc).rotation.z = PI / 2.0
	B.put(B.box(0.05, 0.05, 0.3), B.brass(), Vector3(-0.02, 0, 0), socket_disc)            # the broad slot
	B.put(B.box(0.06, 0.12, 0.04), B.mat(B.RED, 0.4), Vector3(4.97, 1.55, SOCKET.y + 0.3), self)  # snapped crank stub
	# Fitting platform with chalk dust; triple mirror.
	B.put(B.cyl(0.9, 0.95, 0.22), wood, Vector3(-2.6, 0.11, 1.6), self)
	solids.append([Vector2(-2.6, 1.6), 0.95])
	for d in [[Vector2(-2.4, 1.4), 0.22], [Vector2(-2.9, 1.9), 0.15], [Vector2(-2.2, 1.95), 0.1]]:
		var dust := B.put(B.cyl(d[1], d[1], 0.005), B.mat(Color(1, 1, 1, 1), 0.9), Vector3(d[0].x, 0.225, d[0].y), self, false)
		dust.scale = Vector3(1.0, 1.0, 0.6)
	for k in 3:
		var m := B.put(B.box(0.04, 1.6, 0.6), ST.plastic(Color("c8d8e0"), 0.02, 0.9), Vector3(-4.85, 0.95, 0.9 + k * 0.62), self)
		m.rotation.y = (k - 1) * 0.25
	# Sewing counter, pincushion in a saucer, a fan that turns its head but doesn't spin.
	B.put(B.box(0.8, 0.95, 2.6), cream, Vector3(-4.5, 0.48, -2.2), self)
	B.put(B.box(0.84, 0.04, 2.64), B.brass(), Vector3(-4.5, 0.97, -2.2), self)
	solids.append(Rect2(Vector2(-4.9, -3.5), Vector2(0.8, 2.6)))
	B.put(B.cyl(0.1, 0.08, 0.02), B.mat(B.CREAM, 0.3), Vector3(-4.5, 1.0, -1.4), self)
	B.put(B.sphere(0.07), B.mat(B.RED, 0.6), Vector3(-4.5, 1.06, -1.4), self)
	B.put(B.cyl(0.06, 0.08, 0.25), B.brass(), Vector3(-4.5, 1.12, -2.9), self)
	fan_head = Node3D.new()
	fan_head.position = Vector3(-4.5, 1.3, -2.9)
	add_child(fan_head)
	B.put(B.cyl(0.16, 0.16, 0.06), B.brass(), Vector3(0.05, 0, 0), fan_head).rotation.z = PI / 2.0
	# The curtained stall, the tailor inside, and the lost sleeve on the receiving doorknob.
	B.put(B.box(1.8, 2.4, 0.06), wood, Vector3(STALL.x, 1.2, STALL.y - 0.9), self)
	for side in [-1.0, 1.0]:
		B.put(B.box(0.06, 2.4, 1.8), wood, Vector3(STALL.x + side * 0.9, 1.2, STALL.y), self)
	B.put(B.box(1.86, 0.06, 1.86), B.brass(), Vector3(STALL.x, 2.4, STALL.y), self)
	solids.append(Rect2(Vector2(STALL.x - 0.95, STALL.y - 0.95), Vector2(1.9, 1.85)))
	curtain = Node3D.new()
	curtain.position = Vector3(STALL.x, 0, STALL.y + 0.9)
	add_child(curtain)
	B.put(B.box(1.7, 2.3, 0.05), ST.textured("velvet_red", 1.0, B.mat(B.RED, 0.8)), Vector3(0, 1.17, 0), curtain)
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
	var lift_sign := Label3D.new()
	lift_sign.text = "FREIGHT — LATCHED ABOVE"
	lift_sign.font_size = 40
	lift_sign.pixel_size = 0.004
	lift_sign.modulate = B.CREAM
	lift_sign.rotation.y = -PI / 2.0
	lift_sign.position = Vector3(6.9, 2.8, -9.0)
	add_child(lift_sign)
	B.put(B.box(0.1, 2.6, 2.0), metal, Vector3(-5.0, 1.3, -9.0), self)
	var load_sign := Label3D.new()
	load_sign.text = "LOADING — LOCKED"
	load_sign.font_size = 40
	load_sign.pixel_size = 0.004
	load_sign.modulate = B.CREAM
	load_sign.rotation.y = PI / 2.0
	load_sign.position = Vector3(-4.9, 2.8, -9.0)
	add_child(load_sign)
	# Biscuit table: red tins with cream sleeves, and the water jug.
	B.put(B.box(1.4, 0.8, 0.7), wood, Vector3(0.6, 0.4, -11.9), self)
	solids.append(Rect2(Vector2(-0.1, -12.25), Vector2(1.4, 0.7)))
	for i in 3:
		B.put(B.cyl(0.07, 0.07, 0.1), B.mat(B.RED, 0.3), Vector3(0.2 + i * 0.18, 0.86, -11.9), self)
		B.put(B.cyl(0.072, 0.072, 0.04), B.mat(B.CREAM, 0.4), Vector3(0.2 + i * 0.18, 0.86, -11.9), self)
	B.put(B.cyl(0.09, 0.11, 0.3), ST.plastic(Color("cfe3ea"), 0.05, 0.0), Vector3(1.1, 0.95, -11.9), self)
	_person(Vector2(-0.9, -9.6), Color("5b2a4a"), Color("d9a77f"), false)   # Hesta: plum cardigan
	_person(Vector2(2.8, -8.2), Color("e8dcc2"), Color("8a5a3c"), true)     # Len: cream porter jacket and cap
	solids.append([Vector2(-0.9, -9.6), 0.45])
	solids.append([Vector2(2.8, -8.2), 0.45])
	# Lamps.
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color("fff1d0")
	glass.emission_enabled = true
	glass.emission = Color("ffd08a")
	glass.emission_energy_multiplier = 3.0
	for p in [Vector3(-4.7, 2.4, -1), Vector3(4.7, 2.4, 3), Vector3(0, 3.3, -9), Vector3(-4.7, 2.4, -11)]:
		B.put(B.sphere(0.15), glass, p, self, false)
		var light := OmniLight3D.new()
		light.light_color = Color("ffc98a")
		light.light_energy = 1.0
		light.omni_range = 6.5
		light.position = p
		add_child(light)
	interactables = [
		[Vector2(STALL.x, STALL.y + 1.5), "tailor"], [Vector2(DOOR_X + 0.65, -4.3), "sleeve"],
		[SOCKET, "socket"], [Vector2(0.6, -11.2), "tins"], [Vector2(2.8, -7.5), "len"], [Vector2(-0.9, -8.9), "hesta"],
		[Vector2(-4.0, -1.4), "pincushion"],
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
	var title := B._label("DS-03 ALTERATIONS  ·  DS-04 RECEIVING  ·  demonstration build", 12, B.BRASS)
	title.position = Vector2(16, 100)
	layer.add_child(title)
	var keys := B._label("WASD move  ·  E use / talk", 12, Color(B.IVORY, 0.7))
	keys.position = Vector2(16, 118)
	layer.add_child(keys)
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


func _update_player(dt: float) -> void:
	var input := Vector2(float(held.get("right", false)) - float(held.get("left", false)),
		float(held.get("down", false)) - float(held.get("up", false)))
	if input.length() > 1.0:
		input = input.normalized()
	var vel := input * 4.2
	p_pos += vel * dt
	_collide()
	if input.length() > 0.1:
		p_yaw = lerp_angle(p_yaw, atan2(input.x, input.y), 1.0 - exp(-14.0 * dt))
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
	var back := 4.4
	var target := Vector3(p_pos.x * 0.7 + (0.6 if p_pos.y < -5.0 else 0.0), 3.1, p_pos.y + back)
	var max_z := 4.65 if p_pos.y > -5.0 else -5.4
	target.z = minf(target.z, max_z)
	target.y += maxf(0.0, (p_pos.y + back) - target.z) * 0.35
	target.y = minf(target.y, 3.2)   # stay under the 3.5 m ceiling
	camera.position = camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	camera.look_at(Vector3(p_pos.x * 0.8, 1.2, p_pos.y - 2.6), Vector3.UP)
