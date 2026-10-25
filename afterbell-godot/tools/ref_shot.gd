extends SceneTree
## Renders the court's gameplay view (HUD included) with Ren facing north up the aisle, the frame
## the user's reference image shows, and pastes the reference beside it for comparison.
##   godot --path afterbell-godot -s res://tools/ref_shot.gd -- --out=/tmp/ref.png [--ref=img.png]
##       [--pos=x,z] [--boss]   (the Floor Manager is hidden unless --boss: the reference has none)

var out := "user://ref_shot.png"
var ref := ""
var pos := Vector2(0.0, -4.2)
var show_boss := false
var room: Node
var wait := -1


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--ref="):
			ref = arg.substr(6)
		elif arg.begins_with("--pos="):
			var p := arg.substr(6).split(",")
			pos = Vector2(float(p[0]), float(p[1]))
		elif arg == "--boss":
			show_boss = true
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(1280, 960)
	room = load("res://main.tscn").instantiate()
	root.add_child(room)


func _process(_d: float) -> bool:
	if wait == -1:
		room.set_process(false)
		if room.get("fade"):
			room.fade.visible = false
		room.start_game()
		room.intro_t = 0.0
		room.p_pos = pos
		for i in 120:
			room.p_pos = pos
			room.m_pos = Vector2(pos.x, pos.y - 20.0)   # face north
			room.step(1.0 / 60.0)
		room.p_pos = pos
		room.m_pos = Vector2(pos.x, pos.y - 20.0)
		room.p_yaw = PI
		for i in 60:
			room._render(1.0 / 30.0)
		room.boss.visible = show_boss
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
		img.save_png(out)
		print("saved ", out)
		quit()
	return false
