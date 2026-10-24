extends RefCounted
## The court's vertical space: Bellwether's central atrium rising three floors above the bell.
##
## Built around the existing court (x -8..8, z -9..9, floor at 0) without touching anything
## the fight uses. North of the bell the floor runs on to two escalators rising to a menswear
## mezzanine, under a tall arched sunset window. East and west, galleries on two upper floors
## sit behind the court's columns. A coffered roof with a skylight closes it all at 16 m.

const ST := preload("res://scripts/style.gd")
const Props := preload("res://scripts/props.gd")

const CREAM := Color("efe3c8")
const IVORY := Color("e6dccb")
const PLUM := Color("5b2a4a")
const PLUM_DEEP := Color("3a1a2f")
const BRASS := Color("b58d3f")
const WOOD := Color("8a6440")

const OUTER_X := 13.0         # outer walls of the side galleries
const GALLERY_X := 8.6        # gallery fronts, just behind the court's columns
const NORTH_Z := -26.0        # back wall with the window
const SOUTH_Z := 9.6
const MEZZ_Z := -18.6         # mezzanine front edge (escalator tops)
const ESC_X := 5.4            # escalators sit either side of the centre line
const ESC_FOOT_Z := -10.0
const LEVELS := [5.0, 10.2]   # upper floor heights
const ROOF := 16.0
const SLAB := 0.45

static var _mats := {}


static func build(root: Node3D) -> void:
	var a := Node3D.new()
	a.name = "Atrium"
	root.add_child(a)
	_shell(a)
	_galleries(a)
	_mezzanine(a)
	for side in [-1.0, 1.0]:
		escalator(a, Vector3(side * ESC_X, 0, ESC_FOOT_Z), LEVELS[0], MEZZ_Z)
	_window(a)
	_roof(a)
	_lower_hall(a)
	_dress_aisles(a)
	_lights(a)
	merge(a)


# ---------------------------------------------------------------- structure

static func _shell(a: Node3D) -> void:
	var depth := SOUTH_Z - NORTH_Z
	var mid_z := (SOUTH_Z + NORTH_Z) * 0.5
	# Floor beyond the court (the court's own floor sits on top of this, a few mm higher).
	_put(_box(OUTER_X * 2.0, 0.1, depth), _m("floor"), Vector3(0, -0.055, mid_z), a, false)
	# Outer walls, full height: plum below, cream stone above the first gallery.
	for s in [-1.0, 1.0]:
		_put(_box(0.4, LEVELS[0], depth), _m("plum_wall"), Vector3(s * (OUTER_X + 0.2), LEVELS[0] * 0.5, mid_z), a)
		_put(_box(0.4, ROOF - LEVELS[0], depth), _m("stone"), Vector3(s * (OUTER_X + 0.2), (ROOF + LEVELS[0]) * 0.5, mid_z), a)
	_put(_box(OUTER_X * 2.0, ROOF, 0.4), _m("stone"), Vector3(0, ROOF * 0.5, SOUTH_Z + 0.2), a)
	_put(_box(OUTER_X * 2.0, ROOF, 0.4), _m("stone"), Vector3(0, ROOF * 0.5, NORTH_Z - 0.2), a)
	# North of the bell partition: low balustrades either side, so the lower hall and the
	# escalators read through.
	for s in [-1.0, 1.0]:
		var x0: float = s * 1.9
		var x1: float = s * 8.15
		_put(_box(absf(x1 - x0), 1.05, 0.25), _m("cream"), Vector3((x0 + x1) * 0.5, 0.52, -9.15), a)
		_put(_box(absf(x1 - x0), 0.08, 0.3), _m("brass"), Vector3((x0 + x1) * 0.5, 1.07, -9.15), a)


