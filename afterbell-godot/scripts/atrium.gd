extends RefCounted
## The court's vertical space: Bellwether's central atrium rising three floors above the bell.
##
## Built around the existing court (x -8..8, z -9..9, floor at 0) without touching anything
## the fight uses. North of the bell the floor runs on to two escalators rising to a menswear
## mezzanine, under a tall arched sunset window. East and west, galleries on two upper floors
## sit behind the court's columns. A coffered roof with a skylight closes it all at 16 m.

const ST := preload("res://scripts/style.gd")
const Props := preload("res://scripts/props.gd")

const CREAM := Color("eee6d4")
const IVORY := Color("ece4d6")
const PLUM := Color("4e1f3a")
const PLUM_DEEP := Color("351428")
const BRASS := Color("b39a5c")
const WOOD := Color("8a6440")

const OUTER_X := 13.0         # outer walls of the side galleries
const GALLERY_X := 8.6        # gallery fronts, just behind the court's columns
const NORTH_Z := -26.0        # back wall with the window
const SOUTH_Z := 9.6
const MEZZ_Z := -18.6         # mezzanine front edge (escalator tops)
const ESC_X := 4.6            # where the escalators arrive at the mezzanine (its rail opens here)...
const ESC_FOOT_X := 2.9       # ...from feet close in by the lily table: a V, as in the reference
const ESC_FOOT_Z := -10.1
const LEVELS := [5.0]         # one gallery floor: the reference's single balcony storey, not a canyon
const ROOF := 12.0
const WINDOW_W := 6.4
const WINDOW_SILL := 7.0
const TERRACE_H := 1.85       # the raised terrace in front of the window, above the mezzanine floor
const TERRACE_D := 2.4
const SLAB := 0.45
const UPPER_ESC_X := 11.9      # gallery-to-gallery escalators, against the outer walls
const UPPER_ESC_FOOT := 2.0
const UPPER_ESC_TOP := -6.6
const HOLE := Rect2(11.12, -6.85, 1.56, 9.1)   # the opening in the top gallery floor (|x|, z)

static var _mats := {}


static func build(root: Node3D) -> void:
	var a := Node3D.new()
	a.name = "Atrium"
	root.add_child(a)
	_shell(a)
	_galleries(a)
	_mezzanine(a)
	for side in [-1.0, 1.0]:
		escalator(a, Vector3(side * ESC_FOOT_X, 0, ESC_FOOT_Z), LEVELS[0], MEZZ_Z, 1.45, false,
				-side * atan2(ESC_X - ESC_FOOT_X, ESC_FOOT_Z - MEZZ_Z))
	_colonnade(a)
	_aisle(a)
	_shops(a)
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


static func _galleries(a: Node3D) -> void:
	var depth := SOUTH_Z - NORTH_Z
	var mid_z := (SOUTH_Z + NORTH_Z) * 0.5
	var width := OUTER_X - GALLERY_X
	for level in LEVELS:
		var top := false   # a second gallery storey (with its escalator hole) is out of this chapter
		for s in [-1.0, 1.0]:
			var cx: float = s * (GALLERY_X + width * 0.5)
			if top:
				# The top floor opens where the escalator arrives: three slab pieces round the hole.
				for piece in [[GALLERY_X, OUTER_X, NORTH_Z, HOLE.position.y], [GALLERY_X, OUTER_X, HOLE.end.y, SOUTH_Z],
						[GALLERY_X, HOLE.position.x, HOLE.position.y, HOLE.end.y], [HOLE.end.x, OUTER_X, HOLE.position.y, HOLE.end.y]]:
					_slab(a, s, piece[0], piece[1], piece[2], piece[3], level)
				# Rails round the opening.
				balustrade(a, Vector3(s * (HOLE.position.x - 0.08), level, HOLE.position.y), Vector3(s * (HOLE.position.x - 0.08), level, HOLE.end.y))
				balustrade(a, Vector3(s * HOLE.position.x, level, HOLE.end.y + 0.08), Vector3(s * OUTER_X, level, HOLE.end.y + 0.08))
			else:
				_slab(a, s, GALLERY_X, OUTER_X, NORTH_Z, SOUTH_Z, level)
			_fascia(a, Vector3(s * GALLERY_X, level, mid_z), Vector3(0, 0, depth))
			balustrade(a, Vector3(s * (GALLERY_X + 0.12), level, NORTH_Z), Vector3(s * (GALLERY_X + 0.12), level, SOUTH_Z))
			# Finished underside: beams across the soffit between the recessed lights.
			var z := NORTH_Z + 0.5
			while z < SOUTH_Z:
				_put(_box(width, 0.22, 0.24), _m("cream"), Vector3(cx, level - SLAB - 0.11, z), a)
				z += 3.0
			_put(_box(0.24, 0.22, depth), _m("cream"), Vector3(s * (OUTER_X - 0.12), level - SLAB - 0.11, mid_z), a)
			# Dressing: racks against the back wall (clear of the escalators), mannequins at the rail.
			var racks := [-21.0, -13.0, 3.0] if top else [-21.0, -13.0, -5.0]
			for rz in racks:
				rack(a, Vector3(s * (OUTER_X - 0.7), level, rz), PI / 2.0)
			for mz in [-17.0, -9.0, -1.0, 6.5]:
				mannequin(a, Vector3(s * (GALLERY_X + 1.0), level, mz), -s * PI / 2.0, int(mz + level) % 3)
			# Ferns at the balcony corners and between the mannequins, where they read from below.
			for pz in [NORTH_Z + 0.8, -13.0, -5.0, 2.75, SOUTH_Z - 0.8]:
				Props.place(a, "planter", Vector3(s * (GALLERY_X + 0.55), level, pz))
			# Two stocked shelf bays between the back-wall racks.
			for k in 2:
				Props.place(a, "shelf_unit", Vector3(s * (OUTER_X - 0.25), level, -17.65 + k * 1.3), -s * PI / 2.0, (k + int(level)) % 4)
			for lz in [-24.0, -15.0, -7.0, 1.0, 8.0]:
				_amber(ST.sconce(a, Vector3(s * OUTER_X, level + 2.3, lz), Vector3(-s, 0, 0), 0.75, 3.6))   # warm pools on the gallery walls


