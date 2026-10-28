extends Node
## The chapter shell, autoloaded as /root/Game: checkpoint save, settings and audio buses, the
## pause menu (Esc), room location cards, scene transitions and the chapter-end screen.
##
## Rooms reach it with get_node_or_null("/root/Game"), so headless tests and direct scene runs
## work without it. A checkpoint is the room the player last entered; Continue and
## "Restart from checkpoint" re-enter that room from its door.

const SAVE_PATH := "user://afterbell_save.json"
var save_path := SAVE_PATH   # tests point this elsewhere
const TITLE := "res://rooms/title.tscn"
const FIRST_ROOM := "res://rooms/cosmetics.tscn"
const COURT := "res://main.tscn"

const CREAM := Color("eee6d4")
const IVORY := Color("f4ecdc")
const PLUM := Color("4e1f3a")
const PLUM_DEEP := Color("2a1220")
const BRASS := Color("c9a86a")
const INK := Color("3a1c2c")
const DISPLAY := preload("res://assets/fonts/LiberationSerif-Bold.ttf")

const CONTROLS := [
	["Move", "W A S D  /  arrow keys"],
	["Attack", "J  or left click  —  hold to wind a heavy strike (three clicks)"],
	["Guard", "K  or right click  —  tap as a sign arrives to send it back"],
	["Dodge", "Space"],
	["Examine / talk / biscuit", "E"],
	["Reflection assist", "T  (a held guard always reflects)"],
	["Ask Mika for help", "H  (after a few misses in Cosmetics)"],
	["Retreat", "R  by the court's west door"],
	["Pause", "Esc"],
]

var checkpoint := ""
var flags := {}
var settings := {"master": 0.85, "effects": 0.9, "ambience": 0.7, "easy": false,
		"reflect_assist": false, "aim_help": true, "shake": true, "keep_progress": true, "quality": 1}

## Graphics presets (settings.quality): [name, render scale, MSAA, SSAO, half-size SSAO, glow,
## directional shadow map size, shadow filter]. Low upscales from 75% with FSR and drops the
## screen-space effects; Medium keeps the look at about half the cost of High.
const QUALITY := [
	["Low", 0.75, Viewport.MSAA_DISABLED, false, true, false, 1024, RenderingServer.SHADOW_QUALITY_HARD],
	["Medium", 1.0, Viewport.MSAA_DISABLED, true, true, true, 2048, RenderingServer.SHADOW_QUALITY_SOFT_LOW],
	["High", 1.0, Viewport.MSAA_2X, true, false, true, 4096, RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM],
]

var _layer: CanvasLayer
var _shade: ColorRect
var _card_panel: PanelContainer
var _card_col: VBoxContainer
var _location: Label
var _location_t := 0.0
var _fade: ColorRect
var _fade_to := ""
var _fade_a := 0.0
var _mode := ""            # "", "pause", "end"
var _toast: Label
var _toast_t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	load_game()
	_apply_volumes()
	_build_ui()
	apply_quality()
	get_tree().node_added.connect(_on_node_added)


## Applies the graphics preset to the window and to whichever room is loaded (rooms make their
## own WorldEnvironment, so it is re-applied as each one arrives).
func apply_quality() -> void:
	var q: Array = QUALITY[clampi(int(settings.quality), 0, QUALITY.size() - 1)]
	var vp := get_viewport()
	vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if q[1] < 1.0 else Viewport.SCALING_3D_MODE_BILINEAR
	vp.scaling_3d_scale = q[1]
	vp.msaa_3d = q[2]
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if q[2] == Viewport.MSAA_DISABLED else Viewport.SCREEN_SPACE_AA_DISABLED
	RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW if q[4] else RenderingServer.ENV_SSAO_QUALITY_MEDIUM,
		q[4], 0.5, 2, 50.0, 300.0)
	RenderingServer.directional_shadow_atlas_set_size(q[6], true)
	RenderingServer.directional_soft_shadow_filter_set_quality(q[7])
	RenderingServer.positional_soft_shadow_filter_set_quality(q[7])
	for env in get_tree().root.find_children("*", "WorldEnvironment", true, false):
		_quality_env(env)


func _quality_env(we: WorldEnvironment) -> void:
	var q: Array = QUALITY[clampi(int(settings.quality), 0, QUALITY.size() - 1)]
	if we.environment:
		we.environment.ssao_enabled = q[3]
		we.environment.glow_enabled = q[5]


func _on_node_added(n: Node) -> void:
	if n is WorldEnvironment:
		_quality_env.call_deferred(n)


