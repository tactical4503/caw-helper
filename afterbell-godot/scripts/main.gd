extends Node3D
## AFTERBELL — Installment 002 greybox: BS-01 The Floor Manager (Menswear Court, DS-10).
## Everything is built in code from primitives so the scene file stays tiny and diffable.
## Values come from the Installment 002 timing table and are untested design targets.

const B := preload("res://scripts/builders.gd")

const DEG := PI / 180.0
# World: x east, -z north. The court DS-10 (building x10–26, y22–40) is centred on the origin.
const BELL := Vector2(0.0, -7.0)         # building (18, 38), shallow north-wall recess
const LEVER := Vector2(0.0, -6.1)        # low lever the chair bumper strikes (CAN-027)
const MARK := Vector2(0.0, -1.5)         # presentation mark
const ENTRY := Vector2(-6.6, 7.4)        # west door near the south-west corner
const MIN_X := -7.6
const MAX_X := 7.6
const MIN_Z := -5.6
const MAX_Z := 8.6
const RACK_LANE_Z := 3.6

# Section 11 timing table.
const SIGN_TELL := 1.0
const SIGN_SPEED := 5.0
const SIGN_SPEED_P3 := 6.5
const REFLECT_WINDOW := 0.18
const MISS_RECOVER := 1.3
const SWEEP_TELL := 1.1
const SWEEP_ARC := 100.0 * DEG
const SWEEP_REACH := 2.6
const SWEEP_RECOVER := 1.4
const SWEEP_CLOSE_TIME := 2.0
const RACK_TELL := 1.2
const RACK_SPEED := 3.0
const RACK_RECOVER := 1.8
const EXPOSED := 5.5
const EXPOSED_EASY := 8.0
const HEAVY_CHARGE := 0.8
const PLAYER_RECOVER := 0.5
const BELL_SETTLE := 0.4
const PHASE_SCENE := 2.5
const PHASE_SCENE_REPEAT := 1.0
const STEER := 30.0 * DEG
const STEER_EASY := 50.0 * DEG
const LAUNCH_SPEED := 7.5
const HIT_FREEZE := 0.06

const COMMITTED := ["present", "sweep_tell", "sweep_active", "rack_tell", "rack_active", "launch"]

var settings := {"easy": false, "reflect_assist": false, "aim_help": false, "keep_progress": false, "shake": true}

# Flow
var mode := "title"
var time := 0.0
var freeze := 0.0
var shake := 0.0
var bells := 0
var phase := 1
var seen := {}
var failed_reflects := 0
var hinted_assist := false
var locked_hits := 0
var first_exposure := true
var signs_said := 0
var victory_t := 0.0
var reward_shown := false

# Ren
var p_pos := ENTRY
var p_yaw := 0.6
var hp := 6
var biscuits := 2
var inv := 0.0
var act := "none"
var act_t := 0.0
var guard := false
var guard_press_t := -9.0
var charging := false
var charge_t := 0.0
var clicks := 0
var dodge_cd := 0.0
var dodge_dir := Vector2.ZERO
var knock := Vector2.ZERO
var walk := 0.0
var speed := 0.0
var stride := 0.0

# Floor Manager
var m_pos := MARK + Vector2(0, -2)
var m_yaw := PI
var chair_yaw := PI
var m_state := "enter"
var m_t := 1.6
var m_close := 0.0
var m_next := "sign"
var m_pose := "idle"
var m_dir := Vector2.ZERO
var m_travel := 0.0
var sweep_hit := false
var flinch := 0.0
var lower := 0.0
var steer_to := PI
var lever_kick := 0.0

var sign_data: B.SignData = null
var racks: Array = []
var tab_falls: Array = []

# Input: keyboard/mouse via InputMap, plus `virtual` for automated tests.
const ACTIONS := {
	"up": [KEY_W, KEY_UP], "down": [KEY_S, KEY_DOWN], "left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT],
	"attack": [KEY_J], "guard": [KEY_K], "dodge": [KEY_SPACE], "eat": [KEY_E],
	"retreat": [KEY_R], "pause": [KEY_ESCAPE], "assist": [KEY_T],
}
var held := {}
var pressed := {}
var _prev := {}
var virtual := {}

var arena: B.Arena
var boss: B.Boss
var ren: B.Ren
var camera: Camera3D
var hud: B.Hud
var sfx: B.Sfx

var _subs: Array = []
var _sub_cur = null
var _sub_t := 0.0


