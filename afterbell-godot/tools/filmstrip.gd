extends SceneTree
## Renders animation clips as contact sheets: evenly spaced frames, front three-quarter row
## above a side-view row. Needs a renderer (not --headless). Examples:
##   godot --path afterbell-godot -s res://tools/filmstrip.gd -- --rig=boss --out=/tmp/sheets
##   godot --path afterbell-godot -s res://tools/filmstrip.gd -- --rig=ren --clips=run,wind,heavy --frames=10
## Each sheet is <out>/<rig>_<clip>.png.

const CELL := Vector2i(220, 260)
var rig_kind := "boss"
var out_dir := "user://sheets"
var frames := 8
var only: PackedStringArray = []

var view: SubViewport
var rig: Node3D
var player: AnimationPlayer
var cam: Camera3D
var caption: Label
var jobs: Array = []   # [clip, view, frame_index]
var sheet: Image
var wait := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		if kv.size() < 2:
			continue
		match kv[0]:
			"rig": rig_kind = kv[1]
			"out": out_dir = kv[1]
			"frames": frames = int(kv[1])
			"clips": only = kv[1].split(",")
	DirAccess.make_dir_recursive_absolute(out_dir)
	# Frames render into a fixed-size offscreen viewport, independent of the window.
	view = SubViewport.new()
	view.size = CELL
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.msaa_3d = Viewport.MSAA_4X
	root.add_child(view)
	var world := Node3D.new()
	view.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("2a1d26")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("8a7680")
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-50), deg_to_rad(-30), 0)
	sun.shadow_enabled = true
	world.add_child(sun)
	var floor_mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(8, 8)
	floor_mi.mesh = plane
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("2f4a3a")
	floor_mi.material_override = fm
	world.add_child(floor_mi)
	rig = load("res://rigs/floor_manager.tscn" if rig_kind == "boss" else "res://rigs/ren.tscn").instantiate()
	world.add_child(rig)
	player = rig.get_node("AnimationPlayer")
	cam = Camera3D.new()
	cam.fov = 40
	world.add_child(cam)
	cam.current = true
	caption = Label.new()
	caption.position = Vector2(6, 4)
	caption.add_theme_font_size_override("font_size", 13)
	view.add_child(caption)

	var row := 0
	for clip in player.get_animation_list():
		if only.size() and not only.has(clip):
			continue
		for v in ["front", "side"]:
			for f in frames:
				jobs.append([clip, v, f, row])
			row += 1
	sheet = Image.create(CELL.x * frames, CELL.y * 2, false, Image.FORMAT_RGBA8)


func _process(_delta: float) -> bool:
	if wait > 0:
		wait -= 1
		if wait == 0:
			var job: Array = jobs.pop_front()
			var img := view.get_texture().get_image()
			img.convert(Image.FORMAT_RGBA8)
			sheet.blit_rect(img, Rect2i(Vector2i.ZERO, CELL), Vector2i(job[2] * CELL.x, (job[3] % 2) * CELL.y))
			if job[1] == "side" and job[2] == frames - 1:
				var path := out_dir.path_join("%s_%s.png" % [rig_kind, job[0]])
				sheet.save_png(path)
				print("saved ", path)
				sheet.fill(Color(0, 0, 0, 0))
		return false
	if jobs.is_empty():
		quit()
		return true
	var job: Array = jobs[0]
	var anim := player.get_animation(job[0])
	var looped := anim.loop_mode != Animation.LOOP_NONE
	var t: float = anim.length * job[2] / float(frames if looped else frames - 1)
	player.play(job[0])
	player.seek(t, true)
	player.pause()
	var tall := rig_kind == "boss"
	var center := Vector3(0, 1.75 if tall else 0.95, 0)
	var dist := 7.6 if tall else 3.6
	var dir := Vector3(0.55, 0.12, 0.83) if job[1] == "front" else Vector3(1, 0.08, 0)
	cam.position = center + dir.normalized() * dist
	cam.look_at(center, Vector3.UP)
	caption.text = "%s  %.2fs  %s" % [job[0], t, job[1]]
	wait = 3
	return false