## One rectangle of gallery floor (|x| from x0 to x1 on side s, z from z0 to z1): slab and carpet.
static func _slab(a: Node3D, s: float, x0: float, x1: float, z0: float, z1: float, level: float) -> void:
	var c := Vector3(s * (x0 + x1) * 0.5, level - SLAB * 0.5, (z0 + z1) * 0.5)
	_put(_box(x1 - x0, SLAB, z1 - z0), _m("slab"), c, a)
	_put(_box(maxf(x1 - x0 - 0.1, 0.05), 0.02, maxf(z1 - z0 - 0.1, 0.05)), _m("carpet"), Vector3(c.x, level + 0.01, c.z), a, false)


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
	label.font_size = 112
	label.pixel_size = 0.0042
	label.outline_size = 0
	label.modulate = Color("3a1a2c")
	label.shaded = false
	label.position = Vector3(0, level - 0.5, MEZZ_Z + 0.2)
	a.add_child(label)
	for s in [-1.0, 1.0]:
		var gem := _put(_box(0.16, 0.16, 0.04), _m("brass"), Vector3(s * 1.75, level - 0.5, MEZZ_Z + 0.19), a)
		gem.rotation.z = PI / 4.0
	# Mannequins along the rail, racks and palms behind, a counter in the middle.
	# Suits and fedoras flank the great bell at the rail; navy suit racks behind them; palms at
	# the ends (as in the reference).
	for x in [-1.7, 1.7, -6.9, 6.9]:
		Props.place(a, "mannequin", Vector3(x, level, MEZZ_Z - 0.9), 0.0, (0 if absf(x) < 3.0 else 2) + 4 * 2)
	for x in [-3.3, 3.3]:
		Props.place(a, "rack", Vector3(x, level, MEZZ_Z - 1.9), 0.0, 0)
	for x in [-7.2, 7.2]:
		rack(a, Vector3(x, level, -23.4), 0.0)
	for x in [-5.6, 5.6]:
		palm(a, Vector3(x, level, MEZZ_Z - 1.2))
	# Ferns at the rail's ends and where it breaks for the escalators.
	for x in [-GALLERY_X + 0.6, -ESC_X - 1.25, ESC_X + 1.25, GALLERY_X - 0.6]:
		Props.place(a, "planter", Vector3(x, level, MEZZ_Z - 0.55))


## A balcony edge with real depth: a cornice lip, two brass bands, a cream frieze with brass
## rosettes every 3 m, and a dropped bottom moulding, 1 m deep in all, running `span` from
## `centre` (centre sits at floor level on the edge line).
static func _fascia(a: Node3D, centre: Vector3, span: Vector3) -> void:
	var along_x := absf(span.x) > absf(span.z)
	var length := span.length()
	var strip := func(y: float, h: float, d: float, m: Material) -> void:
		var size := Vector3(length, h, d) if along_x else Vector3(d, h, length)
		_put(_box(size.x, size.y, size.z), m, centre + Vector3(0, y, 0), a)
	strip.call(-0.5, 1.0, 0.34, _m("cream"))          # the frieze
	strip.call(-0.03, 0.07, 0.46, _m("cream"))        # cornice lip
	strip.call(-0.1, 0.035, 0.4, _m("brass"))
	strip.call(-0.86, 0.035, 0.4, _m("brass"))
	strip.call(-0.97, 0.07, 0.42, _m("cream"))        # bottom moulding
	var count := int(length / 3.0)
	for i in count:
		var t := -length * 0.5 + (i + 0.5) * length / count
		for f in [-1.0, 1.0]:
			var off := Vector3(t, -0.48, f * 0.18) if along_x else Vector3(f * 0.18, -0.48, t)
			var ros := _put(_cyl(0.09, 0.09, 0.03, 16), _m("brass"), centre + off, a)
			ros.rotation = Vector3(PI / 2.0, 0, 0) if along_x else Vector3(0, 0, PI / 2.0)


## A substantial balustrade from `from` to `to` (axis-aligned, at floor height): square newel
## posts every 2.4 m with brass caps, a walnut handrail capped in brass, a cream bottom rail
## and turned cream balusters with a knop. The balusters are MultiMeshes, one draw per part.
static func balustrade(a: Node3D, from: Vector3, to: Vector3, height := 1.0) -> void:
	var length := from.distance_to(to)
	if length < 0.2:
		return
	var along_x := absf(to.x - from.x) > absf(to.z - from.z)
	var mid := (from + to) * 0.5
	var bar := func(y: float, h: float, d: float, m: Material) -> void:
		var size := Vector3(length, h, d) if along_x else Vector3(d, h, length)
		_put(_box(size.x, size.y, size.z), m, mid + Vector3(0, y, 0), a)
	bar.call(0.07, 0.14, 0.18, _m("walnut"))                # bottom rail
	bar.call(height - 0.05, 0.1, 0.17, _m("walnut"))        # handrail
	bar.call(height + 0.01, 0.025, 0.12, _m("brass"))       # brass cap on the rail
	var posts := maxi(1, int(round(length / 2.4)))
	for i in posts + 1:
		var p := from.lerp(to, i / float(posts))
		_put(_box(0.17, height + 0.08, 0.17), _m("cream"), p + Vector3(0, (height + 0.08) * 0.5, 0), a)
		_put(_box(0.22, 0.05, 0.22), _m("brass"), p + Vector3(0, height + 0.1, 0), a)
		_put(_sphere(0.06, 12), _m("brass"), p + Vector3(0, height + 0.17, 0), a)
	var count := int(length / 0.2)
	var parts := [[_cyl(0.03, 0.042, height - 0.24, 10), 0.14 + (height - 0.24) * 0.5],
			[_sphere(0.055, 12), height * 0.42], [_box(0.08, 0.06, 0.08), 0.17]]
	for part in parts:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = part[0]
		mm.instance_count = count
		for i in count:
			var t := (i + 0.5) / float(count)
			mm.set_instance_transform(i, Transform3D(Basis(), from.lerp(to, t) + Vector3(0, part[1], 0)))
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = _m("walnut")   # dark turned balusters, as in the reference
		a.add_child(mmi)


