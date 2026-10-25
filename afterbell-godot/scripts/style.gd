extends RefCounted
## Visual style: mid-90s ray-traced CGI promo-render look.
## Matte painted surfaces with reflections kept to metal, saturated colour, very round geometry, procedural
## noise textures with bump on stone/brick/wood, one strong sun with crisp shadows, a vivid blue
## sky that lights and reflects into everything, and mirror-like water and polished floors.
## Every material in the game comes through here, so the look can be retuned (or replaced by
## real textures) in one place.

const SATURATION := 1.08     # push colours toward the bold primaries of the era
const SEGMENTS := 32         # round things need dense tessellation for clean highlights


static func _boost(c: Color) -> Color:
	return Color.from_hsv(c.h, minf(c.s * SATURATION, 1.0), c.v, c.a)


## Painted / lacquered surfaces are matte-to-satin; only metal (metal >= 0.5) is polished.
## `rough` is the authored value: 0 = satin, 1 = fully matte. Metals map into a tight, shiny range
## so brass, steel and the like carry the reflections in a scene.
static func plastic(color: Color, rough: float, metal: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = _boost(color)
	m.metallic = metal
	if metal >= 0.5:
		m.roughness = clampf(rough * 0.6, 0.15, 0.45)
		m.metallic_specular = 0.5
	else:
		m.roughness = clampf(0.55 + rough * 0.4, 0.55, 0.95)
		m.metallic_specular = 0.3
	return m


## Procedural surfaces in the spirit of 90s shader noise: a two-colour ramp driven by noise,
## a matching bump map, and triplanar mapping so any box gets consistent texel density.
static func procedural(dark: Color, light: Color, kind: String, scale := 0.5) -> StandardMaterial3D:
	var noise := FastNoiseLite.new()
	noise.seed = hash(kind) % 1000
	match kind:
		"stone":   # mottled stone / brick face
			noise.noise_type = FastNoiseLite.TYPE_CELLULAR
			noise.frequency = 0.035
			noise.fractal_octaves = 3
		"marble":  # streaked polished floor
			noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			noise.frequency = 0.012
			noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
			noise.fractal_octaves = 4
		"wood":
			noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
			noise.frequency = 0.01
			noise.fractal_octaves = 2
		_:         # carpet / fabric nap
			noise.noise_type = FastNoiseLite.TYPE_VALUE
			noise.frequency = 0.18
			noise.fractal_octaves = 2
	var ramp := Gradient.new()
	ramp.set_color(0, _boost(dark))
	ramp.set_color(1, _boost(light))
	var albedo := NoiseTexture2D.new()
	albedo.width = 512
	albedo.height = 512
	albedo.seamless = true
	albedo.noise = noise
	albedo.color_ramp = ramp
	var bump := NoiseTexture2D.new()
	bump.width = 512
	bump.height = 512
	bump.seamless = true
	bump.noise = noise
	bump.as_normal_map = true
	bump.bump_strength = 6.0 if kind == "stone" else 2.0
	var m := StandardMaterial3D.new()
	m.albedo_texture = albedo
	m.normal_enabled = true
	m.normal_texture = bump
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * scale
	m.roughness = {"marble": 0.45, "stone": 0.75, "wood": 0.65}.get(kind, 0.9)  # satin at most
	m.metallic_specular = 0.4
	return m


## Every surface texture covers this many metres per repeat, so detail is equally sharp on
## neighbouring objects (1024 px over 2 m = about 5 px per cm everywhere).
const TEXTURE_TILE_M := 2.0


## A texture set made by tools/quiet_textures.py (assets/textures/NAME/{albedo,normal,roughness}.png).
## Triplanar at one shared density (TEXTURE_TILE_M), so any box and any material match.
## `_legacy_scale` is ignored: per-call scales made neighbouring surfaces disagree.
## Falls back to `fallback` if the set is missing.
static func textured(name: String, _legacy_scale: float, fallback: StandardMaterial3D, metal := 0.0) -> StandardMaterial3D:
	var dir := "res://assets/textures/%s/" % name
	if not ResourceLoader.exists(dir + "albedo.png"):
		return fallback
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(dir + "albedo.png")
	m.normal_enabled = true
	m.normal_texture = load(dir + "normal.png")
	m.roughness = 1.0
	m.roughness_texture = load(dir + "roughness.png")
	m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
	m.metallic = metal
	m.metallic_specular = 0.5 if metal >= 0.5 else 0.35
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE / TEXTURE_TILE_M
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC   # no shimmer at grazing angles
	return m


## A flat sign face from assets/textures/signs/NAME.png (satin enamel).
static func sign_face(name: String) -> StandardMaterial3D:
	var path := "res://assets/textures/signs/%s.png" % name
	if not ResourceLoader.exists(path):
		return null
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(path)
	m.roughness = 0.55
	return m


static func water() -> StandardMaterial3D:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.02
	var ripples := NoiseTexture2D.new()
	ripples.seamless = true
	ripples.noise = noise
	ripples.as_normal_map = true
	ripples.bump_strength = 3.0
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.03, 0.32, 0.58, 0.9)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.02
	m.metallic = 0.4
	m.normal_enabled = true
	m.normal_texture = ripples
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * 0.25
	return m


