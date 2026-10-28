extends RefCounted
## Static batching: merges every non-moving mesh under a root into one mesh per
## (material, shadow mode, layer, grid cell). Props are baked one mesh per kind but each placement
## is still its own draw per surface, and each one is drawn again in every shadow pass; merging
## them by material inside CELL-metre cells cuts those draws by an order of magnitude while
## keeping frustum culling working (a cell off screen is skipped whole).
##
## Skipped (left as they are): anything under a node in `keep` (moving parts the game animates),
## skinned meshes, meshes without data, and nodes that aren't plain MeshInstance3D (labels, decals,
## multimeshes, lights).

const CELL := 16.0


static var _looks := {}


## One shared instance per distinct look: builders often make a fresh but identical material per
## part, which would otherwise keep identical parts in separate batches.
static func _same(m: Material) -> Material:
	if not (m is BaseMaterial3D):
		return m
	var b := m as BaseMaterial3D
	var tex := func(t: Texture2D) -> String: return str(t.get_rid().get_id()) if t else "-"
	var key := "%s|%s|%.3f|%.3f|%.3f|%d|%d|%s|%s|%s|%s|%s|%d|%.2f|%s|%s|%d|%d|%.3f" % [b.albedo_color, tex.call(b.albedo_texture),
		b.roughness, b.metallic, b.metallic_specular, b.transparency, b.cull_mode, b.uv1_scale, b.uv1_triplanar,
		tex.call(b.normal_texture), tex.call(b.roughness_texture), b.emission_enabled, b.shading_mode, b.normal_scale,
		b.emission, b.clearcoat_enabled, b.blend_mode, b.texture_filter, b.emission_energy_multiplier]
	if not _looks.has(key):
		_looks[key] = m
	return _looks[key]


static func batch(root: Node3D, keep: Array = []) -> Dictionary:
	if DisplayServer.get_name() == "headless":
		return {}   # no mesh data without a renderer; tests don't need the batching
	var keep_set := {}
	for k in keep:
		if k:
			keep_set[k] = true
	var groups := {}
	var victims: Array = []
	var stack := [root]
	var root_inv := root.global_transform.affine_inverse()
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for c in node.get_children():
			if keep_set.has(c) or c is Skeleton3D or c is AnimationPlayer:
				continue
			if c is MeshInstance3D:
				var mi := c as MeshInstance3D
				if mi.mesh != null and mi.skin == null and mi.visible and mi.get_child_count() == 0 and not mi.has_meta("no_batch"):
					var xf := root_inv * mi.global_transform
					var aabb := xf * mi.mesh.get_aabb()
					var centre := aabb.get_center()
					var cell := Vector3i(floori(centre.x / CELL), 0, floori(centre.z / CELL))
					for s in mi.mesh.get_surface_count():
						var mat: Material = _same(mi.get_active_material(s))
						if mat == null:
							continue
						var key := "%d|%d|%d|%s" % [mat.get_instance_id(), mi.cast_shadow, mi.layers, cell]
						if not groups.has(key):
							groups[key] = [mat, mi.cast_shadow, mi.layers, []]
						groups[key][3].append([mi.mesh, s, xf])
					victims.append(mi)
					continue
			if c is Node3D or c is Node:
				stack.append(c)
	var holder := Node3D.new()
	holder.name = "Batched"
	root.add_child(holder)
	var before := 0
	for v in victims:
		before += (v as MeshInstance3D).mesh.get_surface_count()
	var made := 0
	for key in groups:
		var g: Array = groups[key]
		var st := SurfaceTool.new()
		for part in g[3]:
			st.append_from(part[0], part[1], part[2])
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = g[0]
		mi.cast_shadow = g[1]
		mi.layers = g[2]
		holder.add_child(mi)
		made += 1
	for v in victims:
		v.get_parent().remove_child(v)
		v.free()
	return {"before": before, "after": made}
