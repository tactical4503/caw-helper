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


## A texture set made by tools/make_texture.py (assets/textures/NAME/{albedo,normal,roughness}.png).
## Triplanar, so any box gets the same texel density. Falls back to `fallback` if it's missing.
static func textured(name: String, scale: float, fallback: StandardMaterial3D, metal := 0.0) -> StandardMaterial3D:
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
	m.metallic_specular = 0.5
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * scale
	return m


## A flat sign face from assets/textures/signs/NAME.png (glossy enamel).
static func sign_face(name: String) -> StandardMaterial3D:
	var path := "res://assets/textures/signs/%s.png" % name
	if not ResourceLoader.exists(path):
		return null
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(path)
	m.roughness = 0.2
	m.clearcoat_enabled = true
	m.clearcoat = 0.4
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
	# Warm department-store interior: lamplight, warm bounce, soft bloom on the lamps and brass.
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("2a1c1a")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("ffd9b0")
	e.ambient_light_energy = 0.22
	e.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 0.85
	e.ssr_enabled = true            # glossy floors and counters mirror the lamps (Forward+)
	e.ssr_max_steps = 48
	e.ssao_enabled = true           # contact shadows under counters and along walls
	e.ssao_intensity = 1.5
	e.glow_enabled = true           # lamps and brass bloom softly
	e.glow_intensity = 0.6
	e.glow_bloom = 0.08
	e.glow_hdr_threshold = 1.2
	e.fog_enabled = true            # warm haze gives the hall depth
	e.fog_light_color = Color("c99a70")
	e.fog_density = 0.008
	e.adjustment_enabled = true
	e.adjustment_saturation = 1.15
	e.adjustment_contrast = 1.05
	return e


## One strong sun with crisp shadows and full specular.
static func sun() -> DirectionalLight3D:
	var key := DirectionalLight3D.new()
	key.light_color = Color("ffd2a0")   # late sun through the atrium skylight
	key.light_energy = 0.5
	key.light_specular = 1.0
	key.shadow_enabled = true
	key.shadow_blur = 0.3
	key.directional_shadow_max_distance = 40.0
	key.rotation = Vector3(deg_to_rad(-52), deg_to_rad(-38), 0)
	return key
