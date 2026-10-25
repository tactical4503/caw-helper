extends SceneTree
## Prints what Godot imported for one model: surfaces, their materials and textures, bounds.
## godot --headless --path . -s res://tools/inspect_import.gd -- res://assets/imports/<dir>/<model>

func _init() -> void:
	for path in OS.get_cmdline_user_args():
		var res := load(path)
		print("== ", path, " -> ", res)
		if res is Mesh:
			_mesh(res, "")
		elif res is PackedScene:
			var root: Node = res.instantiate()
			_walk(root, "")
			root.free()
	quit()

func _walk(n: Node, ind: String) -> void:
	var extra := ""
	if n is Skeleton3D:
		extra = " bones=%d" % n.get_bone_count()
	if n is AnimationPlayer:
		extra = " anims=%s" % [n.get_animation_list()]
	print(ind, n.name, " <", n.get_class(), ">", extra)
	if n is MeshInstance3D and n.mesh:
		_mesh(n.mesh, ind + "  ")
	for c in n.get_children():
		_walk(c, ind + "  ")

func _mesh(m: Mesh, ind: String) -> void:
	print(ind, "aabb ", m.get_aabb(), " surfaces ", m.get_surface_count())
	for i in m.get_surface_count():
		var mat := m.surface_get_material(i)
		var desc := "none"
		if mat is BaseMaterial3D:
			var t: Texture2D = mat.albedo_texture
			desc = "col=%s tex=%s transp=%d cull=%d rough=%.2f metal=%.2f normal=%s" % [mat.albedo_color, t.resource_path.get_file() if t else "-", mat.transparency, mat.cull_mode, mat.roughness, mat.metallic, mat.normal_enabled]
		var nm := ""
		if m is ArrayMesh:
			nm = m.surface_get_name(i)
		var tris: int = m.surface_get_arrays(i)[Mesh.ARRAY_VERTEX].size()
		print(ind, "  [", i, "] ", nm, " v=", tris, " ", desc)
