extends Node3D
## The title screen: the real atrium and the Floor Manager's court, empty and quiet at sunset,
## with the camera drifting slowly up the aisle toward the bell on the mezzanine.
## New game / Continue / Controls / Settings / Quit, in the store's cream-and-plum.

const B := preload("res://scripts/builders.gd")
const GameShell := preload("res://scripts/game.gd")

var camera: Camera3D
var time := 0.0
var _continue: Button


func _ready() -> void:
	B.build_arena(self)
	camera = Camera3D.new()
	camera.fov = 52.0
	add_child(camera)
	camera.current = true
	_place_camera(0.0)
	_build_menu()
	add_child(load("res://scripts/fade.gd").new())


func _process(delta: float) -> void:
	time += delta
	_place_camera(time)


## A slow push up the aisle with a gentle sway, always holding the bell in frame.
func _place_camera(t: float) -> void:
	var k := fmod(t, 60.0) / 60.0
	var z := lerpf(7.5, 1.0, 0.5 - 0.5 * cos(k * TAU))
	camera.position = Vector3(sin(t * 0.07) * 1.6, 2.1 + sin(t * 0.05) * 0.25, z)
	camera.look_at(Vector3(sin(t * 0.07) * 0.4, 5.6, -19.8), Vector3.UP)


func _game() -> Node:
	return get_node_or_null("/root/Game")


func _build_menu() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var shade := TextureRect.new()   # a soft plum gradient behind the menu side of the frame
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	g.colors = PackedColorArray([Color(0.12, 0.05, 0.09, 0.9), Color(0.12, 0.05, 0.09, 0.55), Color(0.12, 0.05, 0.09, 0.0)])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 256
	tex.height = 4
	shade.texture = tex
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	shade.offset_right = 760
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(shade)
	var col := VBoxContainer.new()
	col.position = Vector2(84, 250)
	col.add_theme_constant_override("separation", 10)
	layer.add_child(col)
	col.add_child(GameShell.label("BELLWETHER'S DEPARTMENT STORE", 16, GameShell.BRASS))
	col.add_child(GameShell.label("AFTERBELL", 92, GameShell.IVORY, true))
	col.add_child(GameShell.label("Chapter One  ·  Closing Time", 26, GameShell.CREAM, true))
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 28)
	col.add_child(gap)
	var game := _game()
	var buttons := []
	if game and game.has_save() and game.checkpoint != game.FIRST_ROOM:
		_continue = _entry("Continue", func() -> void: game.continue_game())
		buttons.append(_continue)
	buttons.append(_entry("New game", func() -> void:
		if game: game.new_game()
		else: get_tree().change_scene_to_file("res://rooms/cosmetics.tscn")))
	buttons.append(_entry("Controls", func() -> void: if game: game.show_controls()))
	buttons.append(_entry("Settings", func() -> void: if game: game.show_settings()))
	buttons.append(_entry("Quit", func() -> void: get_tree().quit()))
	for b in buttons:
		b.custom_minimum_size = Vector2(340, 0)
		col.add_child(b)
	buttons[0].grab_focus.call_deferred()
	var foot := GameShell.label("Move WASD  ·  Attack J  ·  Guard K  ·  Examine E  ·  Pause Esc", 19, Color(GameShell.IVORY, 0.82))
	foot.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	foot.offset_left = 84
	foot.offset_top = -64
	layer.add_child(foot)


func _entry(text: String, action: Callable) -> Button:
	var b := GameShell.button(text)
	var game := _game()
	b.pressed.connect(func() -> void:
		if game: game._click()
		action.call())
	if game:
		b.focus_entered.connect(game._tick)
	b.mouse_entered.connect(b.grab_focus)
	return b