## An escalator rising north from `foot` to floor height `rise`, its top landing at `top_z`.
## Stepped treads with gold nosings, steel skirts and decks, a cream-clad truss with a brass
## seam, smoked glass panels under a black handrail on a steel guide, curled newel ends on
## solid housings, and brass-edged landing plates.
static func escalator(a: Node3D, foot: Vector3, rise: float, top_z: float, width := 1.15, flush := false, yaw := 0.0) -> void:
	var run := (foot.z - top_z) / cos(yaw)   # turned by `yaw` about its foot, it still lands at top_z
	var length := sqrt(run * run + rise * rise)
	var pitch := atan2(rise, run)
	top_z = foot.z - run
	var e := Node3D.new()
	e.name = "Escalator"
	a.add_child(e)
	e.transform = Transform3D(Basis(Vector3.UP, yaw), foot) * Transform3D(Basis(), -foot)
	var mid := Vector3(foot.x, rise * 0.5, (foot.z + top_z) * 0.5)
	var up := Vector3(0, cos(pitch), sin(pitch))   # local "up" of the incline (rotation.x = pitch)
	var incline := func(size: Vector3, m: Material, at: Vector3, cast := true) -> void:
		var mi := _put(_box(size.x, size.y, size.z), m, at, e, cast)
		mi.rotation.x = pitch
	# Truss: the solid underside, clad in cream with a brass seam each side. Starting on an upper
	# floor (`flush`), it is slimmer and stops at the foot so nothing pokes through the slab.
	if flush:
		incline.call(Vector3(width + 0.36, 0.5, length), _m("cream"), mid - up * 0.3)
	else:
		incline.call(Vector3(width + 0.36, 0.9, length + 0.6), _m("cream"), mid - up * 0.5)
	for s in [-1.0, 1.0]:
		incline.call(Vector3(0.02, 0.05, length + 0.6), _m("brass"), mid - up * 0.3 + Vector3(s * (width * 0.5 + 0.19), 0, 0))
	# Treads with a gold nosing on each step.
	var n := int(run / 0.4)
	var tread_d := run / n
	var riser := rise / n
	for part in [[_box(width, 0.3, tread_d), _m("steps"), 0.0], [_box(width - 0.04, 0.012, 0.045), _m("nosing"), 1.0]]:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = part[0]
		mm.instance_count = n
		for i in n:
			var y := (i + 1) * riser - 0.15
			var z := foot.z - (i + 0.5) * tread_d
			if part[2] > 0.0:
				y = (i + 1) * riser + 0.006
				z = foot.z - i * tread_d - 0.03
			mm.set_instance_transform(i, Transform3D(Basis(), Vector3(foot.x, y, z)))
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = part[1]
		e.add_child(mmi)
	# Landing plates with brass edges, top and bottom.
	for land in [[Vector3(foot.x, 0.02, foot.z + 0.75), 1.5], [Vector3(foot.x, rise + 0.025, top_z - 0.5), 1.0]]:
		_put(_box(width + 0.3, 0.04, land[1]), _m("steel"), land[0], e)
		for s in [-1.0, 1.0]:
			_put(_box(0.03, 0.045, land[1]), _m("brass"), land[0] + Vector3(s * (width * 0.5 + 0.15), 0, 0), e)
	# Each side: steel skirt, deck, glass, handrail on its guide, newel housings with curled ends.
	for s in [-1.0, 1.0]:
		var x: float = foot.x + s * (width * 0.5 + 0.08)
		incline.call(Vector3(0.03, 0.32, length), _m("steel"), Vector3(foot.x + s * (width * 0.5 + 0.015), mid.y, mid.z) + up * 0.05)
		incline.call(Vector3(0.16, 0.05, length + 0.2), _m("steel"), Vector3(x, mid.y, mid.z) + up * 0.17)
		incline.call(Vector3(0.035, 0.8, length + 0.2), _m("glass"), Vector3(x, mid.y, mid.z) + up * 0.58, false)
		incline.call(Vector3(0.04, 0.05, length + 0.2), _m("steel"), Vector3(x, mid.y, mid.z) + up * 0.96)
		incline.call(Vector3(0.1, 0.075, length + 0.2), _m("rubber"), Vector3(x, mid.y, mid.z) + up * 1.02)
		for end in [[Vector3(x, 0.55, foot.z + 0.15), 0.0], [Vector3(x, rise + 0.55, top_z - 0.15), rise]]:
			var c: Vector3 = end[0]
			_put(_box(0.16, 0.55, 0.9), _m("cream"), Vector3(x, float(end[1]) + 0.275, c.z + (0.35 if end[1] == 0.0 else -0.35)), e)
			var newel := _put(_cyl(0.5, 0.5, 0.1, 24), _m("rubber"), c, e)
			newel.rotation.z = PI / 2.0
			_put(_cyl(0.46, 0.46, 0.04, 24), _m("glass"), c, e, false).rotation.z = PI / 2.0


# ---------------------------------------------------------------- the window

static func _window(a: Node3D) -> void:
	var w := WINDOW_W
	var r := w * 0.5
	var sill := WINDOW_SILL            # above the raised terrace at the back of the mezzanine
	var spring := 8.4                  # where the arch starts; the crown sits just under the roof
	var z := NORTH_Z + 0.02
	var sky := QuadMesh.new()
	sky.size = Vector2(w, spring + r - sill)
	_put(sky, _sky_mat(), Vector3(0, (sill + spring + r) * 0.5, z), a, false)
	_sunset_view(a, z, w, sill, spring + r)
	# Stone fills outside the arch (stepped finely enough that the frame hides the steps).
	var slices := 30
	for i in slices:
		var y0 := spring + r * i / float(slices)
		var y1 := spring + r * (i + 1) / float(slices)
		var half := sqrt(maxf(r * r - pow(y1 - spring, 2.0), 0.0))
		var fill := r - half + 0.02
		for s in [-1.0, 1.0]:
			_put(_box(fill, y1 - y0 + 0.01, 0.08), _m("stone"), Vector3(s * (r - fill * 0.5 + 0.01), (y0 + y1) * 0.5, z + 0.12), a, false)
	# Ivory surround: jambs, deep sill, arch voussoirs, keystone.
	for s in [-1.0, 1.0]:
		_put(_box(0.5, spring - sill, 0.4), _m("cream"), Vector3(s * (r + 0.2), (sill + spring) * 0.5, z + 0.18), a)
	_put(_box(w + 1.2, 0.3, 0.6), _m("cream"), Vector3(0, sill - 0.1, z + 0.28), a)
	_put(_box(w + 1.0, 0.05, 0.62), _m("brass"), Vector3(0, sill + 0.06, z + 0.28), a)
	var segs := 28
	for i in segs:
		var t0 := PI * i / segs
		var t1 := PI * (i + 1) / segs
		var p0 := Vector2(cos(t0), sin(t0)) * (r + 0.2)
		var p1 := Vector2(cos(t1), sin(t1)) * (r + 0.2)
		var seg := _put(_box(p0.distance_to(p1) + 0.05, 0.5, 0.4), _m("cream"), Vector3((p0.x + p1.x) * 0.5, spring + (p0.y + p1.y) * 0.5, z + 0.18), a)
		seg.rotation.z = (t0 + t1) * 0.5 + PI / 2.0
	_put(_box(0.7, 0.95, 0.5), _m("cream"), Vector3(0, spring + r + 0.3, z + 0.22), a)
	var key := _put(_cyl(0.18, 0.18, 0.04, 20), _m("brass"), Vector3(0, spring + r + 0.3, z + 0.48), a)
	key.rotation.x = PI / 2.0
	# Dark bronze framework: outer frame, mullions, transoms, a fan of bars and a ring in the arch.
	var dark := _m("frame_dark")
	var fz := z + 0.1
	for s in [-1.0, 1.0]:
		_put(_box(0.16, spring - sill, 0.12), dark, Vector3(s * (r - 0.08), (sill + spring) * 0.5, fz), a)
	_put(_box(w, 0.16, 0.12), dark, Vector3(0, sill + 0.08, fz), a)
	# A square grid of glazing bars, as in the reference: six bays across, rows every 1.1 m, each
	# bar running up into the arch and stopping at its curve; the arch's own ring frames them.
	var arch_y := func(x: float) -> float:
		return spring + sqrt(maxf(r * r - x * x, 0.0))
	for k in range(-2, 3):
		var bx := r * k / 3.0
		var top: float = arch_y.call(absf(bx)) - 0.05
		_put(_box(0.08, top - sill, 0.1), dark, Vector3(bx, (sill + top) * 0.5, fz), a)
	var by := sill + 1.1
	while by < spring + r - 0.3:
		var half := r if by <= spring else sqrt(maxf(r * r - pow(by - spring, 2.0), 0.0))
		_put(_box(half * 2.0 - 0.1, 0.07, 0.1), dark, Vector3(0, by, fz), a)
		by += 1.1
	for i in 18:
		var t0 := PI * i / 18.0
		var t1 := PI * (i + 1) / 18.0
		var p0: Vector2 = Vector2(cos(t0), sin(t0)) * (r - 0.06)
		var p1: Vector2 = Vector2(cos(t1), sin(t1)) * (r - 0.06)
		var seg := _put(_box(p0.distance_to(p1) + 0.03, 0.12, 0.1), dark, Vector3((p0.x + p1.x) * 0.5, spring + (p0.y + p1.y) * 0.5, fz), a)
		seg.rotation.z = (t0 + t1) * 0.5 + PI / 2.0
	# The window terrace: a raised tier at the back of the mezzanine, cream-faced with brass bands,
	# its balustrade along the front and palms either side of the parasol view (the reference's
	# second tier above the bell).
	var tw := r + 1.6
	var ty: float = LEVELS[0] + TERRACE_H
	var tz := NORTH_Z + TERRACE_D
	_put(_box(tw * 2.0, TERRACE_H, TERRACE_D), _m("cream"), Vector3(0, LEVELS[0] + TERRACE_H * 0.5, NORTH_Z + TERRACE_D * 0.5), a)
	_put(_box(tw * 2.0, 0.02, TERRACE_D - 0.1), _m("carpet"), Vector3(0, ty + 0.01, NORTH_Z + TERRACE_D * 0.5), a, false)
	for y in [ty - 0.12, LEVELS[0] + 0.5]:
		_put(_box(tw * 2.0 + 0.04, 0.05, 0.04), _m("brass"), Vector3(0, y, tz + 0.01), a)
	balustrade(a, Vector3(-tw, ty, tz - 0.12), Vector3(tw, ty, tz - 0.12), 0.85)
	for x in [-2.3, 2.3]:
		palm(a, Vector3(x, ty, NORTH_Z + 1.1))
	# Fluted ivory pilasters with plum inset panels flank the window (no hanging cloth).
	for s in [-1.0, 1.0]:
		_pilaster(a, Vector3(s * (r + 1.5), LEVELS[0], z + 0.2), ROOF - 0.6 - LEVELS[0])


