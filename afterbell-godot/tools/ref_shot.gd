extends SceneTree
## Renders the court's gameplay view (HUD included) with Ren facing north up the aisle, the frame
## the user's reference image shows, and pastes the reference beside it for comparison.
##   godot --path afterbell-godot -s res://tools/ref_shot.gd -- --out=/tmp/ref.png [--ref=img.png]
##       [--pos=x,z] [--boss]   (the Floor Manager is hidden unless --boss: the reference has none)

var out := "user://ref_shot.png"
var ref := ""
var pos := Vector2(0.0, -4.2)
var show_boss := false
var mpos := Vector2.INF   # --mpos=x,z puts the Floor Manager there (with --boss)
var cam := Vector3.INF
var look := Vector3.ZERO
var room: Node
var wait := -1


func _initialize() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("CAPTURE FAIL: ref_shot needs a real renderer, not --headless")
		quit(1)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--ref="):
			ref = arg.substr(6)
		elif arg.begins_with("--pos="):
			var p := arg.substr(6).split(",")
			pos = Vector2(float(p[0]), float(p[1]))
		elif arg.begins_with("--mpos="):
			var mp := arg.substr(7).split(",")
			mpos = Vector2(float(mp[0]), float(mp[1]))
		elif arg == "--boss":
			show_boss = true
		elif arg.begins_with("--cam="):   # free camera: --cam=x,y,z --look=x,y,z (no reference paste)
			var c := arg.substr(6).split(",")
			cam = Vector3(float(c[0]), float(c[1]), float(c[2]))
		elif arg.begins_with("--look="):
			var l := arg.substr(7).split(",")
			look = Vector3(float(l[0]), float(l[1]), float(l[2]))
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(1280, 960)
	room = load("res://main.tscn").instantiate()
	root.add_child(room)


func _process(_d: float) -> bool:
	# _ready runs after SceneTree._initialize, so validate on the first frame.
	if room == null or not room.has_method("start_game") or room.get("arena") == null or room.get("gauge") == null:
		printerr("CAPTURE FAIL: court did not initialize; inspect preceding script errors")
		quit(1)
		return true
	if wait == -1:
		room.set_process(false)
		if room.get("fade"):
			room.fade.visible = false
		room.start_game()
		room.intro_t = 0.0
		room.p_pos = pos
		for i in 120:
			room.p_pos = pos
			room.m_pos = mpos if mpos != Vector2.INF else Vector2(pos.x, pos.y - 20.0)   # face north
			room.step(1.0 / 60.0)
		room.p_pos = pos
		room.m_pos = mpos if mpos != Vector2.INF else Vector2(pos.x, pos.y - 20.0)
		room.p_yaw = PI - 0.45 if mpos == Vector2.INF else atan2(mpos.x - pos.x, mpos.y - pos.y)
		for i in 60:
			room._render(1.0 / 30.0)
		room.boss.visible = show_boss
		room.gauge.gamepad = true   # the reference shows controller glyphs
		if cam != Vector3.INF:
			room.set_process(false)
			room.camera.position = cam
			room.camera.look_at(look, Vector3.UP)
		wait = 20
		return false
	wait -= 1
	if wait == 0:
		var img := root.get_texture().get_image()
		if ref != "":
			var r := Image.load_from_file(ref)
			if r:
				r.resize(img.get_width(), img.get_height())
				var both := Image.create(img.get_width() * 2, img.get_height(), false, img.get_format())
				r.convert(img.get_format())
				both.blit_rect(r, Rect2i(Vector2i.ZERO, r.get_size()), Vector2i.ZERO)
				both.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(img.get_width(), 0))
				img = both
		var saved := img.save_png(out)
		if saved != OK:
			printerr("CAPTURE FAIL: cannot write ", out, " (", saved, ")")
			quit(1)
			return true
		# Keep renderer work beside the exact camera capture, rather than comparing
		# counts from perf_probe's different (moving) opening camera.
		var rs := RenderingServer
		var metrics := {
			"engine": Engine.get_version_info().string,
			"adapter": rs.get_video_adapter_name(),
			"viewport": [root.size.x, root.size.y],
			"player": [pos.x, pos.y],
			"boss_visible": show_boss,
			"draw_calls": rs.get_rendering_info(rs.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			"primitives": rs.get_rendering_info(rs.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
			"objects": rs.get_rendering_info(rs.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			"lights": room.find_children("*", "Light3D", true, false).size(),
		}
		var report := FileAccess.open(out.get_basename() + ".json", FileAccess.WRITE)
		if report:
			report.store_string(JSON.stringify(metrics, "\t") + "\n")
		print("CAPTURE METRICS: ", JSON.stringify(metrics))
		print("saved ", out)
		quit()
	return false