func testing() -> bool:
	return Engine.has_meta("afterbell_testing")


# ---------------------------------------------------------------- save and flow

func has_save() -> bool:
	return checkpoint != "" and ResourceLoader.exists(checkpoint)


func save_game() -> void:
	if testing():
		return
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"checkpoint": checkpoint, "flags": flags, "settings": settings}, "\t"))


func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if typeof(data) != TYPE_DICTIONARY:
		return
	checkpoint = str(data.get("checkpoint", ""))
	flags = data.get("flags", {}) if typeof(data.get("flags")) == TYPE_DICTIONARY else {}
	var s = data.get("settings", {})
	if typeof(s) == TYPE_DICTIONARY:
		for k in s:
			if settings.has(k) and typeof(s[k]) == typeof(settings[k]):
				settings[k] = s[k]


func new_game() -> void:
	flags = {}
	checkpoint = FIRST_ROOM
	save_game()
	goto(FIRST_ROOM)


func continue_game() -> void:
	goto(checkpoint if has_save() else FIRST_ROOM)


## Called by every room on arrival: records the checkpoint and shows the room's name.
func enter_room(path: String, place: String) -> void:
	checkpoint = path
	save_game()
	if place != "":
		_location.text = place
		_location_t = 4.0


func set_flag(key: String, value = true) -> void:
	flags[key] = value
	save_game()


func flag(key: String, default = false):
	return flags.get(key, default)


## Fades to black and changes scene; rooms fade themselves back in.
func goto(path: String) -> void:
	get_tree().paused = false
	_close()
	if testing():
		return
	_fade_to = path


func quit_to_title() -> void:
	goto(TITLE)


func restart_checkpoint() -> void:
	goto(checkpoint if has_save() else FIRST_ROOM)


## A short line at the top of the screen (errand complete, item received...).
func toast(text: String) -> void:
	_toast.text = text
	_toast_t = 3.2


# ---------------------------------------------------------------- audio

func _setup_buses() -> void:
	for bus in ["Effects", "Ambience"]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus)
			AudioServer.set_bus_send(i, "Master")


func _apply_volumes() -> void:
	for pair in [["Master", "master"], ["Effects", "effects"], ["Ambience", "ambience"]]:
		var i := AudioServer.get_bus_index(pair[0])
		if i >= 0:
			var v: float = settings[pair[1]]
			AudioServer.set_bus_volume_db(i, linear_to_db(maxf(v, 0.0001)))
			AudioServer.set_bus_mute(i, v <= 0.001)


# ---------------------------------------------------------------- input

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key: int = event.physical_keycode
	if key != KEY_ESCAPE and key != KEY_P:
		return
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path == TITLE or _mode == "end":
		if _mode == "panel" and key == KEY_ESCAPE:
			_close()
			get_viewport().set_input_as_handled()
		return
	if _mode == "":
		open_pause()
	else:
		_close()
	get_viewport().set_input_as_handled()


# ---------------------------------------------------------------- UI

func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 80
	add_child(_layer)
	_shade = ColorRect.new()
	_shade.color = Color(0.08, 0.04, 0.06, 0.72)
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.visible = false
	_layer.add_child(_shade)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.add_child(center)
	_card_panel = PanelContainer.new()
	_card_panel.add_theme_stylebox_override("panel", card_style())
	_card_panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(_card_panel)
	_card_col = VBoxContainer.new()
	_card_col.add_theme_constant_override("separation", 12)
	_card_panel.add_child(_card_col)

	_location = label("", 40, IVORY, true)
	_location.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_location.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_location.offset_left = -400
	_location.offset_right = 400
	_location.offset_top = 120
	_location.modulate.a = 0.0
	_layer.add_child(_location)
	_toast = label("", 20, BRASS, true)
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.offset_left = -400
	_toast.offset_right = 400
	_toast.offset_top = 176
	_toast.modulate.a = 0.0
	_layer.add_child(_toast)
	_fade = ColorRect.new()
	_fade.color = Color(0.06, 0.04, 0.05, 0.0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_fade)


func _process(delta: float) -> void:
	_location_t = maxf(0.0, _location_t - delta)
	_location.modulate.a = clampf(minf(_location_t, 4.0 - _location_t) * 1.6, 0.0, 1.0) if _location_t > 0.0 else 0.0
	_toast_t = maxf(0.0, _toast_t - delta)
	_toast.modulate.a = clampf(minf(_toast_t, 3.2 - _toast_t) * 2.0, 0.0, 1.0) if _toast_t > 0.0 else 0.0
	if _fade_to != "":
		_fade_a = minf(1.0, _fade_a + delta / 0.45)
		_fade.color.a = _fade_a
		if _fade_a >= 1.0:
			var path := _fade_to
			_fade_to = ""
			get_tree().change_scene_to_file(path)
	elif _fade_a > 0.0:
		_fade_a = maxf(0.0, _fade_a - delta / 0.45)
		_fade.color.a = _fade_a


