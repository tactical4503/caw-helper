extends SceneTree
## Renders one gameplay-camera screenshot per room, for lighting and art review.
## Needs a renderer (not --headless):
##   godot --path afterbell-godot -s res://tools/room_shots.gd -- --out=/tmp/rooms

const SHOTS := [
	# [name, scene, player position, setup]
	["cosmetics", "res://rooms/cosmetics.tscn", Vector2(0.3, 1.2), ""],
	["hats", "res://rooms/hats.tscn", Vector2(-1.0, 2.2), ""],
	["alterations", "res://rooms/alterations.tscn", Vector2(0.5, 2.8), "tailor"],
	["receiving", "res://rooms/alterations.tscn", Vector2(0.8, -6.2), "hesta"],
	["alterations_gate", "res://rooms/alterations.tscn", Vector2(2.8, 0.6), "gate"],
	["court", "res://main.tscn", Vector2(0.3, 4.4), ""],
	["court_doors", "res://main.tscn", Vector2(-3.5, 6.2), "look_west"],
	["atrium_aisle", "res://main.tscn", Vector2(-3.5, 6.2), "look_north"],
	["atrium_east", "res://main.tscn", Vector2(-3.5, 6.2), "look_east"],
	["atrium_gallery", "res://main.tscn", Vector2(-3.5, 6.2), "gallery"],
]

var out_dir := "user://rooms"
var room: Node
var index := -1
var wait := 0


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
	DirAccess.make_dir_recursive_absolute(out_dir)
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(1280, 720)
	_next()


func _next() -> void:
	if room:
		room.queue_free()
	index += 1
	if index >= SHOTS.size():
		quit()
		return
	var shot: Array = SHOTS[index]
	room = load(shot[1]).instantiate()
	root.add_child(room)
	wait = -1


func _process(_delta: float) -> bool:
	if index >= SHOTS.size():
		return true
	var shot: Array = SHOTS[index]
	if wait == -1:
		room.set_process(false)
		if room.get("fade"):
			room.fade.visible = false
		if shot[1] == "res://main.tscn":
			room.start_game()
			room.p_pos = shot[2]
			for i in 150:
				room.step(1.0 / 60.0)
			room._render(1.0)
			match shot[3]:
				"look_west":   # face the service doors and the room beyond them
					room.camera.position = Vector3(-2.0, 1.75, 5.2)
					room.camera.look_at(Vector3(-9.5, 1.3, 7.6), Vector3.UP)
				"look_north":   # down the central aisle to the window
					room.camera.position = Vector3(0.0, 2.2, 8.4)
					room.camera.look_at(Vector3(0.0, 5.2, -20.0), Vector3.UP)
				"gallery":   # from the west gallery: the upper floors, their escalator and supports
					room.camera.position = Vector3(-10.4, 6.75, 7.5)
					room.camera.look_at(Vector3(6.0, 7.0, -10.0), Vector3.UP)
				"look_east":   # across the east rail to the shop fronts and galleries
					room.camera.position = Vector3(4.5, 2.0, 3.5)
					room.camera.look_at(Vector3(13.0, 3.2, -3.0), Vector3.UP)
		else:
			match shot[3]:
				"tailor":
					room.tailor_asked = true
				"hesta":
					room.met_hesta = true
			room.p_pos = shot[2]
			for i in 90:
				room.step(1.0 / 60.0)
			room._place_camera(10.0)
			if shot[3] == "gate":   # the atrium gate and its winding station, close
				room.camera.position = Vector3(2.2, 1.65, 1.2)
				room.camera.look_at(Vector3(5.0, 1.35, -0.3), Vector3.UP)
		wait = 25
		return false
	wait -= 1
	if wait == 0:
		var path := out_dir.path_join(shot[0] + ".png")
		root.get_texture().get_image().save_png(path)
		print("saved ", path)
		_next()
	return false
