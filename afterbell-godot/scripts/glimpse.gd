extends RefCounted
## Rooms glimpsed through doorways: a shallow, furnished space built on the far side of an
## opening, with its own light so it reads as somewhere else in the store.
##
##   Glimpse.build(parent, at, yaw, "staff_corridor", width, depth, height)
##
## Local space: `at` is the floor centre of the opening on the wall's far face; the glimpse
## runs back along local -z. Kinds: staff_corridor (cool fluorescent), atrium (tall, peach
## sunset), cosmetics (warm pink lamplight).
##
## Everything here is on visual layer 2 as well as 1; the glimpse's own lights only touch
## layer 2, so a corridor's cool light never tints the warm room you are standing in, while
## that room's lamps still spill through the doorway.

const Props := preload("res://scripts/props.gd")
const Atrium := preload("res://scripts/atrium.gd")
const ST := preload("res://scripts/style.gd")

const LAYER := 2


static func build(parent: Node3D, at: Vector3, yaw: float, kind: String, width := 5.0, depth := 3.5, height := 3.2) -> Node3D:
	var g := Node3D.new()
	g.name = "Glimpse_" + kind
	g.position = at
	g.rotation.y = yaw
	parent.add_child(g)
	match kind:
		"staff_corridor": _staff_corridor(g, width, depth, height)
		"atrium": _atrium(g, width, depth, height)
		"cosmetics": _cosmetics(g, width, depth, height)
	for v in g.find_children("*", "VisualInstance3D", true, false):
		if v is GeometryInstance3D or v is Label3D:
			(v as VisualInstance3D).layers = 1 | (1 << (LAYER - 1))
	return g


# ---------------------------------------------------------------- the rooms

## Behind the staff doors: a working corridor. Green-grey paint over a dark dado, checker lino,
## lockers, a notice board, a covered garment trolley, a bench, a clock, under a cool tube light.
static func _staff_corridor(g: Node3D, w: float, d: float, h: float) -> void:
	var paint := ST.plastic(Color("b9c4b2"), 0.75, 0.0)
	var dado := ST.plastic(Color("3f5446"), 0.6, 0.0)
	_shell(g, w, d, h, paint, ST.plastic(Color("b7b4a2"), 0.8, 0.0), ST.plastic(Color("d9d6c8"), 0.85, 0.0))
	# Checker lino.
	var light := ST.plastic(Color("cfcab3"), 0.6, 0.0)
	var dark := ST.plastic(Color("5b6b5a"), 0.6, 0.0)
	var t := 0.5
	var nx := int(w / t)
	var nz := int(d / t)
	for i in nx:
		for j in nz:
			Props._put(Props._box(t, 0.012, t), light if (i + j) % 2 == 0 else dark, Vector3(-w * 0.5 + (i + 0.5) * t, 0.006, -(j + 0.5) * t), g)
	# Dark green dado on the back and side walls.
	Props._put(Props._box(w, 1.0, 0.03), dado, Vector3(0, 0.5, -d + 0.015), g)
	for s in [-1.0, 1.0]:
		Props._put(Props._box(0.03, 1.0, d), dado, Vector3(s * (w * 0.5 - 0.015), 0.5, -d * 0.5), g)
	# Lockers along the back wall.
	var steel := ST.plastic(Color("6f7d72"), 0.5, 0.4)
	for i in 5:
		var x := -w * 0.5 + 0.5 + i * 0.42
		Props._put(Props._box(0.4, 1.85, 0.45), steel, Vector3(x, 0.925, -d + 0.25), g)
		for y in [1.55, 1.62, 1.69]:
			Props._put(Props._box(0.22, 0.015, 0.01), ST.plastic(Color("2c332d"), 0.6, 0.0), Vector3(x, y, -d + 0.48), g)   # vents
		Props._put(Props._box(0.02, 0.1, 0.02), Props._m("brass"), Vector3(x + 0.14, 1.0, -d + 0.48), g)
	# Notice board with pinned papers.
	var board := Vector3(w * 0.5 - 1.1, 1.55, -d + 0.03)
	Props._put(Props._box(1.0, 0.7, 0.04), ST.plastic(Color("8a6440"), 0.8, 0.0), board, g)
	Props._put(Props._box(0.92, 0.62, 0.045), ST.plastic(Color("b08b5a"), 0.95, 0.0), board, g)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 6:
		var p := Props._put(Props._box(0.2, 0.26, 0.05), Props._m("shirt"), board + Vector3(-0.32 + (i % 3) * 0.32, 0.14 - (i / 3) * 0.3, 0.003), g)
		p.rotation.z = rng.randf_range(-0.08, 0.08)
		Props._put(Props._sphere(0.012, 6), Props._m("sale_red"), board + Vector3(-0.32 + (i % 3) * 0.32, 0.25 - (i / 3) * 0.3, 0.03), g)
	# Covered garment trolley and a bench.
	var trolley := Node3D.new()
	trolley.position = Vector3(-w * 0.5 + 0.9, 0, -d * 0.45)
	trolley.rotation.y = 0.25
	g.add_child(trolley)
	Props.place(trolley, "rack", Vector3.ZERO, 0.0, 0)
	Props._put(Props._box(1.5, 1.05, 0.55), ST.plastic(Color("e9e4d6"), 0.9, 0.0), Vector3(0, 1.05, 0), trolley)   # dust sheet
	Props._put(Props._box(1.4, 0.06, 0.4), ST.plastic(Color("6e4326"), 0.6, 0.0), Vector3(w * 0.5 - 1.0, 0.45, -d * 0.45), g)
	for s in [-1.0, 1.0]:
		Props._put(Props._box(0.06, 0.45, 0.36), steel, Vector3(w * 0.5 - 1.0 + s * 0.62, 0.225, -d * 0.45), g)
	# Wall clock and a fire bucket.
	var clock := Props._put(Props._cyl(0.18, 0.18, 0.05, 24), Props._m("shirt"), Vector3(0.2, 2.45, -d + 0.04), g)
	clock.rotation.x = PI / 2.0
	var rim := Props._put(Props._cyl(0.2, 0.2, 0.04, 24), ST.plastic(Color("2c332d"), 0.5, 0.0), Vector3(0.2, 2.45, -d + 0.025), g)
	rim.rotation.x = PI / 2.0
	for k in 2:
		var hand := Props._put(Props._box(0.015, 0.13 - k * 0.04, 0.01), ST.plastic(Color("1c1c1c"), 0.5, 0.0), Vector3(0.2, 2.45, -d + 0.07), g)
		hand.rotation.z = 0.6 + k * 2.1
		hand.position += Vector3(sin(-hand.rotation.z), cos(hand.rotation.z), 0) * (0.05 - k * 0.015)
	Props._put(Props._cyl(0.13, 0.1, 0.26, 16), Props._m("sale_red"), Vector3(w * 0.5 - 0.25, 1.1, -0.6), g)
	# Fluorescent tube in a steel trough, and its cool light.
	Props._put(Props._box(1.3, 0.06, 0.2), steel, Vector3(0, h - 0.05, -d * 0.5), g)
	var tube := StandardMaterial3D.new()
	tube.albedo_color = Color("eef7f0")
	tube.emission_enabled = true
	tube.emission = Color("e6fff0")
	tube.emission_energy_multiplier = 1.1
	Props._put(Props._box(1.2, 0.035, 0.08), tube, Vector3(0, h - 0.09, -d * 0.5), g)
	_light(g, Vector3(0, h - 0.4, -d * 0.5), Color("d8f0e4"), 1.6, maxf(w, d) + 1.0)


