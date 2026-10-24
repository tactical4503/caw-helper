extends Node3D
## DS-02 Hats and gloves — first hostile pair and the rack lesson (Installment 002, Section 5).
## Condensed demonstration layout, not the final campaign room.
##
## Etiquette guards (EN-H01): "Staff access only", palm forward + baton lifted for 0.85 s, then a
## short downward strike (one segment), 1.1 s recovery. Two stability pips: a three-hit light combo
## empties them; a wound heavy strike during the lifted tell or the recovery topples at once. A
## toppled guard sits down ("A short break."), stays out of the encounter and is never destroyed.
## Only one guard commits to a strike at a time; the other circles or points.
##
## The movable rack runs on a floor guide with two stops. Hold guard at either padded handle and
## walk to push it; let go and it stops. East stop: blocks the alcove, opens the north aisle. West
## stop: opens the alcove (souvenir pin SV-01), narrows the aisle. The second guard appears only
## after the rack has been moved. Leaving north continues to the Floor Manager's court.

const B := preload("res://scripts/builders.gd")
const ST := preload("res://scripts/style.gd")
const MAIN := preload("res://scripts/main.gd")
const REN_RIG := preload("res://rigs/ren.tscn")
const Dialogue := preload("res://scripts/dialogue.gd")
const Mover := preload("res://scripts/mover.gd")
const Props := preload("res://scripts/props.gd")
const ShoulderCam := preload("res://scripts/shoulder_cam.gd")
var mover = Mover.new()
const GaugeHud := preload("res://scripts/hud.gd")
const Fade := preload("res://scripts/fade.gd")
var fade

# Local coordinates: x east, -z north. DS-02 is building x0–10, y6–24 (10 m × 18 m).
const HALF_W := 5.0
const HALF_D := 9.0
const ENTRY := Vector2(4.2, 5.0)           # from Cosmetics, through the east wall
const EXIT_X := 0.9                         # north door half-width
const PARTITION_Z := -3.3                   # hat shelving across the room with the aisle gap
const RACK_Z := -2.4                        # rack guide, just south of the shelving
const RACK_START := 0.0
const STOP_WEST := -0.75
const STOP_EAST := 2.2
const RACK_HALF := Vector2(0.85, 0.33)
const PIN_AT := Vector2(2.2, -4.1)

# EN-H01 timing (Section 9 table).
const GUARD_TELL := 0.85
const GUARD_RECOVER := 1.1
const GUARD_SPEED := 1.4
const GUARD_WAKE := 4.0
const HEAVY_CHARGE := 0.8
const REFLECT_DODGE := 0.28

class Guard:
	var node: Node3D
	var arm_baton: Node3D
	var arm_palm: Node3D
	var cap: Node3D
	var post := Vector2.ZERO
	var pos := Vector2.ZERO
	var yaw := 0.0
	var state := "post"   # dormant, post, approach, circle, tell, strike, recover, flinch, seated, standing
	var t := 0.0
	var pips := 2.0
	var hit_done := false
	var spoke := false
	var orbit := 1.0

var keys_prev := {}
var held := {}
var pressed := {}
var virtual := {}

var ren: Node3D
var ren_anim: AnimationPlayer
var ren_clip := ""
var p_pos := ENTRY
var p_yaw := -PI / 2.0
var hp := 6
var biscuits := 2
var inv := 0.0
var act := "none"
var act_t := 0.0
var guard := false
var charging := false
var charge_t := 0.0
var clicks := 0
var dodge_dir := Vector2.ZERO
var knock := Vector2.ZERO
var speed := 0.0
var time := 0.0

var guards: Array = []
var rack: Node3D
var rack_x := RACK_START
var rack_moved := 0.0
var second_awake := false
var cleared := false
var pin_taken := false
var pin_node: Node3D
var leaving := false
var next_scene := "res://rooms/alterations.tscn"
var solids: Array = []    # Rect2 footprints in (x, z)
var trees: Array = []     # Vector2 centres, radius 0.35

var camera: Camera3D
var sfx
var gauge
var dialogue
var who: Label
var subtitle: Label


func _ready() -> void:
	for a in MAIN.ACTIONS:
		var action: String = "ab_" + a
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in MAIN.ACTIONS[a]:
				var ev := InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)
	_build_room()
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
	sfx.ambience.call_deferred("amb_hats")
	gauge = GaugeHud.new()
	add_child(gauge)
	gauge.set_combat(true)
	gauge.set_health(hp, 6)
	gauge.set_biscuits(biscuits)
	gauge.set_objective("Get past the staff")
	_build_hud()
	guards.append(_make_guard(Vector2(-2.6, -1.4), "post"))
	guards.append(_make_guard(Vector2(-3.4, 6.6), "dormant"))
	say("MIKA", "Hats. Staff doors are north, past that rack.", 2.6)
	_place_camera(1.0)


