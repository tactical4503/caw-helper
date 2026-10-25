extends RefCounted
## Finishing for the smaller rooms: upper-wall panelling, crown mouldings, ceiling beams, wall
## shelving, the hat cabinet, the fitting booth and the atrium gate's winding station.
##
## Static pieces go into a "Finish" node the room merges at the end (Finish.done), so a room full
## of mouldings costs a handful of draws. Walls are described by two points on the wall face
## (same x or same z) and `face`, the direction out of the wall into the room.

const Props := preload("res://scripts/props.gd")

const PANEL_W := 1.15        # framed panels: nominal width and the gap between them
const PANEL_GAP := 0.45


## The container for a room's static finishing.
static func begin(room: Node3D) -> Node3D:
	var f := Node3D.new()
	f.name = "Finish"
	room.add_child(f)
	return f


## Bake the finishing into a few meshes once the room is built.
static func done(f: Node3D) -> void:
	load("res://scripts/atrium.gd").merge(f)


## Framed panels on the upper wall between `y0` and `y1`, evenly along `from`..`to`, skipping any
## [a, b] interval in `avoid` (measured along the wall from `from`). Brass frame, raised cream
## field, a plum inset on every other panel. A crown moulding runs along the top at `ceiling`.
static func upper_wall(f: Node3D, from: Vector3, to: Vector3, face: Vector3, y0: float, y1: float, ceiling: float, avoid := []) -> void:
	var length := from.distance_to(to)
	var dir := (to - from).normalized()
	crown(f, from, to, face, ceiling)
	var free := _free_spans(length, avoid)
	var i := 0
	for span in free:
		var room: float = span[1] - span[0]
		var n := int((room + PANEL_GAP) / (PANEL_W + PANEL_GAP))
		if n < 1:
			continue
		var w := (room - PANEL_GAP * (n + 1)) / n
		if w < 0.5:
			continue
		for k in n:
			var along: float = span[0] + PANEL_GAP + k * (w + PANEL_GAP) + w * 0.5
			_panel(f, from + dir * along, dir, face, w, y0, y1, i % 2 == 1)
			i += 1


## A crown moulding at the wall/ceiling junction: cream cove with a brass bead under it.
static func crown(f: Node3D, from: Vector3, to: Vector3, face: Vector3, ceiling: float) -> void:
	var mid := (from + to) * 0.5
	var length := from.distance_to(to)
	_strip(f, mid, from, to, face, ceiling - 0.09, 0.18, 0.12, Props._m("cream"), length)
	_strip(f, mid, from, to, face, ceiling - 0.2, 0.03, 0.14, Props._m("brass"), length)
	_strip(f, mid, from, to, face, ceiling - 0.03, 0.06, 0.2, Props._m("cream"), length)


## Ceiling beams across a room: `rect` is the room's floor rectangle (x, z), beams run across the
## short way (along x if `along_x`) at each of `at` (z or x positions), soffit at `ceiling`.
static func ceiling_beams(f: Node3D, rect: Rect2, ceiling: float, along_x: bool, at: Array, dark := false) -> void:
	var m: Material = Props._m("steel_dark") if dark else Props._m("cream")
	for p in at:
		var pos := Vector3(rect.get_center().x if along_x else p, ceiling - 0.13, p if along_x else rect.get_center().y)
		var size := Vector3(rect.size.x, 0.26, 0.26) if along_x else Vector3(0.26, 0.26, rect.size.y)
		Props._put(Props._box(size.x, size.y, size.z), m, pos, f)
		if not dark:
			var bead := Vector3(size.x, 0.025, 0.3) if along_x else Vector3(0.3, 0.025, size.z)
			Props._put(Props._box(bead.x, bead.y, bead.z), Props._m("brass"), pos - Vector3(0, 0.12, 0), f)
		else:
			for s in [-1.0, 1.0]:   # I-beam flanges
				var fl := Vector3(size.x, 0.03, 0.34) if along_x else Vector3(0.34, 0.03, size.z)
				Props._put(Props._box(fl.x, fl.y, fl.z), m, pos + Vector3(0, s * 0.13, 0), f)