func _ready() -> void:
	randomize()
	_setup_input()
	arena = B.build_arena(self)
	boss = B.build_boss()
	add_child(boss.root)
	ren = B.build_ren()
	add_child(ren.root)
	for i in 2:
		var r := B.build_rack(i)
		add_child(r.node)
		racks.append(r)
	camera = Camera3D.new()
	camera.fov = 46.0
	add_child(camera)
	camera.position = Vector3(0, 12, 14)
	camera.look_at(Vector3(0, 1, 0), Vector3.UP)
	sfx = B.Sfx.new()
	add_child(sfx)
	hud = B.build_hud(self)
	hud.start_button.pressed.connect(_on_start)
	hud.again_button.pressed.connect(_on_again)
	for key in hud.options:
		var box: CheckBox = hud.options[key]
		box.button_pressed = settings[key]
		box.toggled.connect(func(on: bool) -> void: settings[key] = on)
	reset_attempt(false)
	_render(0.0)


func _setup_input() -> void:
	for a in ACTIONS:
		var action: String = "ab_" + a
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in ACTIONS[a]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
	var lmb := InputEventMouseButton.new()
	lmb.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("ab_attack", lmb)
	var rmb := InputEventMouseButton.new()
	rmb.button_index = MOUSE_BUTTON_RIGHT
	InputMap.action_add_event("ab_guard", rmb)


func _poll_input() -> void:
	for a in ACTIONS:
		var h: bool = Input.is_action_pressed("ab_" + a) or bool(virtual.get(a, false))
		pressed[a] = h and not bool(_prev.get(a, false))
		_prev[a] = h
		held[a] = h


func is_held(a: String) -> bool:
	return bool(held.get(a, false))


func was_pressed(a: String) -> bool:
	return bool(pressed.get(a, false))


# ---------------------------------------------------------------- flow

func _on_start() -> void:
	hud.title.visible = false
	hud.root.visible = true
	if mode == "title":
		reset_attempt(false)
	mode = "play"


func _on_again() -> void:
	hud.end.visible = false
	var keep: bool = settings.keep_progress and hp <= 0 and m_state != "defeated"
	reset_attempt(keep)
	mode = "play"


func start_game() -> void:
	_on_start()


func reset_attempt(keep: bool) -> void:
	p_pos = ENTRY
	p_yaw = 0.6
	hp = 6
	biscuits = 2
	inv = 0.0
	act = "none"
	act_t = 0.0
	charging = false
	guard = false
	knock = Vector2.ZERO
	if not keep:
		bells = 0
		phase = 1
	m_pos = MARK + Vector2(0, -2)
	m_yaw = PI
	chair_yaw = PI
	steer_to = PI
	m_state = "enter"
	m_t = 1.2
	m_close = 0.0
	m_next = "sign"
	m_pose = "idle"
	flinch = 0.0
	lower = 0.0
	locked_hits = 0
	first_exposure = bells == 0
	victory_t = 0.0
	reward_shown = false
	_clear_sign()
	for i in arena.tabs.size():
		var t: MeshInstance3D = arena.tabs[i]
		t.visible = i >= bells
		t.position.y = -0.42
		t.rotation = Vector3.ZERO
	tab_falls.clear()
	arena.cabinet_door.rotation.y = 0.0
	for i in racks.size():
		var r: B.Rack = racks[i]
		var p: Vector2 = B.RACK_HOME[i]
		if phase >= 2:
			p = Vector2(7.0, -5.2) if i == 1 else Vector2(-7.2, RACK_LANE_Z)
		r.pos = p
		r.target = p
		r.state = "park"
		r.dir = 1
	arena.lane_marks.visible = phase >= 2
	_subs.clear()
	_sub_cur = null
	say("MIKA", "Bell's behind him. Get his brake open and we can reach the governor.", 3.0)
	_update_hud()


func say(who: String, text: String, dur := 2.6) -> void:
	_subs.append([who, text, dur])


func _update_subs(dt: float) -> void:
	if _sub_cur != null:
		_sub_t -= dt
		if _sub_t <= 0.0:
			_sub_cur = null
	if _sub_cur == null and not _subs.is_empty():
		_sub_cur = _subs.pop_front()
		_sub_t = _sub_cur[2]
	if _sub_cur == null:
		hud.subtitle_who.text = ""
		hud.subtitle.text = ""
	else:
		hud.subtitle_who.text = _sub_cur[0]
		hud.subtitle.text = _sub_cur[1]


func _update_hud() -> void:
	hud.set_health(hp, biscuits)
	hud.set_tabs(bells)


func _process(delta: float) -> void:
	var raw: float = minf(delta, 0.05)
	var dt := raw
	if mode == "play":
		if freeze > 0.0:
			freeze -= raw
			dt = 0.0
		step(dt)
	elif mode == "paused":
		_poll_input()
		if was_pressed("pause"):
			_on_start()
	_update_subs(raw if mode == "play" else 0.0)
	_render(dt if mode == "play" else raw * 0.2)