# ---------------------------------------------------------------- building

func _build_room() -> void:
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	add_child(env)
	add_child(ST.sun())
	var cream := B.mat(B.CREAM, 0.5)
	var wall := ST.textured("plaster_cream", 0.3, B.mat(B.CREAM, 0.7))
	B.put(B.box(HALF_W * 2 + 2, 0.1, HALF_D * 2 + 2), ST.textured("tile_cream", 0.6, cream), Vector3(0, -0.05, 0), self, false)
	B.put(B.box(HALF_W * 2 - 1, 0.02, HALF_D * 2 - 1), ST.textured("carpet_forest", 0.5, B.mat(B.CARPET, 0.95)), Vector3(0, 0.01, 0), self, false)
	var ceil := B.put(B.box(HALF_W * 2 + 2, 0.2, HALF_D * 2 + 2), B.mat(Color("cbbd9f"), 0.8), Vector3(0, 4.0, 0), self, false)
	ceil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Walls. East wall has the opening from Cosmetics at z 4.1–5.9; north wall the staff door.
	B.put(B.box(0.3, 4.0, HALF_D * 2), wall, Vector3(-HALF_W - 0.15, 2.0, 0), self)
	B.put(B.box(0.3, 4.0, HALF_D + 4.1), wall, Vector3(HALF_W + 0.15, 2.0, (-HALF_D + 4.1) / 2.0), self)
	B.put(B.box(0.3, 4.0, HALF_D - 5.9), wall, Vector3(HALF_W + 0.15, 2.0, (5.9 + HALF_D) / 2.0), self)
	B.put(B.box(HALF_W * 2, 4.0, 0.3), wall, Vector3(0, 2.0, HALF_D + 0.15), self)
	for side in [-1.0, 1.0]:
		B.put(B.box(HALF_W - EXIT_X, 4.0, 0.3), wall, Vector3(side * (HALF_W + EXIT_X) / 2.0, 2.0, -HALF_D - 0.15), self)
	B.put(B.box(EXIT_X * 2, 1.6, 0.3), wall, Vector3(0, 3.2, -HALF_D - 0.15), self)
	# Staff doors: cased frame, a pair of half-glazed doors swung open into the corridor.
	Props.door_frame(self, Vector3(0, 0, -HALF_D - 0.15), EXIT_X * 2.0, 2.4)
	Props.door_leaf(self, Vector3(-EXIT_X, 0, -HALF_D - 0.3), EXIT_X, 2.4, 0.0, PI / 2.0 * 0.92, true)
	Props.door_leaf(self, Vector3(EXIT_X, 0, -HALF_D - 0.3), EXIT_X, 2.4, PI, -PI / 2.0 * 0.92, true)
	# The way in from Cosmetics: a header and casing round the east opening.
	B.put(B.box(0.3, 1.5, 1.8), wall, Vector3(HALF_W + 0.15, 3.25, 5.0), self)
	Props.door_frame(self, Vector3(HALF_W + 0.15, 0, 5.0), 1.8, 2.5, PI / 2.0)
	# Finished lower walls on all four sides, stopping at the two portals.
	B.wainscot(self, Vector3(-HALF_W + 0.02, 0, 0), Vector3(0, 0, HALF_D * 2))
	B.wainscot(self, Vector3(0, 0, HALF_D - 0.02), Vector3(HALF_W * 2, 0, 0))
	for side in [-1.0, 1.0]:
		B.wainscot_between(self, Vector3(side * (EXIT_X + 0.44), 0, -HALF_D + 0.02), Vector3(side * HALF_W, 0, -HALF_D + 0.02))
	B.wainscot_between(self, Vector3(HALF_W - 0.02, 0, -HALF_D), Vector3(HALF_W - 0.02, 0, 3.66))
	B.wainscot_between(self, Vector3(HALF_W - 0.02, 0, 6.34), Vector3(HALF_W - 0.02, 0, HALF_D))
	Props.portal(self, Vector3(0, 0, -HALF_D - 0.15), EXIT_X * 2.0, 2.4, 0.0, 1.0, "STAFF  ·  ALTERATIONS")
	Props.portal(self, Vector3(HALF_W + 0.15, 0, 5.0), 1.8, 2.5, PI / 2.0, -1.0, "COSMETICS")
	# Hat shelving across the room, with the aisle gap (x -1..1) and the alcove (x 1..3.4).
	var shelf := ST.plastic(Color("6e4326"), 0.35, 0.0)   # lacquered walnut
	for part in [[-3.0, 4.0], [4.2, 1.6]]:
		var cx: float = part[0]
		var w: float = part[1]
		# A proper run of shelving: dark recessed plinth, rounded walnut case, brass band, cornice.
		B.put(Props.rounded_block(w - 0.08, 0.12, 0.52, 0.04), B.mat(Color("2a1420"), 0.7), Vector3(cx, 0, PARTITION_Z), self)
		B.put(Props.rounded_block(w, 1.54, 0.6, 0.07), shelf, Vector3(cx, 0.12, PARTITION_Z), self)
		B.put(Props.rounded_block(w + 0.02, 0.035, 0.62, 0.08), B.brass(), Vector3(cx, 0.5, PARTITION_Z), self)
		B.put(Props.rounded_block(w + 0.1, 0.07, 0.7, 0.1, 0.02), shelf, Vector3(cx, 1.66, PARTITION_Z), self)
		for i in int(w / 0.6):
			var hx: float = cx - w / 2.0 + 0.3 + i * 0.6
			_hat(Vector3(hx, 1.75, PARTITION_Z), [B.CREAM, B.PLUM, B.RED][i % 3])
		solids.append(Rect2(Vector2(cx - w / 2.0, PARTITION_Z - 0.3), Vector2(w, 0.6)))
	# The alcove behind the shelving.
	for wall_part in [[Vector3(2.2, 1.0, -4.65), Vector3(2.4, 2.0, 0.1)], [Vector3(1.0, 1.0, -3.85), Vector3(0.1, 2.0, 1.5)],
			[Vector3(3.4, 1.0, -3.85), Vector3(0.1, 2.0, 1.5)]]:
		var pos: Vector3 = wall_part[0]
		var size: Vector3 = wall_part[1]
		B.put(B.box(size.x, size.y, size.z), shelf, pos, self)
		solids.append(Rect2(Vector2(pos.x - size.x / 2.0, pos.z - size.z / 2.0), Vector2(size.x, size.z)))
	# Souvenir pin SV-01: the rooftop lunchroom umbrella, on a little velvet stand.
	pin_node = Node3D.new()
	pin_node.position = Vector3(PIN_AT.x, 0, PIN_AT.y)
	add_child(pin_node)
	B.put(B.box(0.3, 0.8, 0.3), ST.textured("carpet_plum", 2.0, B.mat(B.PLUM, 0.8)), Vector3(0, 0.4, 0), pin_node)
	var canopy := CylinderMesh.new()
	canopy.top_radius = 0.0
	canopy.bottom_radius = 0.12
	canopy.height = 0.07
	B.put(canopy, B.mat(B.CREAM, 0.3), Vector3(0, 0.98, 0), pin_node)
	B.put(B.cyl(0.006, 0.006, 0.16), B.brass(), Vector3(0, 0.89, 0), pin_node)
	# Rack guide on the floor with its two stops and a painted arrow.
	B.put(B.box(STOP_EAST - STOP_WEST + RACK_HALF.x * 2, 0.012, 0.12), B.mat(B.CREAM, 0.6), Vector3((STOP_WEST + STOP_EAST) / 2.0, 0.03, RACK_Z + 0.42), self, false)
	for x in [STOP_WEST, STOP_EAST]:
		B.put(B.box(0.08, 0.06, 0.3), B.brass(), Vector3(x + signf(x - 0.7) * RACK_HALF.x, 0.03, RACK_Z + 0.42), self, false)
	rack = B.build_rack(0).node
	rack.rotation.y = PI / 2.0
	add_child(rack)
	# Hat trees interrupt sightlines without hiding enemies.
	for t in [Vector2(-2.4, 2.4), Vector2(1.6, 1.0), Vector2(-1.2, 6.2), Vector2(2.6, 6.8)]:
		trees.append(t)
		B.put(B.cyl(0.025, 0.025, 1.7), B.brass(), Vector3(t.x, 0.85, t.y), self)
		B.put(B.cyl(0.25, 0.28, 0.05), B.mat(B.BLACK, 0.3), Vector3(t.x, 0.03, t.y), self)
		for k in 3:
			var a := k * TAU / 3.0
			_hat(Vector3(t.x + cos(a) * 0.18, 1.45 + k * 0.12, t.y + sin(a) * 0.18), [B.PLUM, B.RED, B.CREAM][k])
	# Dressing along the walls, clear of the guards' posts, the hat trees and the rack's run.
	for p in [["rack", Vector3(-4.3, 0, 3.4), PI / 2.0, 1], ["rack", Vector3(4.3, 0, -6.6), PI / 2.0, 0],
			["mannequin", Vector3(-4.3, 0, 8.3), 0.6, 0], ["mannequin", Vector3(4.3, 0, 8.3), -0.6, 1],
			["mannequin", Vector3(-4.3, 0, -8.3), 0.6, 3], ["mannequin", Vector3(2.6, 0, -8.4), -0.3, 2],
			["flower_display", Vector3(-3.7, 0, -6.0), 0.0, 0], ["easel", Vector3(3.9, 0, 1.8), -0.3, 0],
			["folded_table", Vector3(0.6, 0, 8.35), PI, 3]]:
		Props.place(self, p[0], p[1], p[2], p[3], "HATS  &  GLOVES")
		solids.append(Props.footprint(p[0], p[1], p[2]))
	# Lamps.
	for p in [Vector3(-HALF_W + 0.3, 2.5, -6), Vector3(-HALF_W + 0.3, 2.5, 0), Vector3(-HALF_W + 0.3, 2.5, 6), Vector3(HALF_W - 0.3, 2.5, -6), Vector3(HALF_W - 0.3, 2.5, 0)]:
		ST.lamp(self, p)
	# Ceiling fixtures down the room; the brightest pool sits over the rack and the staff door.
	for z in [6.0, 1.0, -2.6, -7.0]:
		ST.ceiling_light(self, Vector3(0, 3.6, z), 0.95 if z == -2.6 else 0.7, 6.0)