## Wall shelving: two walnut shelves on brass brackets, `w` wide, lower shelf at `y`, filled with
## `items` ("perfume", "hats", "bolts", "cartons").
static func shelf(f: Node3D, at: Vector3, face: Vector3, w: float, y: float, items: String) -> void:
	var dir := Vector3(-face.z, 0, face.x)
	for tier in 2:
		var ty := y + tier * 0.45
		var c := at + face * 0.15 + Vector3(0, ty, 0)
		_board(f, c, dir, face, w, 0.04, 0.3, Props._m("walnut"))
		_board(f, c + Vector3(0, 0.022, 0) + face * 0.149, dir, face, w, 0.012, 0.012, Props._m("brass"))
		for s in [-1.0, 1.0]:
			var b: Vector3 = at + dir * (s * (w * 0.5 - 0.12)) + face * 0.1 + Vector3(0, ty - 0.1, 0)
			_board(f, b, dir, face, 0.03, 0.18, 0.2, Props._m("brass"))
		var n := int(w / 0.22)
		for k in n:
			var p := c + dir * (-w * 0.5 + (k + 0.5) * w / n) + Vector3(0, 0.02, 0)
			match items:
				"perfume":
					var col: String = ["glass_rose", "glass_amber", "glass_lilac"][(k + tier) % 3]
					Props._put(Props._cyl(0.035, 0.04, 0.14, 12), Props._m(col), p + Vector3(0, 0.07, 0), f)
					Props._put(Props._sphere(0.022, 8), Props._m("brass"), p + Vector3(0, 0.17, 0), f)
				"hats":
					if k % 2 == 0:
						var col2: String = ["plum", "suit_navy", "dress_cream", "hat"][(k / 2 + tier) % 4]
						Props._put(Props._cyl(0.13, 0.13, 0.015, 18), Props._m(col2), p + Vector3(0, 0.01, 0), f)
						Props._put(Props._cyl(0.08, 0.09, 0.1, 16), Props._m(col2), p + Vector3(0, 0.07, 0), f)
				"bolts":
					var col3: String = ["suit_navy", "dress_cream", "suit_brown", "plum", "dress_sage"][(k + tier * 2) % 5]
					var bolt := Props._put(Props._cyl(0.06, 0.06, 0.26, 12), Props._m(col3), p + Vector3(0, 0.065, 0), f)
					bolt.basis = Basis(face.cross(Vector3.UP).normalized(), PI / 2.0) if face.length() > 0 else Basis()
				"cartons":
					Props._put(Props._box(0.2, 0.2 + (k % 2) * 0.06, 0.24), Props._m("carton"), p + Vector3(0, 0.11, 0), f)


