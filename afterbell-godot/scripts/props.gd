extends RefCounted
## The store's reusable prop library: a few good models, repeated deliberately.
##
##   Props.place(parent, "rack", Vector3(x, 0, z), yaw, variant)
##
## Kinds: rack (0 suits, 1 dresses), mannequin (0 navy suit + fedora, 1 cream dress + cloche,
## 2 brown suit, 3 plum dress), perfume_counter, perfume_tower, perfume_boxes (a cluster to stand
## on any counter), flower_display, easel (needs text), sale_card, hanging_sign (needs text).
##
## Each kind/variant is built once and baked into a single multi-material mesh; every placement
## shares that mesh, so a room full of racks costs a handful of draws. Text is a Label3D per
## placement. Without a renderer (headless tests) the parts are left unbaked.
##
## Local space: standing on y = 0, front facing +z. footprint() gives the floor rectangle a room
## should treat as solid.

const ST := preload("res://scripts/style.gd")

const HALF := {
	"rack": Vector2(0.95, 0.32), "mannequin": Vector2(0.3, 0.3), "perfume_counter": Vector2(0.88, 0.34),
	"perfume_tower": Vector2(0.6, 0.6), "flower_display": Vector2(0.66, 0.66), "easel": Vector2(0.36, 0.32),
}

static var _cache := {}
static var _mats := {}


## Builds (or reuses) a prop and adds it to `parent`. `text` is for signs.
static func place(parent: Node3D, kind: String, at: Vector3, yaw := 0.0, variant := 0, text := "") -> Node3D:
	var node := _instance(kind, variant)
	node.name = kind.capitalize().replace(" ", "")
	node.position = at
	node.rotation.y = yaw
	parent.add_child(node)
	match kind:
		"easel":
			_label(node, text, Vector3(0, 1.12, 0.045), 0.0042 if text.length() <= 5 else 0.0026, Color("efe3c8"), 56, 0.52)
		"sale_card":
			_label(node, text if text != "" else "SALE", Vector3(0, 0.3, 0.012), 0.0022, Color("efe3c8"), 48)
		"hanging_sign":
			_label(node, text, Vector3(0, 0, 0.035), 0.0045, Color("4a2238"), 64)
	return node


## The floor rectangle (x, z) a placed prop occupies, for room collision.
static func footprint(kind: String, at: Vector3, yaw := 0.0) -> Rect2:
	var h: Vector2 = HALF.get(kind, Vector2(0.3, 0.3))
	if absf(sin(yaw)) > 0.7:
		h = Vector2(h.y, h.x)
	return Rect2(Vector2(at.x, at.z) - h, h * 2.0)


## Pushes `p` out of any rect in `rects` grown by `pad` (rooms' prop collision).
static func push_out(p: Vector2, rects: Array, pad := 0.3) -> Vector2:
	for r in rects:
		var g: Rect2 = (r as Rect2).grow(pad)
		if not g.has_point(p):
			continue
		var m := minf(minf(p.x - g.position.x, g.end.x - p.x), minf(p.y - g.position.y, g.end.y - p.y))
		if m == p.x - g.position.x:
			p.x = g.position.x
		elif m == g.end.x - p.x:
			p.x = g.end.x
		elif m == p.y - g.position.y:
			p.y = g.position.y
		else:
			p.y = g.end.y
	return p