## One fixed simulation tick. Public so headless tests can drive the fight deterministically.
func step(dt: float) -> void:
	_poll_input()
	if was_pressed("pause"):
		mode = "paused"
		hud.title.visible = true
		hud.start_button.text = "Resume"
		return
	if was_pressed("assist"):
		settings.reflect_assist = not settings.reflect_assist
		hud.options["reflect_assist"].button_pressed = settings.reflect_assist
		say("", "Reflection assist %s" % ("on: a held guard reflects marked signs." if settings.reflect_assist else "off."), 2.0)
	time += dt
	_update_player(dt)
	_update_manager(dt)
	_update_racks(dt)
	_update_sign(dt)
	if m_state == "defeated":
		victory_t += dt
		if victory_t > 15.0 and not reward_shown:
			reward_shown = true
			sfx.spring()
			sfx.pip()
			mode = "end"
			_show_end("Key item · Q-01", "Store Governor",
				"A brass cylinder the length of Ren's palm, cream inspection sleeve, silver fork, Meridian Works mark. Mika takes it by the sleeve. — End of the greybox slice.",
				"Replay")


func _show_end(eyebrow: String, title: String, body: String, button: String) -> void:
	hud.end_eyebrow.text = eyebrow
	hud.end_title.text = title
	hud.end_body.text = body
	hud.again_button.text = button
	hud.end.visible = true


func _defeat() -> void:
	mode = "end"
	var body := "Back at the service passage with full health and two biscuits. "
	body += "Bell progress is kept." if settings.keep_progress else "The Manager starts again from phase one."
	_show_end("Defeat", "Ren is down", body, "Try again")


func _victory() -> void:
	m_state = "defeated"
	victory_t = 0.0
	_clear_sign()
	sfx.squeak()
	for line in [["REN", "Are you finished?"], ["FLOOR MANAGER", "I have not completed the closing procedure."],
			["MIKA", "Neither has the town."], ["FLOOR MANAGER", "If we close, where do they go?"],
			["HESTA", "We count them first."]]:
		say(line[0], line[1], 2.8)


# ---------------------------------------------------------------- combat helpers

static func yaw_to(a: Vector2, b: Vector2) -> float:
	return atan2(b.x - a.x, b.y - a.y)


static func damp(a: float, b: float, k: float, dt: float) -> float:
	return lerpf(a, b, 1.0 - exp(-k * dt))


static func damp_angle(a: float, b: float, k: float, dt: float) -> float:
	return lerp_angle(a, b, 1.0 - exp(-k * dt))


func hurt_player(n: int, from: Vector2) -> bool:
	if inv > 0.0 or act == "dodge" or mode != "play":
		return false
	hp = maxi(0, hp - n)
	inv = 0.9
	var away := p_pos - from
	knock = (away.normalized() if away.length() > 0.001 else Vector2(0, 1)) * 6.0
	charging = false
	act = "none"
	sfx.hurt()
	_add_shake(0.12)
	_update_hud()
	if hp <= 0:
		_defeat()
	return true


func _add_shake(a: float) -> void:
	if settings.shake:
		shake = maxf(shake, a)


func committed() -> bool:
	return m_state in COMMITTED


func _start_exposure() -> void:
	m_state = "exposed"
	m_t = EXPOSED_EASY if settings.easy else EXPOSED
	m_pose = "exposed"
	steer_to = yaw_to(m_pos, LEVER)
	sfx.thud()
	sfx.squeak()
	_add_shake(0.08)
	if first_exposure:
		first_exposure = false
		say("MIKA", "Brake's out! Get behind the red paddle — wind it and send him into the bell.", 3.4)


func _heavy_strike() -> void:
	var d := p_pos.distance_to(m_pos)
	if m_state == "exposed" and d < 2.8:
		var hit_dir := (m_pos - p_pos).normalized()
		var bell_dir := (LEVER - m_pos).normalized()
		var off := acos(clampf(hit_dir.dot(bell_dir), -1.0, 1.0))
		freeze = HIT_FREEZE
		sfx.heavy()
		_add_shake(0.15)
		m_dir = hit_dir
		if off <= (STEER_EASY if settings.easy else STEER):
			# Forgiving steering: the casters swivel toward the lever; no teleport.
			m_state = "launch"
			steer_to = atan2(bell_dir.x, bell_dir.y)
		else:
			m_state = "wrong_roll"
			m_travel = 0.0
			steer_to = atan2(hit_dir.x, hit_dir.y)
		return
	if d < 2.6:
		_hit_locked(true)


