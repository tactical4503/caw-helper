extends SceneTree
## Walking paths: from each room's entrance there must be a route at least ~1.1 m wide (the
## player's 0.3 m collision pad plus a 0.25 m body either side) to every door and every spot a
## puzzle needs Ren to reach. Walks a 10 cm grid using each room's own collision.
## Run: godot --headless --path afterbell-godot -s res://tests/paths_test.gd

const STEP := 0.1
const BODY := 0.25
var _failures := 0
var _done := false


func _initialize() -> void:
	Engine.set_meta("afterbell_testing", true)


func _process(_d: float) -> bool:
	if _done:
		return true
	_done = true
	_run()
	print("RESULT: %s (%d failure(s))" % ["PASS" if _failures == 0 else "FAIL", _failures])
	quit(1 if _failures else 0)
	return true


func check(ok: bool, what: String) -> void:
	print(("  ok   " if ok else "  FAIL ") + what)
	if not ok:
		_failures += 1


## A spot is walkable when collision leaves Ren, and a body-width either side of him, in place.
func walkable(room: Node, collide: Callable, p: Vector2) -> bool:
	for o in [Vector2.ZERO, Vector2(BODY, 0), Vector2(-BODY, 0), Vector2(0, BODY), Vector2(0, -BODY)]:
		room.p_pos = p + o
		collide.call()
		if room.p_pos.distance_to(p + o) > 0.001:
			return false
	return true


## Flood-fills walkable cells from `start`; returns the names of `targets` it never gets within
## 0.45 m of.
func unreached(room: Node, collide: Callable, start: Vector2, targets: Dictionary, bounds: Rect2) -> Array:
	var w := int(bounds.size.x / STEP)
	var h := int(bounds.size.y / STEP)
	var seen := {}
	var cell := func(p: Vector2) -> Vector2i: return Vector2i(int((p.x - bounds.position.x) / STEP), int((p.y - bounds.position.y) / STEP))
	var centre := func(c: Vector2i) -> Vector2: return bounds.position + (Vector2(c) + Vector2(0.5, 0.5)) * STEP
	var queue: Array = [cell.call(start)]
	seen[queue[0]] = true
	var reached := []
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		var p: Vector2 = centre.call(c)
		for name in targets:
			if not name in reached and p.distance_to(targets[name]) < 0.45:
				reached.append(name)
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nc: Vector2i = c + d
			if nc.x < 0 or nc.y < 0 or nc.x >= w or nc.y >= h or seen.has(nc):
				continue
			seen[nc] = true
			if walkable(room, collide, centre.call(nc)):
				queue.append(nc)
	var missing := []
	for name in targets:
		if not name in reached:
			missing.append(name)
	return missing


func _room(path: String) -> Node:
	var room: Node = load(path).instantiate()
	root.add_child(room)
	room.set_process(false)
	return room


func _run() -> void:
	print("Cosmetics:")
	var c := _room("res://rooms/cosmetics.tscn")
	var miss := unreached(c, c._collide_player, c.ENTRY, {
		"hats gate": Vector2(-7.4, c.GATE_Z), "aisle by the catcher": Vector2(-2.4, -1.4),
		"aisle by the attendant": Vector2(2.4, -1.4), "atrium shutter": Vector2(0.0, -3.4),
		"east wall": Vector2(7.4, 2.0)}, Rect2(-8, -4, 16, 8))
	check(miss.is_empty(), "clear paths from the vestibule %s" % [miss])
	c.queue_free()

	print("Hats:")
	var h := _room("res://rooms/hats.tscn")
	h.rack_x = h.STOP_EAST
	miss = unreached(h, h._collide_player, h.ENTRY, {
		"staff doors": Vector2(0.0, -8.6), "rack handle": Vector2(-1.3, -2.4), "south end": Vector2(-1.8, 7.6),
		"west rack aisle": Vector2(-3.4, 0.0)}, Rect2(-5, -9.6, 10, 19))
	check(miss.is_empty(), "rack at the east stop: clear paths from Cosmetics %s" % [miss])
	h.rack_x = h.STOP_WEST
	miss = unreached(h, h._collide_player, h.ENTRY, {"umbrella pin": h.PIN_AT + Vector2(0, 0.6)}, Rect2(-5, -9.6, 10, 19))
	check(miss.is_empty(), "rack at the west stop: the alcove pin is reachable %s" % [miss])
	h.queue_free()

	print("Alterations and Receiving:")
	var a := _room("res://rooms/alterations.tscn")
	miss = unreached(a, a._collide, a.ENTRY, {
		"crank socket": a.SOCKET, "fitting stall": Vector2(a.STALL.x, a.STALL.y + 1.3), "atrium gate": Vector2(4.4, a.GATE_Z),
		"sewing counter": Vector2(-3.6, -2.2), "receiving door": Vector2(a.DOOR_X, -4.5),
		"biscuit table": Vector2(0.6, -11.0), "Hesta": Vector2(-0.9, -8.8), "Len": Vector2(2.8, -7.4)},
		Rect2(-5, -13, 12, 18))
	check(miss.is_empty(), "clear paths from Hats %s" % [miss])
	a.queue_free()
