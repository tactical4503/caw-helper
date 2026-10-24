extends CanvasLayer
## Dynamic in-game HUD, drawn in code (no image assets), styled after the target screenshot:
##   * top left: Ren's helmet portrait and a segmented, skewed health bar. Lost segments flash
##     cream then drain (a "ghost" trail); healed segments glow in; the bar pulses at two or
##     fewer segments. Biscuits sit underneath. The panel shakes on a hit.
##   * top right: objective plaque with a brass diamond. A new objective strikes the old one
##     through, then slides in.
##   * bottom right: context prompt with a button glyph that follows the last input device
##     (keyboard letter, or the controller face button).
##   * top centre: boss name and the governor's service tabs; a knocked-out tab flashes and drops.
##   * In safe rooms (combat off) the health panel fades back after a few quiet seconds and
##     returns the moment anything changes.
##
## API: set_health(hp, max), set_biscuits(n), set_objective(text), show_prompt(action, text),
##      hide_prompt(), set_boss(name, tabs_left, tabs_max), clear_boss(), set_combat(on)

const CREAM := Color("efe3c8")
const RED := Color("c0352c")
const PLUM := Color("5b2a4a")
const BRASS := Color("c9a14e")
const INK := Color("17121a")
const GREEN := Color("3fb07a")

## Keyboard key and controller glyph for each prompt action.
const GLYPHS := {
	"interact": ["E", "triangle"], "guard": ["K", "square"], "attack": ["J", "cross"],
	"retreat": ["R", "circle"], "assist": ["T", "T"], "help": ["H", "H"], "go": ["W", "stick"],
}

var max_hp := 6
var hp := 6
var ghost_hp := 6.0          # drains toward hp after a short delay
var ghost_delay := 0.0
var biscuits := 2
var hurt_t := 0.0
var heal_t := 0.0
var quiet_t := 0.0
var combat := true
var panel_alpha := 1.0

var objective := ""
var objective_next := ""
var objective_in := 1.0      # 0 → 1 slide-in progress
var objective_out := 0.0     # > 0 while the old objective is shown struck through

var prompt_action := ""
var prompt_text := ""
var prompt_amount := 0.0     # 0 hidden → 1 shown (pop)

var boss_name := ""
var boss_tabs := 0
var boss_max := 3
var boss_amount := 0.0
var boss_hit_t := 0.0

var gamepad := false
var time := 0.0
var _c: Control
var _font: Font


func _ready() -> void:
	_c = Control.new()
	_c.set_anchors_preset(Control.PRESET_FULL_RECT)
	_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_c)
	_c.draw.connect(_draw_all)
	_font = ThemeDB.fallback_font


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.4):
		gamepad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		gamepad = false


# ---------------------------------------------------------------- API

func set_health(value: int, maximum := 6) -> void:
	if value < hp:
		hurt_t = 0.55
		ghost_delay = 0.45
	elif value > hp:
		heal_t = 0.7
		ghost_hp = value
	hp = value
	max_hp = maximum
	quiet_t = 0.0


func set_biscuits(n: int) -> void:
	if n != biscuits:
		quiet_t = 0.0
	biscuits = n


func set_objective(text: String) -> void:
	if text == objective or text == objective_next:
		return
	if objective == "":
		objective = text
		objective_in = 0.0
	else:
		objective_next = text
		objective_out = 1.1


func show_prompt(action: String, text: String) -> void:
	if text == "":
		hide_prompt()
		return
	if text != prompt_text:
		prompt_amount = minf(prompt_amount, 0.6)  # re-pop on change
	prompt_action = action
	prompt_text = text


func hide_prompt() -> void:
	prompt_text = ""


func set_boss(name: String, tabs_left: int, tabs_max := 3) -> void:
	if name == boss_name and tabs_left < boss_tabs:
		boss_hit_t = 0.8
	boss_name = name
	boss_tabs = tabs_left
	boss_max = tabs_max


func clear_boss() -> void:
	boss_name = ""


func set_combat(on: bool) -> void:
	combat = on
	quiet_t = 0.0


# ---------------------------------------------------------------- animation

func _process(delta: float) -> void:
	time += delta
	hurt_t = maxf(0.0, hurt_t - delta)
	heal_t = maxf(0.0, heal_t - delta)
	boss_hit_t = maxf(0.0, boss_hit_t - delta)
	quiet_t += delta
	if ghost_delay > 0.0:
		ghost_delay -= delta
	else:
		ghost_hp = move_toward(ghost_hp, hp, delta * 2.5)
	var want := 1.0 if (combat or quiet_t < 4.0 or hp <= 2) else 0.35
	panel_alpha = lerpf(panel_alpha, want, 1.0 - exp(-4.0 * delta))
	objective_in = minf(1.0, objective_in + delta * 2.2)
	if objective_out > 0.0:
		objective_out -= delta
		if objective_out <= 0.0:
			objective = objective_next
			objective_next = ""
			objective_in = 0.0
	prompt_amount = move_toward(prompt_amount, 1.0 if prompt_text != "" else 0.0, delta * 6.0)
	boss_amount = move_toward(boss_amount, 1.0 if boss_name != "" else 0.0, delta * 2.0)
	_c.queue_redraw()