func _light_strike() -> void:
	if p_pos.distance_to(m_pos) > 2.3:
		return
	if m_state == "sweep_tell":
		sfx.knock()
		m_state = "recover"
		m_t = 0.9
		m_pose = "idle"
		flinch = 1.0
		return
	if m_state == "exposed":
		sfx.knock()
		flinch = 0.5
		if not seen.has("wind_hint"):
			seen["wind_hint"] = true
			say("MIKA", "Not a tap. Hold it — let the spring wind.", 2.4)
		return
	_hit_locked(false)


func _hit_locked(heavy: bool) -> void:
	sfx.knock()
	flinch = 1.0 if heavy else 0.6
	locked_hits += 1
	if locked_hits >= 3 and not seen.has("locked"):
		seen["locked"] = true
		say("", "The chair is locked.", 2.2)


# ---------------------------------------------------------------- the sale sign

func _throw_sign() -> void:
	var spd := SIGN_SPEED_P3 if phase >= 3 else SIGN_SPEED
	var start := m_pos + Vector2(sin(m_yaw), cos(m_yaw)) * 0.6
	var s := B.SignData.new()
	s.node = B.build_placard()
	add_child(s.node)
	s.pos = start
	s.y = 1.45
	s.vel = (p_pos - start).normalized() * spd
	s.state = "out"
	s.node.position = Vector3(start.x, s.y, start.y)
	s.node.rotation.y = atan2(s.vel.x, s.vel.y)
	sign_data = s


func _clear_sign() -> void:
	if sign_data != null:
		sign_data.node.queue_free()
		sign_data = null


func _sign_resolved(reflected: bool) -> void:
	if not reflected and m_state == "wait_sign":
		m_state = "recover"
		m_t = MISS_RECOVER
		m_pose = "idle"


func _note_failed_reflect() -> void:
	failed_reflects += 1
	if failed_reflects >= 3 and not settings.reflect_assist and not hinted_assist:
		hinted_assist = true
		say("NELL", "He repeats himself. Tap guard right as the bordered sign arrives — or press T for reflection assist.", 4.0)


func _update_sign(dt: float) -> void:
	if sign_data == null:
		return
	var s := sign_data
	s.t += dt
	if s.state == "out":
		s.pos += s.vel * dt
		s.node.rotation.z += dt * 0.6
		if s.pos.distance_to(p_pos) < 0.75 and act != "dodge":
			var timed := time - guard_press_t <= REFLECT_WINDOW
			if guard and (timed or settings.reflect_assist):
				s.state = "back"
				sfx.reflect()
				freeze = HIT_FREEZE
				failed_reflects = 0
			elif guard:
				s.state = "drop"
				sfx.thud()
				_note_failed_reflect()
				_sign_resolved(false)
			else:
				hurt_player(1, s.pos - s.vel)
				s.state = "drop"
				_note_failed_reflect()
				_sign_resolved(false)
		elif s.t > 5.0 or absf(s.pos.x) > 9.0 or absf(s.pos.y) > 10.0:
			_clear_sign()
			_sign_resolved(false)
			return
	elif s.state == "back":
		var d := s.pos.distance_to(m_pos)
		s.pos = s.pos.move_toward(m_pos, 10.0 * dt)
		s.y = damp(s.y, 1.9, 6.0, dt)
		s.node.rotation.y += dt * 9.0
		if d < 0.55:
			_clear_sign()
			if m_state in ["wait_sign", "recover", "idle"]:
				_start_exposure()
			return
	elif s.state == "drop":
		s.y = maxf(0.05, s.y - dt * 3.0)
		s.node.rotation.x = damp(s.node.rotation.x, -PI / 2.0, 8.0, dt)
		if s.t > 2.2:
			_clear_sign()
			return
	s.node.position = Vector3(s.pos.x, s.y, s.pos.y)


# ---------------------------------------------------------------- Floor Manager AI

func _idle_duration() -> float:
	return 1.0 if phase >= 3 else (1.5 if phase == 2 else 2.0)