## Through the lattice gate: a slice of the atrium framed for a doorway-height view. A tall
## arched sunset window fills the back wall from just above the floor; an escalator climbs
## toward a side gallery; a column with its banner, lilies and a mannequin pair stand in the
## peach light.
static func _atrium(g: Node3D, w: float, d: float, h: float) -> void:
	var stone := ST.textured("stone_cream", 0.35, ST.plastic(Color("ddd5c3"), 0.75, 0.0))
	_shell(g, w, d, h, stone, ST.textured("carpet_forest", 0.5, ST.plastic(Color("22433e"), 0.9, 0.0)), ST.plastic(Color("cbbd9f"), 0.8, 0.0))
	# Sunset window: sill at 0.9 m so it shows through a doorway, rising well above it.
	var ww := w * 0.5
	var sill := 0.9
	var wh := h * 0.62
	var sky := QuadMesh.new()
	sky.size = Vector2(ww, wh)
	Props._put(sky, Atrium._sky_mat(), Vector3(0, sill + wh * 0.5, -d + 0.04), g)
	for x in [-ww * 0.5, -ww / 6.0, ww / 6.0, ww * 0.5]:
		Props._put(Props._box(0.08 if absf(x) < ww * 0.4 else 0.22, wh, 0.08), Props._m("cream"), Vector3(x, sill + wh * 0.5, -d + 0.08), g)
	for k in 4:
		Props._put(Props._box(ww + 0.2, 0.07 if k % 3 else 0.2, 0.08), Props._m("cream"), Vector3(0, sill + wh * k / 3.0, -d + 0.08), g)
	# Side gallery on the left with its rail and a mannequin looking down.
	var level := 3.0
	var gw := 1.6
	Props._put(Props._box(gw, 0.35, d), Props._m("cream"), Vector3(-w * 0.5 + gw * 0.5, level - 0.175, -d * 0.5), g)
	Props._put(Props._box(0.04, 0.03, d), Props._m("brass"), Vector3(-w * 0.5 + gw + 0.01, level - 0.3, -d * 0.5), g)
	Atrium.balustrade(g, Vector3(-w * 0.5 + gw - 0.05, level, -0.2), Vector3(-w * 0.5 + gw - 0.05, level, -d))
	Props.place(g, "mannequin", Vector3(-w * 0.5 + gw - 0.5, level, -d * 0.55), PI / 2.0, 0)
	# Escalator climbing away to the gallery level, a column with its banner, lilies, a pair.
	Atrium.escalator(g, Vector3(-w * 0.5 + gw + 0.9, 0, -0.8), level, -d + 0.8)
	var col := Vector3(w * 0.3, 0, -d * 0.55)
	Props._put(Props._box(0.6, h, 0.6), Props._m("cream"), col + Vector3(0, h * 0.5, 0), g)
	Props._put(Props._box(0.7, 0.16, 0.7), Props._m("brass"), col + Vector3(0, 0.08, 0), g)
	Atrium._banner(g, col + Vector3(0, 2.6, 0.33), Vector3(0, 0, 1), 0.55, 1.8)
	Props.place(g, "flower_display", Vector3(0.6, 0, -d * 0.45))
	Props.place(g, "mannequin_group", Vector3(w * 0.28, 0, -d + 1.3), -0.3, 1)
	Props._put(Props._cyl(0.02, 0.02, h - 3.2, 6), Props._m("brass"), Vector3(0.6, (h + 3.2) * 0.5, -d * 0.45), g)
	for i in 6:
		var a := TAU * i / 6.0
		ST.globe(g, Vector3(0.6 + cos(a) * 0.4, 3.1, -d * 0.45 + sin(a) * 0.4), 0.1)
	# Peach sunset pouring in, and a warm chandelier fill.
	var sun := SpotLight3D.new()
	sun.light_color = Color("ffb48c")
	sun.light_energy = 4.0
	sun.spot_range = d + h
	sun.spot_angle = 55.0
	sun.spot_angle_attenuation = 1.5
	sun.light_cull_mask = 1 << (LAYER - 1)
	sun.position = Vector3(0, sill + wh * 0.7, -d + 0.5)
	g.add_child(sun)
	sun.look_at(g.to_global(Vector3(0, 0, -0.3)), Vector3.UP)
	_light(g, Vector3(0.6, 2.8, -d * 0.45), Color("ffc896"), 2.0, maxf(w, d) + 1.5)
	_light(g, Vector3(0, 1.6, -1.0), Color("ffd2a8"), 0.9, 4.0)   # lift the near floor so it reads through the gate