# ---------------------------------------------------------------- drawing

func _draw_all() -> void:
	var size := _c.size
	var s := clampf(size.y / 720.0, 0.7, 1.8)
	_draw_health(s)
	if objective != "":
		_draw_objective(size, s)
	if prompt_amount > 0.01:
		_draw_prompt(size, s)
	if boss_amount > 0.01:
		_draw_boss(size, s)


func _text(pos: Vector2, text: String, font_size: float, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	_c.draw_string(_font, pos + Vector2(0, 2), text, align, width, int(font_size), Color(0, 0, 0, color.a * 0.6))
	_c.draw_string(_font, pos, text, align, width, int(font_size), color)


func _text_width(text: String, font_size: float) -> float:
	return _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(font_size)).x


func _skewed(x: float, y: float, w: float, h: float, skew: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x + skew, y), Vector2(x + w + skew, y), Vector2(x + w, y + h), Vector2(x, y + h)])


func _draw_health(s: float) -> void:
	var a := panel_alpha
	var shake := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * hurt_t * 9.0 * s
	var c := Vector2(54, 54) * s + shake
	# Portrait: Ren's red helmet with the sweeping black visor, silver ridge and cream chin plate.
	_c.draw_circle(c, 34 * s, Color(INK, 0.9 * a))
	_c.draw_circle(c, 30 * s, Color(RED.lerp(CREAM, hurt_t), a))
	_c.draw_colored_polygon(PackedVector2Array([c + Vector2(-26, -2) * s, c + Vector2(26, -2) * s, c + Vector2(20, 12) * s,
		c + Vector2(-20, 12) * s]), Color(INK, a))
	_c.draw_rect(Rect2(c + Vector2(-2, -26) * s, Vector2(4, 24) * s), Color("b8bec4", a))
	_c.draw_rect(Rect2(c + Vector2(-9, 15) * s, Vector2(18, 8) * s), Color(CREAM, a))
	_c.draw_arc(c, 34 * s, 0, TAU, 48, Color(BRASS, a), 3 * s)
	# Bar plate.
	var x0 := c.x + 44 * s
	var y0 := c.y - 16 * s
	var seg_w := 30 * s
	var seg_h := 18 * s
	var gap := 5 * s
	var skew := 7 * s
	var plate_w := max_hp * (seg_w + gap) + 18 * s
	_c.draw_colored_polygon(_skewed(x0 - 8 * s, y0 - 6 * s, plate_w, seg_h + 12 * s, skew), Color(INK, 0.75 * a))
	_text(Vector2(x0, y0 - 10 * s), "REN", 12 * s, Color(BRASS, a))
	var low := hp <= 2
	var pulse := 0.5 + 0.5 * sin(time * 8.0)
	for i in max_hp:
		var x := x0 + i * (seg_w + gap)
		var poly := _skewed(x, y0, seg_w, seg_h, skew)
		var col: Color
		if i < hp:
			col = RED.lerp(Color("ff6a50"), pulse * 0.6) if low else RED
			if heal_t > 0.0 and i >= hp - 2:
				col = col.lerp(CREAM, heal_t)
		elif i < ceili(ghost_hp):
			col = CREAM.lerp(RED, 1.0 - clampf(ghost_hp - i, 0.0, 1.0))
		else:
			col = Color("2a2024")
		_c.draw_colored_polygon(poly, Color(col, a))
		var outline := poly.duplicate()
		outline.append(poly[0])
		_c.draw_polyline(outline, Color(CREAM, 0.35 * a), 1.2 * s)
	# Biscuits: red tins with cream paper sleeves.
	for i in biscuits:
		var bx := x0 + i * 26 * s
		var by := y0 + seg_h + 12 * s
		_c.draw_rect(Rect2(Vector2(bx, by), Vector2(20, 13) * s), Color(RED, a))
		_c.draw_rect(Rect2(Vector2(bx, by), Vector2(20, 5) * s), Color(CREAM, a))