func _update_manager(dt: float) -> void:
	m_t -= dt
	var d_p := m_pos.distance_to(p_pos)
	var face_p := yaw_to(m_pos, p_pos)
	var st := m_state
	var rack0: B.Rack = racks[0]

	match st:
		"enter":
			m_pose = "idle"
			if m_t <= 0.0:
				m_state = "roll"
				if not seen.has("valued"):
					seen["valued"] = true
					say("FLOOR MANAGER", "Valued— … Valued customers. The court is closed for fitting.", 3.0)
		"roll":
			m_pose = "idle"
			var d := m_pos.distance_to(MARK)
			if d < 0.08:
				m_state = "idle"
				m_t = _idle_duration()
			else:
				steer_to = yaw_to(m_pos, MARK)
				m_pos = m_pos.move_toward(MARK, 2.2 * dt)
				if randf() < dt * 1.2:
					sfx.squeak()
		"idle", "recover":
			m_pose = "idle"
			steer_to = face_p
			if d_p < 3.0:
				m_close += dt
			else:
				m_close = maxf(0.0, m_close - dt)
			if m_close > SWEEP_CLOSE_TIME:
				m_close = 0.0
				m_state = "sweep_tell"
				m_t = SWEEP_TELL
				sweep_hit = false
			elif m_t <= 0.0:
				if st == "recover":
					m_state = "idle"
					m_t = _idle_duration() * 0.5
				elif phase >= 2 and m_next == "rack" and sign_data == null and rack0.state == "park":
					m_state = "rack_tell"
					m_t = RACK_TELL
					m_next = "sign"
					sfx.rattle()
					rack0.state = "tell"
					rack0.dir = 1 if rack0.pos.x < 0.0 else -1
				elif sign_data == null:
					m_state = "present"
					m_t = SIGN_TELL
					sfx.chime()
					if phase >= 2:
						m_next = "rack"
					if signs_said < 2:
						say("FLOOR MANAGER", "Please read.", 1.1)
					signs_said += 1
		"present":
			m_pose = "present"
			steer_to = face_p
			if m_t <= 0.0:
				_throw_sign()
				m_state = "wait_sign"
				m_pose = "throw"
				m_t = 4.0
				sfx.swing()
		"wait_sign":
			steer_to = face_p
			if m_t < 3.6:
				m_pose = "idle"
		"sweep_tell":
			m_pose = "sweep_tell"
			if m_t <= 0.0:
				m_state = "sweep_active"
				m_t = 0.2
				sfx.swing()
			else:
				steer_to = face_p
		"sweep_active":
			m_pose = "sweep_active"
			if not sweep_hit and d_p < SWEEP_REACH + 0.4 and absf(wrapf(face_p - m_yaw, -PI, PI)) < SWEEP_ARC / 2.0:
				sweep_hit = true
				hurt_player(1, m_pos)
			if m_t <= 0.0:
				m_state = "sweep_recover"
				m_t = SWEEP_RECOVER
		"sweep_recover":
			m_pose = "idle"
			if m_t <= 0.0:
				m_state = "idle"
				m_t = _idle_duration() * 0.6
		"rack_tell":
			m_pose = "rack"
			steer_to = yaw_to(m_pos, rack0.pos)
			if m_t <= 0.0:
				m_state = "rack_active"
				rack0.state = "move"
				rack0.hit = false
		"rack_active":
			m_pose = "idle"
			steer_to = face_p
			if rack0.state == "park":
				m_state = "rack_recover"
				m_t = RACK_RECOVER
		"rack_recover":
			m_pose = "idle"
			steer_to = face_p
			if m_t <= 0.0:
				m_state = "idle"
				m_t = _idle_duration() * 0.5
		"exposed":
			m_pose = "exposed"
			steer_to = yaw_to(m_pos, LEVER)
			if m_t <= 0.0:
				m_state = "recover"
				m_t = 1.0
				m_pose = "idle"
				sfx.squeak()
		"launch":
			m_pose = "exposed"
			var d := m_pos.distance_to(LEVER)
			# Steer the travel vector toward the lever over a few tenths of a second.
			var to_lever := (LEVER - m_pos).normalized()
			m_dir = m_dir.lerp(to_lever, 1.0 - exp(-10.0 * dt)).normalized()
			steer_to = atan2(m_dir.x, m_dir.y)
			m_pos += m_dir * LAUNCH_SPEED * dt
			if d < 0.75:
				_bell_collision()
		"wrong_roll":
			var spd := 5.0 * dt * maxf(0.2, 1.0 - m_travel / 2.6)
			m_pos.x = clampf(m_pos.x + m_dir.x * spd, MIN_X + 0.9, MAX_X - 0.9)
			m_pos.y = clampf(m_pos.y + m_dir.y * spd, MIN_Z, MAX_Z - 0.9)
			m_travel += spd
			if m_travel > 2.4:
				m_state = "stop_stun"
				m_t = 1.5
				sfx.thud()
				say("", "Wrong side — he hit the padded display stop.", 1.8)
		"stop_stun":
			m_pose = "idle"
			if m_t <= 0.0:
				m_state = "roll"
		"bell_scene":
			m_pose = "idle"
			steer_to = face_p
			if m_t <= 0.0:
				if bells >= 3:
					_victory()
					return
				m_state = "roll"
		"defeated":
			m_pose = "parked"
			lower = damp(lower, 1.0, 1.5, dt)

	chair_yaw = damp_angle(chair_yaw, steer_to, 14.0 if st == "launch" else 5.0, dt)
	var upper_target := face_p
	if st in ["exposed", "launch"]:
		upper_target = chair_yaw
	elif st == "sweep_active":
		upper_target = m_yaw
	m_yaw = damp_angle(m_yaw, upper_target, 0.6 if st == "defeated" else 4.0, dt)
	flinch = maxf(0.0, flinch - dt * 3.0)