## The view out: a low sun with a soft halo behind the far rooftops, wisps of cloud, two layers
## of skyline (the near one with a few lit windows) and the rooftop parasol across the street.
static func _sunset_view(a: Node3D, z: float, w: float, sill: float, top: float) -> void:
	var glow := func(color: Color, energy: float) -> StandardMaterial3D:
		var m := StandardMaterial3D.new()
		m.albedo_color = Color.BLACK
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = energy
		return m
	var sun := _put(_cyl(0.55, 0.55, 0.01, 32), glow.call(Color("ffe2b0"), 1.6), Vector3(1.3, sill + 1.7, z + 0.02), a, false)
	sun.rotation.x = PI / 2.0
	var halo_m: StandardMaterial3D = glow.call(Color("ffc29a"), 0.6)
	halo_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_m.albedo_color = Color(0, 0, 0, 0.45)
	var halo := _put(_cyl(1.3, 1.3, 0.01, 32), halo_m, Vector3(1.3, sill + 1.7, z + 0.015), a, false)
	halo.rotation.x = PI / 2.0
	var cloud: StandardMaterial3D = glow.call(Color("e7a0a8"), 0.7)
	for c in [[-2.2, top - 3.0, 2.4], [1.8, top - 4.2, 1.8], [-0.6, top - 5.2, 1.4], [2.6, sill + 3.0, 1.2]]:
		var puff := _put(_sphere(0.5, 16), cloud, Vector3(c[0], c[1], z + 0.03), a, false)
		puff.scale = Vector3(c[2], 0.22, 0.02)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2002
	var r := w * 0.5
	for layer in [[_m("skyline_far"), 1.2, 3.4, 0.035], [_m("skyline"), 0.5, 2.2, 0.05]]:
		var x := -r
		while x < r:
			var bw := minf(rng.randf_range(0.4, 1.0), r - x)
			var bh := rng.randf_range(layer[1], layer[2])
			_put(_box(bw, bh, 0.01), layer[0], Vector3(x + bw * 0.5, sill + bh * 0.5, z + layer[3]), a, false)
			if layer[3] > 0.04:
				for k in rng.randi_range(0, 3):
					var lit := _put(_box(0.08, 0.1, 0.01), _m("window_lit"), Vector3(x + rng.randf_range(0.1, bw - 0.1), sill + rng.randf_range(0.3, bh - 0.2), z + 0.056), a, false)
					lit.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			x += bw
	_put(_cyl(0.0, 0.8, 0.3, 16), _m("skyline"), Vector3(-0.2, sill + 2.7, z + 0.06), a, false)
	_put(_box(0.04, 0.9, 0.01), _m("skyline"), Vector3(-0.2, sill + 2.2, z + 0.06), a, false)


## A fluted ivory pilaster rising `h` from `base` against the back wall: stepped base, three
## flutes, a framed plum inset panel with a brass fleur, a brass-banded capital.
static func _pilaster(a: Node3D, base: Vector3, h: float) -> void:
	var w := 1.0
	_put(_box(w + 0.2, 0.4, 0.45), _m("cream"), base + Vector3(0, 0.2, 0.05), a)
	_put(_box(w + 0.1, 0.05, 0.4), _m("brass"), base + Vector3(0, 0.42, 0.05), a)
	_put(_box(w, h, 0.3), _m("cream"), base + Vector3(0, h * 0.5, 0), a)
	for fx in [-0.28, 0.0, 0.28]:
		_put(_box(0.06, h - 1.6, 0.02), _m("flute"), base + Vector3(fx, h * 0.5 - 0.2, 0.15), a)
	var panel := base + Vector3(0, h * 0.42, 0.16)
	_put(_box(0.66, 2.6, 0.04), _m("brass"), panel, a)
	_put(_box(0.58, 2.52, 0.05), _m("plum"), panel, a)
	fleur(a, panel + Vector3(0, 0.3, 0.04), Vector3(0, 0, 1), 0.42)
	for cap in [[h - 0.5, w + 0.08, 0.06, "brass"], [h - 0.36, w + 0.16, 0.2, "cream"], [h - 0.12, w + 0.3, 0.24, "cream"]]:
		_put(_box(cap[1], cap[2], 0.42), _m(cap[3]), base + Vector3(0, cap[0], 0.06), a)


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
	light.emission_energy_multiplier = 0.2 if ST.DECO else 0.45
	var skylight := _put(_box(6.0, 0.05, depth - 6.0), light, Vector3(0, ROOF - 0.02, mid_z), a, false)
	skylight.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var z := NORTH_Z + 2.0
	while z < SOUTH_Z:
		var beam := _put(_box(OUTER_X * 2.0, 0.45, 0.35), _m("walnut" if ST.DECO else "cream"), Vector3(0, ROOF - 0.22, z), a, false)
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		z += 3.0
	for x in [-GALLERY_X, -3.0, 3.0, GALLERY_X]:
		var rib := _put(_box(0.35, 0.45, depth), _m("walnut" if ST.DECO else "cream"), Vector3(x, ROOF - 0.22, mid_z), a, false)
		rib.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _lower_hall(a: Node3D) -> void:
	# Past the court's lily table, as in the reference: gentlemen's suits in fedoras either side
	# of the aisle, a brass rack of jackets, and racks along the escalator feet.
	for p in [[Vector3(-1.4, 0, -11.4), 0.3, 0], [Vector3(1.5, 0, -11.8), -0.3, 2], [Vector3(-0.8, 0, -13.3), 0.1, 2],
			[Vector3(0.9, 0, -13.7), -0.1, 0], [Vector3(-4.7, 0, -11.6), 0.4, 2], [Vector3(4.8, 0, -12.0), -0.4, 0]]:
		Props.place(a, "mannequin", p[0], p[1], p[2] + 4 * ([1, 2, 1, 3, 2, 1][int(absf(p[0].x * 10.0)) % 6]))
	Props.place(a, "rack", Vector3(2.05, 0, -8.4), PI / 2.0 - 0.15, 0)   # the brass jacket rack by the lily table
	rack(a, Vector3(-5.3, 0, -15.0), 0.15)
	rack(a, Vector3(5.4, 0, -15.4), -0.15)
	for side in [-1.0, 1.0]:
		Props.place(a, "folded_table", Vector3(side * 1.4, 0, -16.4), 0.0, 2 if side > 0 else 0)
		mannequin(a, Vector3(side * 6.9, 0, -12.5), 0.0, 0)
		mannequin(a, Vector3(side * 6.9, 0, -16.0), 0.0, 2)