## The Hats partition as a hat cabinet: recessed plinth, plum panelled base with brass band,
## a glazed upper case with two shelves of hats behind the glass, and a moulded cornice.
## Fits the old partition's footprint (w x 0.6, 1.75 tall) so collision is unchanged.
static func hat_cabinet(f: Node3D, centre: Vector3, w: float) -> void:
	var d := 0.6
	Props._put(Props.rounded_block(w - 0.08, 0.1, d - 0.08, 0.04), Props._m("plinth"), centre, f)
	Props._put(Props.rounded_block(w, 0.6, d, 0.05), Props._m("walnut"), centre + Vector3(0, 0.1, 0), f)
	var panels := maxi(1, int(w / 0.8))
	for s in [-1.0, 1.0]:
		for k in panels:
			var x: float = centre.x - w * 0.5 + (k + 0.5) * w / panels
			Props._put(Props._box(w / panels - 0.12, 0.36, 0.012), Props._m("plum"), Vector3(x, centre.y + 0.4, centre.z + s * (d * 0.5 + 0.004)), f)
	Props._put(Props.rounded_block(w + 0.03, 0.03, d + 0.03, 0.06), Props._m("brass"), centre + Vector3(0, 0.7, 0), f)
	# Glazed case: walnut posts, back board, two glass shelves of hats, glass fronts.
	for s in [-1.0, 1.0]:
		for e in [-1.0, 1.0]:
			Props._put(Props._box(0.06, 0.88, 0.06), Props._m("walnut"), centre + Vector3(e * (w * 0.5 - 0.03), 1.17, s * (d * 0.5 - 0.03)), f)
	Props._put(Props._box(w - 0.1, 0.88, 0.04), Props._m("walnut_dark"), centre + Vector3(0, 1.17, 0), f)
	for ty in [0.74, 1.12]:
		Props._put(Props._box(w - 0.1, 0.02, d - 0.08), Props._m("glass_clear"), centre + Vector3(0, ty, 0), f)
		var n := int((w - 0.2) / 0.36)
		for k in n:
			var x := centre.x - (w - 0.2) * 0.5 + (k + 0.5) * (w - 0.2) / n
			for s in [-1.0, 1.0]:
				var col: String = ["plum", "dress_cream", "suit_navy", "sale_red"][(k + int(ty * 10)) % 4]
				var hat := Vector3(x, centre.y + ty + 0.01, centre.z + s * 0.15)
				Props._put(Props._cyl(0.12, 0.12, 0.012, 18), Props._m(col), hat + Vector3(0, 0.006, 0), f)
				Props._put(Props._cyl(0.075, 0.085, 0.09, 16), Props._m(col), hat + Vector3(0, 0.055, 0), f)
	for s in [-1.0, 1.0]:
		Props._put(Props._box(w - 0.1, 0.84, 0.01), Props._m("glass_clear"), centre + Vector3(0, 1.17, s * (d * 0.5 - 0.02)), f)
	Props._put(Props.rounded_block(w + 0.08, 0.1, d + 0.08, 0.08, 0.02), Props._m("walnut"), centre + Vector3(0, 1.61, 0), f)
	Props._put(Props._box(w + 0.1, 0.025, d + 0.1), Props._m("brass"), centre + Vector3(0, 1.6, 0), f)


## The alcove's thin walls as cream panelling: framed both sides, brass capped.
static func panel_screen(f: Node3D, centre: Vector3, size: Vector3) -> void:
	Props._put(Props._box(size.x, size.y, size.z), Props._m("cream"), centre, f)
	Props._put(Props._box(size.x + 0.04, 0.04, size.z + 0.04), Props._m("brass"), centre + Vector3(0, size.y * 0.5, 0), f)
	Props._put(Props._box(size.x + 0.02, 0.14, size.z + 0.02), Props._m("plinth"), centre + Vector3(0, -size.y * 0.5 + 0.07, 0), f)
	var along_x := size.x > size.z
	var length := size.x if along_x else size.z
	var n := maxi(1, int(length / 0.8))
	for s in [-1.0, 1.0]:
		for k in n:
			var t := -length * 0.5 + (k + 0.5) * length / n
			var off: Vector3 = Vector3(t, 0.1, s * (size.z * 0.5 + 0.006)) if along_x else Vector3(s * (size.x * 0.5 + 0.006), 0.1, t)
			var pw := length / n - 0.18
			var ps := Vector3(pw, size.y - 0.6, 0.012) if along_x else Vector3(0.012, size.y - 0.6, pw)
			Props._put(Props._box(ps.x, ps.y, ps.z), Props._m("brass"), centre + off, f)
			var inner := Vector3(ps.x - (0.03 if along_x else 0.0), ps.y - 0.03, ps.z + 0.004) if along_x else Vector3(ps.x + 0.004, ps.y - 0.03, ps.z - 0.03)
			Props._put(Props._box(inner.x, inner.y, inner.z), Props._m("cream"), centre + off, f)