func _bell_collision() -> void:
	bells += 1
	freeze = HIT_FREEZE
	sfx.bell()
	_add_shake(0.12)
	m_state = "bell_scene"
	m_pose = "idle"
	m_pos -= m_dir * 0.4
	lever_kick = 1.0
	tab_falls.append([arena.tabs[bells - 1], 0.0])
	_update_hud()
	var key := "scene%d" % bells
	var first := not seen.has(key)
	seen[key] = true
	m_t = BELL_SETTLE + (PHASE_SCENE if first else PHASE_SCENE_REPEAT)
	if bells == 1:
		if first:
			say("FLOOR MANAGER", "The bell is for staff.", 2.0)
			say("NELL", "Got the other rack — the service door's clear!", 2.2)
		phase = 2
		arena.lane_marks.visible = true
		var r0: B.Rack = racks[0]
		var r1: B.Rack = racks[1]
		r0.target = Vector2(-7.2, RACK_LANE_Z)
		r0.state = "reposition"
		r1.target = Vector2(7.0, -5.2)
		r1.state = "reposition"
	elif bells == 2:
		if first:
			say("", "(His price-tag sash has caught on the lever. He frees it, carefully.)", 2.2)
			say("MIKA", "He's faster now. Same sign, same answer.", 2.2)
		phase = 3


func _update_racks(dt: float) -> void:
	for r in racks:
		var rack: B.Rack = r
		match rack.state:
			"reposition":
				if rack.pos.distance_to(rack.target) < 0.05:
					rack.state = "park"
				else:
					rack.pos = rack.pos.move_toward(rack.target, 2.4 * dt)
			"tell":
				rack.cloth.rotation.x = sin(time * 30.0) * 0.05  # wheel-swivel shiver
			"move":
				rack.pos.x += rack.dir * RACK_SPEED * dt
				if (rack.dir > 0 and rack.pos.x >= 7.2) or (rack.dir < 0 and rack.pos.x <= -7.2):
					rack.pos.x = clampf(rack.pos.x, -7.2, 7.2)
					rack.state = "park"
				if not rack.hit and absf(p_pos.x - rack.pos.x) < 0.55 and absf(p_pos.y - rack.pos.y) < 1.15:
					if hurt_player(1, Vector2(rack.pos.x - rack.dir, p_pos.y)):
						rack.hit = true


# ---------------------------------------------------------------- Ren