## A pillar: stepped stone base with a brass torus, brass bands at rail height on every floor,
## and a moulded capital with brass medallions under each balcony it carries and under the
## roof. `brackets` (+1/-1 = toward +x/-x, 0 = none) adds short corbels tying it into the
## balcony edge at each floor. Used by the court's columns and the atrium's own.
static func pillar(a: Node3D, x: float, z: float, top: float = ROOF, brackets := 0.0, reach := 0.0) -> void:
	var at := Vector3(x, 0, z)
	_put(_box(1.08, 0.24, 1.08), _m("cream"), at + Vector3(0, 0.12, 0), a)
	_put(_box(0.94, 0.07, 0.94), _m("brass"), at + Vector3(0, 0.275, 0), a)
	_put(_box(0.86, 0.3, 0.86), _m("cream"), at + Vector3(0, 0.46, 0), a)
	_put(_box(0.7, top - 0.6, 0.7), _m("cream"), at + Vector3(0, 0.6 + (top - 0.6) * 0.5, 0), a)
	var bands := [1.12]
	var caps := []
	for level in LEVELS:
		if level - SLAB < top - 0.3:
			caps.append(level - SLAB)
			if level + 1.12 < top:
				bands.append(level + 1.12)
	caps.append(top)
	for y in bands:
		_put(_box(0.76, 0.06, 0.76), _m("brass"), at + Vector3(0, y, 0), a)
	for cy in caps:
		_put(_box(0.76, 0.05, 0.76), _m("brass"), at + Vector3(0, cy - 0.42, 0), a)
		_put(_box(0.86, 0.18, 0.86), _m("cream"), at + Vector3(0, cy - 0.27, 0), a)
		_put(_box(1.0, 0.12, 1.0), _m("cream"), at + Vector3(0, cy - 0.06, 0), a)
		for f in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
			var med := _put(_cyl(0.07, 0.07, 0.03, 16), _m("brass"), at + Vector3(0, cy - 0.62, 0) + f * 0.36, a)
			med.rotation = Vector3(PI / 2.0, 0, 0) if absf(f.z) > 0.5 else Vector3(0, 0, PI / 2.0)
		if brackets != 0.0 and cy < top and reach > 0.0:
			_put(_box(reach, 0.32, 0.5), _m("cream"), at + Vector3(brackets * (0.35 + reach * 0.5), cy - 0.16, 0), a)
			_put(_box(reach, 0.04, 0.52), _m("brass"), at + Vector3(brackets * (0.35 + reach * 0.5), cy - 0.3, 0), a)


## The atrium's own columns: the rest of the gallery colonnade north of the court, and a row
## carrying the mezzanine's front edge, so every upper floor visibly stands on something.
static func _colonnade(a: Node3D) -> void:
	for s in [-1.0, 1.0]:
		for z in [-12.6, -17.2, -22.0]:
			pillar(a, s * 8.25, z, ROOF, s, 0.0)
	for x in [-7.2, -2.2, 2.2, 7.2]:
		pillar(a, x, MEZZ_Z + 0.25, LEVELS[0] - SLAB + 0.02)
		_amber(ST.lantern(a, Vector3(x, 2.9, MEZZ_Z + 0.61), Vector3(0, 0, 1), 0.7, 5.0))   # globes framing MENSWEAR below
	# Under the mezzanine, between the inner columns: a walnut-framed glazed shopfront with an open
	# centre doorway, so the lit MENSWEAR floor shows through, as in the reference.
	var fz := MEZZ_Z - 2.6
	var fy: float = LEVELS[0] - SLAB
	_put(_box(5.6, 0.5, 0.25), _m("walnut"), Vector3(0, fy - 0.25, fz), a)                # fascia over the front
	_put(_box(5.64, 0.05, 0.27), _m("brass"), Vector3(0, fy - 0.52, fz), a)
	for x in [-2.75, -1.95, -0.75, 0.75, 1.95, 2.75]:
		_put(_box(0.14, fy - 0.5, 0.18), _m("walnut"), Vector3(x, (fy - 0.5) * 0.5, fz), a)
	for x in [-2.35, -1.35, 1.35, 2.35]:
		var pane := _put(_box(0.8 if absf(x) > 2.0 else 1.06, fy - 1.1, 0.03), _m("shop_glass"), Vector3(x, 0.6 + (fy - 1.1) * 0.5, fz), a, false)
		pane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for x in [-1.75, 1.75]:
		_put(_box(2.0, 0.6, 0.2), _m("walnut"), Vector3(x, 0.3, fz), a)                     # stall risers under the glass
		_put(_box(2.04, 0.04, 0.24), _m("brass"), Vector3(x, 0.61, fz), a)
	# Under the mezzanine, the MENSWEAR floor glows: a pendant, warm light and stocked shelving.
	_amber(ST.pendant(a, Vector3(0, 3.7, MEZZ_Z - 1.6), LEVELS[0] - SLAB, 1.4, 8.0))
	var shop_glow := OmniLight3D.new()
	shop_glow.light_color = AMBER
	shop_glow.light_energy = 3.2
	shop_glow.omni_range = 10.0
	shop_glow.position = Vector3(0, 3.0, NORTH_Z + 3.0)
	a.add_child(shop_glow)
	for k in 11:
		var x := -6.5 + k * 1.3
		Props.place(a, "shelf_unit", Vector3(x, 0, NORTH_Z + 0.25), 0.0, [1, 0, 3, 0, 1][k % 5])
	# The floor itself: display tables of shirts and hats, suits on forms, a rack, more light.
	for p in [[Vector3(-3.4, 0, -22.4), 0], [Vector3(3.4, 0, -22.4), 3], [Vector3(-1.6, 0, -24.0), 1], [Vector3(1.6, 0, -24.0), 2]]:
		Props.place(a, "folded_table", p[0], 0.0, p[1])
	for p in [[Vector3(-5.6, 0, -21.4), 0.4, 0], [Vector3(5.6, 0, -21.4), -0.4, 2], [Vector3(-2.6, 0, -25.0), 0.2, 2], [Vector3(2.6, 0, -25.0), -0.2, 0]]:
		Props.place(a, "mannequin", p[0], p[1], p[2] + 4 * 2)
	rack(a, Vector3(-6.0, 0, -24.0), 0.0)
	rack(a, Vector3(6.0, 0, -24.0), 0.0)
	for x in [-4.5, 4.5]:
		_amber(ST.pendant(a, Vector3(x, 3.7, -22.6), LEVELS[0] - SLAB, 1.0, 6.0))