## The fitting booth: walnut corner posts and rails, cream panelled sides with plum insets, a
## panelled back, a moulded cornice; the curtain (separate, it moves) hangs across the front.
## `centre` is the floor centre; the open front faces +z. 1.8 x 1.8 x 2.4, as before.
static func booth(f: Node3D, centre: Vector3) -> void:
	var w := 1.8
	var h := 2.4
	for x in [-w * 0.5, w * 0.5]:
		for z in [-w * 0.5, w * 0.5]:
			Props._put(Props._box(0.09, h, 0.09), Props._m("walnut"), centre + Vector3(x, h * 0.5, z), f)
	for side in [[Vector3(0, 0, -w * 0.5), true], [Vector3(-w * 0.5, 0, 0), false], [Vector3(w * 0.5, 0, 0), false]]:
		var c: Vector3 = centre + side[0]
		var along_x: bool = side[1]
		var size := Vector3(w - 0.09, h - 0.2, 0.05) if along_x else Vector3(0.05, h - 0.2, w - 0.09)
		Props._put(Props._box(size.x, size.y, size.z), Props._m("cream"), c + Vector3(0, h * 0.5, 0), f)
		Props._put(Props._box(size.x, 0.16, size.z + 0.02), Props._m("walnut"), c + Vector3(0, 0.08, 0), f)   # base rail
		for py in [0.75, 1.65]:
			var ps := Vector3(w - 0.4, 0.7, 0.062) if along_x else Vector3(0.062, 0.7, w - 0.4)
			Props._put(Props._box(ps.x, ps.y, ps.z), Props._m("brass"), c + Vector3(0, py, 0), f)
			var inner := Vector3(ps.x - 0.04, 0.66, 0.066) if along_x else Vector3(0.066, 0.66, ps.z - 0.04)
			Props._put(Props._box(inner.x, inner.y, inner.z), Props._m("plum"), c + Vector3(0, py, 0), f)
	Props._put(Props._box(w + 0.16, 0.12, w + 0.16), Props._m("walnut"), centre + Vector3(0, h + 0.06, 0), f)
	Props._put(Props._box(w + 0.18, 0.03, w + 0.18), Props._m("brass"), centre + Vector3(0, h - 0.0, 0), f)
	# A long mirror on the back panel, inside.
	Props._put(Props._box(0.5, 1.5, 0.02), Props._m("mirror"), centre + Vector3(-0.45, 1.25, -w * 0.5 + 0.045), f)


## The atrium gate's winding station on the wall around the crank socket: a walnut-framed
## cream panel with a name plate, a dial showing how far the gate is raised (returns its needle
## pivot), the socket escutcheon, a "WIND TO RAISE" plate, and the snapped crank on a hook.
## `at` is on the wall face at the socket's centre; `face` points into the room.
static func gate_panel(room: Node3D, f: Node3D, at: Vector3, face: Vector3) -> Node3D:
	var dir := Vector3(-face.z, 0, face.x)
	var c := at + face * 0.03 + Vector3(0, 0.2, 0)
	_board(f, c, dir, face, 0.9, 1.5, 0.06, Props._m("walnut"))
	_board(f, c + face * 0.031, dir, face, 0.8, 1.4, 0.004, Props._m("cream"))
	_board(f, c + face * 0.034 + Vector3(0, 0.6, 0), dir, face, 0.66, 0.12, 0.006, Props._m("plum"))
	_board(f, at + face * 0.045, dir, face, 0.36, 0.36, 0.01, Props._m("brass"))      # escutcheon
	_board(f, c + face * 0.034 + Vector3(0, -0.5, 0), dir, face, 0.5, 0.1, 0.006, Props._m("brass"))
	var basis := Basis.looking_at(-face, Vector3.UP)
	for t in [["ATRIUM  GATE", c + Vector3(0, 0.6, 0), 0.0024, Color("efe3c8")], ["WIND  ↻  TO  RAISE", c + Vector3(0, -0.5, 0), 0.0016, Color("3a1a2f")],
			["SHUT", c + Vector3(0, 0.12, 0) + dir * 0.17, 0.0012, Color("3a1a2f")], ["OPEN", c + Vector3(0, 0.12, 0) - dir * 0.17, 0.0012, Color("3a1a2f")]]:
		var l := Label3D.new()
		l.text = t[0]
		l.pixel_size = t[2]
		l.font_size = 48
		l.modulate = t[3]
		l.outline_size = 0
		l.double_sided = false
		l.basis = basis
		l.position = t[1] + face * 0.05
		room.add_child(l)
	# Dial: brass bezel, ivory face, the needle pivot (rotated by the room as the gate rises).
	var dial := c + Vector3(0, 0.3, 0) + face * 0.04
	var bezel := Props._put(Props._cyl(0.15, 0.15, 0.03, 24), Props._m("brass"), dial, f)
	bezel.basis = basis * Basis(Vector3.RIGHT, PI / 2.0)
	var face_disc := Props._put(Props._cyl(0.13, 0.13, 0.034, 24), Props._m("shirt"), dial, f)
	face_disc.basis = bezel.basis
	# The needle: a mount facing out of the panel, and a pivot the room turns about the dial's axle
	# (rotation.z: +1.2 = SHUT, -1.2 = OPEN).
	var mount := Node3D.new()
	mount.position = dial + face * 0.022
	mount.basis = basis
	room.add_child(mount)
	var hub := Props._put(Props._cyl(0.015, 0.015, 0.01, 12), Props._m("brass"), Vector3.ZERO, mount)
	hub.rotation.x = PI / 2.0
	var pivot := Node3D.new()
	mount.add_child(pivot)
	var arm := Props._put(Props._box(0.012, 0.11, 0.006), Props._m("sale_red"), Vector3(0, 0.05, 0), pivot)
	arm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pivot.rotation.z = 1.2
	# The snapped crank, hung on a brass hook beside the panel with its tag.
	var hook := at + dir * 0.6 + face * 0.04 + Vector3(0, 0.6, 0)
	Props._put(Props._cyl(0.01, 0.01, 0.06, 6), Props._m("brass"), hook, f).basis = basis * Basis(Vector3.RIGHT, PI / 2.0)
	Props._put(Props._box(0.04, 0.3, 0.04), Props._m("sale_red"), hook + Vector3(0, -0.17, 0) + face * 0.03, f)
	Props._put(Props._box(0.12, 0.08, 0.004), Props._m("shirt"), hook + Vector3(0.0, -0.36, 0) + face * 0.06, f)
	return pivot