func _update_player(dt: float) -> void:
	var input := Vector2(
		(1.0 if is_held("right") else 0.0) - (1.0 if is_held("left") else 0.0),
		(1.0 if is_held("down") else 0.0) - (1.0 if is_held("up") else 0.0))
	if input.length() > 1.0:
		input = input.normalized()

	inv = maxf(0.0, inv - dt)
	dodge_cd = maxf(0.0, dodge_cd - dt)
	if act != "none":
		act_t -= dt
		if act_t <= 0.0:
			if act == "eat":
				hp = mini(6, hp + 2)
				_update_hud()
				sfx.pip()
			act = "none"

	var free := act == "none"
	var was_guard := guard
	guard = is_held("guard") and free and not charging
	if guard and not was_guard:
		guard_press_t = time

	if was_pressed("attack") and free and not charging:
		charging = true
		charge_t = 0.0
		clicks = 0
	if charging:
		charge_t += dt
		var c := mini(3, int(floor(charge_t / (HEAVY_CHARGE / 3.0) + 0.001)))
		while clicks < c:
			clicks += 1
			sfx.click()
		if not is_held("attack"):
			charging = false
			_face_target(0.0)
			if charge_t >= HEAVY_CHARGE:
				act = "heavy"
				act_t = PLAYER_RECOVER + 0.15
				_heavy_strike()
			else:
				act = "light"
				act_t = 0.32
				sfx.swing()
				_light_strike()
	if was_pressed("dodge") and free and dodge_cd <= 0.0:
		charging = false
		var dir := input
		if dir.length() < 0.2:
			dir = Vector2(-sin(p_yaw), -cos(p_yaw))
		dodge_dir = dir.normalized()
		act = "dodge"
		act_t = 0.28
		dodge_cd = 0.55
		sfx.swing()
	if was_pressed("eat") and free and biscuits > 0 and hp < 6:
		biscuits -= 1
		act = "eat"
		act_t = 0.9
		charging = false
		_update_hud()

	var spd := 5.0
	if guard:
		spd = 1.6
	elif charging:
		spd = 2.6
	elif act == "eat":
		spd = 1.0
	elif act == "light" or act == "heavy":
		spd = 0.6
	var vel := input * spd
	if act == "dodge":
		vel = dodge_dir * 11.0
	vel += knock
	knock = knock.lerp(Vector2.ZERO, 1.0 - exp(-8.0 * dt))
	p_pos.x = clampf(p_pos.x + vel.x * dt, MIN_X, MAX_X)
	p_pos.y = clampf(p_pos.y + vel.y * dt, MIN_Z, MAX_Z)
	var solids: Array = arena.plinths.duplicate()
	for r in racks:
		var rack: B.Rack = r
		if rack.state != "move":
			solids.append(Rect2(rack.pos - Vector2(0.3, 0.85), Vector2(0.6, 1.7)))
	for s in solids:  # push out of plinths and parked racks
		var rect: Rect2 = s
		var c := rect.get_center()
		var o := p_pos - c
		var px := rect.size.x / 2.0 + 0.3 - absf(o.x)
		var pz := rect.size.y / 2.0 + 0.3 - absf(o.y)
		if px > 0.0 and pz > 0.0:
			if px < pz:
				p_pos.x += signf(o.x) * px
			else:
				p_pos.y += signf(o.y) * pz
	var dm := p_pos.distance_to(m_pos)
	if dm < 1.05 and dm > 0.001:
		p_pos = m_pos + (p_pos - m_pos) / dm * 1.05

	if guard or charging:
		_face_target(dt)
	elif input.length() > 0.1:
		p_yaw = damp_angle(p_yaw, atan2(input.x, input.y), 14.0, dt)
	speed = vel.length()
	walk += speed * dt * 2.2

	# Retreat: the west door is available whenever the boss is not committed.
	var near_door := p_pos.x < -6.6 and p_pos.y > 6.2
	if near_door and not committed() and m_state != "defeated":
		hud.prompt.text = "R — Retreat to the service passage (resets this attempt, keeps the shortcut)"
		if was_pressed("retreat"):
			reset_attempt(settings.keep_progress)
			say("", "Retreated to the service passage.", 1.8)
	elif charging and charge_t >= HEAVY_CHARGE:
		hud.prompt.text = "Wound — release"
	else:
		hud.prompt.text = ""


func _face_target(dt: float) -> void:
	var y := yaw_to(p_pos, m_pos)
	p_yaw = damp_angle(p_yaw, y, 16.0, dt) if dt > 0.0 else y


# ---------------------------------------------------------------- presentation