func _hat(at: Vector3, color: Color) -> void:
	B.put(B.cyl(0.15, 0.17, 0.02), ST.plastic(color, 0.4, 0.0), at, self)
	B.put(B.cyl(0.09, 0.1, 0.1), ST.plastic(color, 0.4, 0.0), at + Vector3(0, 0.06, 0), self)


func _make_guard(at: Vector2, state: String) -> Guard:
	var g := Guard.new()
	g.post = at
	g.pos = at
	g.state = state
	g.node = Node3D.new()
	add_child(g.node)
	var ivory := ST.plastic(B.IVORY, 0.3, 0.0)
	var body := Node3D.new()
	body.name = "Body"
	g.node.add_child(body)
	for side in [-1.0, 1.0]:
		B.put(B.capsule(0.07, 0.4), ivory, Vector3(side * 0.1, 0.4, 0), body)
	B.put(B.cyl(0.2, 0.15, 0.65), ivory, Vector3(0, 1.15, 0), body).scale = Vector3(1, 1, 0.7)
	B.put(B.sphere(0.13), ivory, Vector3(0, 1.7, 0), body).scale = Vector3(0.9, 1.2, 1.0)
	g.cap = Node3D.new()
	g.cap.position = Vector3(0, 1.84, 0)
	body.add_child(g.cap)
	B.put(B.cyl(0.13, 0.13, 0.08), B.mat(B.CREAM, 0.4), Vector3.ZERO, g.cap)     # flat cream usher cap
	B.put(B.cyl(0.16, 0.16, 0.015), B.mat(B.BLACK, 0.3), Vector3(0, -0.04, 0), g.cap)
	for side in [-1.0, 1.0]:
		B.put(B.sphere(0.06), B.brass(), Vector3(side * 0.24, 1.45, 0), body)
	g.arm_palm = Node3D.new()
	g.arm_palm.position = Vector3(0.24, 1.45, 0)
	body.add_child(g.arm_palm)
	B.put(B.capsule(0.045, 0.5), ivory, Vector3(0, -0.3, 0), g.arm_palm)
	B.put(B.box(0.1, 0.12, 0.03), ivory, Vector3(0, -0.62, 0), g.arm_palm)        # the raised palm
	g.arm_baton = Node3D.new()
	g.arm_baton.position = Vector3(-0.24, 1.45, 0)
	body.add_child(g.arm_baton)
	B.put(B.capsule(0.045, 0.5), ivory, Vector3(0, -0.3, 0), g.arm_baton)
	B.put(B.cyl(0.03, 0.03, 0.75), B.mat(Color("8a6440"), 0.4), Vector3(0, -0.6, 0.32), g.arm_baton).rotation.x = PI / 2.0  # padded measuring baton
	g.node.visible = state != "dormant"
	return g


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := B._label("DS-02  HATS AND GLOVES  ·  demonstration build", 12, B.BRASS)
	title.position = Vector2(16, 100)
	layer.add_child(title)
	var keys := B._label("J attack (hold to wind)  ·  K guard  ·  Space dodge  ·  E examine / biscuit", 12, Color(B.IVORY, 0.7))
	keys.position = Vector2(16, 118)
	layer.add_child(keys)
	var bottom := VBoxContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -120
	bottom.offset_bottom = -24
	bottom.alignment = BoxContainer.ALIGNMENT_END
	layer.add_child(bottom)
	who = B._label("", 13, B.BRASS)
	subtitle = B._label("", 20)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for l in [who, subtitle]:
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
	for a in MAIN.ACTIONS:
		var h: bool = Input.is_action_pressed("ab_" + a) or bool(virtual.get(a, false))
		pressed[a] = h and not bool(keys_prev.get(a, false))
		keys_prev[a] = h
		held[a] = h
	time += dt
	_update_player(dt)
	for g in guards:
		_update_guard(g, dt)
	_check_clear()
	dialogue.update(dt)
	_render_actors(dt)