## A garment on its hanger, hook at the origin, front facing +x (so on a rail along x you see
## the shoulders and sleeves edge-on, as on a real rack). For racks built elsewhere too.
static func coat(parent: Node3D, at: Vector3, cloth: Material, dress := false, yaw := 0.0) -> Node3D:
	var c := Node3D.new()
	c.position = at
	c.rotation.y = yaw
	parent.add_child(c)
	_put(_cyl(0.008, 0.008, 0.08, 6), _m("brass"), Vector3(0, 0.0, 0), c)
	_put(_box(0.025, 0.03, 0.42), _m("wood"), Vector3(0, -0.055, 0), c)
	var shoulders := _put(_capsule(0.05, 0.44), cloth, Vector3(0, -0.1, 0), c)
	shoulders.rotation.x = PI / 2.0
	if dress:
		_put(_box(0.07, 0.42, 0.34), cloth, Vector3(0, -0.32, 0), c)
		var skirt := _put(_cyl(0.17, 0.27, 0.62, 16), cloth, Vector3(0, -0.84, 0), c)
		skirt.scale = Vector3(0.42, 1, 1)
		_put(_box(0.075, 0.05, 0.34), _m("brass"), Vector3(0, -0.53, 0), c)       # belt
	else:
		_put(_box(0.08, 0.8, 0.44), cloth, Vector3(0, -0.5, 0), c)
		for s in [-1.0, 1.0]:
			var lapel := _put(_box(0.012, 0.32, 0.07), cloth, Vector3(0.047, -0.27, s * 0.06), c)
			lapel.rotation.x = s * 0.32
			var sleeve := _put(_capsule(0.042, 0.62), cloth, Vector3(0.0, -0.44, s * 0.235), c)
			sleeve.rotation.x = s * -0.06
		_put(_box(0.01, 0.2, 0.05), _m("shirt"), Vector3(0.042, -0.23, 0), c)
		for y in [-0.47, -0.62]:
			_put(_sphere(0.012, 6), _m("brass"), Vector3(0.045, y, 0.02), c)
	return c


# ---------------------------------------------------------------- the models

static func _build(kind: String, v: int) -> Node3D:
	var n := Node3D.new()
	match kind:
		"rack": _rack(n, v)
		"mannequin": _mannequin(n, v)
		"perfume_counter": _perfume_counter(n, v)
		"perfume_tower": _perfume_tower(n, v)
		"perfume_boxes": _perfume_boxes(n, Vector3.ZERO, Vector2(0.6, 0.34), v)
		"flower_display": _flower_display(n)
		"easel": _easel(n, v)
		"sale_card": _sale_card(n)
		"hanging_sign": _hanging_sign(n)
	return n


static func _rack(n: Node3D, v: int) -> void:
	var len := 1.7
	for s in [-1.0, 1.0]:
		_put(_cyl(0.022, 0.022, 1.62, 8), _m("brass"), Vector3(s * len * 0.5, 0.83, 0), n)
		_put(_box(0.05, 0.035, 0.56), _m("brass"), Vector3(s * len * 0.5, 0.02, 0), n)
		for z in [-0.26, 0.26]:
			_put(_sphere(0.03, 8), _m("rubber"), Vector3(s * len * 0.5, 0.03, z), n)
		_put(_sphere(0.035, 10), _m("brass"), Vector3(s * len * 0.5, 1.66, 0), n)
	var rail := _put(_cyl(0.018, 0.018, len + 0.04, 8), _m("brass"), Vector3(0, 1.62, 0), n)
	rail.rotation.z = PI / 2.0
	var palette := ["suit_navy", "suit_charcoal", "suit_brown", "suit_navy", "plum", "suit_charcoal"] if v == 0 \
			else ["dress_cream", "plum", "dress_rose", "dress_cream", "dress_sage", "plum"]
	var count := 9
	for i in count:
		var x := -len * 0.42 + i * (len * 0.84 / (count - 1))
		coat(n, Vector3(x, 1.6, 0), _m(palette[(i * 5 + v) % palette.size()]), v == 1, (i % 3 - 1) * 0.05)


