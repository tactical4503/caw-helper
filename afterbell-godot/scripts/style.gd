extends RefCounted
## Visual style: mid-90s ray-traced CGI promo-render look.
## Glossy plastic with hard specular hotspots, saturated colour, very round geometry, procedural
## noise textures with bump on stone/brick/wood, one strong sun with crisp shadows, a vivid blue
## sky that lights and reflects into everything, and mirror-like water and polished floors.
## Every material in the game comes through here, so the look can be retuned (or replaced by
## real textures) in one place.

const SATURATION := 1.08     # push colours toward the bold primaries of the era
const GLOSS := 0.3           # scales authored roughness down: everything reads as lacquer/plastic
const SEGMENTS := 32         # round things need dense tessellation for clean highlights


static func _boost(c: Color) -> Color:
	return Color.from_hsv(c.h, minf(c.s * SATURATION, 1.0), c.v, c.a)


## Glossy plastic (or polished metal when metal > 0). `rough` is the authored value; the style
## maps it into the shiny range so even "matte" surfaces keep a soft hotspot.
static func plastic(color: Color, rough: float, metal: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = _boost(color)
	m.metallic = metal
	m.roughness = clampf(rough * GLOSS + 0.05, 0.05, 0.4)
	m.metallic_specular = 0.5
	if metal < 0.5:
		# A thin, sharp clearcoat gives the hard white hotspot without washing the base colour
		# out with sky reflections.
		m.clearcoat_enabled = true
		m.clearcoat = 0.35
		m.clearcoat_roughness = 0.05
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
	m.roughness = {"marble": 0.15, "stone": 0.6, "wood": 0.4}.get(kind, 0.9)  # carpet stays matte
	m.metallic_specular = 0.4
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
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("1d47b8")
	sky_mat.sky_horizon_color = Color("a9d4ff")
	sky_mat.sky_curve = 0.12
	sky_mat.ground_horizon_color = Color("a9d4ff")
	sky_mat.ground_bottom_color = Color("24406e")
	sky_mat.sun_angle_max = 20.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.35
	e.ambient_light_sky_contribution = 0.35
	e.ambient_light_color = Color("ffe8cc")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	# 90s renderers had no tone mapping: colours stay pure and hotspots simply clip to white.
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	e.tonemap_exposure = 0.85
	e.ssr_enabled = true            # glossy floors and water mirror the scene (Forward+)
	e.ssr_max_steps = 48
	e.glow_enabled = true           # specular hotspots bloom slightly, as in the old renders
	e.glow_intensity = 0.35
	e.glow_bloom = 0.04
	e.glow_hdr_threshold = 1.1
	e.fog_enabled = true            # blue atmospheric depth
	e.fog_light_color = Color("9cc8ff")
	e.fog_density = 0.0015
	e.fog_aerial_perspective = 0.6
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.0
	e.adjustment_contrast = 1.1
	return e


## One strong sun with crisp shadows and full specular.
static func sun() -> DirectionalLight3D:
	var key := DirectionalLight3D.new()
	key.light_color = Color("fff6e4")
	key.light_energy = 1.35
	key.light_specular = 1.0
	key.shadow_enabled = true
	key.shadow_blur = 0.3
	key.directional_shadow_max_distance = 40.0
	key.rotation = Vector3(deg_to_rad(-52), deg_to_rad(-38), 0)
	return key