## The broad central aisle: a lighter runner with ivory borders from the court to the mezzanine.
static func _aisle(a: Node3D) -> void:
	var z0 := -9.35
	var z1 := MEZZ_Z + 0.4
	var cz := (z0 + z1) * 0.5
	var len := z0 - z1
	_put(_box(4.2, 0.02, len), _m("runner"), Vector3(0, 0.012, cz), a, false)
	for s in [-1.0, 1.0]:
		_put(_box(0.12, 0.022, len), _m("cream"), Vector3(s * 2.0, 0.013, cz), a, false)
		_put(_box(0.04, 0.023, len), _m("brass"), Vector3(s * 1.86, 0.014, cz), a, false)


## Recessed shop entrances beneath the balconies: along both side aisles and under the mezzanine.
static func _shops(a: Node3D) -> void:
	var names := [["MILLINERY", "GLOVES  ·  HOSIERY", "FOOTWEAR"], ["TAILORING", "LEATHER GOODS", "PERFUMERY"]]
	for side in 2:
		var s := -1.0 if side == 0 else 1.0
		var zs := [-12.0, 0.5, 6.6]
		for i in 3:
			shop_front(a, Vector3(s * OUTER_X, 0, zs[i]), -s * PI / 2.0, names[side][i])
	# Under the mezzanine the MENSWEAR floor runs straight back to stocked walls (see _colonnade).


## One shop front built out from a wall: pilasters, a fascia with its name plaque, two display
## windows with mannequins on plum plinths, and a recessed, lit entrance with open doors.
## Local frame: origin on the wall face at floor level, +z out toward the atrium.
## Which window_stock arrangement each department's windows show (Props.window_stock).
const DEPARTMENT_STOCK := {"LEATHER GOODS": 0, "PERFUMERY": 1, "MILLINERY": 2, "FOOTWEAR": 3,
		"GLOVES  ·  HOSIERY": 4, "TAILORING": 5, "GENTLEMEN'S OUTFITTERS": 6}


static func shop_front(a: Node3D, at: Vector3, yaw: float, name: String) -> void:
	var f := Node3D.new()
	f.position = at
	f.rotation.y = yaw
	a.add_child(f)
	var depth := 0.9
	var door_w := 2.0
	var win_w := 1.5
	var pier := 0.3
	var total := door_w + 2.0 * (win_w + pier) + 2.0 * pier
	var h := 3.0
	# Back of the recess: a warm lit interior with shelving silhouettes.
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color("2a1a14")
	glow.emission_enabled = true
	glow.emission = Color("ffd2a0")
	glow.emission_energy_multiplier = 0.45
	_put(_box(door_w, 2.6, 0.04), glow, Vector3(0, 1.3, 0.03), f, false)
	for y in [0.6, 1.3, 2.0]:
		_put(_box(door_w - 0.3, 0.04, 0.1), _m("wood"), Vector3(0, y, 0.08), f)
	for sx in [-1.0, 1.0]:
		_put(_box(0.04, 2.6, depth), _m("cream"), Vector3(sx * door_w * 0.5, 1.3, depth * 0.5), f)   # recess cheeks
		Props.door_leaf(f, Vector3(sx * door_w * 0.5, 0, 0.1), door_w * 0.5 - 0.05, 2.5, PI if sx > 0 else 0.0, sx * -1.2, true)
	_put(_box(door_w, 0.04, depth), _m("cream"), Vector3(0, 2.62, depth * 0.5), f)   # recess soffit
	_put(_box(door_w + 0.04, 0.02, depth), _m("brass"), Vector3(0, 0.01, depth * 0.5), f)
	# Piers, display windows and their mannequins.
	var piers := [door_w * 0.5 + pier * 0.5, door_w * 0.5 + pier + win_w + pier * 0.5]
	for sx in [-1.0, 1.0]:
		for px in piers:
			_put(_box(pier, h, depth + 0.1), _m("cream"), Vector3(sx * px, h * 0.5, depth * 0.5), f)
			_put(_box(pier + 0.06, 0.06, depth + 0.16), _m("brass"), Vector3(sx * px, 0.3, depth * 0.5), f)
		var wx: float = sx * (door_w * 0.5 + pier + win_w * 0.5)
		_put(_box(win_w, 0.5, depth), _m("plum"), Vector3(wx, 0.25, depth * 0.5), f)            # plinth
		_put(_box(win_w + 0.02, 0.04, depth + 0.02), _m("brass"), Vector3(wx, 0.51, depth * 0.5), f)
		_put(_box(win_w, h - 0.5, 0.04), glow, Vector3(wx, 0.5 + (h - 0.5) * 0.5, 0.03), f, false)
		var glass := _put(_box(win_w, 2.1, 0.03), _m("glass_clear"), Vector3(wx, 1.6, depth - 0.05), f, false)
		glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_put(_box(win_w, 0.05, 0.08), _m("brass"), Vector3(wx, 2.67, depth - 0.05), f)
		var m := Props.place(f, "mannequin", Vector3(wx, 0.53, depth * 0.45), 0.0, int(absf(wx) * 3.0 + name.length() + sx) % 16)
		m.scale = Vector3.ONE * 0.92
		# The department's own stock either side of the mannequin.
		var stock := Props.place(f, "window_stock", Vector3(wx, 0.53, depth * 0.45), 0.0, DEPARTMENT_STOCK.get(name, 6))
		stock.scale = Vector3.ONE * 0.95
	# Fascia with the shop's name, a cornice above it.
	_put(_box(total, 0.7, depth + 0.15), _m("cream"), Vector3(0, h + 0.35, depth * 0.5), f)
	_put(_box(total + 0.2, 0.08, depth + 0.3), _m("cream"), Vector3(0, h + 0.74, depth * 0.5), f)
	_put(_box(total + 0.04, 0.04, depth + 0.2), _m("brass"), Vector3(0, h + 0.02, depth * 0.5), f)
	Props.plaque(f, Vector3(0, h + 0.36, depth + 0.08), minf(total - 1.0, 3.6), name)
	var light := OmniLight3D.new()
	light.light_color = Color("ffd8b0")
	light.light_energy = 0.4
	light.omni_range = 3.0
	light.position = Vector3(0, 2.0, depth + 0.4)
	f.add_child(light)