static func _galleries(a: Node3D) -> void:
	var depth := SOUTH_Z - NORTH_Z
	var mid_z := (SOUTH_Z + NORTH_Z) * 0.5
	var width := OUTER_X - GALLERY_X
	for level in LEVELS:
		for s in [-1.0, 1.0]:
			var cx: float = s * (GALLERY_X + width * 0.5)
			_put(_box(width, SLAB, depth), _m("slab"), Vector3(cx, level - SLAB * 0.5, mid_z), a)
			_put(_box(width - 0.2, 0.02, depth - 0.2), _m("carpet"), Vector3(cx, level + 0.01, mid_z), a, false)
			_fascia(a, Vector3(s * GALLERY_X, level, mid_z), Vector3(0, 0, depth))
			balustrade(a, Vector3(s * (GALLERY_X + 0.1), level, NORTH_Z), Vector3(s * (GALLERY_X + 0.1), level, SOUTH_Z))
			# Dressing: racks against the back wall, mannequins looking down over the rail.
			for z in [-21.0, -13.0, -5.0, 3.0]:
				rack(a, Vector3(s * (OUTER_X - 0.7), level, z), PI / 2.0)
			for z in [-17.0, -9.0, -1.0, 6.5]:
				mannequin(a, Vector3(s * (GALLERY_X + 1.0), level, z), -s * PI / 2.0, int(z + level) % 3)
			for z in [-24.0, -15.0, -7.0, 1.0, 8.0]:
				ST.globe(a, Vector3(s * (OUTER_X - 0.12), level + 2.6, z), 0.16)
				_put(_box(0.08, 0.08, 0.08), _m("brass"), Vector3(s * (OUTER_X - 0.04), level + 2.6, z), a)


static func _mezzanine(a: Node3D) -> void:
	var level: float = LEVELS[0]
	var depth := MEZZ_Z - NORTH_Z
	var cz := (MEZZ_Z + NORTH_Z) * 0.5
	_put(_box(GALLERY_X * 2.0, SLAB, depth), _m("slab"), Vector3(0, level - SLAB * 0.5, cz), a)
	_put(_box(GALLERY_X * 2.0, 0.02, depth - 0.2), _m("carpet"), Vector3(0, level + 0.01, cz - 0.1), a, false)
	# Front fascia and rail, open where the escalators arrive.
	var gap := 0.8
	var spans := [[-GALLERY_X, -ESC_X - gap], [-ESC_X + gap, ESC_X - gap], [ESC_X + gap, GALLERY_X]]
	for span in spans:
		var x0: float = span[0]
		var x1: float = span[1]
		_fascia(a, Vector3((x0 + x1) * 0.5, level, MEZZ_Z), Vector3(x1 - x0, 0, 0))
		balustrade(a, Vector3(x0, level, MEZZ_Z - 0.1), Vector3(x1, level, MEZZ_Z - 0.1))
	var label := Label3D.new()
	label.text = "M E N S W E A R"
	label.font_size = 96
	label.pixel_size = 0.0055
	label.outline_size = 0
	label.modulate = Color("4a2238")
	label.position = Vector3(0, level - 0.28, MEZZ_Z + 0.17)
	a.add_child(label)
	for s in [-1.0, 1.0]:
		var gem := _put(_box(0.16, 0.16, 0.04), _m("brass"), Vector3(s * 2.2, level - 0.28, MEZZ_Z + 0.17), a)
		gem.rotation.z = PI / 4.0
	# Mannequins along the rail, racks and palms behind, a counter in the middle.
	for x in [-7.4, -3.0, 3.0, 7.4]:
		mannequin(a, Vector3(x, level, MEZZ_Z - 1.0), 0.0, int(absf(x)) % 3)
	for x in [-6.5, 6.5]:
		rack(a, Vector3(x, level, -23.4), 0.0)
	for x in [-3.9, 3.9]:
		palm(a, Vector3(x, level, -24.8))
	Props.counter(a, Vector3(0, level, -21.5), Vector3(2.4, Props.WAIST, 0.8))