func _update_player(dt: float) -> void:
	var input := Vector2(float(held.get("right", false)) - float(held.get("left", false)),
		float(held.get("down", false)) - float(held.get("up", false)))
	if input.length() > 1.0:
		input = input.normalized()
	input = Mover.to_world(input, camera)
	inv = maxf(0.0, inv - dt)
	if act != "none":
		act_t -= dt
		if act_t <= 0.0:
			if act == "eat":
				hp = mini(6, hp + 2)
				gauge.set_health(hp, 6)
				sfx.pip()
			act = "none"
	var free := act == "none"
	guard = held.get("guard", false) and free and not charging
	# Attack: tap = light, hold 0.8 s = wound heavy (three spring clicks).
	if pressed.get("attack", false) and free and not charging:
		charging = true
		charge_t = 0.0
		clicks = 0
	if charging:
		charge_t += dt
		var c := mini(3, int(floor(charge_t / (HEAVY_CHARGE / 3.0) + 0.001)))
		while clicks < c:
			clicks += 1
			sfx.click()
		if not held.get("attack", false):
			charging = false
			var target := _nearest_guard_in_front(2.3)
			if target:
				p_yaw = atan2(target.pos.x - p_pos.x, target.pos.y - p_pos.y)
			if charge_t >= HEAVY_CHARGE:
				act = "heavy"
				act_t = 0.65
				sfx.heavy()
				if target:
					_hit_guard(target, true)
			else:
				act = "light"
				act_t = 0.5   # long enough for the mocap slash to finish
				sfx.swing()
				if target:
					_hit_guard(target, false)
	if pressed.get("dodge", false) and free:
		charging = false
		var d := input if input.length() > 0.2 else Vector2(-sin(p_yaw), -cos(p_yaw))
		dodge_dir = d.normalized()
		act = "dodge"
		act_t = REFLECT_DODGE
		sfx.swing()
	var near_pin := not pin_taken and p_pos.distance_to(PIN_AT + Vector2(0, 0.6)) < 0.9
	if pressed.get("eat", false) and free:
		if near_pin:
			_take_pin()
		elif biscuits > 0 and hp < 6:
			biscuits -= 1
			act = "eat"
			act_t = 0.9
			gauge.set_biscuits(biscuits)
	var spd := 4.5
	if guard:
		spd = 1.6
	elif charging:
		spd = 2.6
	elif act in ["light", "heavy", "eat"]:
		spd = 0.6
	var vel: Vector2 = mover.step(input, spd, dt)
	if act == "dodge":
		vel = dodge_dir * 10.0
		mover.vel = dodge_dir * 4.0
	# Rack pushing: guard held at a handle, walking along the guide.
	var pushing := false
	if guard and absf(p_pos.y - RACK_Z) < 0.75 and absf(input.x) > 0.3:
		var west_end := rack_x - RACK_HALF.x
		var east_end := rack_x + RACK_HALF.x
		var at_west := absf(p_pos.x - west_end) < 0.75 and p_pos.x < west_end and input.x > 0.0
		var at_east := absf(p_pos.x - east_end) < 0.75 and p_pos.x > east_end and input.x < 0.0
		if at_west or at_east:
			var before := rack_x
			rack_x = clampf(rack_x + input.x * 1.3 * dt, STOP_WEST, STOP_EAST)
			rack_moved += absf(rack_x - before)
			vel = Vector2(rack_x - before, 0.0) / maxf(dt, 0.0001)
			pushing = absf(rack_x - before) > 0.0
			if pushing and int(time * 6.0) != int((time - dt) * 6.0):
				sfx.squeak()
	vel += knock
	knock = knock.lerp(Vector2.ZERO, 1.0 - exp(-8.0 * dt))
	p_pos += vel * dt
	_collide_player()
	if pushing:
		p_yaw = lerp_angle(p_yaw, atan2(signf(vel.x), 0.0), 1.0 - exp(-12.0 * dt))
	elif charging or guard:
		var t := _nearest_guard_in_front(6.0, true)
		if t:
			p_yaw = lerp_angle(p_yaw, atan2(t.pos.x - p_pos.x, t.pos.y - p_pos.y), 1.0 - exp(-14.0 * dt))
	elif input.length() > 0.1:
		p_yaw = Mover.turn(p_yaw, input, dt)
	speed = vel.length()
	if rack_moved > 0.5 and not second_awake:
		second_awake = true
		_wake_second()
	# Prompts.
	var near_handle := absf(p_pos.y - RACK_Z) < 0.75 and (absf(p_pos.x - (rack_x - RACK_HALF.x)) < 0.8 or absf(p_pos.x - (rack_x + RACK_HALF.x)) < 0.8)
	if near_pin:
		gauge.show_prompt("interact", "Take the souvenir pin")
	elif near_handle:
		gauge.show_prompt("guard", "Hold guard and walk — PUSH")
	elif charging and charge_t >= HEAVY_CHARGE:
		gauge.show_prompt("attack", "Wound — release")
	elif p_pos.y < -HALF_D + 1.4 and absf(p_pos.x) < EXIT_X:
		gauge.show_prompt("go", "North — to Alterations")
	else:
		gauge.hide_prompt()
	if p_pos.y < -HALF_D + 0.5 and absf(p_pos.x) < EXIT_X and not leaving:
		_leave()


