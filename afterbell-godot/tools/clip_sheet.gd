extends SceneTree
## Renders each great-sword mocap clip retargeted onto a supplied staff figure: six frames per
## clip, front three-quarter view, one PNG per clip. For choosing and checking the guards' clips.
##   godot --path afterbell-godot -s res://tools/clip_sheet.gd -- --out=/tmp/clips --model=clerk_plum

const Imported := preload("res://scripts/imported_assets.gd")
const Retarget := preload("res://scripts/mocap_retarget.gd")
const ST := preload("res://scripts/style.gd")
const CLIPS := ["great_sword_idle", "great_sword_idle_2", "great_sword_walk", "great_sword_strafe", "great_sword_run",
	"great_sword_slash", "great_sword_slash_2", "great_sword_attack", "great_sword_impact", "great_sword_impact_2",
	"great_sword_blocking", "great_sword_casting", "great_sword_power_up", "draw_a_great_sword_1", "great_sword_kick",
	"two_handed_sword_death"]
const FRAMES := 6

var out_dir := "user://clips"
var model := "clerk_plum"
var rt: RefCounted
var clip_i := 0
var frame_i := 0
var wait := 0
var cam: Camera3D


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--model="):
			model = arg.substr(8)
	DirAccess.make_dir_recursive_absolute(out_dir)
	root.size = Vector2i(480, 640)
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = ST.environment()
	w.add_child(env)
	w.add_child(ST.sun())
	var fl := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(10, 10)
	fl.mesh = pm
	fl.material_override = ST.plastic(Color("2c5650"), 0.9, 0.0)
	w.add_child(fl)
	var fig: Node3D = Imported.make(model)
	w.add_child(fig)
	var clips := {}
	for c in CLIPS:
		clips[c] = [c, true]
	rt = Retarget.new(fig, "npc10" if model == "clerk_plum" else "npc12", clips, w)
	cam = Camera3D.new()
	cam.fov = 40
	w.add_child(cam)
	cam.look_at_from_position(Vector3(1.4, 1.3, 3.4), Vector3(0, 0.9, 0), Vector3.UP)
	var fill := OmniLight3D.new()
	fill.position = Vector3(1.5, 2.5, 2.5)
	fill.light_energy = 2.0
	fill.omni_range = 8.0
	w.add_child(fill)
	_start()


func _start() -> void:
	rt.play(CLIPS[clip_i], 0.0)
	frame_i = 0
	_seek()


func _seek() -> void:
	var length: float = rt.length(CLIPS[clip_i])
	rt.player.seek(length * frame_i / float(FRAMES), true)
	rt.update(0.0)
	wait = 4


func _process(_d: float) -> bool:
	wait -= 1
	if wait > 0:
		return false
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join("%s_%d.png" % [CLIPS[clip_i], frame_i]))
	frame_i += 1
	if frame_i >= FRAMES:
		clip_i += 1
		if clip_i >= CLIPS.size():
			quit()
			return true
		_start()
	else:
		_seek()
	return false
