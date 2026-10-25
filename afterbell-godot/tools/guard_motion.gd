extends SceneTree
## Films the Hats guards (the supplied staff figures) through a scripted sequence at 30 fps:
## walking in, idling, the tell, the strike and its follow-through, a flinch, sitting down and
## getting back up. Saves every `--every`th frame for contact sheets or a GIF.
##   godot --path afterbell-godot -s res://tools/guard_motion.gd -- --out=/tmp/motion --every=3

## [state, seconds, walk velocity (x, z) in m/s]
const SCRIPT := [["approach", 2.0, Vector2(0.0, 0.9)], ["post", 1.0, Vector2.ZERO], ["tell", 0.85, Vector2.ZERO],
		["strike", 0.18, Vector2.ZERO], ["recover", 0.9, Vector2.ZERO], ["flinch", 0.45, Vector2.ZERO],
		["approach", 0.6, Vector2.ZERO], ["seated", 1.6, Vector2.ZERO], ["standing", 1.2, Vector2.ZERO]]

var out_dir := "user://motion"
var every := 3
var feet := false   # --view=feet: a low camera on the first guard's legs and shadow
var room: Node
var frame := 0
var seg := 0
var seg_t := 0.0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg == "--view=feet":
			feet = true
		elif arg.begins_with("--every="):
			every = int(arg.substr(8))
	DirAccess.make_dir_recursive_absolute(out_dir)
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(960, 720)
	room = load("res://rooms/hats.tscn").instantiate()
	root.add_child(room)


func _process(_d: float) -> bool:
	var dt := 1.0 / 30.0
	if frame == 0:
		room.set_process(false)
		if room.get("fade"):
			room.fade.visible = false
		room.p_pos = Vector2(0.0, 3.4)
		for k in room.guards.size():
			var g = room.guards[k]
			g.node.visible = true
			g.pos = Vector2(-0.8 + k * 1.6, -1.6)
			g.last = g.pos
			g.yaw = 0.0
			g.vis_yaw = 0.0
	var step: Array = SCRIPT[seg]
	for k in room.guards.size():
		var g = room.guards[k]
		g.state = step[0]
		g.pos += step[2] * dt
		g.yaw = lerp_angle(g.yaw, atan2(room.p_pos.x - g.pos.x, room.p_pos.y - g.pos.y), 1.0 - exp(-6.0 * dt))
	room._render_actors(dt)
	room.ren.visible = false
	var g0 = room.guards[0]
	if feet:
		room.camera.position = Vector3(g0.pos.x + 1.5, 0.55, g0.pos.y + 1.4)
		room.camera.look_at(Vector3(g0.pos.x, 0.3, g0.pos.y), Vector3.UP)
	else:
		room.camera.position = Vector3(g0.pos.x + 1.6, 1.3, g0.pos.y + 2.6)   # a three-quarter view of the first guard
		room.camera.look_at(Vector3(g0.pos.x + 0.2, 0.95, g0.pos.y), Vector3.UP)
	if frame > 1 and frame % every == 0:
		var path := out_dir.path_join("f%04d.png" % frame)
		root.get_texture().get_image().save_png(path)
	frame += 1
	seg_t += dt
	if seg_t >= step[1]:
		seg_t = 0.0
		seg += 1
		if seg >= SCRIPT.size():
			print("frames ", frame)
			quit()
			return true
	return false