func _collide_player() -> void:
	p_pos.x = clampf(p_pos.x, -HALF_W + 0.35, HALF_W - 0.35 if absf(p_pos.y - 5.0) > 0.8 else HALF_W + 0.5)
	var north_limit := -HALF_D + 0.35 if absf(p_pos.x) > EXIT_X - 0.3 else -HALF_D - 0.5
	p_pos.y = clampf(p_pos.y, north_limit, HALF_D - 0.35)
	var boxes: Array = solids.duplicate()
	boxes.append(Rect2(Vector2(rack_x - RACK_HALF.x, RACK_Z - RACK_HALF.y), RACK_HALF * 2.0))
	for b in boxes:
		var r: Rect2 = b
		var grown := r.grow(0.3)
		if grown.has_point(p_pos):
			var push_l := p_pos.x - grown.position.x
			var push_r := grown.end.x - p_pos.x
			var push_u := p_pos.y - grown.position.y
			var push_d := grown.end.y - p_pos.y
			var m := minf(minf(push_l, push_r), minf(push_u, push_d))
			if m == push_l:
				p_pos.x = grown.position.x
			elif m == push_r:
				p_pos.x = grown.end.x
			elif m == push_u:
				p_pos.y = grown.position.y
			else:
				p_pos.y = grown.end.y
	for t in trees:
		var d: float = p_pos.distance_to(t)
		if d < 0.6 and d > 0.001:
			p_pos = t + (p_pos - t) / d * 0.6
	for g in guards:
		var gg: Guard = g
		if gg.state in ["dormant"]:
			continue
		var d := p_pos.distance_to(gg.pos)
		if d < 0.6 and d > 0.001:
			p_pos = gg.pos + (p_pos - gg.pos) / d * 0.6