## A corner of Cosmetics: cream panelled walls, a perfume counter under a lamp, a mannequin
## and lilies, in warm pink-amber light.
static func _cosmetics(g: Node3D, w: float, d: float, h: float) -> void:
	_shell(g, w, d, h, ST.textured("plaster_cream", 0.3, ST.plastic(Color("eee6d4"), 0.7, 0.0)),
			ST.textured("carpet_forest", 0.5, ST.plastic(Color("22433e"), 0.9, 0.0)), ST.plastic(Color("cbbd9f"), 0.8, 0.0))
	var B := load("res://scripts/builders.gd")
	B.wainscot(g, Vector3(0, 0, -d + 0.02), Vector3(w, 0, 0))
	Props.place(g, "perfume_counter", Vector3(-w * 0.12, 0, -d + 0.65), 0.0, 0)
	Props.place(g, "mannequin", Vector3(w * 0.32, 0, -d + 0.8), -0.4, 1)
	Props.place(g, "flower_display", Vector3(-w * 0.36, 0, -d * 0.4))
	Props.plaque(g, Vector3(0, 2.3, -d + 0.02), 1.6, "COSMETICS  ·  FRAGRANCE")
	ST.globe(g, Vector3(-w * 0.12, 2.0, -d + 0.15))
	_light(g, Vector3(-w * 0.1, 2.2, -d + 0.8), Color("ffbfa0"), 1.4, maxf(w, d) + 1.0)


# ---------------------------------------------------------------- helpers

## Floor, ceiling, back and side walls of a w x d x h box behind the opening.
static func _shell(g: Node3D, w: float, d: float, h: float, wall: Material, floor: Material, ceiling: Material) -> void:
	Props._put(Props._box(w, 0.1, d), floor, Vector3(0, -0.05, -d * 0.5), g)
	Props._put(Props._box(w, 0.2, d), ceiling, Vector3(0, h + 0.1, -d * 0.5), g)
	Props._put(Props._box(w, h, 0.2), wall, Vector3(0, h * 0.5, -d - 0.1), g)
	for s in [-1.0, 1.0]:
		Props._put(Props._box(0.2, h, d), wall, Vector3(s * (w * 0.5 + 0.1), h * 0.5, -d * 0.5), g)


## An omni light that only lights this glimpse.
static func _light(g: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
	var l := OmniLight3D.new()
	l.light_color = color
	l.light_energy = energy
	l.light_specular = 0.2
	l.omni_range = reach
	l.omni_attenuation = 1.0
	l.light_cull_mask = 1 << (LAYER - 1)
	l.position = at
	g.add_child(l)