func _clear_card() -> void:
	for c in _card_col.get_children():
		c.queue_free()


func _close() -> void:
	_mode = ""
	_shade.visible = false
	if is_inside_tree():
		get_tree().paused = false


func open_pause() -> void:
	_mode = "pause"
	get_tree().paused = true
	_clear_card()
	_card_col.add_child(label("PAUSED", 14, BRASS))
	_card_col.add_child(label("Closing Time", 40, IVORY, true))
	var first := _menu_button("Resume", _close)
	_card_col.add_child(first)
	_card_col.add_child(_menu_button("Controls", func() -> void: show_controls(true)))
	_card_col.add_child(_menu_button("Settings", func() -> void: show_settings(true)))
	_card_col.add_child(_menu_button("Restart from checkpoint", restart_checkpoint))
	_card_col.add_child(_menu_button("Quit to title", quit_to_title))
	_shade.visible = true
	first.grab_focus.call_deferred()


## The controls card; `from_pause` returns to the pause menu, otherwise just closes.
func show_controls(from_pause := false) -> void:
	_mode = "pause" if from_pause else "panel"
	_clear_card()
	_card_col.add_child(label("CONTROLS", 14, BRASS))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 8)
	for row in CONTROLS:
		grid.add_child(label(row[0], 18, BRASS))
		var v := label(row[1], 18, IVORY)
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.custom_minimum_size = Vector2(420, 0)
		grid.add_child(v)
	_card_col.add_child(grid)
	var back := _menu_button("Back", open_pause if from_pause else _close)
	_card_col.add_child(back)
	_shade.visible = true
	back.grab_focus.call_deferred()


func show_settings(from_pause := false) -> void:
	_mode = "pause" if from_pause else "panel"
	_clear_card()
	_card_col.add_child(label("SETTINGS", 14, BRASS))
	for pair in [["Master volume", "master"], ["Effects", "effects"], ["Store ambience", "ambience"]]:
		var row := HBoxContainer.new()
		var caption := label(pair[0], 18, IVORY)
		caption.custom_minimum_size = Vector2(200, 0)
		row.add_child(caption)
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = settings[pair[1]]
		slider.custom_minimum_size = Vector2(300, 28)
		var key: String = pair[1]
		slider.value_changed.connect(func(v: float) -> void:
			settings[key] = v
			_apply_volumes()
			save_game())
		row.add_child(slider)
		_card_col.add_child(row)
	var gfx := HBoxContainer.new()
	var gcap := label("Graphics", 18, IVORY)
	gcap.custom_minimum_size = Vector2(200, 0)
	gfx.add_child(gcap)
	for k in QUALITY.size():
		var b := _menu_button(QUALITY[k][0], func() -> void:
			settings.quality = k
			apply_quality()
			save_game()
			show_settings(from_pause))
		b.custom_minimum_size = Vector2(96, 0)
		if k == int(settings.quality):
			b.text = "• " + QUALITY[k][0]
		gfx.add_child(b)
	_card_col.add_child(gfx)
	for opt in [["reflect_assist", "Reflection assist — a held guard always reflects"],
			["easy", "Easy assist — longer openings in the court"],
			["aim_help", "Aiming help — floor arrow while the Manager is exposed"],
			["keep_progress", "Keep the court's progress after a defeat"],
			["shake", "Camera shake"]]:
		var cb := CheckBox.new()
		cb.text = opt[1]
		cb.button_pressed = settings[opt[0]]
		cb.add_theme_font_size_override("font_size", 17)
		cb.add_theme_color_override("font_color", IVORY)
		cb.add_theme_color_override("font_hover_color", CREAM)
		cb.add_theme_color_override("font_pressed_color", IVORY)
		cb.add_theme_icon_override("unchecked", _check_icon(false))   # brass boxes that read on plum
		cb.add_theme_icon_override("checked", _check_icon(true))
		var key: String = opt[0]
		cb.toggled.connect(func(on: bool) -> void:
			settings[key] = on
			save_game())
		_card_col.add_child(cb)
	var back := _menu_button("Back", open_pause if from_pause else _close)
	_card_col.add_child(back)
	_shade.visible = true
	back.grab_focus.call_deferred()