func _nearest_guard_in_front(reach: float, any_direction := false) -> Guard:
	var best: Guard = null
	var best_d := reach
	for g in guards:
		var gg: Guard = g
		if gg.state in ["dormant", "seated", "standing"]:
			continue
		var d := p_pos.distance_to(gg.pos)
		if d > best_d:
			continue
		var to := (gg.pos - p_pos).normalized()
		var facing := Vector2(sin(p_yaw), cos(p_yaw))
		if any_direction or to.dot(facing) > 0.1 or d < 1.0:
			best = gg
			best_d = d
	return best


# ---------------------------------------------------------------- etiquette guards

func _attack_token_free(me: Guard) -> bool:
	for g in guards:
		var gg: Guard = g
		if gg != me and gg.state in ["tell", "strike"]:
			return false
	return true


func _update_guard(g: Guard, dt: float) -> void:
	g.t -= dt
	var to_p := p_pos - g.pos
	var d := to_p.length()
	var face := atan2(to_p.x, to_p.y)
	match g.state:
		"dormant", "seated":
			pass
		"standing":
			g.pos = g.pos.move_toward(g.post, 1.2 * dt)
			g.yaw = lerp_angle(g.yaw, face, 1.0 - exp(-3.0 * dt))
		"post":
			g.yaw = lerp_angle(g.yaw, face, 1.0 - exp(-2.0 * dt))
			if d < GUARD_WAKE:
				_alert(g)
		"approach", "circle":
			g.yaw = lerp_angle(g.yaw, face, 1.0 - exp(-6.0 * dt))
			if d > 1.6:
				var want := g.pos + to_p.normalized() * GUARD_SPEED * dt
				if g.state == "circle":
					# Hold at a respectful distance and drift around Ren, pointing.
					var side := Vector2(-to_p.y, to_p.x).normalized() * g.orbit
					want = g.pos + (side * 0.8 + to_p.normalized() * (d - 2.6)).limit_length(1.0) * GUARD_SPEED * dt
				g.pos = want
			if d < 1.9 and g.t <= 0.0:
				if _attack_token_free(g):
					g.state = "tell"
					g.t = GUARD_TELL
					g.hit_done = false
				else:
					g.state = "circle"
					g.t = 0.8
			elif g.state == "circle" and _attack_token_free(g) and g.t <= 0.0:
				g.state = "approach"
		"tell":
			g.yaw = lerp_angle(g.yaw, face, 1.0 - exp(-4.0 * dt))
			if g.t <= 0.0:
				g.state = "strike"
				g.t = 0.18
				sfx.swing()
		"strike":
			if not g.hit_done and d < 1.95:
				var facing := Vector2(sin(g.yaw), cos(g.yaw))
				if to_p.normalized().dot(facing) > 0.4:
					g.hit_done = true
					_strike_ren(g)
			if g.t <= 0.0:
				g.state = "recover"
				g.t = GUARD_RECOVER
		"recover":
			if g.t <= 0.0:
				g.state = "approach"
				g.t = 0.4
		"flinch":
			if g.t <= 0.0:
				g.state = "approach"
				g.t = 0.5
	# Keep guards from stacking on one another.
	for o in guards:
		var other: Guard = o
		if other == g or other.state in ["dormant"]:
			continue
		var sep := g.pos - other.pos
		if sep.length() < 0.8 and sep.length() > 0.001:
			g.pos += sep.normalized() * (0.8 - sep.length()) * 0.5
	g.pos.x = clampf(g.pos.x, -HALF_W + 0.4, HALF_W - 0.4)
	g.pos.y = clampf(g.pos.y, -HALF_D + 0.4, HALF_D - 0.4)


