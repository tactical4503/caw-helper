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

## Ren is the ruler (rigs/ren.tscn, measured with tools/ruler.gd): 1.83 m tall standing, about
## 1.70 m in his guard crouch, belt at 1.02 m. Furniture and doorways are sized from him.
const REN_HEIGHT := 1.83
const WAIST := 1.0            # counter tops sit at his belt
const DOOR_HEIGHT := 2.4      # doorways clear his helmet by more than half a metre
const FIGURE_SCALE := 0.9     # mannequins stand about his height, hats included

const HALF := {
	"rack": Vector2(0.95, 0.32), "mannequin": Vector2(0.3, 0.3), "perfume_counter": Vector2(0.88, 0.34),
	"perfume_tower": Vector2(0.6, 0.6), "flower_display": Vector2(0.66, 0.66), "easel": Vector2(0.36, 0.32),
	"folded_table": Vector2(0.68, 0.38), "mannequin_group": Vector2(0.88, 0.88),
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
	if HALF.has(kind):
		var h: Vector2 = HALF[kind]
		contact_shadow(node, Vector2(h.x * 2.0 + 0.35, h.y * 2.0 + 0.35))
	match kind:
		"easel":
			_label(node, text, Vector3(0, 1.12, 0.056), 0.0042 if text.length() <= 5 else 0.0026, Color("eee6d4"), 56, 0.0 if text.length() <= 5 else 0.52)
		"sale_card":
			_label(node, text if text != "" else "SALE", Vector3(0, 0.3, 0.012), 0.0022, Color("eee6d4"), 48)
		"hanging_sign":
			# Scale the lettering so the whole name fits inside the 2 m panel.
			_label(node, text, Vector3(0, 0, 0.035), minf(0.0045, 1.8 / (maxf(text.length(), 1) * 0.55 * 64.0)), Color("4a2238"), 64)
	return node


## The floor rectangle (x, z) a placed prop occupies, for room collision.
static func footprint(kind: String, at: Vector3, yaw := 0.0) -> Rect2:
	var h: Vector2 = HALF.get(kind, Vector2(0.3, 0.3))
	if absf(sin(yaw)) > 0.7:
		h = Vector2(h.y, h.x)
	return Rect2(Vector2(at.x, at.z) - h, h * 2.0)


static var _shadow_tex: GradientTexture2D


## A soft contact shadow under a piece of furniture: a decal that darkens the floor (and the
## bottom few centimetres of the piece) in a soft-edged oval `size` across, so it sits on the
## carpet instead of floating.
static func contact_shadow(parent: Node3D, size: Vector2, at := Vector3.ZERO) -> Decal:
	if _shadow_tex == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		g.colors = PackedColorArray([Color(0, 0, 0, 0.6), Color(0, 0, 0, 0.35), Color(0, 0, 0, 0.0)])
		_shadow_tex = GradientTexture2D.new()
		_shadow_tex.gradient = g
		_shadow_tex.fill = GradientTexture2D.FILL_RADIAL
		_shadow_tex.fill_from = Vector2(0.5, 0.5)
		_shadow_tex.fill_to = Vector2(0.5, 0.0)
		_shadow_tex.width = 64
		_shadow_tex.height = 64
	var d := Decal.new()
	d.size = Vector3(size.x, 0.3, size.y)
	d.texture_albedo = _shadow_tex
	d.albedo_mix = 1.0
	d.upper_fade = 0.6
	d.lower_fade = 0.3
	d.position = at + Vector3(0, 0.1, 0)
	parent.add_child(d)
	return d


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
		"mannequin":
			var figure := Node3D.new()
			figure.scale = Vector3.ONE * FIGURE_SCALE
			n.add_child(figure)
			_mannequin(figure, v)
		"perfume_counter": _perfume_counter(n, v)
		"perfume_tower": _perfume_tower(n, v)
		"perfume_boxes": _perfume_boxes(n, Vector3.ZERO, Vector2(1.1, 0.4), v)
		"folded_table": _folded_table(n, v)
		"mannequin_group": _mannequin_group(n, v)
		"flower_display": _flower_display(n)
		"easel": _easel(n, v)
		"sale_card": _sale_card(n)
		"hanging_sign": _hanging_sign(n)
	return n


static func _rack(n: Node3D, v: int) -> void:
	var len := 1.7
	rack_frame(n, len, 1.62, 0.56)
	# Sorted into colour blocks of three, evenly spaced and hung square.
	var blocks := ["suit_navy", "suit_charcoal", "suit_brown"] if v == 0 else ["dress_cream", "dress_rose", "plum"]
	var count := 9
	for i in count:
		var x := -len * 0.42 + i * (len * 0.84 / (count - 1))
		coat(n, Vector3(x, 1.6, 0), _m(blocks[i / 3]), v == 1)


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
	counter(n, Vector3.ZERO, Vector3(w, WAIST, d), "plum" if v % 2 else "cream", 0.08, Vector3(0, 0, -1), false)   # panelled front, drawers behind
	_perfume_boxes(n, Vector3(0, WAIST, 0), Vector2(w - 0.25, d - 0.18), v)


static func _perfume_tower(n: Node3D, v: int) -> void:
	var fam: Array = FAMILIES[v % FAMILIES.size()]
	_put(_cyl(0.55, 0.57, 0.45, 32), _m("plum"), Vector3(0, 0.225, 0), n)
	_put(_cyl(0.58, 0.58, 0.04, 32), _m("brass"), Vector3(0, 0.46, 0), n)
	_put(_cyl(0.6, 0.6, 0.05, 32), _m("cream"), Vector3(0, 0.505, 0), n)
	_put(_cyl(0.3, 0.32, 0.36, 28), _m("cream"), Vector3(0, 0.71, 0), n)
	_put(_cyl(0.33, 0.33, 0.03, 28), _m("brass"), Vector3(0, 0.9, 0), n)
	# Ten identical boxes round the lower tier, facing out, alternating the family's colours.
	for i in 10:
		var a := TAU * i / 10.0
		var g := Node3D.new()
		g.position = Vector3(cos(a) * 0.44, 0.53, sin(a) * 0.44)
		g.rotation.y = -a + PI / 2.0
		n.add_child(g)
		_put(_box(0.15, 0.16, 0.11), _m(fam[i % 2]), Vector3(0, 0.08, 0), g)
		_put(_box(0.152, 0.162, 0.012), _m("brass"), Vector3(0, 0.08, 0), g)
	# Hero bottle in the middle of the top tier, six small ones round it.
	_bottle_at(n, Vector3(0, 0.915, 0), fam[2], 0.24, 0.09, false)
	for i in 6:
		var a := TAU * i / 6.0
		_bottle_at(n, Vector3(cos(a) * 0.22, 0.915, sin(a) * 0.22), fam[2], 0.09, 0.025, i % 2 == 0)


## Colour families for perfume displays: [box, accent box, glass].
const FAMILIES := [["box_pink", "box_rose", "glass_rose"], ["box_lilac", "plum", "glass_lilac"],
		["cream", "box_rose", "glass_amber"], ["suit_navy", "cream", "glass_amber"]]


## One perfume arrangement on a surface at `at` (centre), filling about `area` (x by z): a
## pyramid of gift boxes on the left, a stepped riser of matching bottles in the middle, a
## mirrored tester tray on the right. Everything lines up; colours stay in one family.
static func _perfume_boxes(n: Node3D, at: Vector3, area: Vector2, v: int) -> void:
	var fam: Array = FAMILIES[v % FAMILIES.size()]
	var w := area.x
	var d := minf(area.y, 0.36)
	_riser(n, at, minf(w * 0.38, 0.42), d, fam)
	_pyramid(n, at + Vector3(-w * 0.34, 0, 0.0), minf(w * 0.27, 0.3), fam)
	_tray(n, at + Vector3(w * 0.34, 0, 0.02), minf(w * 0.12, 0.13), fam)


## Three stepped tiers, back highest; a row of identical bottles on each, a hero bottle on top.
static func _riser(n: Node3D, at: Vector3, w: float, d: float, fam: Array) -> void:
	var td := d / 3.0
	for i in 3:
		var h := 0.04 + 0.05 * i
		var z := d * 0.5 - td * (i + 0.5)
		_put(_box(w, h, td), _m("cream"), at + Vector3(0, h * 0.5, z), n)
		_put(_box(w + 0.006, 0.01, 0.006), _m("brass"), at + Vector3(0, h - 0.005, z + td * 0.5), n)
		var count := 1 if i == 2 else maxi(2, int(w / 0.085))
		for k in count:
			var x := 0.0 if count == 1 else -w * 0.5 + (k + 0.5) * w / count
			var big := i == 2
			_bottle_at(n, at + Vector3(x, h, z), fam[2] if i != 1 else "glass_amber", 0.17 if big else 0.1, 0.05 if big else 0.03, i == 0)


## Gift boxes stacked 3-2-1 facing front, alternating the family's two box colours.
static func _pyramid(n: Node3D, at: Vector3, w: float, fam: Array) -> void:
	var s := w / 3.0
	var y := 0.0
	for row in 3:
		var count := 3 - row
		for k in count:
			var x := (k - (count - 1) * 0.5) * s
			var col: String = fam[(k + row) % 2]
			_put(_box(s * 0.96, s * 0.8, s * 0.85), _m(col), at + Vector3(x, y + s * 0.4, 0), n)
			_put(_box(s * 0.97, s * 0.81, 0.012), _m("brass"), at + Vector3(x, y + s * 0.4, 0), n)    # ribbon
			_put(_box(0.012, s * 0.81, s * 0.86), _m("brass"), at + Vector3(x, y + s * 0.4, 0), n)
		y += s * 0.8


## A round mirrored tray with three tester bottles and a little cream card.
static func _tray(n: Node3D, at: Vector3, r: float, fam: Array) -> void:
	_put(_cyl(r, r, 0.012, 24), _m("brass"), at + Vector3(0, 0.006, 0), n)
	_put(_cyl(r - 0.012, r - 0.012, 0.014, 24), _m("mirror"), at + Vector3(0, 0.008, 0), n)
	for k in 3:
		var a := TAU * k / 3.0 + PI / 2.0
		_bottle_at(n, at + Vector3(cos(a) * r * 0.5, 0.015, sin(a) * r * 0.5), fam[2], 0.08, 0.022, false)
	var card := _put(_box(0.07, 0.05, 0.004), _m("shirt"), at + Vector3(0, 0.04, r + 0.02), n)
	card.rotation.x = -0.35


static func _bottle_at(n: Node3D, at: Vector3, glass: String, h: float, r: float, square: bool) -> void:
	if square:
		_put(_box(r * 2.2, h, r * 1.4), _m(glass), at + Vector3(0, h * 0.5, 0), n)
	else:
		_put(_cyl(r, r * 1.1, h, 14), _m(glass), at + Vector3(0, h * 0.5, 0), n)
	_put(_cyl(r * 0.35, r * 0.4, 0.03, 10), _m("brass"), at + Vector3(0, h + 0.015, 0), n)
	_put(_sphere(r * 0.55, 10), _m("brass"), at + Vector3(0, h + 0.05, 0), n)


## A walnut display table of folded knitwear: three neat stacks, one colour each.
static func _folded_table(n: Node3D, v: int) -> void:
	var h := WAIST * 0.82
	_put(rounded_block(1.3, 0.05, 0.7, 0.06, 0.012), _m("walnut"), Vector3(0, h - 0.05, 0), n)
	_put(rounded_block(1.2, 0.09, 0.6, 0.04), _m("walnut_dark"), Vector3(0, h - 0.14, 0), n)   # apron
	_put(_box(1.24, 0.014, 0.64), _m("brass"), Vector3(0, h - 0.05, 0), n)
	for x in [-0.55, 0.55]:
		for z in [-0.25, 0.25]:
			_put(_cyl(0.025, 0.018, h - 0.14, 10), _m("walnut"), Vector3(x, (h - 0.14) * 0.5, z), n)
			_put(_cyl(0.022, 0.022, 0.03, 10), _m("brass"), Vector3(x, 0.015, z), n)
	var stacks: Array = [["suit_navy", "suit_charcoal", "dress_cream"], ["dress_rose", "plum", "dress_cream"],
			["dress_sage", "dress_cream", "suit_brown"], ["box_lilac", "plum", "box_pink"]][v % 4]
	for k in 3:
		var x := (k - 1) * 0.4
		for i in 5:
			var y := h + 0.024 + i * 0.048
			_put(_box(0.32, 0.044, 0.25), _m(stacks[k]), Vector3(x, y, 0), n)
			_put(_box(0.3, 0.012, 0.012), _m(stacks[k]), Vector3(x, y + 0.012, 0.128), n)   # folded edge
	# A small brass card stand at the front.
	_put(_box(0.12, 0.01, 0.05), _m("brass"), Vector3(0.0, h + 0.005, 0.3), n)
	var card := _put(_box(0.16, 0.1, 0.006), _m("sale_red"), Vector3(0.0, h + 0.06, 0.3), n)
	card.rotation.x = -0.3


## Two mannequins posed toward each other on a shared round platform.
static func _mannequin_group(n: Node3D, v: int) -> void:
	_put(rounded_block(1.7, 0.04, 1.7, 0.84), _m("plinth"), Vector3.ZERO, n)
	_put(_cyl(0.85, 0.86, 0.12, 40), _m("plum"), Vector3(0, 0.1, 0), n)
	_put(_cyl(0.87, 0.87, 0.02, 40), _m("brass"), Vector3(0, 0.165, 0), n)
	_put(_cyl(0.84, 0.84, 0.02, 40), _m("cream"), Vector3(0, 0.17, 0), n)
	var looks: Array = [[0, 1], [2, 3], [0, 3], [2, 1]][v % 4]
	for k in 2:
		var s := -1.0 if k == 0 else 1.0
		var fig := Node3D.new()
		fig.position = Vector3(s * 0.34, 0.18, -0.05 * k)
		fig.rotation.y = -s * 0.4
		fig.scale = Vector3.ONE * FIGURE_SCALE
		n.add_child(fig)
		_mannequin(fig, looks[k])


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
	_put(_box(0.66, 0.86, 0.045), _m("brass"), Vector3(0, 1.1, 0.012), n)
	_put(_box(0.6, 0.8, 0.055), _m(board), Vector3(0, 1.1, 0.02), n)
	_put(_box(0.5, 0.012, 0.004), _m("brass"), Vector3(0, 1.39, 0.041), n)
	_put(_box(0.5, 0.012, 0.004), _m("brass"), Vector3(0, 0.81, 0.041), n)
	_put(_sphere(0.025, 8), _m("brass"), Vector3(0, 1.56, 0.02), n)


static func _sale_card(n: Node3D) -> void:
	_put(_box(0.14, 0.015, 0.08), _m("brass"), Vector3(0, 0.008, 0), n)
	_put(_cyl(0.006, 0.006, 0.18, 6), _m("brass"), Vector3(0, 0.1, -0.01), n)
	_put(_box(0.34, 0.2, 0.008), _m("sale_red"), Vector3(0, 0.29, 0.0), n)
	_put(_box(0.36, 0.22, 0.004), _m("brass"), Vector3(0, 0.29, -0.006), n)


static func _hanging_sign(n: Node3D) -> void:
	_put(_box(2.0, 0.42, 0.06), _m("cream"), Vector3.ZERO, n)
	for y in [-0.23, 0.23]:
		_put(_box(2.1, 0.05, 0.09), _m("brass"), Vector3(0, y, 0), n)
	for x in [-1.03, 1.03]:
		_put(_box(0.05, 0.51, 0.09), _m("brass"), Vector3(x, 0, 0), n)
		_put(_cyl(0.008, 0.008, 0.7, 6), _m("brass"), Vector3(x * 0.8, 0.57, 0), n)


# ---------------------------------------------------------------- counters and doors

## A counter that reads as solid furniture: a recessed dark plinth, a plum base with a brass
## band, a cream cabinet, a brass trim line and an overhanging countertop with a softened edge.
## Every layer has rounded corners. `at` is the floor centre; size is (width, height, depth).
## `top` picks the countertop: "cream" (stone), "walnut" or "plum".
## A shop counter about Ren's belt height: recessed toe plinth, plum base, brass bands, a
## panelled cream cabinet and an 8 cm top with a softened edge, lifted off the cabinet on a dark
## reveal so it reads as a separate slab. Every face but `service` carries framed, recessed
## panels with brass beading. `service` (a local axis: ±x or ±z; zero for none) is the staff
## side: drawers with brass pulls over cupboard doors, and on long runs an open stock shelf.
## `merge` bakes the parts together; pass false when the caller bakes the counter itself.
static func counter(parent: Node3D, at: Vector3, size: Vector3, top := "cream", r := 0.08, service := Vector3.ZERO, merge := true) -> Node3D:
	var c := Node3D.new()
	c.position = at
	parent.add_child(c)
	var w := size.x
	var h := size.y
	var d := size.z
	_put(rounded_block(w - 0.1, 0.1, d - 0.1, r * 0.6), _m("plinth"), Vector3.ZERO, c)
	_put(rounded_block(w, 0.34, d, r), _m("plum"), Vector3(0, 0.1, 0), c)
	_put(rounded_block(w + 0.02, 0.04, d + 0.02, r + 0.01), _m("brass"), Vector3(0, 0.44, 0), c)
	_put(rounded_block(w - 0.02, h - 0.6, d - 0.02, r), _m("cream"), Vector3(0, 0.48, 0), c)
	_put(rounded_block(w + 0.03, 0.035, d + 0.03, r + 0.015), _m("brass"), Vector3(0, h - 0.125, 0), c)
	_put(rounded_block(w + 0.04, 0.014, d + 0.04, r + 0.02), _m("walnut_dark"), Vector3(0, h - 0.094, 0), c)
	var tops := {"cream": "counter_top", "walnut": "walnut", "plum": "plum"}
	_put(rounded_block(w + 0.1, 0.08, d + 0.1, r + 0.05, 0.03), _m(tops[top]), Vector3(0, h - 0.08, 0), c)
	for face in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
		var along: float = (d if face.x != 0.0 else w) - 0.02 - 2.0 * r   # the flat run between the rounded corners
		if along < 0.3:
			continue
		var f := Node3D.new()
		f.position = face * (((w if face.x != 0.0 else d) - 0.02) * 0.5)   # on the cabinet face, +z outward
		f.basis = Basis(Vector3.UP, atan2(face.x, face.z))
		c.add_child(f)
		if face.is_equal_approx(service):
			_service_face(f, along, h)
		else:
			_panelled_face(f, along, h)
	contact_shadow(c, Vector2(w + 0.45, d + 0.45))
	if merge:
		Atrium_merge(c)
	return c


## Rails and stiles standing 12 mm proud of the cabinet, so each field reads as recessed behind
## them, with a brass bead inside every opening. Face-local: x along the face, +z outward.
static func _panelled_face(f: Node3D, along: float, h: float) -> void:
	var y0 := 0.48
	var y1 := h - 0.12
	var stile := 0.05
	var n := maxi(1, roundi(along / 0.7))
	var pw := (along - stile * (n + 1)) / n
	for y in [y0 + stile * 0.5, y1 - stile * 0.5]:
		_put(_box(along, stile, 0.024), _m("cream"), Vector3(0, y, 0), f)
	for i in n + 1:
		_put(_box(stile, y1 - y0 - stile * 2.0, 0.024), _m("cream"), Vector3(-along * 0.5 + stile * 0.5 + i * (pw + stile), (y0 + y1) * 0.5, 0), f)
	for i in n:
		_bead(f, Vector3(-along * 0.5 + stile + pw * 0.5 + i * (pw + stile), (y0 + y1) * 0.5, 0.004), Vector2(pw - 0.03, y1 - y0 - stile * 2.0 - 0.03))


## A thin brass bead framing a rectangle `size` centred on `at` (face-local).
static func _bead(f: Node3D, at: Vector3, size: Vector2) -> void:
	for s in [-1.0, 1.0]:
		_put(_box(size.x + 0.012, 0.012, 0.01), _m("brass"), at + Vector3(0, s * size.y * 0.5, 0), f)
		_put(_box(0.012, size.y, 0.01), _m("brass"), at + Vector3(s * size.x * 0.5, 0, 0), f)


## The staff side: bays of two drawers over a cupboard door, with an open stock shelf in the
## middle bay of a long run.
static func _service_face(f: Node3D, along: float, h: float) -> void:
	var n := maxi(1, roundi(along / 0.55))
	var bay := along / n
	var open_bay := n / 2 if n >= 3 else -1
	for i in n:
		var cx := -along * 0.5 + bay * (i + 0.5)
		if i == open_bay:
			_stock_shelf(f, cx, bay - 0.05, h)
			continue
		var y0 := 0.5
		var dh := (h - 0.14 - y0 - 0.02) * 0.5
		for k in 2:
			_front(f, Vector3(cx, y0 + dh * 0.5 + k * (dh + 0.02), 0), Vector2(bay - 0.05, dh), "cream", true)
		_front(f, Vector3(cx, 0.27, 0.01), Vector2(bay - 0.05, 0.28), "plum", false)   # on the plum base, 1 cm further out


## A drawer or door front over a dark shadow gap. Drawers get a brass bar pull; doors a knob
## and escutcheon near the meeting edge.
static func _front(f: Node3D, at: Vector3, size: Vector2, mat: String, drawer: bool) -> void:
	_put(_box(size.x + 0.012, size.y + 0.012, 0.006), _m("walnut_dark"), at + Vector3(0, 0, 0.002), f)
	_put(_box(size.x, size.y, 0.018), _m(mat), at + Vector3(0, 0, 0.009), f)
	if drawer:
		var length := minf(0.16, size.x * 0.4)
		var bar := _put(_cyl(0.007, 0.007, length, 8), _m("brass"), at + Vector3(0, 0, 0.034), f)
		bar.rotation.z = PI / 2.0
		for s in [-1.0, 1.0]:
			var post := _put(_cyl(0.005, 0.006, 0.016, 6), _m("brass"), at + Vector3(s * length * 0.4, 0, 0.026), f)
			post.rotation.x = PI / 2.0
	else:
		var knob := at + Vector3(size.x * 0.36, size.y * 0.2, 0)
		var plate := _put(_box(0.03, 0.06, 0.004), _m("brass"), knob + Vector3(0, 0, 0.02), f)
		plate.position.y -= 0.01
		_put(_sphere(0.014, 8), _m("brass"), knob + Vector3(0, 0, 0.032), f)


## An open bay on the staff side: shadowed interior, two walnut shelves, brass-beaded opening,
## and the stock a counter keeps under it (cartons, tissue, a ledger).
static func _stock_shelf(f: Node3D, cx: float, w: float, h: float) -> void:
	var y0 := 0.13
	var y1 := h - 0.14
	var mid := (y0 + y1) * 0.5
	_put(_box(w, y1 - y0, 0.004), _m("walnut_dark"), Vector3(cx, mid, 0.013), f)
	_bead(f, Vector3(cx, mid, 0.017), Vector2(w, y1 - y0))
	for y in [y0, mid]:
		_put(_box(w - 0.02, 0.02, 0.05), _m("walnut"), Vector3(cx, y + 0.01, 0.03), f)
	for k in 2:   # cartons on the lower shelf
		_put(_box(w * 0.36, 0.16, 0.036), _m("carton"), Vector3(cx - w * 0.22 + k * w * 0.42, y0 + 0.1, 0.034), f)
	for k in 3:   # folded tissue, then the ledger on top
		_put(_box(w * 0.4, 0.022, 0.04), _m("shirt"), Vector3(cx - w * 0.2, mid + 0.031 + k * 0.024, 0.034), f)
	_put(_box(w * 0.34, 0.2, 0.034), _m("walnut_dark"), Vector3(cx + w * 0.24, mid + 0.12, 0.035), f)
	_put(_box(w * 0.34, 0.03, 0.036), _m("brass"), Vector3(cx + w * 0.24, mid + 0.16, 0.035), f)   # the ledger's label band


## A tube between two points.
static func _tube(parent: Node3D, a: Vector3, b: Vector3, r: float, mat: Material, segments := 10) -> MeshInstance3D:
	var t := _put(_cyl(r, r, a.distance_to(b), segments), mat, (a + b) * 0.5, parent)
	t.basis = _aim_y(b - a)
	return t


## A hex bolt head at `at`, its shank pointing back along -`dir`.
static func _bolt(parent: Node3D, at: Vector3, dir: Vector3, mat: Material) -> void:
	var b := _put(_cyl(0.008, 0.008, 0.008, 6), mat, at + dir * 0.004, parent)
	b.basis = _aim_y(dir)


## A swivel caster standing on the floor at `at`: top plate, fork, rubber wheel, axle.
static func _caster(parent: Node3D, at: Vector3, mat: Material, plate_y: float) -> void:
	_put(_box(0.05, 0.008, 0.05), mat, at + Vector3(0, plate_y, 0), parent)
	_put(_cyl(0.008, 0.008, plate_y - 0.04, 6), mat, at + Vector3(0, (plate_y + 0.04) * 0.5, 0), parent)   # swivel stem
	for s in [-1.0, 1.0]:
		_put(_box(0.005, 0.04, 0.034), mat, at + Vector3(s * 0.014, 0.034, 0), parent)
	var wheel := _put(_cyl(0.025, 0.025, 0.018, 14), _m("rubber"), at + Vector3(0, 0.026, 0), parent)
	wheel.rotation.z = PI / 2.0
	var axle := _put(_cyl(0.006, 0.006, 0.036, 6), mat, at + Vector3(0, 0.026, 0), parent)
	axle.rotation.z = PI / 2.0


## A garment-rail frame put together the way real ones are: tube uprights socketed into
## bolted T-fittings on caster feet, ball elbows at the top, a lower stretcher on tees, and a
## height collar with a thumb screw on each upright. Rail along x, uprights `length` apart,
## rail centre at `rail_y`, feet `foot` deep.
static func rack_frame(parent: Node3D, length: float, rail_y: float, foot := 0.56, tube: Material = null, fitting: Material = null) -> void:
	var t: Material = tube if tube else _m("brass")
	var j: Material = fitting if fitting else _m("steel_dark")
	var fy := 0.085                     # foot tube centre
	var low := 0.27                     # stretcher height
	for s in [-1.0, 1.0]:
		var x: float = s * length * 0.5
		_tube(parent, Vector3(x, fy, -foot * 0.5), Vector3(x, fy, foot * 0.5), 0.016, t)
		for e in [-1.0, 1.0]:
			var cap := _put(_cyl(0.019, 0.019, 0.02, 10), _m("rubber"), Vector3(x, fy, e * (foot * 0.5 + 0.008)), parent)
			cap.rotation.x = PI / 2.0
			_caster(parent, Vector3(x, 0, e * (foot * 0.5 - 0.05)), j, fy - 0.02)
		# T-fitting where the upright sockets into the foot, bolted through from the outside.
		_tube(parent, Vector3(x, fy, -0.055), Vector3(x, fy, 0.055), 0.024, j, 12)
		_tube(parent, Vector3(x, fy, 0), Vector3(x, fy + 0.09, 0), 0.024, j, 12)
		_bolt(parent, Vector3(x + s * 0.024, fy + 0.055, 0), Vector3(s, 0, 0), j)
		_tube(parent, Vector3(x, fy, 0), Vector3(x, rail_y, 0), 0.016, t)
		# Tee for the stretcher.
		_tube(parent, Vector3(x, low - 0.035, 0), Vector3(x, low + 0.035, 0), 0.023, j, 12)
		_tube(parent, Vector3(x, low, 0), Vector3(x - s * 0.055, low, 0), 0.021, j, 12)
		# Height collar with its thumb screw.
		_tube(parent, Vector3(x, 0.93, 0), Vector3(x, 0.99, 0), 0.022, j, 12)
		_tube(parent, Vector3(x + s * 0.02, 0.96, 0), Vector3(x + s * 0.046, 0.96, 0), 0.005, j, 6)
		_put(_sphere(0.014, 8), j, Vector3(x + s * 0.052, 0.96, 0), parent).scale = Vector3(0.6, 1.0, 1.0)
		# Ball elbow, collared on both legs, bolted.
		_put(_sphere(0.028, 12), j, Vector3(x, rail_y, 0), parent)
		_tube(parent, Vector3(x, rail_y - 0.065, 0), Vector3(x, rail_y, 0), 0.022, j, 12)
		_tube(parent, Vector3(x, rail_y, 0), Vector3(x - s * 0.065, rail_y, 0), 0.022, j, 12)
		_bolt(parent, Vector3(x, rail_y - 0.04, 0.022), Vector3(0, 0, 1), j)
	_tube(parent, Vector3(-length * 0.5, rail_y, 0), Vector3(length * 0.5, rail_y, 0), 0.017, t, 12)
	_tube(parent, Vector3(-length * 0.5, low, 0), Vector3(length * 0.5, low, 0), 0.013, t)


## A bentwood hat stand to just under Ren's height (finial at 1.8 m): four splayed walnut legs
## in brass shoes, a turned pole with beads, two tiers of brass hooks that curl up to a ball,
## and four hats hung on them. `variant` (0-3) picks the hats.
static func hat_stand(parent: Node3D, at: Vector3, variant := 0) -> Node3D:
	var n := Node3D.new()
	n.name = "HatStand"
	n.position = at
	parent.add_child(n)
	var wood := _m("walnut")
	for k in 4:
		var a := TAU * k / 4.0 + PI / 4.0
		var out := Vector3(cos(a), 0, sin(a))
		var foot := out * 0.31 + Vector3(0, 0.026, 0)
		_tube(n, Vector3(0, 0.38, 0) + out * 0.035, foot, 0.024, wood, 8)
		_put(_sphere(0.028, 8), _m("brass"), foot, n).scale = Vector3(1, 0.9, 1)   # brass shoe
	_put(_cyl(0.045, 0.055, 0.14, 14), wood, Vector3(0, 0.38, 0), n)     # leg collar
	_put(_cyl(0.022, 0.027, 1.3, 12), wood, Vector3(0, 1.13, 0), n)      # shaft
	for y in [0.52, 1.06]:
		_put(_sphere(0.036, 12), wood, Vector3(0, y, 0), n).scale = Vector3(1, 0.55, 1)   # turned beads
	_put(_cyl(0.026, 0.03, 0.05, 12), wood, Vector3(0, 1.77, 0), n)
	_put(_sphere(0.04, 14), wood, Vector3(0, 1.82, 0), n)                # finial
	var hats: Array = [[["fedora", "hat", "plum"], ["cloche", "plum", "dress_cream"], ["boater", "straw", "suit_navy"], ["bowler", "shoe", "rubber"]],
			[["bowler", "shoe", "plum"], ["boater", "straw", "plum"], ["fedora", "suit_brown", "shoe"], ["cloche", "dress_rose", "plum"]],
			[["cloche", "dress_cream", "plum"], ["fedora", "suit_charcoal", "shoe"], ["bowler", "suit_brown", "shoe"], ["boater", "straw", "sale_red"]],
			[["boater", "straw", "suit_navy"], ["bowler", "shoe", "rubber"], ["cloche", "dress_sage", "dress_cream"], ["fedora", "suit_navy", "plum"]]][variant % 4]
	for tier in 2:
		var y := 1.64 if tier == 0 else 1.36
		_put(_cyl(0.032, 0.032, 0.05, 12), _m("brass"), Vector3(0, y, 0), n)   # hook boss
		for k in 3:
			var a := TAU * k / 3.0 + (0.0 if tier == 0 else PI / 3.0) + variant * 0.4
			var tip := _hook(n, y, a, 0.15 if tier == 0 else 0.11)
			if tier == 0 or k == 0:
				var out := Vector3(cos(a), 0, sin(a))
				var hat := Node3D.new()
				hat.position = tip + out * 0.06 + Vector3(0, 0.03, 0)
				hat.basis = _aim_y(Vector3.UP + out * 0.45)   # hangs tipped outward off the hook
				n.add_child(hat)
				var spec: Array = hats[k if tier == 0 else 3]
				_hat(hat, spec[0], _m(spec[1]), _m(spec[2]))
	contact_shadow(n, Vector2(0.75, 0.75))
	Atrium_merge(n)
	return n


## One brass hook out of the pole at height `y`, bearing `a`: a stem rising outward, curling up
## to a ball. Returns where a hat's crown rests.
static func _hook(n: Node3D, y: float, a: float, length: float) -> Vector3:
	var out := Vector3(cos(a), 0, sin(a))
	var base := Vector3(0, y, 0) + out * 0.028
	var tip := base + (out * 0.82 + Vector3.UP * 0.57).normalized() * length
	_tube(n, base, tip, 0.008, _m("brass"), 8)
	_tube(n, tip, tip + Vector3(0, 0.03, 0) + out * 0.006, 0.007, _m("brass"), 8)
	_put(_sphere(0.012, 8), _m("brass"), tip + Vector3(0, 0.034, 0) + out * 0.006, n)
	return tip


## A hat with its crown top at the origin, hanging down local -y: fedora, cloche, boater or
## bowler, in `felt` with a `band`.
static func _hat(n: Node3D, kind: String, felt: Material, band: Material) -> void:
	match kind:
		"fedora":   # tapered, pinched crown, ribbon band, broad snap brim
			_put(_cyl(0.078, 0.098, 0.11, 18), felt, Vector3(0, -0.055, 0), n).scale = Vector3(1, 1, 0.84)
			_put(_box(0.1, 0.016, 0.03), felt, Vector3(0, 0.0, 0), n)                   # the crease along the top
			for s in [-1.0, 1.0]:
				_put(_sphere(0.022, 8), felt, Vector3(0.03, -0.012, s * 0.05), n).scale = Vector3(1.4, 0.6, 0.6)   # front pinch
			_put(_cyl(0.1, 0.1, 0.026, 18), band, Vector3(0, -0.092, 0), n).scale = Vector3(1, 1, 0.85)
			var brim := _put(_cyl(0.16, 0.16, 0.012, 24), felt, Vector3(0, -0.106, 0), n)
			brim.scale = Vector3(1, 1, 0.88)
			brim.rotation.z = 0.06
		"cloche":   # deep bell crown, short brim turned down, flower pin
			_put(_sphere(0.104, 18), felt, Vector3(0, -0.08, 0), n).scale = Vector3(1, 0.85, 1)
			_put(_cyl(0.106, 0.128, 0.04, 20), felt, Vector3(0, -0.13, 0), n)
			_put(_cyl(0.107, 0.107, 0.022, 20), band, Vector3(0, -0.1, 0), n)
			_put(_sphere(0.024, 8), band, Vector3(0.09, -0.09, 0.05), n)
		"boater":   # straw: flat top, straight sides, wide flat brim, ribbon
			_put(_cyl(0.09, 0.092, 0.075, 20), felt, Vector3(0, -0.0375, 0), n)
			_put(_cyl(0.094, 0.094, 0.032, 20), band, Vector3(0, -0.058, 0), n)
			_put(_cyl(0.17, 0.17, 0.01, 28), felt, Vector3(0, -0.078, 0), n)
		"bowler":   # rounded dome, narrow curled brim
			_put(_sphere(0.096, 18), felt, Vector3(0, -0.052, 0), n).scale = Vector3(1, 0.55, 1)
			_put(_cyl(0.096, 0.1, 0.06, 18), felt, Vector3(0, -0.082, 0), n)
			_put(_cyl(0.101, 0.101, 0.018, 18), band, Vector3(0, -0.1, 0), n)
			_put(_cyl(0.135, 0.135, 0.01, 24), felt, Vector3(0, -0.114, 0), n)
			_put(_cyl(0.138, 0.138, 0.02, 24), felt, Vector3(0, -0.108, 0), n)   # the rolled edge


## The tailor's cutting table: an oval walnut top with a moulded edge on a turned pedestal and
## four splayed feet, set with the work in progress: a bolt of cloth half unrolled under a paper
## pattern, shears, a tape measure, a tomato pincushion stuck with pins, tailor's chalk and
## spools of thread. Top at 0.9 m, a hand's width under Ren's belt.
static func cutting_table(parent: Node3D, at: Vector3) -> Node3D:
	var n := Node3D.new()
	n.name = "CuttingTable"
	n.position = at
	parent.add_child(n)
	var top_y := 0.9
	var oval := Vector3(1, 1, 0.72)
	_put(_cyl(0.9, 0.9, 0.045, 48), _m("walnut"), Vector3(0, top_y - 0.0225, 0), n).scale = oval
	_put(_cyl(0.9, 0.87, 0.02, 48), _m("walnut_dark"), Vector3(0, top_y - 0.055, 0), n).scale = oval   # moulded under-edge
	_put(_cyl(0.78, 0.78, 0.08, 40), _m("walnut_dark"), Vector3(0, top_y - 0.1, 0), n).scale = oval    # apron
	_put(_cyl(0.79, 0.79, 0.014, 40), _m("brass"), Vector3(0, top_y - 0.14, 0), n).scale = oval        # brass bead under the apron
	# Pedestal: a block under the top, the turned column with beads, the foot hub.
	_put(_cyl(0.16, 0.14, 0.06, 16), _m("walnut_dark"), Vector3(0, top_y - 0.17, 0), n)
	_put(_cyl(0.075, 0.1, 0.56, 16), _m("walnut"), Vector3(0, 0.44, 0), n)
	for y in [0.3, 0.62]:
		_put(_sphere(0.11, 16), _m("walnut"), Vector3(0, y, 0), n).scale = Vector3(1, 0.4, 1)
	_put(_cyl(0.13, 0.15, 0.1, 16), _m("walnut_dark"), Vector3(0, 0.16, 0), n)
	for k in 4:   # splayed feet along the long and short axes, brass toe caps
		var a := TAU * k / 4.0
		var out := Vector3(cos(a), 0, sin(a))
		var reach := 0.62 if k % 2 == 0 else 0.46
		var toe := out * reach + Vector3(0, 0.035, 0)
		var leg := _tube(n, out * 0.1 + Vector3(0, 0.17, 0), toe, 0.04, _m("walnut"), 10)
		leg.scale = Vector3(1, 1, 0.7)
		var cap := _put(_cyl(0.034, 0.034, 0.06, 12), _m("brass"), toe + out * 0.01, n)
		cap.basis = _aim_y(out)
	contact_shadow(n, Vector2(1.9, 1.4))
	var y := top_y
	# A bolt of plum wool, half unrolled toward the front, a paper pattern pinned on the cloth.
	var bolt := _put(_cyl(0.06, 0.06, 0.62, 16), _m("plum"), Vector3(-0.2, y + 0.06, -0.3), n)
	bolt.rotation.z = PI / 2.0
	_put(_box(0.62, 0.004, 0.42), _m("plum"), Vector3(-0.2, y + 0.002, -0.06), n)
	var pattern := _put(_box(0.3, 0.003, 0.24), _m("pattern"), Vector3(-0.24, y + 0.006, -0.04), n)
	pattern.rotation.y = 0.18
	for p in [Vector3(-0.36, 0, -0.12), Vector3(-0.12, 0, 0.06), Vector3(-0.1, 0, -0.14)]:
		_put(_sphere(0.006, 6), _m("sale_red"), p + Vector3(0, y + 0.012, 0), n)   # pin heads holding the pattern
	# Tailor's shears, open a little, beside the cloth.
	var shears := Node3D.new()
	shears.position = Vector3(0.28, y + 0.008, 0.1)
	shears.rotation.y = 0.5
	n.add_child(shears)
	for s in [-1.0, 1.0]:
		var half := Node3D.new()
		half.rotation.y = s * 0.12
		shears.add_child(half)
		_put(_box(0.2, 0.006, 0.018), _m("steel"), Vector3(0.1, s * 0.003, 0), half)        # blade
		var bow := _put(_cyl(0.03, 0.03, 0.01, 14), _m("shoe"), Vector3(-0.07, s * 0.003, s * 0.025), half)   # black bow handle
		bow.scale = Vector3(1.3, 1, 0.8)
		_put(_cyl(0.017, 0.017, 0.012, 12), _m("walnut"), Vector3(-0.07, s * 0.003, s * 0.025), half).scale = Vector3(1.3, 1, 0.8)   # the hole in the bow, showing the table
	_put(_cyl(0.008, 0.008, 0.016, 8), _m("brass"), Vector3.ZERO, shears)                   # pivot screw
	# Tape measure: a cream tape in loose loops ending at the rolled spool.
	var path := [Vector3(0.05, 0, 0.28), Vector3(0.25, 0, 0.32), Vector3(0.42, 0, 0.22), Vector3(0.48, 0, 0.0), Vector3(0.4, 0, -0.16), Vector3(0.24, 0, -0.18)]
	for i in path.size() - 1:
		var a: Vector3 = path[i]
		var b: Vector3 = path[i + 1]
		var seg := _put(_box(a.distance_to(b) + 0.01, 0.002, 0.016), _m("tape"), (a + b) * 0.5 + Vector3(0, y + 0.002, 0), n)
		seg.rotation.y = -atan2(b.z - a.z, b.x - a.x)
	_put(_cyl(0.032, 0.032, 0.018, 18), _m("tape"), Vector3(0.24, y + 0.009, -0.18), n)
	_put(_cyl(0.012, 0.012, 0.02, 10), _m("brass"), Vector3(0.24, y + 0.01, -0.18), n)
	_put(_box(0.012, 0.004, 0.02), _m("brass"), path[0] + Vector3(-0.005, y + 0.003, 0), n)   # metal end tab
	# Tomato pincushion with its strawberry, stuck with pins.
	var cushion := Vector3(0.47, y, 0.28)
	_put(_sphere(0.055, 14), _m("sale_red"), cushion + Vector3(0, 0.04, 0), n).scale = Vector3(1, 0.72, 1)
	_put(_cyl(0.012, 0.016, 0.014, 8), _m("leaf"), cushion + Vector3(0, 0.08, 0), n)
	var berry := _put(_sphere(0.016, 8), _m("sale_red"), cushion + Vector3(0.05, 0.075, 0.02), n)
	berry.scale = Vector3(0.8, 1.3, 0.8)
	for k in 7:
		var a := TAU * k / 7.0
		var dir := Vector3(cos(a) * 0.7, 0.75, sin(a) * 0.7).normalized()
		var root := cushion + Vector3(0, 0.04, 0) + Vector3(dir.x * 0.05, dir.y * 0.036, dir.z * 0.05)
		_tube(n, root, root + dir * 0.022, 0.0015, _m("steel"), 4)
		_put(_sphere(0.005, 6), _m(["glass_amber", "dress_cream", "glass_lilac", "sale_red"][k % 4]), root + dir * 0.025, n)
	# Tailor's chalk: two flat triangles.
	for c in [[Vector3(-0.55, 0, 0.18), "chalk_blue", 0.3], [Vector3(-0.5, 0, 0.26), "dress_cream", -0.5]]:
		var tri := _put(_cyl(0.035, 0.035, 0.008, 3), _m(c[1]), c[0] + Vector3(0, y + 0.004, 0), n)
		tri.rotation.y = c[2]
	# Spools of thread on their wooden ends.
	for s in [[Vector3(-0.62, 0, -0.08), "sale_red"], [Vector3(-0.56, 0, -0.16), "suit_navy"], [Vector3(-0.66, 0, -0.18), "dress_cream"]]:
		var p: Vector3 = s[0] + Vector3(0, y, 0)
		_put(_cyl(0.016, 0.016, 0.034, 12), _m(s[1]), p + Vector3(0, 0.022, 0), n)
		for e in [0.003, 0.041]:
			_put(_cyl(0.021, 0.021, 0.006, 12), _m("wood"), p + Vector3(0, e, 0), n)
	Atrium_merge(n)
	return n


## A cased doorway in a wall: lined reveal, moulded casings with plinth blocks and a capped
## head on both faces, and a brass threshold. Local x runs along the wall, z through it;
## `at` is the floor centre of the opening and `wall` the wall's depth.
static func door_frame(parent: Node3D, at: Vector3, width: float, height: float, yaw := 0.0, wall := 0.3) -> Node3D:
	var f := Node3D.new()
	f.position = at
	f.rotation.y = yaw
	parent.add_child(f)
	var cw := 0.14     # casing width
	var proud := 0.05  # how far the casing stands off the wall
	for s in [-1.0, 1.0]:
		# Reveal lining sits 1 cm inside the opening so it never shares a face with the wall's
		# cut end (coplanar faces flicker as speckle).
		_put(_box(0.04, height, wall + 0.02), _m("walnut"), Vector3(s * (width * 0.5 + 0.01), height * 0.5, 0), f)
		for face in [-1.0, 1.0]:
			var z: float = face * (wall * 0.5 + proud * 0.5)
			_put(_box(cw, height + cw * 0.5, proud), _m("walnut"), Vector3(s * (width * 0.5 + cw * 0.5), (height + cw * 0.5) * 0.5, z), f)
			_put(_box(cw * 0.35, height, proud + 0.02), _m("walnut"), Vector3(s * (width * 0.5 + cw * 0.25), height * 0.5, z + face * 0.005), f)   # bead
			_put(_box(cw + 0.03, 0.24, proud + 0.025), _m("walnut"), Vector3(s * (width * 0.5 + cw * 0.5), 0.12, z), f)   # plinth block
	_put(_box(width + 0.04, 0.04, wall + 0.02), _m("walnut"), Vector3(0, height + 0.01, 0), f)   # head lining, 1 cm below the lintel
	for face in [-1.0, 1.0]:
		var z: float = face * (wall * 0.5 + proud * 0.5)
		_put(_box(width + cw * 2.0, 0.2, proud), _m("walnut"), Vector3(0, height + 0.1, z), f)
		_put(_box(width + cw * 2.0 + 0.08, 0.05, proud + 0.05), _m("walnut"), Vector3(0, height + 0.225, z + face * 0.02), f)   # cap
		_put(_box(width + cw * 2.0 + 0.02, 0.02, proud + 0.02), _m("brass"), Vector3(0, height + 0.19, z + face * 0.005), f)
	_put(_box(width, 0.015, wall + 0.06), _m("brass"), Vector3(0, 0.008, 0), f)   # threshold
	return f


## A recessed doorway: cream pilasters and a heading stand forward of the wall on the `side`
## the room is on (+1 = local +z), so the door and its casing sit back in a deep reveal.
## The heading carries an enamel name plaque. Same placement as door_frame.
static func portal(parent: Node3D, at: Vector3, width: float, height: float, yaw := 0.0, side := 1.0, text := "", depth := 0.26, wall := 0.3) -> Node3D:
	var p := Node3D.new()
	p.position = at
	p.rotation.y = yaw
	parent.add_child(p)
	var pw := 0.28                                     # pilaster width
	var inner := width * 0.5 + 0.14                    # outside edge of the casing
	var z := side * (wall * 0.5 + depth * 0.5)
	var top := height + 0.3
	for s in [-1.0, 1.0]:
		var x: float = s * (inner + pw * 0.5)
		_put(_box(pw, top, depth), _m("cream"), Vector3(x, top * 0.5, z), p)
		_put(_box(pw + 0.04, 0.18, depth + 0.04), _m("plinth"), Vector3(x, 0.09, z), p)   # base block
		_put(_box(pw + 0.05, 0.025, depth + 0.05), _m("brass"), Vector3(x, 0.19, z), p)
		_put(_box(pw + 0.06, 0.08, depth + 0.06), _m("cream"), Vector3(x, top - 0.12, z), p)   # capital
		_put(_box(pw + 0.065, 0.02, depth + 0.065), _m("brass"), Vector3(x, top - 0.17, z), p)
		# The reveal's return: wall from the pilaster back to the casing.
		_put(_box(0.02, top, depth), _m("cream"), Vector3(s * inner, top * 0.5, z), p)
	var span := (inner + pw) * 2.0
	_put(_box(span, 0.55, depth), _m("cream"), Vector3(0, top + 0.275, z), p)                    # heading
	_put(_box(span + 0.12, 0.07, depth + 0.08), _m("cream"), Vector3(0, top + 0.585, z + side * 0.04), p)   # cornice
	_put(_box(span + 0.13, 0.022, depth + 0.09), _m("brass"), Vector3(0, top + 0.54, z + side * 0.045), p)
	_put(_box(width + 0.28, 0.3, depth - 0.02), _m("cream"), Vector3(0, height + 0.15, z), p)     # soffit over the casing
	if text != "":
		plaque(p, Vector3(0, top + 0.27, z + side * (depth * 0.5)), minf(span - 0.3, 2.2), text, PI if side < 0.0 else 0.0)
	return p


## A brass-framed plum enamel plaque with cream lettering scaled to fit, its face toward
## local +z (turned by `yaw`). `at` is the centre of its back.
static func plaque(parent: Node3D, at: Vector3, width: float, text: String, yaw := 0.0) -> Node3D:
	var q := Node3D.new()
	q.position = at
	q.rotation.y = yaw
	parent.add_child(q)
	_put(_box(width + 0.06, 0.36, 0.03), _m("brass"), Vector3(0, 0, 0.015), q)
	_put(_box(width, 0.3, 0.04), _m("plum"), Vector3(0, 0, 0.02), q)
	_label(q, text, Vector3(0, 0, 0.042), minf(0.0042, (width - 0.12) / (maxf(text.length(), 1) * 0.55 * 64.0)), Color("eee6d4"), 64)
	return q


## A panelled walnut door hinged at `hinge` (the leaf runs along local +x), opened `open`
## radians: raised panels, brass lever handles both sides, a brass kick plate, optional window.
static func door_leaf(parent: Node3D, hinge: Vector3, width: float, height: float, yaw := 0.0, open := 0.0, window := false) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = hinge
	pivot.rotation.y = yaw + open
	parent.add_child(pivot)
	var t := 0.055
	_put(_box(width, height, t), _m("walnut"), Vector3(width * 0.5, height * 0.5, 0), pivot)
	# Three brass butt hinges on the hinge edge: knuckle barrel with a finial top and bottom.
	for hy in [0.25, height * 0.5, height - 0.3]:
		_put(_cyl(0.016, 0.016, 0.11, 10), _m("brass"), Vector3(-0.012, hy, 0), pivot)
		for e in [-1.0, 1.0]:
			_put(_sphere(0.012, 8), _m("brass"), Vector3(-0.012, hy + e * 0.062, 0), pivot)
		_put(_box(0.05, 0.1, t + 0.004), _m("brass"), Vector3(0.025, hy, 0), pivot)
	var panels := [[0.62, 0.95]] if window else [[0.62, 0.95], [1.65, 0.85]]
	for face in [-1.0, 1.0]:
		for pnl in panels:
			var py: float = pnl[0] + pnl[1] * 0.5
			_put(_box(width - 0.3, pnl[1], 0.012), _m("walnut_dark"), Vector3(width * 0.5, py, face * (t * 0.5 + 0.004)), pivot)
			_put(_box(width - 0.38, pnl[1] - 0.08, 0.02), _m("walnut"), Vector3(width * 0.5, py, face * (t * 0.5 + 0.01)), pivot)
		_put(_box(width - 0.06, 0.22, 0.006), _m("brass"), Vector3(width * 0.5, 0.13, face * (t * 0.5 + 0.003)), pivot)   # kick plate
		var hx := width - 0.09
		var rose := _put(_cyl(0.035, 0.035, 0.02, 16), _m("brass"), Vector3(hx, 1.0, face * (t * 0.5 + 0.01)), pivot)
		rose.rotation.x = PI / 2.0
		var neck := _put(_cyl(0.012, 0.012, 0.05, 8), _m("brass"), Vector3(hx, 1.0, face * (t * 0.5 + 0.04)), pivot)
		neck.rotation.x = PI / 2.0
		_put(_box(0.13, 0.022, 0.024), _m("brass"), Vector3(hx - 0.06, 1.0, face * (t * 0.5 + 0.065)), pivot)   # lever
		_put(_box(0.024, 0.07, 0.008), _m("brass"), Vector3(hx, 0.92, face * (t * 0.5 + 0.004)), pivot)   # keyhole plate
		if window:
			for y in [1.38, 2.12]:
				_put(_box(width - 0.3, 0.05, 0.02), _m("walnut"), Vector3(width * 0.5, y, face * (t * 0.5 + 0.01)), pivot)
			for x in [0.15, width - 0.15]:
				_put(_box(0.05, 0.79, 0.02), _m("walnut"), Vector3(x, 1.75, face * (t * 0.5 + 0.01)), pivot)
	if window:
		var glass := _put(_box(width - 0.36, 0.7, 0.012), _m("door_glass"), Vector3(width * 0.5, 1.75, 0), pivot)
		glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return pivot


## A locked brass lattice gate (folding "lazy tongs") filling an opening: top and bottom track,
## vertical bars, diamond straps between them, a padlock on a short chain. See-through.
## Placement like door_frame: `at` is the floor centre of the opening, local x along the wall.
static func lattice_gate(parent: Node3D, at: Vector3, width: float, height: float, yaw := 0.0) -> Node3D:
	var gate := Node3D.new()
	gate.name = "LatticeGate"
	gate.position = at
	gate.rotation.y = yaw
	parent.add_child(gate)
	_put(_box(width, 0.09, 0.12), _m("brass"), Vector3(0, height - 0.045, 0), gate)
	_put(_box(width, 0.05, 0.1), _m("brass"), Vector3(0, 0.025, 0), gate)
	var bays := int(width / 0.3)
	var bay := width / bays
	var rows := 3
	var rh := (height - 0.14) / rows
	for i in bays + 1:
		_put(_box(0.022, height - 0.1, 0.022), _m("brass"), Vector3(-width * 0.5 + i * bay, height * 0.5, 0), gate)
	var length := sqrt(bay * bay + rh * rh)
	var tilt := atan2(rh, bay)
	for i in bays:
		for r in rows:
			var c := Vector3(-width * 0.5 + (i + 0.5) * bay, 0.07 + (r + 0.5) * rh, 0.0)
			for s in [-1.0, 1.0]:
				var strap := _put(_box(length, 0.014, 0.008), _m("brass"), c + Vector3(0, 0, s * 0.016), gate)
				strap.rotation.z = s * tilt
	# Padlock and chain where the two halves meet.
	var lock := Vector3(0, 1.05, 0.06)
	for k in 4:
		var link := _put(_cyl(0.022, 0.022, 0.008, 10), _m("steel_dark"), lock + Vector3(0, 0.12 - k * 0.04, 0), gate)
		link.rotation.x = PI / 2.0 if k % 2 == 0 else 0.0
	_put(_box(0.09, 0.1, 0.04), _m("brass"), lock + Vector3(0, -0.06, 0.0), gate)
	var shackle := _put(_cyl(0.035, 0.035, 0.012, 14), _m("steel_dark"), lock + Vector3(0, 0.0, 0.0), gate)
	shackle.rotation.x = PI / 2.0
	Atrium_merge(gate)
	return gate


## Bakes a static assembly into a few meshes (the atrium's merge, without a preload cycle).
static func Atrium_merge(node: Node3D) -> void:
	load("res://scripts/atrium.gd").merge(node)


## A pleated velvet curtain on a brass rod with rings: soft vertical folds instead of a flat
## slab. `at` is the floor centre of the curtain line; it hangs `height` tall across `width`.
static func curtain(parent: Node3D, at: Vector3, width: float, height: float) -> Node3D:
	var c := Node3D.new()
	c.name = "Curtain"
	c.position = at
	parent.add_child(c)
	var folds := maxi(4, int(width / 0.11))
	var pitch := width / folds
	for i in folds:
		var x := -width * 0.5 + pitch * (i + 0.5)
		var fold := _put(_cyl(pitch * 0.62, pitch * 0.7, height - 0.04, 12), _m("velvet"), Vector3(x, (height - 0.04) * 0.5 + 0.02, 0.025 * (1 if i % 2 else -1)), c)
		fold.scale = Vector3(1.0, 1.0, 0.45)
	var rod := _put(_cyl(0.014, 0.014, width + 0.16, 10), _m("brass"), Vector3(0, height + 0.03, 0), c)
	rod.rotation.z = PI / 2.0
	for s in [-1.0, 1.0]:
		_put(_sphere(0.028, 10), _m("brass"), Vector3(s * (width * 0.5 + 0.09), height + 0.03, 0), c)
	for i in folds:
		var ring := _put(_cyl(0.022, 0.022, 0.012, 12), _m("brass"), Vector3(-width * 0.5 + pitch * (i + 0.5), height + 0.03, 0), c)
		ring.rotation.z = PI / 2.0
	Atrium_merge(c)
	return c


## A brass pull bar on two standoffs, for shutters and roller gates. Local x along the bar,
## standing off toward +z.
static func pull_handle(parent: Node3D, at: Vector3, length := 0.5, yaw := 0.0) -> Node3D:
	var hnd := Node3D.new()
	hnd.position = at
	hnd.rotation.y = yaw
	parent.add_child(hnd)
	var bar := _put(_cyl(0.016, 0.016, length, 10), _m("brass"), Vector3(0, 0, 0.07), hnd)
	bar.rotation.z = PI / 2.0
	for s in [-1.0, 1.0]:
		var post := _put(_cyl(0.012, 0.014, 0.07, 8), _m("brass"), Vector3(s * length * 0.42, 0, 0.035), hnd)
		post.rotation.x = PI / 2.0
		var plate := _put(_cyl(0.028, 0.028, 0.01, 12), _m("brass"), Vector3(s * length * 0.42, 0, 0.004), hnd)
		plate.rotation.x = PI / 2.0
	return hnd


static var _shapes := {}


## A block with rounded vertical corners (radius `r`) and, optionally, a softened top edge
## (`bevel`). Sits on y = 0, centred in x and z. Cached per size.
static func rounded_block(w: float, h: float, d: float, r: float, bevel := 0.0, seg := 5) -> ArrayMesh:
	var key := "%.3f/%.3f/%.3f/%.3f/%.3f" % [w, h, d, r, bevel]
	if _shapes.has(key):
		return _shapes[key]
	r = clampf(r, 0.002, minf(w, d) * 0.5 - 0.001)
	bevel = clampf(bevel, 0.0, minf(r - 0.001, h * 0.5))
	var ring := []   # [point (x, z), outward normal (x, z), corner centre]
	for c in [[1.0, 1.0, 0.0], [-1.0, 1.0, 90.0], [-1.0, -1.0, 180.0], [1.0, -1.0, 270.0]]:
		var centre := Vector2(c[0] * (w * 0.5 - r), c[1] * (d * 0.5 - r))
		for i in seg + 1:
			var a := deg_to_rad(c[2] + 90.0 * i / seg)
			var n := Vector2(cos(a), sin(a))
			ring.append([centre + n * r, n, centre])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := ring.size()
	var side_top := h - bevel
	var inset := r - bevel
	for i in count:
		var j := (i + 1) % count
		var a0: Vector2 = ring[i][0]
		var b0: Vector2 = ring[j][0]
		var na: Vector2 = ring[i][1]
		var nb: Vector2 = ring[j][1]
		_quad(st, [Vector3(a0.x, 0, a0.y), Vector3(b0.x, 0, b0.y), Vector3(b0.x, side_top, b0.y), Vector3(a0.x, side_top, a0.y)],
				[Vector3(na.x, 0, na.y), Vector3(nb.x, 0, nb.y), Vector3(nb.x, 0, nb.y), Vector3(na.x, 0, na.y)])
		var a1 := a0
		var b1 := b0
		if bevel > 0.0:
			a1 = ring[i][2] + na * inset
			b1 = ring[j][2] + nb * inset
			var ba := Vector3(na.x, 1.0, na.y).normalized()
			var bb := Vector3(nb.x, 1.0, nb.y).normalized()
			_quad(st, [Vector3(a0.x, side_top, a0.y), Vector3(b0.x, side_top, b0.y), Vector3(b1.x, h, b1.y), Vector3(a1.x, h, a1.y)], [ba, bb, bb, ba])
		_tri(st, [Vector3(0, h, 0), Vector3(a1.x, h, a1.y), Vector3(b1.x, h, b1.y)], Vector3.UP)
		_tri(st, [Vector3(0, 0, 0), Vector3(b0.x, 0, b0.y), Vector3(a0.x, 0, a0.y)], Vector3.DOWN)
	st.index()              # same layout as Godot's primitive meshes, so bakes can mix them
	st.generate_tangents()
	var mesh := st.commit()
	_shapes[key] = mesh
	return mesh


## Adds a triangle facing along `n` (Godot draws clockwise faces as front).
static func _tri(st: SurfaceTool, v: Array, n: Vector3, normals := []) -> void:
	var p0: Vector3 = v[0]
	var p1: Vector3 = v[1]
	var p2: Vector3 = v[2]
	var ns: Array = normals if not normals.is_empty() else [n, n, n]
	var order := [0, 1, 2]
	if (p1 - p0).cross(p2 - p0).dot(n) > 0.0:
		order = [0, 2, 1]
	for k in order:
		var p: Vector3 = v[k]
		st.set_normal(ns[k])
		st.set_uv(Vector2(p.x + p.z, p.y))
		st.add_vertex(p)


static func _quad(st: SurfaceTool, v: Array, ns: Array) -> void:
	var avg: Vector3 = (ns[0] + ns[1] + ns[2] + ns[3]) * 0.25
	_tri(st, [v[0], v[1], v[2]], avg, [ns[0], ns[1], ns[2]])
	_tri(st, [v[0], v[2], v[3]], avg, [ns[0], ns[2], ns[3]])


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
		"brass": m = ST.textured("brass", 2.0, ST.plastic(Color("b39a5c"), 0.35, 0.85), 0.85)
		"wood": m = ST.plastic(Color("8a6440"), 0.5, 0.0)
		"walnut": m = ST.plastic(Color("5e3a22"), 0.55, 0.0)
		"walnut_dark": m = ST.plastic(Color("40261a"), 0.6, 0.0)
		"plinth": m = ST.plastic(Color("2a1420"), 0.7, 0.0)
		"counter_top": m = ST.textured("marble_cream", 0.8, ST.plastic(Color("ece3d1"), 0.45, 0.0))
		"door_glass":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.85, 0.75, 0.6, 0.35)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.6
		"rubber": m = ST.plastic(Color("17161b"), 0.6, 0.0)
		"cream": m = ST.textured("plaster_cream", 0.6, ST.plastic(Color("eee6d4"), 0.55, 0.0))
		"plum": m = ST.textured("laminate_plum", 1.0, ST.plastic(Color("4e1f3a"), 0.6, 0.0))
		"velvet": m = ST.textured("velvet_red", 1.0, ST.plastic(Color("4e1f3a"), 0.9, 0.0))
		"ivory": m = ST.plastic(Color("ece4d6"), 0.45, 0.0)
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
		"mirror": m = ST.plastic(Color("c9ccd0"), 0.08, 0.9)
		"steel_dark": m = ST.plastic(Color("4a4a4e"), 0.35, 0.8)
		"carton": m = ST.textured("cardboard", 1.0, ST.plastic(Color("a57a4c"), 0.9, 0.0))
		"glass_clear":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.85, 0.88, 0.9, 0.16)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.05
		"leaf": m = ST.plastic(Color("3a6a34"), 0.7, 0.0)
		"lily": m = ST.plastic(Color("f6f0e4"), 0.7, 0.0)
		"pollen": m = ST.plastic(Color("e2a43a"), 0.8, 0.0)
		"sale_red": m = ST.plastic(Color("9e1b22"), 0.7, 0.0)
		"straw": m = ST.plastic(Color("d6bd86"), 0.85, 0.0)
		"steel": m = ST.plastic(Color("a9abae"), 0.3, 0.85)
		"tape": m = ST.plastic(Color("e9dcae"), 0.75, 0.0)
		"pattern": m = ST.plastic(Color("d9c9a4"), 0.9, 0.0)
		"chalk_blue": m = ST.plastic(Color("9fb4c8"), 0.95, 0.0)
		_: m = ST.plastic(Color("eee6d4"), 0.6, 0.0)
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