## Cream fascia band along a floor edge (with brass trim), running `span` from `centre`.
static func _fascia(a: Node3D, centre: Vector3, span: Vector3) -> void:
	var along_x := absf(span.x) > absf(span.z)
	var length := span.length()
	var size := Vector3(length, 0.75, 0.3) if along_x else Vector3(0.3, 0.75, length)
	_put(_box(size.x, size.y, size.z), _m("cream"), centre + Vector3(0, -0.36, 0), a)
	var trim := Vector3(length, 0.06, 0.34) if along_x else Vector3(0.34, 0.06, length)
	for y in [-0.05, -0.68]:
		_put(_box(trim.x, trim.y, trim.z), _m("brass"), centre + Vector3(0, y, 0), a)


## Brass-capped balustrade from `from` to `to` (axis-aligned, at floor height). The balusters
## are one MultiMesh per run, so a long gallery rail is a single draw.
static func balustrade(a: Node3D, from: Vector3, to: Vector3, height := 1.0) -> void:
	var length := from.distance_to(to)
	var along_x := absf(to.x - from.x) > absf(to.z - from.z)
	var mid := (from + to) * 0.5
	var top := Vector3(length, 0.07, 0.12) if along_x else Vector3(0.12, 0.07, length)
	_put(_box(top.x, top.y, top.z), _m("brass"), mid + Vector3(0, height, 0), a)
	var base := Vector3(length, 0.1, 0.14) if along_x else Vector3(0.14, 0.1, length)
	_put(_box(base.x, base.y, base.z), _m("cream"), mid + Vector3(0, 0.05, 0), a)
	var count := int(length / 0.26)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _cyl(0.025, 0.035, height - 0.1, 8)
	mm.instance_count = count
	for i in count:
		var t := (i + 0.5) / float(count)
		mm.set_instance_transform(i, Transform3D(Basis(), from.lerp(to, t) + Vector3(0, height * 0.5 + 0.02, 0)))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = _m("brass")
	a.add_child(mmi)


## An escalator rising north from `foot` to floor height `rise`, its top landing at `top_z`.
## Stepped treads on a cream-clad truss, dark glass side panels and black handrails.
static func escalator(a: Node3D, foot: Vector3, rise: float, top_z: float, width := 1.15) -> void:
	var run := foot.z - top_z
	var length := sqrt(run * run + rise * rise)
	var pitch := atan2(rise, run)
	var e := Node3D.new()
	e.name = "Escalator"
	a.add_child(e)
	var mid := Vector3(foot.x, rise * 0.5, (foot.z + top_z) * 0.5)
	var up := Vector3(0, cos(pitch), sin(pitch))   # local "up" of the incline (rotation.x = pitch)
	# Truss: the solid underside, clad in cream with a brass seam.
	var truss := _put(_box(width + 0.36, 0.9, length + 0.6), _m("cream"), mid - up * 0.5, e)
	truss.rotation.x = pitch
	for s in [-1.0, 1.0]:
		var seam := _put(_box(0.02, 0.05, length + 0.6), _m("brass"), mid - up * 0.3 + Vector3(s * (width * 0.5 + 0.19), 0, 0), e)
		seam.rotation.x = pitch
	# Treads.
	var n := int(run / 0.4)
	var tread_d := run / n
	var riser := rise / n
	var steps := MultiMesh.new()
	steps.transform_format = MultiMesh.TRANSFORM_3D
	steps.mesh = _box(width, 0.3, tread_d)
	steps.instance_count = n
	for i in n:
		var y := (i + 1) * riser - 0.15
		steps.set_instance_transform(i, Transform3D(Basis(), Vector3(foot.x, y, foot.z - (i + 0.5) * tread_d)))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = steps
	mmi.material_override = _m("steps")
	e.add_child(mmi)
	# Comb plates at both ends.
	_put(_box(width, 0.05, 1.2), _m("steel"), Vector3(foot.x, 0.025, foot.z + 0.6), e)
	_put(_box(width, 0.05, 0.8), _m("steel"), Vector3(foot.x, rise + 0.03, top_z - 0.4), e)
	# Balustrades: smoked glass, black rubber handrail, curled newel ends.
	for s in [-1.0, 1.0]:
		var x: float = foot.x + s * (width * 0.5 + 0.08)
		var glass := _put(_box(0.04, 0.85, length + 0.2), _m("glass"), Vector3(x, mid.y, mid.z) + up * 0.55, e, false)
		glass.rotation.x = pitch
		var rail := _put(_box(0.09, 0.07, length + 0.2), _m("rubber"), Vector3(x, mid.y, mid.z) + up * 1.0, e)
		rail.rotation.x = pitch
		for end in [Vector3(x, 0.55, foot.z + 0.15), Vector3(x, rise + 0.55, top_z - 0.15)]:
			var newel := _put(_cyl(0.5, 0.5, 0.09, 20), _m("rubber"), end, e)
			newel.rotation.z = PI / 2.0
			_put(_cyl(0.46, 0.46, 0.05, 20), _m("glass"), end, e, false).rotation.z = PI / 2.0


