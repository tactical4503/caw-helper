extends CanvasLayer
## Black fade between rooms. Each room adds one: it fades in on arrival, and
## go_to(scene) fades out before changing scene.

const TIME := 0.45

var _rect: ColorRect
var _target := 1.0
var _alpha := 1.0
var _next := ""


func _ready() -> void:
	layer = 50
	_rect = ColorRect.new()
	_rect.color = Color(0.06, 0.04, 0.05, 1.0)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_target = 0.0


func go_to(scene: String) -> void:
	if Engine.has_meta("afterbell_testing"):
		return
	_next = scene
	_target = 1.0


func _process(delta: float) -> void:
	_alpha = move_toward(_alpha, _target, delta / TIME)
	_rect.color.a = _alpha
	_rect.visible = _alpha > 0.001
	if _next != "" and _alpha >= 1.0:
		var scene := _next
		_next = ""
		get_tree().change_scene_to_file(scene)
