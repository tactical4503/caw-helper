extends SceneTree
## Loads each scene, lets it settle, and prints per-frame rendering counts (draw calls, objects,
## primitives) plus the average frame time over 30 frames. Counts are renderer work and do not
## depend on the GPU; frame times are only meaningful on the machine that produced them.
##   godot --path afterbell-godot -s res://tools/perf_probe.gd

const SCENES := ["res://rooms/title.tscn", "res://rooms/cosmetics.tscn", "res://rooms/hats.tscn",
		"res://rooms/alterations.tscn", "res://main.tscn"]

var index := -1
var frames := 0
var t0 := 0
var room: Node
var proc_sum := 0.0


func _initialize() -> void:
	Engine.set_meta("afterbell_testing", true)
	root.size = Vector2i(1280, 960)
	_next()


func _next() -> void:
	if room:
		room.queue_free()
	index += 1
	if index >= SCENES.size():
		quit()
		return
	room = load(SCENES[index]).instantiate()
	root.add_child(room)
	frames = 0


func _process(_d: float) -> bool:
	if index >= SCENES.size():
		return true
	frames += 1
	if frames == 15:
		t0 = Time.get_ticks_usec()
		proc_sum = 0.0
	if frames > 15:
		proc_sum += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	if frames == 45:
		var ms := (Time.get_ticks_usec() - t0) / 30000.0
		var rs := RenderingServer
		var lights := 0
		var shadowed := 0
		var omni := 0
		for l in room.find_children("*", "Light3D", true, false):
			if (l as Light3D).visible:
				lights += 1
				if (l as Light3D).shadow_enabled:
					shadowed += 1
				if l is OmniLight3D:
					omni += 1
		var meshes := room.find_children("*", "GeometryInstance3D", true, false).size()
		print("%-24s draws %5d  objects %5d  tris %8d  frame %.1f ms  script %.2f ms  lights %d (omni %d, shadowed %d)  geo nodes %d" % [SCENES[index].get_file(),
				rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
				rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
				rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME), ms, proc_sum / 30.0, lights, omni, shadowed, meshes])
		_next()
	return false