# ---------------------------------------------------------------- the window

static func _window(a: Node3D) -> void:
	var w := 6.8
	var r := w * 0.5
	var sill := 6.4
	var spring := 12.0                 # where the arch starts
	var z := NORTH_Z + 0.02
	var sky := QuadMesh.new()
	sky.size = Vector2(w, spring + r - sill)
	_put(sky, _sky_mat(), Vector3(0, (sill + spring + r) * 0.5, z), a, false)
	# A city skyline at dusk, and a parasol on a rooftop terrace across the street.
	var rng := RandomNumberGenerator.new()
	rng.seed = 2002
	var x := -r
	while x < r:
		var bw := rng.randf_range(0.35, 0.9)
		var bh := rng.randf_range(0.6, 2.6)
		_put(_box(minf(bw, r - x), bh, 0.02), _m("skyline"), Vector3(x + minf(bw, r - x) * 0.5, sill + bh * 0.5, z + 0.03), a, false)
		x += bw
	_put(_cyl(0.0, 0.8, 0.3, 16), _m("skyline"), Vector3(-0.6, sill + 3.0, z + 0.05), a, false)
	_put(_box(0.04, 1.0, 0.02), _m("skyline"), Vector3(-0.6, sill + 2.4, z + 0.05), a, false)
	# Stone fills outside the arch (stepped finely enough that the frame hides the steps).
	var slices := 24
	for i in slices:
		var y0 := spring + r * i / float(slices)
		var y1 := spring + r * (i + 1) / float(slices)
		var half := sqrt(maxf(r * r - pow(y1 - spring, 2.0), 0.0))
		var fill := r - half + 0.02
		for s in [-1.0, 1.0]:
			_put(_box(fill, y1 - y0 + 0.01, 0.06), _m("stone"), Vector3(s * (r - fill * 0.5 + 0.01), (y0 + y1) * 0.5, z + 0.05), a, false)
	# Frame: jambs, sill, arch voussoirs, keystone; glazing bars.
	for s in [-1.0, 1.0]:
		_put(_box(0.32, spring - sill, 0.3), _m("cream"), Vector3(s * (r + 0.1), (sill + spring) * 0.5, z + 0.12), a)
	_put(_box(w + 0.8, 0.22, 0.45), _m("cream"), Vector3(0, sill - 0.05, z + 0.2), a)
	var segs := 20
	for i in segs:
		var t0 := PI * i / segs
		var t1 := PI * (i + 1) / segs
		var p0 := Vector2(cos(t0), sin(t0)) * (r + 0.1)
		var p1 := Vector2(cos(t1), sin(t1)) * (r + 0.1)
		var seg := _put(_box(p0.distance_to(p1) + 0.04, 0.32, 0.3), _m("cream"), Vector3((p0.x + p1.x) * 0.5, spring + (p0.y + p1.y) * 0.5, z + 0.12), a)
		seg.rotation.z = (t0 + t1) * 0.5 + PI / 2.0
	_put(_box(0.5, 0.7, 0.36), _m("cream"), Vector3(0, spring + r + 0.22, z + 0.14), a)
	for bx in [-r * 0.5, 0.0, r * 0.5]:
		var top := spring + sqrt(r * r - bx * bx)
		_put(_box(0.07, top - sill, 0.06), _m("brass"), Vector3(bx, (sill + top) * 0.5, z + 0.08), a)
	for by in [8.3, 10.2, spring]:
		_put(_box(w, 0.07, 0.06), _m("brass"), Vector3(0, by, z + 0.08), a)
	# Plum banners flanking the window.
	for s in [-1.0, 1.0]:
		_banner(a, Vector3(s * (r + 1.6), 11.0, z + 0.1), Vector3(0, 0, 1), 1.2, 5.0)


