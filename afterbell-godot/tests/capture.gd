extends SceneTree
## Renders staged moments of the fight to PNG for visual review.
## Needs a real renderer (not --headless). Example:
##   godot --path afterbell-godot --rendering-driver opengl3 -s res://tests/capture.gd -- --out=/tmp/shots
## Optional: --size=1280x720 (use 390x844 for a phone-portrait check).

const DT := 1.0 / 60.0
const SHOTS := ["approach", "present", "exposed", "launch", "victory"]
var main
var out_dir := "user://shots"
var _queue: Array = []
var _wait := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--size="):
			var wh := arg.substr(7).split("x")
			root.size = Vector2i(int(wh[0]), int(wh[1]))
	DirAccess.make_dir_recursive_absolute(out_dir)
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	_queue = SHOTS.duplicate()


func _process(_delta: float) -> bool:
	if _wait > 0:
		_wait -= 1
		if _wait == 0:
			var name: String = _queue.pop_front()
			var path := out_dir.path_join(name + ".png")
			root.get_texture().get_image().save_png(path)
			print("saved ", path)
		return false
	if _queue.is_empty():
		quit()
		return true
	_stage(_queue[0])
	_wait = 20  # let the camera and poses settle under real rendering
	return false


func _sim(steps: int) -> void:
	for i in steps:
		main.step(DT)


func _stage(shot: String) -> void:
	main.settings.reflect_assist = true
	main.settings.shake = false
	if main.mode == "title" or main.mode == "end":
		main.hud.end.visible = false
		main.mode = "title"
		main.start_game()
	main.virtual.clear()
	match shot:
		"approach":
			main.p_pos = Vector2(-3.0, 5.0)
			_sim(150)
		"present":
			main.p_pos = Vector2(0.4, 4.4)
			for i in 600:
				if main.m_state == "present" and main.m_t < 0.5:
					break
				main.step(DT)
		"exposed":
			main.p_pos = Vector2(0.3, 4.4)
			main.virtual["guard"] = true
			for i in 1800:
				if main.m_state == "exposed":
					break
				main.step(DT)
			main.virtual["guard"] = false
			main.p_pos = main.m_pos + Vector2(0.4, 1.7)
			main.virtual["attack"] = true
			_sim(55)  # mid-wind: arm back, ring lit
		"launch":
			main.virtual["attack"] = false
			_sim(14)
		"victory":
			main.bells = 2
			main.phase = 3
			main.p_pos = Vector2(0.3, 4.4)
			main.virtual["guard"] = true
			for i in 1800:
				if main.m_state == "exposed":
					break
				main.step(DT)
			main.virtual["guard"] = false
			main.p_pos = main.m_pos + Vector2(0.2, 1.6)
			main.virtual["attack"] = true
			_sim(56)
			main.virtual["attack"] = false
			for i in 1200:
				if main.m_state == "defeated":
					break
				main.step(DT)
			_sim(240)
