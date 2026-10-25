extends SceneTree
## Walks the chapter shell through the real Game autoload and saves a screenshot at each step:
## title, new game (Cosmetics with its location card), pause, settings, the court, chapter end.
##   godot --path afterbell-godot -s res://tools/shell_shots.gd -- --out=/tmp/shell

var out_dir := "user://shell"
var step := 0
var wait := 0
var game: Node

const STEPS := ["title", "new_game", "pause", "settings", "court", "chapter_end", "back_to_title"]


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.substr(6)
	DirAccess.make_dir_recursive_absolute(out_dir)
	root.size = Vector2i(1280, 960)
	change_scene_to_file("res://rooms/title.tscn")
	wait = 12


func _snap(name: String) -> void:
	var path := out_dir.path_join("%d_%s.png" % [step, name])
	root.get_texture().get_image().save_png(path)
	print("saved ", path, "  scene=", current_scene.scene_file_path if current_scene else "-")


func _process(_d: float) -> bool:
	if game == null:
		game = root.get_node_or_null("Game")
	wait -= 1
	if wait > 0:
		return false
	if step >= STEPS.size():
		quit()
		return true
	var name: String = STEPS[step]
	match name:
		"title":
			_snap(name)
			game.new_game()
			wait = 25
		"new_game":
			_snap(name)
			game.open_pause()
			wait = 10
		"pause":
			_snap(name)
			game.show_settings(true)
			wait = 10
		"settings":
			_snap(name)
			game.goto(game.COURT)
			wait = 25
		"court":
			_snap(name)
			var court := current_scene
			court.m_state = "defeated"
			court.victory_t = 15.5
			court.step(0.016)
			wait = 20
		"chapter_end":
			_snap(name)
			game.quit_to_title()
			wait = 20
		"back_to_title":
			_snap(name)
			print("checkpoint=", game.checkpoint, " flags=", game.flags)
	step += 1
	return false