static func _mannequin(n: Node3D, v: int) -> void:
	var dress := v == 1 or v == 3
	var outfit: Material = _m(["suit_navy", "dress_cream", "suit_brown", "plum"][v % 4])
	var ivory := _m("ivory")
	_put(_cyl(0.2, 0.24, 0.04, 24), _m("rubber"), Vector3(0, 0.02, 0), n)
	_put(_cyl(0.21, 0.21, 0.012, 24), _m("brass"), Vector3(0, 0.045, 0), n)
	_put(_cyl(0.018, 0.018, 0.4, 8), _m("brass"), Vector3(0, 0.25, 0.1), n)
	if dress:
		for s in [-1.0, 1.0]:
			_put(_capsule(0.055, 0.6), ivory, Vector3(s * 0.08, 0.35, 0), n)
		var skirt := _put(_cyl(0.18, 0.3, 0.62, 24), outfit, Vector3(0, 0.82, 0), n)
		skirt.scale = Vector3(1, 1, 0.82)
		var bodice := _put(_cyl(0.18, 0.15, 0.5, 20), outfit, Vector3(0, 1.36, 0), n)
		bodice.scale = Vector3(1, 1, 0.7)
		_put(_cyl(0.155, 0.155, 0.06, 20), _m("brass" if v == 1 else "dress_cream"), Vector3(0, 1.13, 0), n).scale = Vector3(1, 1, 0.72)
	else:
		for s in [-1.0, 1.0]:
			_put(_cyl(0.072, 0.062, 0.86, 12), outfit, Vector3(s * 0.095, 0.52, 0), n)
			_put(_box(0.1, 0.06, 0.25), _m("shoe"), Vector3(s * 0.095, 0.1, 0.04), n)
		_put(_sphere(0.16, 16), outfit, Vector3(0, 0.98, 0), n).scale = Vector3(1.1, 0.7, 0.8)
		var jacket := _put(_cyl(0.21, 0.17, 0.62, 20), outfit, Vector3(0, 1.3, 0), n)
		jacket.scale = Vector3(1, 1, 0.7)
		_put(_box(0.08, 0.3, 0.02), _m("shirt"), Vector3(0, 1.45, 0.14), n)
		_put(_box(0.03, 0.22, 0.015), _m("plum"), Vector3(0, 1.42, 0.152), n)       # tie
		for s in [-1.0, 1.0]:
			var lapel := _put(_box(0.06, 0.3, 0.015), outfit, Vector3(s * 0.065, 1.44, 0.148), n)
			lapel.rotation.z = s * 0.38
		for y in [1.2, 1.3]:
			_put(_sphere(0.014, 6), _m("brass"), Vector3(0, y, 0.15), n)
	# Shoulders and arms: one arm down, one bent forward to present.
	var shoulder := _put(_capsule(0.065, 0.5), outfit, Vector3(0, 1.56, 0), n)
	shoulder.rotation.z = PI / 2.0
	shoulder.scale = Vector3(1, 1, 0.85)
	var down := _put(_capsule(0.048, 0.62), outfit if not dress else ivory, Vector3(-0.25, 1.24, 0), n)
	down.rotation.z = -0.07
	_put(_sphere(0.045, 10), ivory, Vector3(-0.27, 0.92, 0.0), n)
	var upper := _put(_capsule(0.048, 0.34), outfit if not dress else ivory, Vector3(0.26, 1.4, 0.02), n)
	upper.rotation.z = 0.12
	var fore := _put(_capsule(0.044, 0.32), outfit if not dress else ivory, Vector3(0.28, 1.2, 0.14), n)
	fore.rotation.x = PI / 2.0 - 0.3
	var palm := _put(_sphere(0.05, 10), ivory, Vector3(0.29, 1.15, 0.3), n)
	palm.scale = Vector3(0.6, 1.0, 1.3)
	# Neck, egg head, hat.
	_put(_cyl(0.05, 0.06, 0.12, 12), ivory, Vector3(0, 1.66, 0), n)
	_put(_sphere(0.125, 18), ivory, Vector3(0, 1.84, 0.01), n).scale = Vector3(0.88, 1.18, 0.96)
	match v % 4:
		0:
			_put(_cyl(0.2, 0.2, 0.014, 24), _m("hat"), Vector3(0, 1.94, 0), n)
			_put(_cyl(0.1, 0.125, 0.14, 18), _m("hat"), Vector3(0, 2.02, 0), n)
			_put(_cyl(0.127, 0.127, 0.035, 18), _m("plum"), Vector3(0, 1.97, 0), n)
		1:
			var cloche := _put(_sphere(0.14, 18), _m("plum"), Vector3(0, 1.93, 0), n)
			cloche.scale = Vector3(1.05, 0.75, 1.05)
			_put(_cyl(0.16, 0.17, 0.02, 20), _m("plum"), Vector3(0, 1.88, 0), n)
			_put(_sphere(0.03, 8), _m("dress_cream"), Vector3(0.12, 1.92, 0.06), n)   # flower pin
		3:
			_put(_cyl(0.22, 0.22, 0.012, 24), _m("dress_cream"), Vector3(0, 1.93, 0), n)
			_put(_cyl(0.11, 0.12, 0.09, 18), _m("dress_cream"), Vector3(0, 1.98, 0), n)
			_put(_cyl(0.122, 0.122, 0.025, 18), _m("plum"), Vector3(0, 1.95, 0), n)