func _render(dt: float) -> void:
	# Floor Manager
	boss.root.position = Vector3(m_pos.x, 0, m_pos.y)
	boss.chair.rotation.y = chair_yaw
	boss.upper.rotation.y = m_yaw
	boss.upper.position.y = -0.55 * lower  # the telescoping column lowers him
	boss.body.rotation.x = -flinch * 0.12 + (-0.06 if m_state == "exposed" else 0.0)
	var pose: Array = B.POSES.get(m_pose, B.POSES["idle"])
	for a in boss.arms:
		var arm: B.Arm = a
		var target: Array = pose[arm.level]
		arm.rx = damp(arm.rx, target[0], 9.0, dt)
		arm.rz = damp(arm.rz, target[1], 9.0, dt)
		arm.ex = damp(arm.ex, target[2], 9.0, dt)
		arm.shoulder.rotation = Vector3(arm.rx, 0, arm.side * arm.rz)
		arm.elbow.rotation.x = arm.ex
	var exp_on: bool = m_state in ["exposed", "launch"]
	boss.paddle.position.z = damp(boss.paddle.position.z, -0.44 if exp_on else -0.18, 10.0, dt)
	boss.paddle.position.y = damp(boss.paddle.position.y, 0.34 if exp_on else 0.44, 10.0, dt)
	boss.paddle_mat.emission_energy_multiplier = 1.2 if exp_on else 0.0
	var presenting := m_state == "present"
	boss.held.visible = presenting or m_state == "roll" or (sign_data == null and m_state in ["idle", "recover"])
	boss.held.position = Vector3(0, 3.35 if presenting else 2.05, 0.3 if presenting else 0.55)
	boss.held.rotation.x = -0.15 if presenting else 0.1

	arena.aim_arrow.visible = settings.aim_help and m_state == "exposed"
	if arena.aim_arrow.visible:
		var y := yaw_to(m_pos, LEVER)
		arena.aim_arrow.position = Vector3(m_pos.x - sin(y) * 2.6, 0, m_pos.y - cos(y) * 2.6)
		arena.aim_arrow.rotation.y = y

	# Bell, lever, tabs, cabinet
	lever_kick = maxf(0.0, lever_kick - dt * 3.0)
	arena.lever.rotation.x = -lever_kick * 0.25
	arena.bell_dome.rotation.z = sin(time * 60.0) * 0.02 * lever_kick
	for f in tab_falls:
		var tab: MeshInstance3D = f[0]
		if tab.position.y > -3.0:
			f[1] += 9.0 * dt
			tab.position.y -= f[1] * dt
			tab.rotation.z += dt * 4.0
		else:
			tab.visible = false
	if m_state == "defeated":
		arena.cabinet_door.rotation.y = damp(arena.cabinet_door.rotation.y, -1.9, 2.0, dt)

	for r in racks:
		var rack: B.Rack = r
		rack.node.position = Vector3(rack.pos.x, 0, rack.pos.y)
		rack.cloth.rotation.z = damp(rack.cloth.rotation.z, -rack.dir * 0.12 if rack.state == "move" else 0.0, 6.0, dt)

	# Ren
	ren.root.position = Vector3(p_pos.x, 0, p_pos.y)
	ren.root.rotation.y = p_yaw
	stride = damp(stride, 1.0 if speed > 0.5 else 0.0, 10.0, dt)
	ren.legs[0].rotation.x = sin(walk) * 0.6 * stride
	ren.legs[1].rotation.x = -sin(walk) * 0.6 * stride
	ren.arm_l.rotation.x = -sin(walk) * 0.4 * stride
	var arm := Vector3(-0.35, 0, 0.15)
	if guard:
		arm = Vector3(-1.45, -0.9, 0)
	elif charging:
		var k := minf(1.0, charge_t / HEAVY_CHARGE)
		arm = Vector3(lerpf(-0.6, -2.7, k), 0, -0.35)
	elif act == "light":
		var k := 1.0 - act_t / 0.32
		arm = Vector3(lerpf(-2.2, -0.5, k), 0, lerpf(-0.7, 0.8, k))
	elif act == "heavy":
		var k := clampf(1.0 - act_t / 0.65, 0.0, 1.0)
		arm = Vector3(lerpf(-2.7, -0.3, minf(1.0, k * 2.5)), 0, 0.9)
	elif act == "eat":
		arm = Vector3(-2.2, 0, 0.4)
	var rate := 14.0 if act == "none" else 40.0
	ren.arm_r.rotation = Vector3(damp(ren.arm_r.rotation.x, arm.x, rate, dt),
		damp(ren.arm_r.rotation.y, arm.y, 14.0, dt), damp(ren.arm_r.rotation.z, arm.z, 14.0, dt))
	ren.root.position.y = absf(sin(walk)) * stride * 0.03
	ren.root.rotation.z = 0.2 if act == "dodge" else 0.0
	ren.root.visible = not (inv > 0.0 and int(time * 20.0) % 2 == 0)
	var wound := charging and charge_t >= HEAVY_CHARGE
	ren.ring_mat.albedo_color.a = damp(ren.ring_mat.albedo_color.a, 0.85 if wound else (0.3 if charging else 0.0), 12.0, dt)

	# Camera: high three-quarter view; pulls back during the opening to show chair and bell together.
	var vp := get_viewport().get_visible_rect().size
	var portrait := vp.x < vp.y
	camera.fov = 62.0 if portrait else 46.0
	var wide := 1.18 if (exp_on or m_state == "bell_scene") else 1.0
	var fx := p_pos.x * (0.8 if portrait else 0.6) + m_pos.x * (0.2 if portrait else 0.4)
	var fz := p_pos.y * 0.62 + m_pos.y * 0.38 + (2.6 if portrait else 0.0)
	var cam_target := Vector3(fx, 11.5 * wide, fz + 10.5 * wide)
	var k_cam := 1.0 - exp(-4.0 * dt) if dt > 0.0 else 1.0
	camera.position = camera.position.lerp(cam_target, k_cam)
	shake = maxf(0.0, shake - dt)
	var sh := shake * 0.4
	camera.look_at(Vector3(fx + (randf() - 0.5) * sh, 1.0 + (randf() - 0.5) * sh, fz - 0.6), Vector3.UP)