static func _sky_mat() -> StandardMaterial3D:
	if _mats.has("sky"):
		return _mats["sky"]
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.42, 0.78, 1.0])
	g.colors = PackedColorArray([Color("d99a9a"), Color("f7ad92"), Color("ffc29c"), Color("ffdcb6")])   # dusky rose → peach → gold
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 8
	tex.height = 128
	var m := StandardMaterial3D.new()
	m.albedo_color = Color.BLACK
	m.emission_enabled = true
	m.emission_texture = tex
	m.emission_energy_multiplier = 1.15
	_mats["sky"] = m
	return m


# ---------------------------------------------------------------- roof, lower hall, lights

static func _roof(a: Node3D) -> void:
	var depth := SOUTH_Z - NORTH_Z
	var mid_z := (SOUTH_Z + NORTH_Z) * 0.5
	var roof := _put(_box(OUTER_X * 2.0, 0.3, depth), _m("ceiling"), Vector3(0, ROOF + 0.15, mid_z), a, false)
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Skylight down the centre, and a coffer grid around it.
	var light := StandardMaterial3D.new()
	light.albedo_color = Color("fff3dc")
	light.emission_enabled = true
	light.emission = Color("ffd2a6")
	light.emission_energy_multiplier = 0.45
	var skylight := _put(_box(6.0, 0.05, depth - 6.0), light, Vector3(0, ROOF - 0.02, mid_z), a, false)
	skylight.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var z := NORTH_Z + 2.0
	while z < SOUTH_Z:
		var beam := _put(_box(OUTER_X * 2.0, 0.45, 0.35), _m("cream"), Vector3(0, ROOF - 0.22, z), a, false)
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		z += 3.0
	for x in [-GALLERY_X, -3.0, 3.0, GALLERY_X]:
		var rib := _put(_box(0.35, 0.45, depth), _m("cream"), Vector3(x, ROOF - 0.22, mid_z), a, false)
		rib.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _lower_hall(a: Node3D) -> void:
	var under: float = LEVELS[0] - SLAB
	# A lit archway into the next department beneath the mezzanine.
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color("2a1a14")
	glow.emission_enabled = true
	glow.emission = Color("ffcf94")
	glow.emission_energy_multiplier = 0.55
	_put(_box(3.4, 3.2, 0.05), glow, Vector3(0, 1.6, NORTH_Z + 0.03), a, false)
	for s in [-1.0, 1.0]:
		_put(_box(0.4, 3.6, 0.4), _m("cream"), Vector3(s * 1.9, 1.8, NORTH_Z + 0.2), a)
		for y in [0.5, 1.3, 2.1]:
			_put(_box(1.0, 0.04, 0.3), _m("wood"), Vector3(s * 1.05, y, NORTH_Z + 0.2), a)
			for i in 4:
				_put(_box(0.16, 0.22, 0.2), _m("plum" if i % 2 else "cream"), Vector3(s * (0.68 + i * 0.24), y + 0.13, NORTH_Z + 0.22), a)
	_put(_box(4.2, 0.4, 0.45), _m("cream"), Vector3(0, 3.6, NORTH_Z + 0.2), a)
	_put(_box(OUTER_X * 2.0, 0.3, 0.3), _m("brass"), Vector3(0, under - 0.15, NORTH_Z + 0.2), a)
	# Lilies between the escalators, perfume counters either side.
	Props.place(a, "flower_display", Vector3(0, 0, -13.5))
	for side in [-1.0, 1.0]:
		Props.place(a, "perfume_counter", Vector3(side * 3.0, 0, -12.2), 0.0, 1 if side > 0 else 2)
	# Suit racks and mannequins on the lower floor beyond the balustrade.
	for s in [-1.0, 1.0]:
		rack(a, Vector3(s * 3.2, 0, -16.5), 0.0)
		mannequin(a, Vector3(s * 7.4, 0, -12.5), 0.0, 1)
		mannequin(a, Vector3(s * 7.4, 0, -16.0), 0.0, 2)
		palm(a, Vector3(s * 2.6, 0, -10.6))