func _draw_objective(size: Vector2, s: float) -> void:
	var font_size := 18 * s
	var w := _text_width(objective, font_size) + 64 * s
	var ease_in := 1.0 - pow(1.0 - objective_in, 3.0)
	var x := size.x - 24 * s - w + (1.0 - ease_in) * (w + 40 * s)
	var y := 24 * s
	var h := 40 * s
	var done := objective_out > 0.0
	var flash := clampf((objective_in < 0.4 and not done) as int * (0.4 - objective_in) * 2.5, 0.0, 1.0)
	_c.draw_rect(Rect2(x, y, w, h), Color(CREAM.lerp(BRASS, flash), 0.93))
	_c.draw_rect(Rect2(x, y, w, h), Color(BRASS, 1.0), false, 2 * s)
	var d := Vector2(x + 24 * s, y + h / 2.0)
	var r := 8 * s
	_c.draw_colored_polygon(PackedVector2Array([d + Vector2(0, -r), d + Vector2(r, 0), d + Vector2(0, r), d + Vector2(-r, 0)]),
		GREEN if done else PLUM)
	var ink := Color(INK, 0.45 if done else 1.0)
	_c.draw_string(_font, Vector2(x + 44 * s, y + h / 2.0 + font_size * 0.35), objective, HORIZONTAL_ALIGNMENT_LEFT, -1, int(font_size), ink)
	if done:
		var k := clampf((1.1 - objective_out) * 3.0, 0.0, 1.0)
		var tw := _text_width(objective, font_size)
		_c.draw_line(Vector2(x + 42 * s, y + h / 2.0), Vector2(x + 42 * s + tw * k, y + h / 2.0), Color(PLUM, 0.9), 2 * s)


func _draw_prompt(size: Vector2, s: float) -> void:
	var k := prompt_amount
	var pop := 1.0 + 0.12 * sin(k * PI)
	var font_size := 20 * s * pop
	var text := prompt_text
	var w := _text_width(text, font_size) + 80 * s
	var h := 50 * s * pop
	var x := size.x - 28 * s - w
	var y := size.y - 120 * s - h + (1.0 - k) * 20 * s
	var a := k
	_c.draw_rect(Rect2(x, y, w, h), Color(INK, 0.82 * a))
	_c.draw_rect(Rect2(x, y, w, h), Color(BRASS, a), false, 2 * s)
	var g := Vector2(x + 28 * s, y + h / 2.0)
	_c.draw_circle(g, 17 * s, Color(INK, a))
	_c.draw_arc(g, 17 * s, 0, TAU, 32, Color(CREAM, 0.8 * a), 1.5 * s)
	var glyph: Array = GLYPHS.get(prompt_action, ["", ""])
	if gamepad and glyph[1] == "triangle":
		_c.draw_polyline(PackedVector2Array([g + Vector2(0, -9) * s, g + Vector2(8, 6) * s, g + Vector2(-8, 6) * s, g + Vector2(0, -9) * s]),
			Color(GREEN, a), 2.5 * s)
	elif gamepad and glyph[1] == "square":
		_c.draw_rect(Rect2(g - Vector2(7, 7) * s, Vector2(14, 14) * s), Color("d877c6", a), false, 2.5 * s)
	elif gamepad and glyph[1] == "cross":
		_c.draw_line(g + Vector2(-7, -7) * s, g + Vector2(7, 7) * s, Color("7aa7ff", a), 2.5 * s)
		_c.draw_line(g + Vector2(7, -7) * s, g + Vector2(-7, 7) * s, Color("7aa7ff", a), 2.5 * s)
	elif gamepad and glyph[1] == "circle":
		_c.draw_arc(g, 7 * s, 0, TAU, 24, Color("ff6a6a", a), 2.5 * s)
	else:
		var key: String = glyph[0] if glyph[0] != "" else "•"
		_c.draw_string(_font, g + Vector2(-_text_width(key, 18 * s) / 2.0, 6.5 * s), key, HORIZONTAL_ALIGNMENT_LEFT, -1, int(18 * s), Color(CREAM, a))
	_c.draw_string(_font, Vector2(x + 56 * s, y + h / 2.0 + font_size * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(font_size), Color(CREAM, a))


func _draw_boss(size: Vector2, s: float) -> void:
	var a := boss_amount
	var cx := size.x / 2.0
	var y := 26 * s - (1.0 - a) * 30 * s
	var name_size := 16 * s
	_text(Vector2(cx - 200 * s, y + name_size), boss_name, name_size, Color(CREAM, a), HORIZONTAL_ALIGNMENT_CENTER, 400 * s)
	_c.draw_line(Vector2(cx - 140 * s, y + name_size + 8 * s), Vector2(cx + 140 * s, y + name_size + 8 * s), Color(BRASS, a), 1.5 * s)
	var tab_w := 20 * s
	var tab_h := 28 * s
	var total := boss_max * tab_w + (boss_max - 1) * 10 * s
	for i in boss_max:
		var tx := cx - total / 2.0 + i * (tab_w + 10 * s)
		var ty := y + name_size + 16 * s
		var gone := i >= boss_tabs
		var just_lost := gone and i == boss_tabs and boss_hit_t > 0.0
		if just_lost:
			ty += (0.8 - boss_hit_t) * 40 * s
			_c.draw_rect(Rect2(tx, ty, tab_w, tab_h), Color(CREAM, a * boss_hit_t / 0.8))
		elif gone:
			_c.draw_rect(Rect2(tx, ty, tab_w, tab_h), Color(BRASS, 0.5 * a), false, 1.5 * s)
		else:
			_c.draw_rect(Rect2(tx, ty, tab_w, tab_h), Color(BRASS, a))
			_c.draw_rect(Rect2(tx, ty, tab_w, 6 * s), Color("f3dca0", a))
