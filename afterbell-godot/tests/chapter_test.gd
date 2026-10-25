extends SceneTree
## Headless checks for the chapter shell (scripts/game.gd, autoloaded as /root/Game): the save
## round trip, Continue's checkpoint, settings and volume buses, pause, and the chapter flags.
## Run: godot --headless --path afterbell-godot -s res://tests/chapter_test.gd

const TEST_SAVE := "user://afterbell_test_save.json"
var _failures := 0
var _done := false


func _init() -> void:
	Engine.set_meta("afterbell_testing", true)


func check(ok: bool, what: String) -> void:
	print(("  ok   " if ok else "  FAIL ") + what)
	if not ok:
		_failures += 1


func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	_run()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("RESULT: %s (%d failure(s))" % ["PASS" if _failures == 0 else "FAIL", _failures])
	quit(1 if _failures else 0)
	return true


func _run() -> void:
	var game: Node = root.get_node_or_null("Game")
	check(game != null, "the Game autoload is present")
	if game == null:
		return
	game.save_path = TEST_SAVE
	print("New game and checkpoints:")
	game.new_game()
	check(game.checkpoint == game.FIRST_ROOM, "new game starts at Cosmetics")
	check(game.flags.is_empty(), "new game clears progress flags")
	game.enter_room("res://rooms/hats.tscn", "Hats & Gloves")
	check(game.checkpoint == "res://rooms/hats.tscn", "entering a room makes it the checkpoint")
	check(game.has_save(), "a checkpoint that exists counts as a save")
	print("Save round trip:")
	Engine.remove_meta("afterbell_testing")          # let save_game() write, to the test file only
	game.set_flag("hats_cleared")
	game.set_flag("souvenir_sv01")
	game.settings.effects = 0.4
	game.save_game()
	Engine.set_meta("afterbell_testing", true)
	check(FileAccess.file_exists(TEST_SAVE), "the save file is written")
	game.checkpoint = ""
	game.flags = {}
	game.settings.effects = 1.0
	game.load_game()
	check(game.checkpoint == "res://rooms/hats.tscn", "Continue returns to the saved room")
	check(game.flag("hats_cleared") and game.flag("souvenir_sv01"), "progress flags survive a reload")
	check(is_equal_approx(game.settings.effects, 0.4), "settings survive a reload")
	print("Corrupt or foreign save data:")
	var f := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	f.store_string("{not json")
	f = null
	game.checkpoint = "res://rooms/hats.tscn"
	game.load_game()
	check(game.checkpoint == "res://rooms/hats.tscn", "a corrupt save is ignored, state kept")
	f = FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	f.store_string(JSON.stringify({"checkpoint": "res://rooms/nowhere.tscn", "settings": {"effects": "loud"}}))
	f = null
	game.load_game()
	check(not game.has_save(), "a checkpoint to a missing scene does not count as a save")
	check(is_equal_approx(game.settings.effects, 0.4), "a wrongly typed setting is ignored")
	print("Audio buses:")
	check(AudioServer.get_bus_index("Effects") != -1 and AudioServer.get_bus_index("Ambience") != -1, "Effects and Ambience buses exist")
	game.settings.effects = 0.5
	game._apply_volumes()
	check(absf(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")) - linear_to_db(0.5)) < 0.01, "the effects slider sets its bus volume")
	game.settings.effects = 0.0
	game._apply_volumes()
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Effects")), "zero volume mutes the bus")
	print("Pause and chapter end:")
	game.open_pause()
	check(paused, "the pause menu pauses the game")
	game._close()
	check(not paused, "resuming unpauses it")
	game.chapter_complete(["test line"])
	check(game.flag("chapter_one_complete"), "finishing the court marks the chapter complete")
	game._close()
	check(not paused, "the chapter screen leaves the game unpaused")