## The aisle beyond the court's east rail: perfume counters facing the fight, mannequins between
## them, and the same lilies on each gallery landing.
static func _dress_aisles(a: Node3D) -> void:
	for z in [-6.5, -1.5, 3.5]:
		Props.place(a, "perfume_counter", Vector3(10.6, 0, z), -PI / 2.0, int(z) & 3)
	for z in [-4.0, 1.0, 6.5]:
		Props.place(a, "mannequin", Vector3(9.3, 0, z), -PI / 2.0, int(absf(z)) % 4)
	Props.place(a, "perfume_tower", Vector3(11.2, 0, 7.6))
	Props.place(a, "easel", Vector3(9.4, 0, -8.3), -PI / 2.0 + 0.4, 1, "SALE")
	for level in LEVELS:
		for s in [-1.0, 1.0]:
			Props.place(a, "flower_display", Vector3(s * 11.4, level, -11.0))
			Props.place(a, "perfume_counter", Vector3(s * 12.0, level, 6.0), -s * PI / 2.0, 3)


static func _lights(a: Node3D) -> void:
	# Sunset through the window: a long warm wash down the atrium onto the bell area.
	var sun_in := SpotLight3D.new()
	sun_in.light_color = Color("ffb48c")   # peach
	sun_in.light_energy = 3.4
	sun_in.light_specular = 0.2
	sun_in.spot_range = 34.0
	sun_in.spot_angle = 42.0
	sun_in.spot_attenuation = 0.6
	sun_in.spot_angle_attenuation = 2.5   # feathered edge
	sun_in.position = Vector3(0, 12.5, NORTH_Z + 1.0)
	a.add_child(sun_in)
	sun_in.look_at(Vector3(0, 0, -4.0), Vector3.UP)
	# Fill for each gallery floor and the mezzanine, and for under the mezzanine.
	for level in LEVELS:
		for s in [-1.0, 1.0]:
			for z in [-12.0, 2.0]:
				ST.ceiling_light(a, Vector3(s * 10.8, level + 3.2, z), 0.7, 7.5)
	for s in [-1.0, 1.0]:
		ST.ceiling_light(a, Vector3(s * 3.5, LEVELS[0] + 3.5, -22.0), 0.8, 8.0)
		ST.ceiling_light(a, Vector3(s * 3.5, LEVELS[0] - 0.6, -14.0), 0.7, 7.0)
		ST.ceiling_light(a, Vector3(s * 10.8, LEVELS[0] - 0.6, -2.0), 0.6, 7.0)


# ---------------------------------------------------------------- dressing

## A plum hanging banner with a brass rod and a brass fleur-de-lis.
static func _banner(a: Node3D, centre: Vector3, face: Vector3, w: float, h: float) -> void:
	var along_x := absf(face.z) > 0.5
	var size := Vector3(w, h, 0.05) if along_x else Vector3(0.05, h, w)
	_put(_box(size.x, size.y, size.z), _m("banner"), centre, a)
	var rod := Vector3(w + 0.12, 0.07, 0.07) if along_x else Vector3(0.07, 0.07, w + 0.12)
	_put(_box(rod.x, rod.y, rod.z), _m("brass"), centre + Vector3(0, h * 0.5, 0), a)
	fleur(a, centre + Vector3(0, h * 0.12, 0) + face * 0.04, face, w * 0.5)


