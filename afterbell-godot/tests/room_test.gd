extends SceneTree
## Headless checks for DS-01, the cosmetics reflection demonstration.
## Run: godot --headless --path afterbell-godot -s res://tests/room_test.gd

const DT := 1.0 / 60.0
var _failures := 0
var _done := false


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
	var room: Node = load("res://rooms/cosmetics.tscn").instantiate()
	root.add_child(room)
	room.set_process(false)  # drive it with fixed steps only
	return room


func until(room: Node, cond: Callable, max_steps := 1200) -> bool:
	for i in max_steps:
		if cond.call():
			return true
		room.step(DT)
	return false


func _run() -> void:
	print("Cosmetics room (DS-01):")
	var room := fresh()
	check(room.has_method("step"), "room script loaded")
	if not room.has_method("step"):
		return
	# Stand in the aisle on the placard's path.
	room.p_pos = Vector2(0.0, -1.4)
	check(until(room, func(): return room.placard_state == "fly"), "attendant throws within one 6 s cycle")
	check(until(room, func(): return room.placard_pos.x < 1.4), "placard travels across the aisle")
	# Unguarded: harmless bounce, counted as a miss.
	until(room, func(): return room.placard_state != "fly", 120)
	check(room.placard_state == "bounce" and room.misses == 1, "unguarded placard bounces off harmlessly (no health in this room)")
	# Timed guard: press ~0.1 s before contact.
	until(room, func(): return room.placard_state == "fly", 600)
	until(room, func(): return room.placard_pos.x < 1.0, 600)
	room.virtual["guard"] = true
	until(room, func(): return room.placard_state != "fly", 120)
	room.virtual["guard"] = false
	check(room.placard_state == "arc", "timed guard returns the placard along the arc")
	check(until(room, func(): return room.gate_open, 120), "placard reaches the receiver and the gate opens")
	until(room, func(): return room.gate_progress >= 1.0, 200)
	check(room.gate.position.y > 2.0, "gate has rolled up")
	room.queue_free()

	print("Dialogue blips:")
	var d = room.dialogue
	d.clear()
	var before: int = d.blips_played
	d.say("FLOOR MANAGER", "Please read.", 1.0)
	d.update(0.1)
	check(room.subtitle.visible_characters > 0 and room.subtitle.visible_characters < 12, "line types out letter by letter")
	for i in 30:
		d.update(1.0 / 60.0)
	check(d.blips_played > before, "the speaker's voice blips play as it types")
	for i in 200:
		d.update(1.0 / 60.0)
	check(d.is_idle(), "finished lines clear from the screen")
	var after_speech: int = d.blips_played
	d.say("", "Narration is silent.", 1.0)
	for i in 200:
		d.update(1.0 / 60.0)
	check(d.blips_played == after_speech, "narration adds no blips")

	print("Help route (three misses):")
	room = fresh()
	room.p_pos = Vector2(0.0, -1.4)
	for i in 3:
		until(room, func(): return room.placard_state == "fly", 600)
		until(room, func(): return room.placard_state == "bounce", 600)
	check(room.hinted, "three misses offer assist and Mika's help")
	room.virtual["help"] = true
	room.step(DT)
	room.virtual["help"] = false
	check(room.gate_open, "H: Mika's manual release opens the gate (not a failure)")

	print("Leaving west:")
	room.p_pos = Vector2(-7.5, 1.8)
	room.virtual["left"] = true
	until(room, func(): return room.leaving, 200)
	room.virtual["left"] = false
	check(room.leaving, "walking through the open gate continues to the boss court")
	check(Engine.has_meta("afterbell_skip_title"), "boss court will skip its title card")
	Engine.remove_meta("afterbell_skip_title")