func _alert(g: Guard) -> void:
	g.state = "approach"
	g.t = 0.6
	g.orbit = 1.0 if randf() < 0.5 else -1.0
	if not g.spoke:
		g.spoke = true
		say("ETIQUETTE GUARD", "Staff access only.", 1.8)


func _wake_second() -> void:
	var g: Guard = guards[1]
	g.node.visible = true
	g.state = "post"
	say("NELL", "Another one — by the hat trees!", 2.0)


func _hit_guard(g: Guard, heavy: bool) -> void:
	if g.state in ["seated", "dormant", "standing"]:
		return
	if g.state in ["post"]:
		_alert(g)
	sfx.knock()
	var opening := g.state in ["tell", "recover"]
	if heavy and opening:
		g.pips = 0.0
	elif heavy:
		g.pips -= 1.0
	else:
		g.pips -= 0.67           # three connected light hits empty two pips
	if g.pips <= 0.01:
		_topple(g)
	elif g.state not in ["tell", "strike", "recover"]:
		g.state = "flinch"       # light hits stagger an approaching guard; they don't stop a committed strike
		g.t = 0.3


func _topple(g: Guard) -> void:
	g.state = "seated"
	sfx.thud()
	say("ETIQUETTE GUARD", "A short break.", 1.8)
	# The cap rolls a short distance away.
	g.cap.top_level = true
	g.cap.global_position = g.node.global_position + Vector3(0.6, 0.06, 0.4)
	g.cap.rotation = Vector3(PI / 2.0, 0, 0)


