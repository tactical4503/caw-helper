extends SceneTree
## Headless fight checks. Drives main.gd with fixed 1/60 s steps and virtual input.
## Run: godot --headless --path afterbell-godot -s res://tests/sim_test.gd

const DT := 1.0 / 60.0
var main
var _done := false
var _failures := 0


func _initialize() -> void:
	main = load("res://main.tscn").instantiate()
	root.add_child(main)


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


func until(cond: Callable, max_steps := 1800) -> bool:
	for i in max_steps:
		if cond.call():
			return true
		main.step(DT)
	return false


func fresh(reflect_assist := false) -> void:
	main.settings.reflect_assist = reflect_assist
	main.mode = "title"
	main.start_game()
	main.virtual.clear()
	main.seen.clear()


func _run() -> void:
	check(main.has_method("step"), "main scene script loaded")
	if not main.has_method("step"):
		return
	print("Timed reflection, no assist, three bells to victory:")
	fresh(false)
	for bell in range(1, 4):
		var exposed := false
		for attempt in 6:
			main.p_pos = Vector2(0.2, 4.6)
			if not until(func(): return main.sign_data != null and main.sign_data.state == "out"):
				break
			until(func(): return main.sign_data == null or main.sign_data.pos.distance_to(main.p_pos) < 1.3, 600)
			main.virtual["guard"] = true
			main.step(DT)
			until(func(): return main.sign_data == null or main.sign_data.state != "out", 120)
			main.virtual["guard"] = false
			if until(func(): return main.m_state == "exposed", 200):
				exposed = true
				break
		check(exposed, "bell %d: reflected sign opens the brake" % bell)
		if not exposed:
			return
		main.p_pos = main.m_pos + Vector2(0.2, 1.6)
		main.virtual["attack"] = true
		main.step(DT)
		for i in 55:
			main.step(DT)
		main.virtual["attack"] = false
		main.step(DT)
		check(main.m_state == "launch", "bell %d: wound strike launches the chair (state=%s)" % [bell, main.m_state])
		check(until(func(): return main.m_state == "bell_scene", 200), "bell %d: chair reaches the lever" % bell)
		check(main.bells == bell, "bell count is %d" % bell)
		if bell < 3:
			until(func(): return main.m_state in ["idle", "present"], 600)
	check(until(func(): return main.m_state == "defeated", 600), "third bell ends the fight")
	check(until(func(): return main.mode == "end", 1200), "reward card appears")

	print("Wrong side, locked chair, sweep:")
	main.hud.end.visible = false
	fresh(true)
	main.p_pos = Vector2(0, 4.5)
	main.virtual["guard"] = true
	check(until(func(): return main.m_state == "exposed"), "held guard reflects with assist")
	main.virtual["guard"] = false
	main.p_pos = main.m_pos + Vector2(-1.8, -0.6)
	main.virtual["attack"] = true
	for i in 56:
		main.step(DT)
	main.virtual["attack"] = false
	main.step(DT)
	check(main.m_state == "wrong_roll", "strike from the wrong side rolls away from the bell")
	check(until(func(): return main.m_state == "stop_stun", 300), "chair stops at the padded display stop")
	until(func(): return main.m_state == "idle")
	for i in 3:
		main.p_pos = main.m_pos + Vector2(0, 1.4)
		main.virtual["attack"] = true
		main.step(DT)
		main.step(DT)
		main.virtual["attack"] = false
		for j in 25:
			main.step(DT)
	check(main.locked_hits >= 3 and main.seen.has("locked"), "light hits on the locked chair show the hint")
	var hp0: int = main.hp
	main.p_pos = main.m_pos + Vector2(0, 1.5)
	check(until(func(): return main.m_state == "sweep_tell", 400), "standing close triggers the sweep tell")
	until(func(): return main.m_state == "sweep_recover", 200)
	check(main.hp == hp0 - 1, "sweep deals one segment")

	print("Phase two rack shove and defeat:")
	main.bells = 1
	main.phase = 2
	main.racks[0].pos = Vector2(-7.2, 3.6)
	main.racks[0].state = "park"
	main.m_next = "rack"
	main.hp = 6
	main.inv = 0.0
	main.p_pos = Vector2(0, 3.6)
	check(until(func(): return main.m_state == "rack_tell", 3000), "phase two alternates in the rack shove")
	until(func(): return main.racks[0].state == "move")
	until(func(): return main.racks[0].state == "park", 600)
	check(main.hp == 5, "rack in the marked lane deals one segment")
	main.hp = 1
	main.inv = 0.0
	main.p_pos = Vector2(0, 3.6)
	main.racks[0].hit = false
	check(until(func(): return main.mode == "end", 3000), "losing the last segment ends the attempt")

	print("Lane choice (phase two):")
	main.hud.end.visible = false
	fresh(true)
	main.phase = 2
	main.bells = 1
	main.m_next = "sign"
	main.p_pos = Vector2(3.2, 4.0)
	check(until(func(): return main.mark.x > 2.0 and main.m_state == "roll", 900), "he moves to the lane facing Ren")
	check(until(func(): return main.m_state == "present", 900) and main.m_pos.distance_to(Vector2(3.0, -1.5)) < 0.2, "then presents from that lane")
	main.phase = 1
	main.bells = 0

	print("Animation clips:")
	var boss_anim: AnimationPlayer = main.boss_anim
	var ren_anim: AnimationPlayer = main.ren_anim
	# Gameplay tells must last exactly as long as the timing table says.
	check(is_equal_approx(boss_anim.get_animation("present").length, main.SIGN_TELL), "present clip = 1.0 s sign tell")
	check(is_equal_approx(boss_anim.get_animation("sweep_tell").length, main.SWEEP_TELL), "sweep_tell clip = 1.1 s")
	check(_has_key_at(boss_anim.get_animation("rack_push"), main.RACK_TELL), "rack_push shoves at the 1.2 s tell mark")
	check(is_equal_approx(ren_anim.get_animation("wind").length, main.HEAVY_CHARGE), "wind clip = 0.8 s heavy charge")
	var missing := []
	for state in main.BOSS_CLIPS:
		for clip in main.BOSS_CLIPS[state]:
			if not boss_anim.has_animation(clip):
				missing.append(clip)
	for clip in ["idle", "run", "guard", "reflect", "wind", "heavy", "light", "dodge", "hurt", "eat"]:
		if not ren_anim.has_animation(clip):
			missing.append(clip)
	check(missing.is_empty(), "every state's clips exist %s" % [missing])
	check(_tracks_resolve(main.boss, boss_anim) and _tracks_resolve(main.ren, ren_anim), "every animated track targets a real joint")


func _has_key_at(anim: Animation, t: float) -> bool:
	for tr in anim.get_track_count():
		if anim.track_find_key(tr, t, Animation.FIND_MODE_APPROX) != -1:
			return true
	return false


func _tracks_resolve(rig: Node, player: AnimationPlayer) -> bool:
	for clip in player.get_animation_list():
		var anim := player.get_animation(clip)
		for tr in anim.get_track_count():
			var path := anim.track_get_path(tr)
			if rig.get_node_or_null(NodePath(path.get_concatenated_names())) == null:
				print("    unresolved: %s in %s" % [path, clip])
				return false
	return true
