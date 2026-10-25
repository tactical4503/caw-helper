extends RefCounted
## Third-party models from the AFTERBELL asset package (assets/imports/, kept out of git; see
## docs/ASSET_IMPORT.md). Each model is wrapped, never edited: a wrapper Node3D whose visual child
## carries the scale/orientation fix, rests on the floor at the wrapper's origin, and gets
## project-local material overrides (the package's MTL values are not used as final materials).
## `make()` returns null when the files are absent, so callers can skip the asset cleanly.

const ROOT := "res://assets/imports/"

## One unit of the Stage sections, in metres. All 17 share the source game's unit, which reads as
## roughly a metre (corridors about 4 units high, façade storeys 3-4 units); judged from renders,
## not measured against a known doorway, so treat it as approximate.
const STAGE_UNIT := 1.0

## id -> { path, label, height (metres, top of the model) or scale, yaw, rough, kind, two_sided,
##        by_texture (see MANNEQUIN), pivot ("source" keeps the file's origin) }
## two_sided: the source mesh is only modelled from the front (a background piece), so its
## material draws back faces too instead of the shaft vanishing from behind.
## kind: "prop" (static mesh), "character" (skinned glTF: the skeleton is kept, there are no clips),
## "stage" (environment section at STAGE_UNIT).
const ASSETS := {
	"pillar_snowpoint": {"path": "environments/snowpoint_temple_pillar/Snowpoint Temple Pillar.obj",
		"label": "Snowpoint Temple Pillar", "height": 5.0, "rough": 0.72, "kind": "prop", "two_sided": true},
	"pillar_turnback": {"path": "environments/turnback_cave_pillar/Turnback Cave Pillar.obj",
		"label": "Turnback Cave Pillar", "height": 5.0, "rough": 0.72, "kind": "prop", "two_sided": true},
	# Dress forms on turned wooden stands, already in metres (1.50 m and 1.52 m).
	"mannequin_female": {"path": "props/mannequin_female/mannequin_female_a_977de03af93efb9e.obj",
		"label": "Mannequin (female)", "scale": 1.0, "rough": 0.85, "kind": "prop", "by_texture": MANNEQUIN},
	"mannequin_male": {"path": "props/mannequin_male/mannequin_male_01_977de03af93efb9e.obj",
		"label": "Mannequin (male)", "scale": 1.0, "rough": 0.85, "kind": "prop", "by_texture": MANNEQUIN},
	# Already in metres (0.52 m long). Both surfaces sample Textures/case1.png's twin at the root.
	"suitcase": {"path": "props/suitcase/Small Suitcase (DR2).obj",
		"label": "Suitcase", "scale": 1.0, "rough": 0.55, "kind": "prop"},
	# Skinned glTF figures (32-bone skeletons, rest pose, no animation clips), already in metres.
	# The folders keep the source file names: the plum clerk is npc10, the teal clerk npc12.
	"clerk_plum": {"path": "characters/plum_clerk_npc10/npc10.gltf",
		"label": "Plum clerk (npc10)", "scale": 1.0, "rough": 0.8, "kind": "character"},
	"clerk_teal": {"path": "characters/teal_clerk_npc12/npc12.gltf",
		"label": "Teal clerk (npc12)", "scale": 1.0, "rough": 0.8, "kind": "character"},
	"eric": {"path": "characters/eric_zombi21/zombi21.gltf",
		"label": "Eric (zombi21)", "scale": 1.0, "rough": 0.8, "kind": "character"},
	"franklin": {"path": "characters/franklin_zombi20/zombi20.gltf",
		"label": "Franklin (zombi20)", "scale": 1.0, "rough": 0.8, "kind": "character"},
	# Stage sections: supplied source environments with their original textures, at their source
	# origin and STAGE_UNIT. Reference only, not AFTERBELL levels (staging, not the chapter).
	"stage1_1_1_a": {"path": "environments/stage1_1_1_a/1-1-A.obj",
		"label": "Stage 1 / 1-1-A", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage1_1_1_b": {"path": "environments/stage1_1_1_b/1-1-B.obj",
		"label": "Stage 1 / 1-1-B", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage1_1_1_c": {"path": "environments/stage1_1_1_c/1-1-C.obj",
		"label": "Stage 1 / 1-1-C", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage1_1_2_a": {"path": "environments/stage1_1_2_a/1-2-A.obj",
		"label": "Stage 1 / 1-2-A", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage1_1_2_b": {"path": "environments/stage1_1_2_b/1-2-B.obj",
		"label": "Stage 1 / 1-2-B", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage1_1_2_c": {"path": "environments/stage1_1_2_c/1-2-C.obj",
		"label": "Stage 1 / 1-2-C", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage1_1_3": {"path": "environments/stage1_1_3/1-3.obj",
		"label": "Stage 1 / 1-3", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_1_a": {"path": "environments/stage2_2_1_a/2-1-A.obj",
		"label": "Stage 2 / 2-1-A", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_1_b": {"path": "environments/stage2_2_1_b/2-1-B.obj",
		"label": "Stage 2 / 2-1-B", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_1_c": {"path": "environments/stage2_2_1_c/2-1-C.obj",
		"label": "Stage 2 / 2-1-C", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_2_a": {"path": "environments/stage2_2_2_a/2-2-A.obj",
		"label": "Stage 2 / 2-2-A", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_2_b": {"path": "environments/stage2_2_2_b/2-2-B.obj",
		"label": "Stage 2 / 2-2-B", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_2_c": {"path": "environments/stage2_2_2_c/2-2-C.obj",
		"label": "Stage 2 / 2-2-C", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_2_c_tes": {"path": "environments/stage2_2_2_c_tes/2-2-C_tes.obj",
		"label": "Stage 2 / 2-2-C_tes", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_3_a": {"path": "environments/stage2_2_3_a/2-3-A.obj",
		"label": "Stage 2 / 2-3-A", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_3_b": {"path": "environments/stage2_2_3_b/2-3-B.obj",
		"label": "Stage 2 / 2-3-B", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
	"stage2_2_3_c": {"path": "environments/stage2_2_3_c/2-3-C.obj",
		"label": "Stage 2 / 2-3-C", "scale": STAGE_UNIT, "rough": 0.8, "kind": "stage", "pivot": "source"},
}

## Per-surface overrides keyed by the surface's albedo file: roughness, and the package's own
## tangent-space normal map (the MTL's map_Bump, which Godot's OBJ import leaves unused).
const MANNEQUIN := {
	"fine_fabric_white.png": {"rough": 0.88, "normal": "fine_fabric_white_local.png"},
	"fine_wood_polished_01.png": {"rough": 0.42, "normal": "fine_wood_polished_01_local.png"},
}


static func exists(id: String) -> bool:
	return ASSETS.has(id) and ResourceLoader.exists(ROOT + ASSETS[id].path)


## The wrapped model, or null if its files are not in the project.
static func make(id: String) -> Node3D:
	if not exists(id):
		return null
	var spec: Dictionary = ASSETS[id]
	var res := load(ROOT + spec.path)
	var visual: Node3D
	if res is Mesh:
		var mi := MeshInstance3D.new()
		mi.mesh = res
		visual = mi
	elif res is PackedScene:
		visual = res.instantiate()
	else:
		return null
	visual.name = "Visual"
	_override_materials(visual, spec)
	var box := _bounds(visual, Transform3D.IDENTITY)
	var s: float = spec.get("scale", 1.0)
	if spec.has("height") and box.size.y > 0.0:
		s = spec.height / box.size.y
	visual.scale = Vector3.ONE * s
	visual.rotation.y = spec.get("yaw", 0.0)
	# Pivot: centred over the wrapper's origin, resting on y = 0 (stage sections keep their own).
	var c := box.get_center()
	if spec.get("pivot", "") != "source":
		visual.position = Basis(Vector3.UP, visual.rotation.y) * Vector3(-c.x, -box.position.y, -c.z) * s
	var wrapper := Node3D.new()
	wrapper.name = id
	wrapper.set_meta("import_id", id)
	wrapper.add_child(visual)
	return wrapper


static func _override_materials(n: Node, spec: Dictionary) -> void:
	if n is MeshInstance3D and n.mesh:
		for i in n.mesh.get_surface_count():
			var src: Material = n.mesh.surface_get_material(i)
			n.set_surface_override_material(i, _local_material(src, spec))
	for c in n.get_children():
		_override_materials(c, spec)


static var _cache := {}

## A project-local copy of the imported material: the package PNG as plain albedo, untinted,
## opaque unless the texture really has cut-out alpha, repeating UVs, matte.
static func _local_material(src: Material, spec: Dictionary) -> Material:
	if not (src is BaseMaterial3D):
		return src
	var tex: Texture2D = src.albedo_texture
	var own: Dictionary = spec.get("by_texture", {}).get(tex.resource_path.get_file() if tex else "", {})
	var key := "%s|%s|%s|%s" % [tex.resource_path if tex else str(src.get_instance_id()), spec.get("rough", 0.7), src.cull_mode, spec.get("two_sided", false)]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color.WHITE
	m.albedo_texture = tex
	m.roughness = own.get("rough", spec.get("rough", 0.7))
	if own.has("normal"):
		var np: String = tex.resource_path.get_base_dir() + "/" + own.normal
		if ResourceLoader.exists(np):
			m.normal_enabled = true
			m.normal_texture = load(np)
			m.normal_scale = 0.6
	m.metallic = 0.0
	m.metallic_specular = 0.35
	m.texture_repeat = true
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	m.cull_mode = BaseMaterial3D.CULL_DISABLED if spec.get("two_sided", false) else src.cull_mode
	# A glTF surface authored as see-through (alpha below 1, blended) stays see-through, alone.
	if spec.get("kind") == "character" and src.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA and src.albedo_color.a < 0.99:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color.a = src.albedo_color.a
	elif tex and _has_cutout(tex):
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		m.alpha_scissor_threshold = 0.5
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_cache[key] = m
	return m


static func _has_cutout(tex: Texture2D) -> bool:
	var img := tex.get_image()
	if img == null:
		return false
	if img.is_compressed():
		img = img.duplicate()
		if img.decompress() != OK:
			return false
	return img.detect_alpha() != Image.ALPHA_NONE


static func _bounds(n: Node, xf: Transform3D) -> AABB:
	var out := AABB()
	var first := true
	var here: Transform3D = xf * (n.transform if n is Node3D else Transform3D.IDENTITY)
	if n is MeshInstance3D and n.mesh:
		out = here * n.mesh.get_aabb()
		first = false
	for c in n.get_children():
		var b := _bounds(c, here)
		if b.size == Vector3.ZERO:
			continue
		out = b if first else out.merge(b)
		first = false
	return out