func _strike_ren(g: Guard) -> void:
	if inv > 0.0 or act == "dodge":
		return
	var facing := Vector2(sin(p_yaw), cos(p_yaw))
	var from := (g.pos - p_pos).normalized()
	if guard and facing.dot(from) > 0.3:
		sfx.thud()                       # blocked on the flat of Knock
		knock = -from * 3.0
		return
	hp = maxi(0, hp - 1)
	inv = 0.9
	knock = -from * 5.0
	act = "none"
	charging = false
	sfx.hurt()
	gauge.set_health(hp, 6)
	if hp <= 0:
		_restart()


func _restart() -> void:
	say("", "Ren is down. Back to the Cosmetics door.", 2.2)
	hp = 6
	biscuits = 2
	p_pos = ENTRY
	gauge.set_health(hp, 6)
	gauge.set_biscuits(biscuits)
	for g in guards:
		var gg: Guard = g
		if gg.state != "seated":
			gg.pos = gg.post
			gg.state = "post" if gg.node.visible else "dormant"
			gg.pips = 2.0


func _check_clear() -> void:
	if cleared or not second_awake:
		return
	for g in guards:
		if (g as Guard).state != "seated":
			return
	cleared = true
	gauge.set_objective("North — to Alterations")
	say("MIKA", "They'll be fine. Breaks were overdue.", 2.4)
	for g in guards:
		var gg: Guard = g
		gg.state = "standing"
		gg.post = gg.pos + Vector2(-0.8, 0)
		gg.cap.top_level = false
		gg.cap.position = Vector3(0, 1.84, 0)
		gg.cap.rotation = Vector3.ZERO


func _take_pin() -> void:
	pin_taken = true
	pin_node.visible = false
	sfx.spring()
	sfx.pip()
	Engine.set_meta("afterbell_sv01", true)
	say("", "Souvenir pin SV-01: a tiny cream umbrella — the rooftop lunchroom's.", 3.0)


func _leave() -> void:
	leaving = true
	fade.go_to(next_scene)


# ---------------------------------------------------------------- presentation

func _render_actors(dt: float) -> void:
	ren.position = Vector3(p_pos.x, 0, p_pos.y)
	ren.rotation.y = p_yaw
	ren.visible = not (inv > 0.0 and int(time * 20.0) % 2 == 0)
	var clip := "idle"
	if inv > 0.6:
		clip = "hurt"
	elif act in ["dodge", "light", "heavy", "eat"]:
		clip = act
	elif charging:
		clip = "wind"
	elif guard:
		clip = "guard"
	elif speed > 0.5:
		clip = "run"
	if clip != ren_clip:
		ren_anim.play(clip, 0.06 if clip in ["light", "heavy", "dodge", "hurt", "guard", "wind"] else 0.15)
		ren_clip = clip
	rack.position = Vector3(rack_x, 0, RACK_Z)
	for g in guards:
		var gg: Guard = g
		gg.node.position = Vector3(gg.pos.x, 0, gg.pos.y)
		gg.node.rotation.y = gg.yaw
		var body: Node3D = gg.node.get_node("Body")
		var baton_x := -0.3
		var palm_x := -0.2
		var sit := 0.0
		match gg.state:
			"tell":
				baton_x = -2.8                 # baton lifted over the shoulder
				palm_x = -1.5                  # left palm raised toward Ren
			"strike":
				baton_x = -0.5
				palm_x = -1.0
			"recover":
				baton_x = -0.2
			"circle":
				palm_x = -1.3                  # points
			"seated":
				sit = 1.0
		gg.arm_baton.rotation.x = lerpf(gg.arm_baton.rotation.x, baton_x, 1.0 - exp(-(30.0 if gg.state == "strike" else 10.0) * dt))
		gg.arm_palm.rotation.x = lerpf(gg.arm_palm.rotation.x, palm_x, 1.0 - exp(-10.0 * dt))
		body.position.y = lerpf(body.position.y, -0.55 * sit, 1.0 - exp(-8.0 * dt))
		body.rotation.x = lerpf(body.rotation.x, -0.25 * sit + (0.15 if gg.state == "flinch" else 0.0), 1.0 - exp(-8.0 * dt))


func _place_camera(delta: float) -> void:
	var walls := Rect2(-HALF_W + 0.35, -HALF_D + 0.35, HALF_W * 2.0 - 0.7, HALF_D * 2.0 - 0.7)
	ShoulderCam.place(camera, p_pos, Vector2(0, -1), delta, walls, 62.0)
