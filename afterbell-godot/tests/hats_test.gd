extends SceneTree
## Headless checks for DS-02, Hats and gloves: etiquette guards, the rack guide, the alcove pin.
## Run: godot --headless --path afterbell-godot -s res://tests/hats_test.gd

const DT := 1.0 / 60.0
var _failures := 0
var _done := false


func _init() -> void:
	Engine.set_meta("afterbell_testing", true)


func _process(_delta: float) -> bool:
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


func fresh() -> Node:
	var room: Node = load("res://rooms/hats.tscn").instantiate()
	root.add_child(room)
	room.set_process(false)
	return room


func steps(room: Node, n: int) -> void:
	for i in n:
		room.step(DT)


func until(room: Node, cond: Callable, max_steps := 1200) -> bool:
	for i in max_steps:
		if cond.call():
			return true
		room.step(DT)
	return false


func _run() -> void:
	print("Etiquette guard (EN-H01):")
	var room := fresh()
	check(room.has_method("step"), "room script loaded")
	if not room.has_method("step"):
		return
	var g = room.guards[0]
	check(g.state == "post" and room.guards[1].state == "dormant", "one guard at its post, the second not yet present")
	room.p_pos = Vector2(-2.6, 1.2)
	room.step(DT)
	check(g.state == "approach", "it wakes when Ren comes within 4 m")
	check(until(room, func(): return g.state == "tell", 600), "it raises the baton (tell) when close")
	var tell_frames := 0
	while g.state == "tell":
		room.step(DT)
		tell_frames += 1
	check(absf(tell_frames * DT - 0.85) < 0.05, "tell lasts 0.85 s (%.2f)" % (tell_frames * DT))
	steps(room, 12)
	check(room.hp == 5, "an unguarded strike costs one segment")
	until(room, func(): return g.state == "tell", 600)
	room.virtual["guard"] = true
	until(room, func(): return g.state == "recover", 200)
	room.virtual["guard"] = false
	check(room.hp == 5, "guarding with the flat of Knock blocks the strike")
	# Wound heavy into the lifted tell: start winding early, release during the tell.
	room.inv = 0.0
	room.virtual["attack"] = true
	until(room, func(): return g.state == "tell" and room.charge_t >= 0.8, 900)
	room.virtual["attack"] = false
	room.step(DT)
	check(g.state == "seated", "a wound heavy strike during the tell topples it at once")
	room.queue_free()

	print("Three-hit combo:")
	room = fresh()
	g = room.guards[0]
	room.p_pos = Vector2(-2.6, 0.4)
	until(room, func(): return g.state == "approach", 60)
	for i in 3:
		room._hit_guard(g, false)
	check(g.state == "seated", "three connected light hits empty both stability pips")
	room.queue_free()

	print("Rack guide:")
	room = fresh()
	room.guards[0].state = "seated"   # keep the first guard out of the way
	room.p_pos = Vector2(0.0, -1.5)
	room.virtual["up"] = true
	steps(room, 120)
	room.virtual["up"] = false
	check(room.p_pos.y > -2.0, "at its start the rack blocks the north aisle")
	room.p_pos = Vector2(-1.3, -2.4)
	room.virtual["guard"] = true
	room.virtual["right"] = true
	steps(room, 240)
	room.virtual["right"] = false
	room.virtual["guard"] = false
	check(is_equal_approx(room.rack_x, room.STOP_EAST), "hold guard and walk: it rides the guide to the east stop")
	check(room.second_awake and room.guards[1].node.visible, "moving the rack brings the second guard")
	room.guards[1].state = "seated"
	room.p_pos = Vector2(0.0, -1.5)
	room.virtual["up"] = true
	steps(room, 150)
	room.virtual["up"] = false
	check(room.p_pos.y < -3.7, "with the rack at the east stop, the aisle is open")
	room.p_pos = Vector2(2.2, -2.0)
	room.virtual["up"] = true
	steps(room, 120)
	room.virtual["up"] = false
	check(room.p_pos.y > -2.9, "east stop blocks the alcove")
	room.rack_x = room.STOP_WEST
	room.p_pos = Vector2(2.2, -2.0)
	room.virtual["up"] = true
	steps(room, 120)
	room.virtual["up"] = false
	room.virtual["eat"] = true
	room.step(DT)
	room.virtual["eat"] = false
	check(room.pin_taken, "west stop opens the alcove and the umbrella pin can be taken")
	room.queue_free()

	print("One commitment at a time:")
	room = fresh()
	room.second_awake = true
	room._wake_second()
	room.p_pos = Vector2(-3.0, 3.0)
	room.guards[1].pos = Vector2(-3.0, 4.5)
	var both := false
	for i in 900:
		room.inv = 1.0   # keep Ren standing for the whole sample
		room.step(DT)
		var committed := 0
		for gg in room.guards:
			if gg.state in ["tell", "strike"]:
				committed += 1
		both = both or committed > 1
	check(not both, "the second guard circles while the first commits")
	room.queue_free()

	print("Clearing and leaving:")
	room = fresh()
	room.second_awake = true
	room._wake_second()
	for gg in room.guards:
		room._topple(gg)
	room.step(DT)
	check(room.cleared and room.guards[0].state == "standing", "both seated: the room clears and they get back up, nonhostile")
	room.p_pos = Vector2(0.0, -7.8)
	room.rack_x = room.STOP_EAST
	room.virtual["up"] = true
	until(room, func(): return room.leaving, 200)
	check(room.leaving and Engine.has_meta("afterbell_skip_title"), "north door leads on to the Floor Manager's court")
	Engine.remove_meta("afterbell_skip_title")