static func _perfume_counter(n: Node3D, v: int) -> void:
	var w := 1.7
	var d := 0.62
	_put(_box(w, 0.42, d), _m("plum"), Vector3(0, 0.21, 0), n)
	_put(_box(w + 0.03, 0.04, d + 0.03), _m("brass"), Vector3(0, 0.43, 0), n)
	_put(_box(w - 0.04, 0.5, d - 0.04), _m("cream"), Vector3(0, 0.69, 0), n)
	for s in [-1.0, 1.0]:   # inset panels on the front
		_put(_box(w * 0.42, 0.34, 0.012), _m("plum"), Vector3(s * w * 0.24, 0.69, d * 0.5 - 0.01), n)
		_put(_box(w * 0.42 + 0.03, 0.015, 0.016), _m("brass"), Vector3(s * w * 0.24, 0.87, d * 0.5 - 0.008), n)
	_put(_box(w + 0.06, 0.035, d + 0.06), _m("brass"), Vector3(0, 0.955, 0), n)
	_put(_box(w, 0.02, d), _m("velvet"), Vector3(0, 0.98, 0), n)
	_perfume_boxes(n, Vector3(0, 0.99, 0), Vector2(w - 0.25, d - 0.18), v)


static func _perfume_tower(n: Node3D, v: int) -> void:
	_put(_cyl(0.55, 0.57, 0.45, 32), _m("plum"), Vector3(0, 0.225, 0), n)
	_put(_cyl(0.58, 0.58, 0.04, 32), _m("brass"), Vector3(0, 0.46, 0), n)
	_put(_cyl(0.6, 0.6, 0.05, 32), _m("cream"), Vector3(0, 0.505, 0), n)
	_put(_cyl(0.3, 0.32, 0.36, 28), _m("cream"), Vector3(0, 0.71, 0), n)
	_put(_cyl(0.33, 0.33, 0.03, 28), _m("brass"), Vector3(0, 0.9, 0), n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 400 + v
	for i in 10:   # gift boxes round the lower tier
		var a := TAU * i / 10.0 + rng.randf_range(-0.1, 0.1)
		_gift(n, Vector3(cos(a) * 0.45, 0.53, sin(a) * 0.45), rng, a)
	_perfume_boxes(n, Vector3(0, 0.915, 0), Vector2(0.4, 0.4), v + 7)
	# A display-size bottle crowning it.
	_put(_cyl(0.1, 0.12, 0.26, 20), _m("glass_rose"), Vector3(0, 1.06, 0), n)
	_put(_cyl(0.035, 0.04, 0.06, 12), _m("brass"), Vector3(0, 1.22, 0), n)
	_put(_sphere(0.06, 14), _m("brass"), Vector3(0, 1.29, 0), n)


## Gift boxes and bottles arranged inside `area` (x by z) on a surface at height `at.y`.
static func _perfume_boxes(n: Node3D, at: Vector3, area: Vector2, v: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 90 + v
	var cols := maxi(2, int(area.x / 0.2))
	var rows := maxi(1, int(area.y / 0.18))
	for c in cols:
		for r in rows:
			var p := at + Vector3(-area.x * 0.5 + (c + 0.5) * area.x / cols, 0, -area.y * 0.5 + (r + 0.5) * area.y / rows)
			p += Vector3(rng.randf_range(-0.02, 0.02), 0, rng.randf_range(-0.02, 0.02))
			if (c + r + v) % 3 == 0:
				_bottle(n, p, rng)
			else:
				var top := _gift(n, p, rng, rng.randf_range(-0.2, 0.2))
				if rng.randf() < 0.35:   # a second box stacked on top
					_gift(n, p + Vector3(0, top, 0), rng, rng.randf_range(-0.3, 0.3), 0.75)


## One wrapped perfume box with a brass ribbon; returns its height.
static func _gift(n: Node3D, at: Vector3, rng: RandomNumberGenerator, yaw: float, size := 1.0) -> float:
	var colors := ["box_pink", "box_lilac", "cream", "plum", "suit_navy", "box_rose"]
	var w := rng.randf_range(0.11, 0.17) * size
	var h := rng.randf_range(0.1, 0.2) * size
	var g := Node3D.new()
	g.position = at
	g.rotation.y = yaw
	n.add_child(g)
	_put(_box(w, h, w * 0.8), _m(colors[rng.randi() % colors.size()]), Vector3(0, h * 0.5, 0), g)
	_put(_box(w + 0.004, h + 0.004, 0.014), _m("brass"), Vector3(0, h * 0.5, 0), g)   # ribbon
	_put(_box(w + 0.006, 0.012, w * 0.8 + 0.006), _m("brass"), Vector3(0, h - 0.012, 0), g)   # lid edge
	return h


static func _bottle(n: Node3D, at: Vector3, rng: RandomNumberGenerator) -> void:
	var glass: String = ["glass_rose", "glass_amber", "glass_lilac"][rng.randi() % 3]
	var h := rng.randf_range(0.1, 0.16)
	var r := rng.randf_range(0.035, 0.05)
	if rng.randf() < 0.5:
		_put(_cyl(r, r * 1.1, h, 14), _m(glass), at + Vector3(0, h * 0.5, 0), n)
	else:
		_put(_box(r * 2.2, h, r * 1.4), _m(glass), at + Vector3(0, h * 0.5, 0), n)
	_put(_cyl(r * 0.35, r * 0.4, 0.03, 10), _m("brass"), at + Vector3(0, h + 0.015, 0), n)
	_put(_sphere(r * 0.55, 10), _m("brass"), at + Vector3(0, h + 0.05, 0), n)


static func _flower_display(n: Node3D) -> void:
	_put(_cyl(0.6, 0.62, 0.7, 36), _m("plum"), Vector3(0, 0.35, 0), n)
	_put(_cyl(0.63, 0.63, 0.04, 36), _m("brass"), Vector3(0, 0.03, 0), n)
	_put(_cyl(0.63, 0.63, 0.03, 36), _m("brass"), Vector3(0, 0.6, 0), n)
	_put(_cyl(0.66, 0.66, 0.06, 36), _m("cream"), Vector3(0, 0.73, 0), n)
	# Vase: dark green glaze, swelling then narrowing.
	_put(_cyl(0.13, 0.1, 0.06, 20), _m("vase"), Vector3(0, 0.79, 0), n)
	_put(_sphere(0.17, 20), _m("vase"), Vector3(0, 0.95, 0), n).scale = Vector3(1, 0.95, 1)
	_put(_cyl(0.1, 0.13, 0.18, 20), _m("vase"), Vector3(0, 1.15, 0), n)
	_put(_cyl(0.12, 0.12, 0.03, 20), _m("brass"), Vector3(0, 1.24, 0), n)
	# Lilies: stems fan out of the vase; each bloom is five petals round a yellow heart.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 9:
		var a := TAU * i / 9.0 + rng.randf_range(-0.2, 0.2)
		var tilt := rng.randf_range(0.25, 0.6)
		var length := rng.randf_range(0.45, 0.65)
		var dir := Vector3(sin(tilt) * cos(a), cos(tilt), sin(tilt) * sin(a))
		var base := Vector3(0, 1.22, 0)
		var tip := base + dir * length
		var stem := _put(_cyl(0.008, 0.01, length, 6), _m("leaf"), (base + tip) * 0.5, n)
		stem.basis = _aim_y(dir)
		var bloom := Node3D.new()
		bloom.position = tip
		bloom.basis = _aim_y(dir)
		n.add_child(bloom)
		for k in 5:
			var pa := TAU * k / 5.0
			var petal := _put(_sphere(0.06, 10), _m("lily"), Vector3(cos(pa) * 0.05, 0.03, sin(pa) * 0.05), bloom)
			petal.scale = Vector3(0.5, 0.25, 1.4)
			petal.rotation.y = -pa + PI / 2.0
			petal.rotation.x = -0.5
		_put(_sphere(0.022, 8), _m("pollen"), Vector3(0, 0.04, 0), bloom)
		if i % 2 == 0:
			var leaf := _put(_sphere(0.07, 8), _m("leaf"), base + dir * length * 0.45 + Vector3(0, 0, 0.02), n)
			leaf.basis = _aim_y(dir.rotated(Vector3.UP, 0.6)) * Basis.from_scale(Vector3(0.35, 1.8, 0.12))


static func _easel(n: Node3D, v: int) -> void:
	for s in [-1.0, 1.0]:
		var leg := _put(_cyl(0.014, 0.016, 1.6, 8), _m("brass"), Vector3(s * 0.26, 0.78, 0.0), n)
		leg.rotation.z = s * -0.08
	var back := _put(_cyl(0.012, 0.014, 1.5, 8), _m("brass"), Vector3(0, 0.72, -0.24), n)
	back.rotation.x = -0.32
	_put(_box(0.58, 0.02, 0.02), _m("brass"), Vector3(0, 0.66, 0.02), n)        # ledge
	var board: String = "sale_red" if v == 1 else "plum"
	_put(_box(0.64, 0.84, 0.025), _m("brass"), Vector3(0, 1.1, 0.02), n)
	_put(_box(0.6, 0.8, 0.03), _m(board), Vector3(0, 1.1, 0.024), n)
	_put(_box(0.5, 0.012, 0.004), _m("brass"), Vector3(0, 1.39, 0.041), n)
	_put(_box(0.5, 0.012, 0.004), _m("brass"), Vector3(0, 0.81, 0.041), n)
	_put(_sphere(0.025, 8), _m("brass"), Vector3(0, 1.56, 0.02), n)


static func _sale_card(n: Node3D) -> void:
	_put(_box(0.14, 0.015, 0.08), _m("brass"), Vector3(0, 0.008, 0), n)
	_put(_cyl(0.006, 0.006, 0.18, 6), _m("brass"), Vector3(0, 0.1, -0.01), n)
	_put(_box(0.34, 0.2, 0.008), _m("sale_red"), Vector3(0, 0.29, 0.0), n)
	_put(_box(0.36, 0.22, 0.004), _m("brass"), Vector3(0, 0.29, -0.006), n)


static func _hanging_sign(n: Node3D) -> void:
	_put(_box(2.0, 0.42, 0.04), _m("cream"), Vector3.ZERO, n)
	for y in [-0.22, 0.22]:
		_put(_box(2.06, 0.03, 0.06), _m("brass"), Vector3(0, y, 0), n)
	for x in [-1.03, 1.03]:
		_put(_box(0.03, 0.47, 0.06), _m("brass"), Vector3(x, 0, 0), n)
		_put(_cyl(0.008, 0.008, 0.7, 6), _m("brass"), Vector3(x * 0.8, 0.57, 0), n)


# ---------------------------------------------------------------- baking and helpers

static func _instance(kind: String, variant: int) -> Node3D:
	if DisplayServer.get_name() == "headless":
		return _build(kind, variant)
	var key := "%s:%d" % [kind, variant]
	if not _cache.has(key):
		_cache[key] = _bake(_build(kind, variant))
	var root := Node3D.new()
	var mi := MeshInstance3D.new()
	mi.mesh = _cache[key]
	root.add_child(mi)
	return root


## One ArrayMesh with a surface per material, from every MeshInstance3D under `node`.
static func _bake(node: Node3D) -> ArrayMesh:
	var groups := {}
	var order := []
	var stack := [[node, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var item: Array = stack.pop_back()
		for c in (item[0] as Node).get_children():
			if not c is Node3D:
				continue
			var xf: Transform3D = item[1] * (c as Node3D).transform
			if c is MeshInstance3D and c.mesh:
				var m: Material = c.material_override
				if not groups.has(m):
					groups[m] = []
					order.append(m)
				groups[m].append([c.mesh, xf])
			stack.append([c, xf])
	var out := ArrayMesh.new()
	for m in order:
		var st := SurfaceTool.new()
		for part in groups[m]:
			var mesh: Mesh = part[0]
			for s in mesh.get_surface_count():
				st.append_from(mesh, s, part[1])
		st.commit(out)
		out.surface_set_material(out.get_surface_count() - 1, m)
	node.free()
	return out


static func _label(node: Node3D, text: String, at: Vector3, px: float, color: Color, size: int, wrap_width := 0.0) -> void:
	var l := Label3D.new()
	l.text = text
	if wrap_width > 0.0:   # keep long text on the board: wrap within its width
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.width = wrap_width / px
	l.font_size = size
	l.pixel_size = px
	l.modulate = color
	l.outline_size = 0
	l.position = at
	l.double_sided = false
	node.add_child(l)


## A basis whose +y points along `dir`.
static func _aim_y(dir: Vector3) -> Basis:
	var y := dir.normalized()
	var x := y.cross(Vector3.FORWARD)
	if x.length() < 0.01:
		x = Vector3.RIGHT
	x = x.normalized()
	return Basis(x, y, x.cross(y))


static func _m(name: String) -> Material:
	if _mats.has(name):
		return _mats[name]
	var m: StandardMaterial3D
	match name:
		"brass": m = ST.textured("brass", 2.0, ST.plastic(Color("b58d3f"), 0.35, 0.85), 0.85)
		"wood": m = ST.plastic(Color("8a6440"), 0.5, 0.0)
		"rubber": m = ST.plastic(Color("17161b"), 0.6, 0.0)
		"cream": m = ST.textured("plaster_cream", 0.6, ST.plastic(Color("efe3c8"), 0.55, 0.0))
		"plum": m = ST.textured("laminate_plum", 1.0, ST.plastic(Color("5b2a4a"), 0.6, 0.0))
		"velvet": m = ST.textured("velvet_red", 1.0, ST.plastic(Color("4a1a2c"), 0.9, 0.0))
		"ivory": m = ST.plastic(Color("e6dccb"), 0.45, 0.0)
		"shirt": m = ST.plastic(Color("f2ece0"), 0.7, 0.0)
		"shoe": m = ST.plastic(Color("1c1715"), 0.4, 0.0)
		"hat": m = ST.plastic(Color("2a2422"), 0.75, 0.0)
		"suit_navy": m = ST.plastic(Color("2c3550"), 0.85, 0.0)
		"suit_brown": m = ST.plastic(Color("5a3d2e"), 0.85, 0.0)
		"suit_charcoal": m = ST.plastic(Color("3a3836"), 0.85, 0.0)
		"dress_cream": m = ST.textured("linen_cream", 2.0, ST.plastic(Color("ece0c8"), 0.85, 0.0))
		"dress_rose": m = ST.plastic(Color("b8697e"), 0.8, 0.0)
		"dress_sage": m = ST.plastic(Color("7d9478"), 0.8, 0.0)
		"box_pink": m = ST.plastic(Color("eab8c8"), 0.6, 0.0)
		"box_lilac": m = ST.plastic(Color("b9a2d4"), 0.6, 0.0)
		"box_rose": m = ST.plastic(Color("c97d97"), 0.6, 0.0)
		"glass_rose": m = ST.plastic(Color("e7a6b6"), 0.25, 0.0)
		"glass_amber": m = ST.plastic(Color("d79a52"), 0.25, 0.0)
		"glass_lilac": m = ST.plastic(Color("b49ad6"), 0.25, 0.0)
		"vase": m = ST.plastic(Color("1e3029"), 0.4, 0.0)
		"leaf": m = ST.plastic(Color("3a6a34"), 0.7, 0.0)
		"lily": m = ST.plastic(Color("f6f0e4"), 0.7, 0.0)
		"pollen": m = ST.plastic(Color("e2a43a"), 0.8, 0.0)
		"sale_red": m = ST.plastic(Color("9e1b22"), 0.7, 0.0)
		_: m = ST.plastic(Color("efe3c8"), 0.6, 0.0)
	_mats[name] = m
	return m


static func _put(mesh: Mesh, material: Material, pos: Vector3, parent: Node3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
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
	s.rings = maxi(segments / 2, 4)
	return s


static func _capsule(r: float, h: float) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = r
	c.height = maxf(h, r * 2.0)
	c.radial_segments = 12
	c.rings = 4
	return c