static func environment() -> Environment:
	# Department-store interior. Neutral-warm ambient keeps the plum walls plum (not salmon), SSAO
	# darkens corners and the undersides of counters, and only the lamps are bright enough to bloom.
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("1c1416")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("f0d8c2")   # warm fill so shade reads amber, not grey
	e.ambient_light_energy = 0.36
	e.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.92   # keeps cream walls off pure white
	e.tonemap_white = 6.0
	e.ssr_enabled = false           # expensive; off by default (glossy materials still catch lamp highlights)
	e.ssao_enabled = true           # contact shadows: corners, under counters, around feet
	e.ssao_radius = 1.2
	e.ssao_intensity = 1.5
	e.ssao_power = 1.3
	e.glow_enabled = true           # a soft halo round the window and lamps, never a white blob
	e.glow_intensity = 0.18
	e.glow_strength = 0.9
	e.glow_bloom = 0.0
	e.glow_hdr_threshold = 1.2
	e.fog_enabled = true            # faint depth falloff, not a milky haze
	e.fog_light_color = Color("3a2a26")
	e.fog_density = 0.0025
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.05
	e.adjustment_contrast = 1.1
	return e


## Overhead key: daylight from the atrium skylight, nearly vertical so shadows read as indoor and
## fall under things rather than across the room. Kept low; the lamps do the warm work.
static func sun() -> DirectionalLight3D:
	var key := DirectionalLight3D.new()
	key.light_color = Color("ffcfae")   # peach: late sun through the skylights
	key.light_energy = 0.4
	key.light_specular = 0.6
	key.shadow_enabled = true
	key.shadow_blur = 5.0
	key.light_angular_distance = 4.0   # wide source: shadow edges soften with distance
	key.shadow_opacity = 0.65
	key.shadow_bias = 0.04
	key.directional_shadow_max_distance = 25.0
	key.rotation = Vector3(deg_to_rad(-78), deg_to_rad(-20), 0)
	return key


static var _lamp_glass: StandardMaterial3D


## A wall or column lamp: a frosted cream globe that glows without blowing out, and a warm soft
## pool of light. No shadows (cheap); low specular so walls get a sheen, not a hot spot.
## `light_offset` moves the light itself away from the wall so the wall gets an even wash.
static func lamp(parent: Node3D, at: Vector3, energy := 0.9, reach := 5.5, light_offset := Vector3.ZERO) -> OmniLight3D:
	globe(parent, at)
	var light := OmniLight3D.new()
	light.light_color = Color("ffbb80")
	light.light_energy = energy * 0.6   # soft pools, no hot spot on the column beside it
	light.light_specular = 0.1
	light.omni_range = reach
	light.omni_attenuation = 1.0   # broad, even falloff rather than a hot core
	light.position = at + light_offset
	parent.add_child(light)
	return light


static var _lamp_cap: StandardMaterial3D


## A lamp fixture with no light of its own: a squat amber glass shade under a brass cap. Its glow
## stays under the bloom threshold so it reads as warm glass, never a white blob.
static func globe(parent: Node3D, at: Vector3, radius := 0.14) -> MeshInstance3D:
	if _lamp_glass == null:
		_lamp_glass = StandardMaterial3D.new()
		_lamp_glass.albedo_color = Color("c98a52")   # amber glass
		_lamp_glass.roughness = 0.75
		_lamp_glass.emission_enabled = true
		_lamp_glass.emission = Color("ff9448")
		_lamp_glass.emission_energy_multiplier = 0.45
		_lamp_cap = StandardMaterial3D.new()
		_lamp_cap.albedo_color = Color("b58d3f")
		_lamp_cap.metallic = 0.85
		_lamp_cap.roughness = 0.35
	var g := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 20
	sphere.rings = 10
	g.mesh = sphere
	g.scale = Vector3(1.0, 0.82, 1.0)
	g.material_override = _lamp_glass
	g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	g.position = at
	parent.add_child(g)
	var cap := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius * 0.35
	cyl.bottom_radius = radius * 0.75
	cyl.height = radius * 0.45
	cyl.radial_segments = 16
	cap.mesh = cyl
	cap.material_override = _lamp_cap
	cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cap.position = at + Vector3(0, radius * 0.85, 0)
	parent.add_child(cap)
	return g


## Overhead fill from the ceiling fixtures: neutral-warm pools on the floor, falling off at walls.
static func ceiling_light(parent: Node3D, at: Vector3, energy := 0.8, reach := 7.0) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.light_color = Color("ffdcb4")
	light.light_energy = energy
	light.light_specular = 0.0
	light.omni_range = reach
	light.omni_attenuation = 1.3
	light.position = at - Vector3(0, 0.7, 0)   # hang below the ceiling so it doesn't glare on it
	parent.add_child(light)
	return light