## A raised brass fleur-de-lis: centre petal, two curled side petals, a band and a foot.
static func fleur(a: Node3D, at: Vector3, face: Vector3, size: float) -> void:
	var f := Node3D.new()
	f.position = at
	a.add_child(f)
	f.look_at(at - face, Vector3.UP)   # local +z toward the viewer
	var s := size
	var petal := _put(_sphere(0.5), _m("brass"), Vector3(0, 0.22 * s, 0), f)
	petal.scale = Vector3(0.28, 0.75, 0.06) * s
	for side in [-1.0, 1.0]:
		var p := _put(_sphere(0.5), _m("brass"), Vector3(side * 0.22 * s, 0.05 * s, 0), f)
		p.scale = Vector3(0.18, 0.5, 0.05) * s
		p.rotation.z = side * -0.7
	_put(_box(0.5 * s, 0.07 * s, 0.05 * s), _m("brass"), Vector3(0, -0.12 * s, 0), f)
	var foot := _put(_sphere(0.5), _m("brass"), Vector3(0, -0.25 * s, 0), f)
	foot.scale = Vector3(0.14, 0.22, 0.05) * s


## Mannequins and racks come from the shared prop library, so the atrium repeats the same
## models as the departments.
static func mannequin(a: Node3D, at: Vector3, yaw: float, look: int) -> void:
	Props.place(a, "mannequin", at, yaw, look)


static func rack(a: Node3D, at: Vector3, yaw: float) -> void:
	Props.place(a, "rack", at, yaw, int(absf(at.z)) % 2)


## A potted palm: brass-banded cream urn, a fan of drooping fronds.
static func palm(a: Node3D, at: Vector3) -> void:
	var p := Node3D.new()
	p.position = at
	a.add_child(p)
	_put(_cyl(0.32, 0.24, 0.6, 20), _m("cream"), Vector3(0, 0.3, 0), p)
	_put(_cyl(0.33, 0.33, 0.06, 20), _m("brass"), Vector3(0, 0.55, 0), p)
	_put(_cyl(0.05, 0.06, 0.9, 8), _m("wood"), Vector3(0, 1.0, 0), p)
	for i in 9:
		var ang := TAU * i / 9.0
		var frond := Node3D.new()
		frond.position = Vector3(0, 1.4, 0)
		frond.rotation = Vector3(0, ang, 0)
		p.add_child(frond)
		var leaf := _put(_box(0.22, 0.02, 0.9), _m("leaf"), Vector3(0, 0, 0.42), frond)
		leaf.rotation.x = 0.45 + (i % 3) * 0.12   # droop
		leaf.position.y = -0.18 - (i % 3) * 0.05


# ---------------------------------------------------------------- helpers

