extends SceneTree
## Headless checks for DS-03 Alterations + DS-04 Receiving.
## Run: godot --headless --path afterbell-godot -s res://tests/alterations_test.gd

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


func steps(room: Node, n: int) -> void:
	for i in n:
		room.step(DT)
		room._place_camera(10.0)   # camera settled behind Ren, as in play


func press(room: Node, key: String) -> void:
	room.virtual[key] = true
	room.step(DT)
	room.virtual[key] = false
	room.step(DT)


func _run() -> void:
	var room: Node = load("res://rooms/alterations.tscn").instantiate()
	root.add_child(room)
	room.set_process(false)
	check(room.has_method("step"), "room script loaded")
	if not room.has_method("step"):
		return
	print("Tailor and sleeve:")
	room.p_pos = Vector2(3.3, -1.9)
	press(room, "eat")
	check(room.tailor_asked, "talking to the tailor: it asks about its other sleeve")
	steps(room, 60)
	check(room.curtain.position.x > 3.3 + 0.5, "the curtain draws back to show the tailor")
	room.p_pos = Vector2(-1.85, -4.3)
	press(room, "eat")
	check(room.sleeve_held, "the sleeve comes off the receiving doorknob")
	room.p_pos = Vector2(3.3, -1.9)
	press(room, "eat")
	check(room.sleeve_returned, "handing it back finishes the little scene")

	print("Crank socket:")
	room.p_pos = Vector2(4.1, -0.9)
	press(room, "eat")
	check(room.crank_t >= 0.0, "Knock goes into the socket sideways")
	room.virtual["left"] = true
	steps(room, 60)
	room.virtual["left"] = false
	check(room.p_pos.distance_to(Vector2(4.1, -0.9)) < 0.01, "Ren stays at the socket while turning")
	steps(room, int(4.5 / DT))   # 5.5 s in
	check(not room.gate_open, "it takes the full six seconds the first time")
	steps(room, int(1.2 / DT))
	check(room.gate_open, "the atrium gate opens")

	print("Receiving:")
	room.p_pos = Vector2(-2.5, -4.4)
	room.virtual["up"] = true
	steps(room, 40)
	room.virtual["up"] = false
	check(room.met_hesta and room.p_pos.y < -5.5, "through the doorway into Receiving, Hesta's scene starts")
	room.p_pos = Vector2(2.8, -7.5)
	press(room, "eat")
	check(room.talked_len and room.gauge.objective_next == "Reach the service bell" or room.gauge.objective == "Reach the service bell", "Len's news; objective is the service bell")
	room.hp = 3
	room.biscuits = 0
	room.p_pos = Vector2(0.6, -11.2)
	press(room, "eat")
	check(room.biscuits == 2 and room.hp == 6, "the biscuit tin and water restock the minimum supply")

	print("Leaving east:")
	room.p_pos = Vector2(4.4, 0.5)
	room.virtual["right"] = true
	steps(room, 60)
	room.virtual["right"] = false
	check(room.leaving and room.next_scene == "res://main.tscn", "east through the gate continues to the court")
	Engine.remove_meta("afterbell_skip_title")
