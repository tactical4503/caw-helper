extends SceneTree
## Films Ren's standing idle from the front, side and back at evenly spaced moments of its cycle,
## on a plain floor under the game's lighting, for judging balance and weight.
##   godot --path afterbell-godot -s res://tools/ren_idle_shots.gd -- --out=/tmp/idle [--capture=great_sword_idle]
## --capture= picks the captured idle ("none" for the keyframed one).

const ST := preload("res://scripts/style.gd")
const Props := preload("res://scripts/props.gd")
const VIEWS := {"front": Vector3(0.3, 1.2, 3.2), "side": Vector3(3.2, 1.2, 0.2), "back": Vector3(-0.4, 1.3, -3.2)}
const TIMES := [0.4, 1.2, 2.0, 2.8, 3.6]

var out_dir := "user://idle"
var capture := "great_sword_idle_2"
var ren: Node3D
var cam: Camera3D
var shots := []
var i := 0
var t := 0.0
var wait := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--capture="):
			capture = arg.substr(10)
			if capture == "none":
				capture = ""
	DirAccess.make_dir_recursive_absolute(out_dir)
	root.size = Vector2i(640, 800)
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	w.add_child(env)
	w.add_child(ST.sun())
	var fl := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(12, 12)
	fl.mesh = pm
	fl.material_override = ST.plastic(Color("3c5a55"), 0.9, 0.0)
	w.add_child(fl)
	ren = load("res://rigs/ren.tscn").instantiate()
	ren.get_node("SkinDriver").idle_capture = capture
	w.add_child(ren)
	Props.actor_shadow(ren, Vector2(1.0, 0.85))
	var key := Props.actor_light(w, ren)
	key.position = Vector3(1.2, 2.6, 2.4)
	cam = Camera3D.new()
	cam.fov = 38
	w.add_child(cam)
	(ren.get_node("AnimationPlayer") as AnimationPlayer).play("idle")
	for v in VIEWS:
		for tt in TIMES:
			shots.append([v, tt])


func _process(dt: float) -> bool:
	t += 1.0 / 30.0
	if i >= shots.size():
		quit()
		return true
	var s: Array = shots[i]
	cam.look_at_from_position(VIEWS[s[0]], Vector3(0, 0.95, 0), Vector3.UP)
	if t >= float(s[1]) + (TIMES[-1] + 0.5) * (i / TIMES.size()):
		wait += 1
		if wait > 2:
			root.get_texture().get_image().save_png(out_dir.path_join("%s_%d.png" % [s[0], i % TIMES.size()]))
			i += 1
			wait = 0
	return false