## The aisle beyond the court's east rail: perfume counters facing the fight, mannequins between
## them, and the same lilies on each gallery landing.
static func _dress_aisles(a: Node3D) -> void:
	var prices := ["24.00", "6.25", "32.50"]
	for i in 3:
		var z: float = [-6.5, -1.5, 3.5][i]
		if i == 1:   # in front of LEATHER GOODS: its own table of bags, wallets, belts and cases
			Props.place(a, "leather_table", Vector3(10.6, 0, z), -PI / 2.0, 0)
			price(a, Vector3(10.36, Props.WAIST * 0.82, z - 0.5), -PI / 2.0, prices[i])
			continue
		Props.place(a, "perfume_counter", Vector3(10.6, 0, z), -PI / 2.0, int(z) & 3)
		price(a, Vector3(10.32, Props.WAIST, z - 0.6), -PI / 2.0, prices[i])
	# The wall between the first two shop fronts: three bays of the same stock lines.
	for k in 3:
		Props.place(a, "shelf_unit", Vector3(OUTER_X - 0.25, 0, -7.6 + k * 1.3), -PI / 2.0, [0, 3, 1][k])
	for z in [-4.0, 1.0]:
		Props.place(a, "mannequin_group", Vector3(10.0, 0, z), -PI / 2.0, int(absf(z)) % 4)
	Props.place(a, "mannequin", Vector3(9.3, 0, 6.5), -PI / 2.0, 2)
	Props.place(a, "perfume_tower", Vector3(11.2, 0, 7.6))
	Props.place(a, "easel", Vector3(9.4, 0, -8.3), -PI / 2.0 + 0.4, 1, "SALE")
	for level in LEVELS:
		for s in [-1.0, 1.0]:
			Props.place(a, "flower_display", Vector3(s * 11.4, level, -11.0))
			Props.place(a, "perfume_counter", Vector3(s * 12.0, level, 6.0), -s * PI / 2.0, 3)
			Props.place(a, "folded_table", Vector3(s * 11.2, level, -1.5), -s * PI / 2.0, int(level) % 4)
	Props.place(a, "easel", Vector3(9.5, LEVELS[0], 0.6), -PI / 2.0 - 0.3, 1, "SALE")


## A price card standing on a counter or table.
static func price(a: Node3D, at: Vector3, yaw: float, text: String) -> void:
	Props.place(a, "price_card", at, yaw, 0, text)


## Lamp colour for the atrium: a soft amber, warmer than the overhead key.
const AMBER := Color("ffd4aa")


## The atrium's mood, applied to the main scene's environment and overhead key light. Ambient is
## kept low and slightly cool so shade reads (pillars get a lit and a shaded side, balcony
## undersides fall dark); the window and the lamps do the warm work. The key comes in high from
## the window side, and its shadows reach the far end of the hall.
static func light_environment(e: Environment, key: DirectionalLight3D) -> void:
	e.ambient_light_color = Color("cfd6e2")   # cool shade, so cream reads cream and not mustard
	e.ambient_light_energy = 0.21
	e.tonemap_exposure = 1.0
	e.ssao_radius = 1.3        # broader contact shade: pillar bases, rack feet, balcony junctions
	e.ssao_intensity = 2.8
	key.light_color = Color("f2ede8")
	key.light_energy = 0.32
	key.light_specular = 0.04   # no glare lines off the escalator glass at this angle
	key.rotation = Vector3(deg_to_rad(-58), deg_to_rad(205), 0)   # from high above the window, slanting south-east
	key.directional_shadow_max_distance = 48.0
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS   # half the shadow draws of 4 splits
	key.shadow_blur = 3.0
	if ST.CG:   # the promo-render grade (Style.LOOK); keeps this hall's sun direction and reach
		ST.cg_environment(e)
		ST.cg_key(key)
		key.light_energy = 0.95
		key.light_specular = 0.6   # escalator glass would streak at full specular
	elif ST.DECO:   # golden hour (Style.LOOK); same sun direction and reach
		ST.deco_environment(e)
		ST.deco_key(key)
		key.light_energy = 0.45   # the upper storeys fall into warm shade; the lamps carry the hall
		key.light_specular = 0.3
		e.ambient_light_energy = 0.24


static func _lights(a: Node3D) -> void:
	# Sunset through the arched window: a broad peach spot just inside the glass, shaped by a
	# window gobo (arch, mullions and transoms) and shadowed, so the mezzanine, rails and pillars
	# cut into the light laid down the aisle toward the bell.
	var sun_in := SpotLight3D.new()
	sun_in.light_color = Color("ffb183")   # peach
	sun_in.light_energy = 8.5
	sun_in.light_specular = 0.04   # no glints off the escalator rails
	sun_in.light_projector = _window_gobo()
	sun_in.light_size = 1.2               # a wide source: soft shadow edges
	sun_in.shadow_enabled = true
	sun_in.shadow_blur = 1.5
	sun_in.spot_range = 46.0
	sun_in.spot_attenuation = 0.15        # flat falloff: near surfaces don't clip, the far end still gets light
	sun_in.spot_angle = 46.0             # wide enough to wash the colonnade's inner faces
	sun_in.spot_angle_attenuation = 1.2
	sun_in.position = Vector3(0, 8.8, NORTH_Z + 0.9)
	a.add_child(sun_in)
	sun_in.look_at(Vector3(0, 0, -1.0), Vector3.UP)   # clears the bell partition onto the court's north end
	# A soft peach bounce off the window reveal into the upper hall: no shadows, no gobo.
	var glow := OmniLight3D.new()
	glow.light_color = Color("ffbf98")
	glow.light_energy = 1.4
	glow.light_specular = 0.0
	glow.omni_range = 14.0
	glow.omni_attenuation = 1.6
	glow.position = Vector3(0, 8.6, NORTH_Z + 3.0)
	a.add_child(glow)
	# Gallery and mezzanine ceiling lights: warm, local pools rather than a flat fill.
	for level in LEVELS:
		for s in [-1.0, 1.0]:
			for z in [-12.0, 2.0]:
				_amber(ST.ceiling_light(a, Vector3(s * 10.8, level + 3.2, z), 0.55, 6.0))
	for s in [-1.0, 1.0]:
		_amber(ST.ceiling_light(a, Vector3(s * 3.5, LEVELS[0] + 3.5, -22.0), 0.65, 6.5))
		_amber(ST.ceiling_light(a, Vector3(s * 3.5, LEVELS[0] - 0.6, -14.0), 0.6, 6.0))
	_under_balconies(a)
	_window_shafts(a)


## Warms a fixture's light to the atrium's amber.
static func _amber(l: Light3D) -> void:
	l.light_color = AMBER


## The window as a light gobo: white panes, dark frame, arch head, five mullions and three
## transoms, matching _window(). Top of the image is the arch.
static func _window_gobo() -> ImageTexture:
	var n := 192
	var img := Image.create(n, n, false, Image.FORMAT_L8)
	for py in n:
		for px in n:
			var u := px / float(n - 1) * 2.0 - 1.0
			var v := 1.0 - py / float(n - 1) * 2.0
			var spring := 0.05
			var r := 0.78
			var inside := (absf(u) < r and v > -0.95 and v < spring) or (u * u + (v - spring) * (v - spring) < r * r and v >= spring)
			var bar := false
			for mx in [-0.52, -0.26, 0.0, 0.26, 0.52]:
				if absf(u - mx) < 0.018 and v < spring:
					bar = true
			for ty in [-0.62, -0.29, spring]:
				if absf(v - ty) < 0.018:
					bar = true
			if v >= spring:
				var d := Vector2(u, v - spring)
				if absf(d.length() - r * 0.42) < 0.018:
					bar = true
				for i in 7:
					var ang := PI * (i + 1) / 8.0
					var dir := Vector2(cos(ang), sin(ang))
					if absf(d.cross(dir)) < 0.014 and d.dot(dir) > 0.0:
						bar = true
			img.set_pixel(px, py, Color(0.92, 0.92, 0.92) if inside and not bar else Color(0, 0, 0))
	return ImageTexture.create_from_image(img)