## Bakes every static mesh under `root` into one mesh per material (and shadow setting), so the
## hundreds of boxes that make the hall cost a few dozen draws. Leaves lights, labels, MultiMeshes
## and any mesh with children alone. Only for geometry that never moves.
static func merge(root: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		return   # no mesh data without a renderer; tests don't need the batching
	var groups := {}
	var stack := [[root, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var item: Array = stack.pop_back()
		var node: Node = item[0]
		for c in node.get_children():
			if not c is Node3D:
				continue
			var xf: Transform3D = item[1] * (c as Node3D).transform
			if c is MeshInstance3D and c.mesh and c.material_override and c.get_child_count() == 0:
				var key := "%d/%d" % [c.material_override.get_instance_id(), c.cast_shadow]
				if not groups.has(key):
					groups[key] = []
				groups[key].append([c, xf])
			else:
				stack.append([c, xf])
	for key in groups:
		var parts: Array = groups[key]
		if parts.size() < 2:
			continue
		var st := SurfaceTool.new()
		for part in parts:
			var mesh: Mesh = part[0].mesh
			for surf in mesh.get_surface_count():
				st.append_from(mesh, surf, part[1])
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = parts[0][0].material_override
		mi.cast_shadow = parts[0][0].cast_shadow
		root.add_child(mi)
		for part in parts:
			part[0].get_parent().remove_child(part[0])
			part[0].free()


static func _m(name: String) -> StandardMaterial3D:
	if _mats.has(name):
		return _mats[name]
	var m: StandardMaterial3D
	match name:
		"floor": m = ST.textured("tile_cream", 0.6, ST.plastic(Color("d8ccb0"), 0.5, 0.0))
		"carpet": m = ST.textured("carpet_forest", 0.5, ST.plastic(Color("2f4a3a"), 0.9, 0.0))
		"plum_wall": m = ST.textured("plaster_cream", 0.3, ST.plastic(CREAM, 0.7, 0.0))
		"stone": m = ST.textured("stone_cream", 0.35, ST.plastic(Color("ddd0b4"), 0.75, 0.0))
		"slab": m = ST.plastic(Color("d9ccb0"), 0.7, 0.0)
		"ceiling": m = ST.plastic(Color("cbbd9f"), 0.8, 0.0)
		"cream": m = ST.textured("plaster_cream", 0.6, ST.plastic(CREAM, 0.55, 0.0))
		"brass": m = ST.textured("brass", 0.8, ST.plastic(BRASS, 0.35, 0.8), 0.8)
		"plum": m = ST.textured("laminate_plum", 1.0, ST.plastic(PLUM, 0.6, 0.0))
		"banner": m = ST.textured("velvet_red", 0.8, ST.plastic(PLUM, 0.7, 0.0))
		"wood": m = ST.plastic(WOOD, 0.5, 0.0)
		"ivory": m = ST.plastic(IVORY, 0.3, 0.0)
		"shirt": m = ST.plastic(Color("f2ece0"), 0.5, 0.0)
		"shoe": m = ST.plastic(Color("1c1715"), 0.3, 0.0)
		"hat": m = ST.plastic(Color("2a2422"), 0.6, 0.0)
		"suit_navy": m = ST.plastic(Color("2c3550"), 0.75, 0.0)
		"suit_brown": m = ST.plastic(Color("5a3d2e"), 0.75, 0.0)
		"suit_charcoal": m = ST.plastic(Color("3a3836"), 0.75, 0.0)
		"leaf": m = ST.plastic(Color("2f5a2c"), 0.6, 0.0)
		"lily": m = ST.plastic(Color("f6f1e6"), 0.5, 0.0)
		"vase": m = ST.plastic(Color("1d2b2a"), 0.2, 0.3)
		"steps": m = ST.textured("metal_charcoal", 1.0, ST.plastic(Color("3a3c40"), 0.45, 0.6), 0.6)
		"steel": m = ST.plastic(Color("9aa0a6"), 0.35, 0.8)
		"rubber": m = ST.plastic(Color("141316"), 0.45, 0.0)
		"skyline":
			m = StandardMaterial3D.new()
			m.albedo_color = Color("2e2140")
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		"glass":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.12, 0.13, 0.16, 0.55)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.1
			m.metallic_specular = 0.8
		_:
			m = ST.plastic(CREAM, 0.6, 0.0)
	_mats[name] = m
	return m


static func _put(mesh: Mesh, material: Material, pos: Vector3, parent: Node3D, cast := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	if not cast:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


static func _box(w: float, h: float, d: float) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3(w, h, d)
	return b


static func _cyl(top: float, bottom: float, h: float, segments := 16) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = segments
	c.rings = 1
	return c


static func _sphere(r: float, segments := 12) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = segments
	s.rings = segments / 2
	return s