## The chapter's last screen: what was achieved, what Ren carries home, and the way out.
func chapter_complete(lines: Array) -> void:
	_mode = "end"
	set_flag("chapter_one_complete")
	_clear_card()
	_card_col.add_child(label("CHAPTER ONE  ·  COMPLETE", 14, BRASS))
	_card_col.add_child(label("Closing Time", 46, IVORY, true))
	for l in lines:
		var t := label(l, 17, IVORY)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.custom_minimum_size = Vector2(520, 0)
		_card_col.add_child(t)
	var title := _menu_button("Return to the title", quit_to_title)
	_card_col.add_child(title)
	_card_col.add_child(_menu_button("Face the Floor Manager again", func() -> void: goto(COURT)))
	_shade.visible = true
	title.grab_focus.call_deferred()


# ---------------------------------------------------------------- shared style

static var _check_icons := {}


## A settings checkbox drawn in the store's colours: a brass-edged box, filled with a cream tick
## on brass when on (the default theme's grey box vanished on the plum card).
static func _check_icon(on: bool) -> ImageTexture:
	if _check_icons.has(on):
		return _check_icons[on]
	var n := 22
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in n:
		for x in n:
			var edge := x < 2 or y < 2 or x >= n - 2 or y >= n - 2
			if edge:
				img.set_pixel(x, y, BRASS)
			elif on:
				img.set_pixel(x, y, Color(BRASS, 0.9))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0.35))
	if on:   # a tick: down to the lower left third, then up to the top right
		for t in 40:
			var k := t / 39.0
			var p := Vector2(5, 11).lerp(Vector2(9, 16), k) if k < 0.4 else Vector2(9, 16).lerp(Vector2(17, 6), (k - 0.4) / 0.6)
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					var q := Vector2i(int(p.x) + dx, int(p.y) + dy)
					if q.x >= 2 and q.y >= 2 and q.x < n - 2 and q.y < n - 2:
						img.set_pixel(q.x, q.y, CREAM)
	_check_icons[on] = ImageTexture.create_from_image(img)
	return _check_icons[on]

static func card_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(PLUM_DEEP, 0.96)
	s.border_color = Color(BRASS, 0.85)
	s.set_border_width_all(2)
	s.set_corner_radius_all(3)
	s.set_content_margin_all(30)
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 12
	return s


static func label(text: String, size: int, color := IVORY, display := false) -> Label:
	var l := Label.new()
	l.text = text
	if display:
		l.add_theme_font_override("font", DISPLAY)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l


## A cream-on-plum menu button with a brass edge; brass when focused or hovered.
static func button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", DISPLAY)
	b.add_theme_font_size_override("font_size", 22)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(PLUM, 0.9)
	normal.border_color = Color(BRASS, 0.5)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(2)
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hot := normal.duplicate()
	hot.bg_color = Color("6b2c50")
	hot.border_color = BRASS
	hot.border_width_left = 6
	var off := normal.duplicate()
	off.bg_color = Color(0.2, 0.12, 0.17, 0.8)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hot)
	b.add_theme_stylebox_override("focus", hot)
	b.add_theme_stylebox_override("pressed", hot)
	b.add_theme_stylebox_override("disabled", off)
	b.add_theme_color_override("font_color", IVORY)
	b.add_theme_color_override("font_hover_color", Color("fff6e6"))
	b.add_theme_color_override("font_focus_color", Color("fff6e6"))
	b.add_theme_color_override("font_disabled_color", Color(IVORY, 0.35))
	return b


func _menu_button(text: String, action: Callable) -> Button:
	var b := button(text)
	b.pressed.connect(func() -> void:
		_click()
		action.call())
	b.focus_entered.connect(_tick)
	return b


func _click() -> void:
	_ui_tone(660.0, 0.08)


func _tick() -> void:
	_ui_tone(1320.0, 0.03)


var _ui_player: AudioStreamPlayer


## A tiny UI blip (soft triangle), on the Effects bus; works while the tree is paused.
func _ui_tone(freq: float, dur: float) -> void:
	if testing():
		return
	if _ui_player == null:
		_ui_player = AudioStreamPlayer.new()
		_ui_player.bus = "Effects"
		_ui_player.volume_db = -14.0
		add_child(_ui_player)
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var ph := fmod(t * freq, 1.0)
		var v := (1.0 - 4.0 * absf(ph - 0.5)) * pow(1.0 - float(i) / n, 2.0) * 0.6
		data.encode_s16(i * 2, int(v * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	_ui_player.stream = wav
	_ui_player.play()