## Gentle light under every balcony: recessed glass discs in the slab soffits, with a few soft
## warm lights so the aisles beneath the galleries and the mezzanine aren't dark caves.
static func _under_balconies(a: Node3D) -> void:
	var disc := StandardMaterial3D.new()
	disc.albedo_color = Color("f3ebde")
	disc.emission_enabled = true
	disc.emission = Color("ffdcb4")
	disc.emission_energy_multiplier = 0.5
	for level in LEVELS:
		var soffit: float = level - SLAB - 0.01
		for s in [-1.0, 1.0]:
			var z := NORTH_Z + 2.0
			while z < SOUTH_Z - 1.0:
				_put(_cyl(0.13, 0.13, 0.02, 20), disc, Vector3(s * 10.8, soffit, z), a, false)
				_put(_cyl(0.15, 0.15, 0.012, 20), _m("brass"), Vector3(s * 10.8, soffit + 0.004, z), a, false)
				z += 3.0
			if level == LEVELS[0]:
				for lz in [-20.0, -11.0, -2.0, 6.0]:
					var l := OmniLight3D.new()
					l.light_color = Color("ffdcb4")
					l.light_energy = 0.26   # just enough to read the shop fronts; the recess stays darker
					l.light_specular = 0.05
					l.omni_range = 4.5
					l.omni_attenuation = 1.2
					l.position = Vector3(s * 10.8, soffit - 0.5, lz)
					a.add_child(l)
	# Under the mezzanine.
	var mz: float = LEVELS[0] - SLAB - 0.01
	for x in [-6.0, -2.0, 2.0, 6.0]:
		for z in [-20.0, -23.5]:
			_put(_cyl(0.13, 0.13, 0.02, 20), disc, Vector3(x, mz, z), a, false)
	for x in [-4.0, 4.0]:
		var l := OmniLight3D.new()
		l.light_color = Color("ffdcb4")
		l.light_energy = 0.32
		l.omni_range = 5.0
		l.omni_attenuation = 1.2
		l.position = Vector3(x, mz - 0.6, -21.5)
		a.add_child(l)


## Peach sunset shafts from the window: a few soft additive planes slanting down from the glass
## toward the bell, brightest at the window and fading out before the floor.
static func _window_shafts(a: Node3D) -> void:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	g.colors = PackedColorArray([Color(1.0, 0.72, 0.55, 0.0), Color(1.0, 0.72, 0.55, 0.06), Color(1.0, 0.72, 0.55, 0.0)])   # faint: stacked edge-on they clipped to a white line
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 4
	tex.height = 64
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_texture = tex
	m.disable_receive_shadows = true
	var top := Vector3(0, 10.4, NORTH_Z + 0.3)
	var foot := Vector3(0, 0.5, -11.0)
	var length := top.distance_to(foot)
	for x in [-2.2, -0.7, 0.8, 2.3]:
		var q := QuadMesh.new()
		q.size = Vector2(0.9 + absf(x) * 0.1, length)
		var mi := _put(q, m, (top + foot) * 0.5 + Vector3(x, 0, 0), a, false)
		mi.rotation.x = atan2(top.z - foot.z, top.y - foot.y)   # local +y runs from the floor up to the window
		mi.rotation.y = x * 0.02


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
## A mannequin in `look`; its pose comes from where it stands, so neighbours differ.
static func mannequin(a: Node3D, at: Vector3, yaw: float, look: int) -> void:
	Props.place(a, "mannequin", at, yaw, look + 4 * (int(absf(at.x * 3.0 + at.z * 2.0)) % 4))


static func rack(a: Node3D, at: Vector3, yaw: float) -> void:
	Props.place(a, "rack", at, yaw, int(absf(at.z)) % 2)


## A kentia palm in a pedestal urn.
static func palm(a: Node3D, at: Vector3) -> void:
	Props.place(a, "planter", at, 0.0, 1)


# ---------------------------------------------------------------- helpers

## Bakes every static mesh under `root` into one mesh per material (and shadow setting), so the
## hundreds of boxes that make the hall cost a few dozen draws. Leaves lights, labels, MultiMeshes
## and any mesh with children alone. Only for geometry that never moves.
## Like merge(), but only for a room's own direct, unnamed, childless mesh children: the
## static architecture placed straight into the room. Named meshes and every assembly that
## moves (gates, curtains, people, racks) are left exactly as they are.
static func merge_direct(root: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var holder := Node3D.new()
	holder.name = "MergedStatic"
	var moved := 0
	for c in root.get_children():
		if c is MeshInstance3D and c.get_child_count() == 0 and c.material_override and String(c.name).begins_with("@"):
			root.remove_child(c)
			holder.add_child(c)
			moved += 1
	root.add_child(holder)
	if moved > 1:
		merge(holder)


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
				var key := "%d/%d/%d" % [c.material_override.get_instance_id(), c.cast_shadow, c.layers]
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
		mi.layers = parts[0][0].layers   # glimpse rooms render on their own layer
		root.add_child(mi)
		for part in parts:
			part[0].get_parent().remove_child(part[0])
			part[0].free()


static func _m(name: String) -> StandardMaterial3D:
	if _mats.has(name):
		return _mats[name]
	var m: StandardMaterial3D
	match name:
		"floor": m = ST.textured("tile_cream", 0.6, ST.plastic(Color("ddd4c2"), 0.5, 0.0))
		"carpet": m = ST.textured("carpet_forest", 0.5, ST.plastic(Color("23443f"), 0.9, 0.0))
		"plum_wall": m = ST.textured("plaster_cream", 0.3, ST.plastic(CREAM, 0.7, 0.0))
		"stone": m = ST.textured("stone_cream", 0.35, ST.plastic(Color("ddd5c3"), 0.75, 0.0))
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
		"steps":   # blue-grey treads, as in the reference
			m = ST.textured("metal_charcoal", 1.0, ST.plastic(Color("3a3c40"), 0.45, 0.6), 0.6)
			m.albedo_color = Color(2.3, 2.5, 2.9)
		"steel": m = ST.plastic(Color("8e9399"), 0.62, 0.45)   # brushed, not mirrored: a glossy strip clipped to a white line at grazing angles
		"rubber": m = ST.plastic(Color("141316"), 0.45, 0.0)
		"skyline":
			m = StandardMaterial3D.new()
			m.albedo_color = Color("2e2140")
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		"skyline_far":
			m = StandardMaterial3D.new()
			m.albedo_color = Color("6d4f74")
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		"window_lit":
			m = StandardMaterial3D.new()
			m.albedo_color = Color("ffd59a")
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		"frame_dark": m = ST.plastic(Color("2b2420"), 0.45, 0.35)
		"flute": m = ST.plastic(Color("d6ccb8"), 0.7, 0.0)
		"walnut": m = ST.plastic(Color("5e3a22"), 0.5, 0.0)
		"nosing": m = ST.plastic(Color("c9a64a"), 0.5, 0.3)
		"runner": m = ST.textured("carpet_sage", 0.5, ST.plastic(Color("3a5650"), 0.9, 0.0))
		"glass_clear":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.85, 0.88, 0.9, 0.18)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.05
		"shop_glass":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.85, 0.8, 0.7, 0.16)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.08
			m.metallic_specular = 0.8
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
