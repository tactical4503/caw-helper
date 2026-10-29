extends SceneTree
## Run with a renderer: SurfaceTool/ArrayMesh data is unavailable in dummy headless mode.
## godot --path afterbell-godot -s res://tests/geometry_test.gd
const Props := preload("res://scripts/props.gd")
var failures := 0

func check(ok: bool, label: String) -> void:
	print(("ok: " if ok else "FAIL: ") + label)
	if not ok:
		failures += 1

func _initialize() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("geometry_test requires a renderer")
		quit(1)
		return
	var low := Props.rounded_block(0.7, 3.0, 0.7, 0.055, 0.02, 2)
	var high := Props.rounded_block(0.7, 3.0, 0.7, 0.055, 0.02, 5)
	check(low != high, "cache distinguishes tessellation for identical dimensions")
	check(low == Props.rounded_block(0.7, 3.0, 0.7, 0.055, 0.02, 2), "matching pieces share their cached mesh")
	check(low.get_surface_count() == 1 and high.get_surface_count() == 1, "one material surface per stone piece")
	var low_indices: PackedInt32Array = low.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	var high_indices: PackedInt32Array = high.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	check(low_indices.size() < high_indices.size(), "two-segment corners reduce submitted geometry")
	check(low.get_aabb().position.is_equal_approx(Vector3(-0.35, 0, -0.35)), "stone rests at y=0 and keeps the shaft footprint")
	check(low.get_aabb().size.is_equal_approx(Vector3(0.7, 3.0, 0.7)), "coarse and fine stone keep authored dimensions")
	print("RESULT: %s (%d failure(s))" % ["FAIL" if failures else "PASS", failures])
	quit(1 if failures else 0)