# ---------------------------------------------------------------- helpers

static func _panel(f: Node3D, centre: Vector3, dir: Vector3, face: Vector3, w: float, y0: float, y1: float, plum: bool) -> void:
	var h := y1 - y0
	var c := centre + Vector3(0, y0 + h * 0.5, 0)
	_board(f, c + face * 0.012, dir, face, w, h, 0.024, Props._m("brass"))
	_board(f, c + face * 0.016, dir, face, w - 0.05, h - 0.05, 0.028, Props._m("cream"))
	if plum:
		_board(f, c + face * 0.03, dir, face, w - 0.3, h - 0.3, 0.008, Props._m("plum"))
		_board(f, c + face * 0.028, dir, face, w - 0.27, h - 0.27, 0.006, Props._m("brass"))


## A box `w` along `dir`, `h` tall, `t` thick (out along `face`), centred at `c`.
static func _board(f: Node3D, c: Vector3, dir: Vector3, face: Vector3, w: float, h: float, t: float, m: Material) -> MeshInstance3D:
	var along_x := absf(dir.x) > 0.5
	var size := Vector3(w, h, t) if along_x else Vector3(t, h, w)
	return Props._put(Props._box(size.x, size.y, size.z), m, c, f)


static func _strip(f: Node3D, mid: Vector3, from: Vector3, to: Vector3, face: Vector3, y: float, h: float, proud: float, m: Material, length: float) -> void:
	var dir := (to - from).normalized()
	_board(f, Vector3(mid.x, y, mid.z) + face * (proud * 0.5), dir, face, length, h, proud, m)


static func _free_spans(length: float, avoid: Array) -> Array:
	var spans := [[0.0, length]]
	for av in avoid:
		var out := []
		for sp in spans:
			if av[1] <= sp[0] or av[0] >= sp[1]:
				out.append(sp)
			else:
				if av[0] > sp[0]:
					out.append([sp[0], av[0]])
				if av[1] < sp[1]:
					out.append([av[1], sp[1]])
		spans = out
	return spans
