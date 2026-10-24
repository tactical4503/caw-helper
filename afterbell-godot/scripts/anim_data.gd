extends RefCounted
## Keyframe source for every greybox animation clip. tools/build_rigs.gd turns these into
## AnimationLibrary resources inside rigs/*.tscn, where they can be opened and edited in Godot's
## animation editor.
##
## Authoring model: a clip is a list of keys [time, overrides, ease]. Keys are cumulative: each
## starts from the previous key's full pose and applies its overrides; "_rest" restarts from the
## rest pose. Every clip keys every animated node, so clips blend cleanly into each other.
## `ease` shapes the motion out of that key (Godot transition curve): 1 linear, <1 fast start
## (strikes, snaps), >1 slow start, negative values ease in and out (settles, holds).
##
## Timing that gameplay depends on is fixed to the Installment 002 timing table and checked by
## tests/sim_test.gd: present = 1.0 s sign tell, sweep_tell = 1.1 s, rack_push tell = 1.2 s,
## wind = 0.8 s heavy charge with three clicks.

const SNAP := 0.3     # explosive start, long settle
const QUICK := 0.5
const LIN := 1.0
const SMOOTH := -2.0  # ease in-out
const HEAVY := 2.2    # slow start, builds

# ---------------------------------------------------------------- Floor Manager

const BODY := "Upper/Lift/Flinch/Body"
const LIFT := "Upper/Lift:position"
const BODY_R := BODY + ":rotation"
const BODY_P := BODY + ":position"
const HEAD := BODY + "/Head:rotation"
const SASH := BODY + "/Sash:rotation"
const PADDLE := "Chair/Paddle:position"

const ARM_U := Vector3(-1.0, -0.12, -1.1)   # [raise, spread, elbow] for one level
const ARM_M := Vector3(-0.25, -0.05, -1.2)
const ARM_L := Vector3(-0.05, -0.1, -0.15)
const PARKED := Vector3(0.05, 0.06, -2.5)
const EXP_U := Vector3(-2.9, 0.6, -0.5)
const EXP_M := Vector3(-2.6, 0.9, -0.6)
const EXP_L := Vector3(-2.3, 1.0, -0.4)
const PADDLE_IN := Vector3(0, 0.44, -0.18)
const PADDLE_OUT := Vector3(0, 0.34, -0.44)


## One arm level on one side: shoulder (raise, 0, ±spread) and elbow hinge.
static func arm(level: int, side: String, v: Vector3) -> Dictionary:
	var s := 1.0 if side == "L" else -1.0
	var path := "%s/Arm%d%s" % [BODY, level, side]
	return {path + ":rotation": Vector3(v.x, 0, s * v.y), path + "/Elbow:rotation": Vector3(v.z, 0, 0)}


## One arm level, mirrored on both rails.
static func pair(level: int, v: Vector3) -> Dictionary:
	var d := arm(level, "L", v)
	d.merge(arm(level, "R", v))
	return d


static func arms(u: Vector3, m: Vector3, l: Vector3) -> Dictionary:
	var d := pair(1, u)
	d.merge(pair(2, m))
	d.merge(pair(3, l))
	return d


static func o(pairs: Array) -> Dictionary:
	## Merge a list of dictionaries into one override set.
	var d := {}
	for p in pairs:
		d.merge(p, true)
	return d


static func boss_rest() -> Dictionary:
	return o([{LIFT: Vector3.ZERO, BODY_R: Vector3.ZERO, BODY_P: Vector3.ZERO, HEAD: Vector3.ZERO,
		SASH: Vector3.ZERO, PADDLE: PADDLE_IN},
		arms(ARM_U, ARM_M, ARM_L)])


static func exposed_pose() -> Dictionary:
	return o([{BODY_R: Vector3(-0.06, 0, 0), HEAD: Vector3(-0.1, 0, 0), PADDLE: PADDLE_OUT}, arms(EXP_U, EXP_M, EXP_L)])


const PRESENT_END := {
	BODY_R: Vector3(-0.12, 0, 0), BODY_P: Vector3(0, 0.02, 0), HEAD: Vector3(-0.15, 0, 0),
	SASH: Vector3(0.1, 0, 0),
}


static func boss_clips() -> Dictionary:
	var c := {}
	var rest := {"_rest": true}

	# 1. Idle: breath on a 2 s cycle; the sash and head lag the body (overlap).
	c["idle"] = [2.0, true, [
		[0.0, rest, SMOOTH],
		[1.0, o([{BODY_P: Vector3(0, -0.025, 0), BODY_R: Vector3(0.03, 0, 0), HEAD: Vector3(0.05, 0.06, 0),
			SASH: Vector3(0.04, 0, 0.05)},
			arms(Vector3(-1.0, -0.12, -1.15), Vector3(-0.22, -0.07, -1.25), ARM_L)]), SMOOTH],
		[2.0, rest, SMOOTH]]]

	# 2. Roll: leans back with dignity, chin up; caster judder; sash trails.
	var roll := {BODY_R: Vector3(-0.07, 0, 0), HEAD: Vector3(-0.08, 0, 0), SASH: Vector3(0.2, 0, 0), BODY_P: Vector3.ZERO}
	c["roll"] = [1.0, true, [
		[0.0, o([rest, roll]), SMOOTH],
		[0.25, {BODY_P: Vector3(0, -0.015, 0), SASH: Vector3(0.26, 0, 0.04)}, SMOOTH],
		[0.5, {BODY_P: Vector3.ZERO, SASH: Vector3(0.2, 0, 0)}, SMOOTH],
		[0.75, {BODY_P: Vector3(0, -0.015, 0), SASH: Vector3(0.24, 0, -0.04)}, SMOOTH],
		[1.0, o([rest, roll]), SMOOTH]]]

	# 3. Present (the 1.0 s sign tell): dip, sweep the placard overhead with overshoot, hold, draw back.
	c["present"] = [1.0, false, [
		[0.0, rest, SMOOTH],
		[0.18, o([{BODY_P: Vector3(0, -0.06, 0), BODY_R: Vector3(0.08, 0, 0), HEAD: Vector3(0.12, 0, 0),
			}, pair(1, Vector3(-0.7, 0.2, -1.4))]), QUICK],
		[0.48, o([{BODY_P: Vector3(0, 0.05, 0), BODY_R: Vector3(-0.1, 0, 0), HEAD: Vector3(-0.2, 0, 0),
			SASH: Vector3(0.1, 0, 0)},
			pair(1, Vector3(-2.95, 0.1, -0.1)), pair(2, Vector3(-0.5, 0.55, -0.9))]), SMOOTH],
		[0.62, o([{BODY_P: Vector3(0, 0.02, 0), BODY_R: Vector3(-0.06, 0, 0), HEAD: Vector3(-0.15, 0, 0),
			}, pair(1, Vector3(-2.75, 0.12, -0.2))]), SMOOTH],
		[0.85, {HEAD: Vector3(-0.15, 0.05, 0)}, SMOOTH],
		[1.0, o([PRESENT_END, pair(1, Vector3(-2.65, 0.12, -0.45))]), LIN]]]

	# 4. Throw: whip forward from the drawn-back hold, follow through, settle.
	c["throw"] = [0.6, false, [
		[0.0, o([rest, PRESENT_END, pair(1, Vector3(-2.65, 0.12, -0.45)), pair(2, Vector3(-0.5, 0.55, -0.9))]), SNAP],
		[0.1, o([{BODY_R: Vector3(0.18, 0, 0), BODY_P: Vector3(0, -0.03, 0), HEAD: Vector3(0.1, 0, 0),
			}, pair(1, Vector3(-1.1, 0.08, 0.1))]), QUICK],
		[0.2, o([{SASH: Vector3(-0.15, 0, 0)}, pair(1, Vector3(-0.85, 0.1, 0.15)), pair(2, Vector3(-0.4, 0.5, -0.7))]), SMOOTH],
		[0.6, rest, SMOOTH]]]

	# 5. Sweep tell (1.1 s): middle arms open wide, torso coils away, head keeps eyes on Ren.
	var coil := o([{BODY_R: Vector3(0, -0.45, 0), HEAD: Vector3(0.05, 0.35, 0), BODY_P: Vector3(0, -0.03, 0)},
		pair(2, Vector3(-0.08, 1.58, 0.0)), pair(3, Vector3(-0.1, -0.05, -0.35))])
	c["sweep_tell"] = [1.1, false, [
		[0.0, rest, QUICK],
		[0.3, o([{BODY_R: Vector3(0, -0.35, 0), HEAD: Vector3(0, 0.3, 0), BODY_P: Vector3(0, -0.03, 0)},
			pair(2, Vector3(-0.15, 1.45, -0.05)), pair(3, Vector3(-0.1, -0.05, -0.35))]), SMOOTH],
		[0.9, coil, LIN],
		[1.0, pair(2, Vector3(-0.12, 1.5, 0.0)), LIN],
		[1.1, coil, LIN]]]

	# 6. Sweep (0.2 s active + 1.4 s recovery): arc across the front, overshoot, heavy recovery.
	c["sweep"] = [1.6, false, [
		[0.0, o([rest, coil]), SNAP],
		[0.12, o([{BODY_R: Vector3(0.05, 0.4, 0), HEAD: Vector3(0, 0.1, 0), SASH: Vector3(0, 0, -0.3)},
			pair(2, Vector3(-1.5, 0.25, 0.0))]), QUICK],
		[0.22, o([{BODY_R: Vector3(0.08, 0.5, 0), SASH: Vector3(0, 0, 0.2)}, pair(2, Vector3(-1.65, -0.15, 0.1))]), SMOOTH],
		[0.6, o([{BODY_R: Vector3(0.04, 0.2, 0), SASH: Vector3.ZERO, BODY_P: Vector3(0, -0.02, 0)},
			pair(2, Vector3(-1.2, 0.3, -0.3))]), SMOOTH],
		[1.6, rest, SMOOTH]]]

	# 7. Rack push: reach, plant hands, load (1.2 s tell), shove, hold, recover.
	c["rack_push"] = [2.4, false, [
		[0.0, rest, SMOOTH],
		[0.35, o([{BODY_R: Vector3(0.15, 0, 0), HEAD: Vector3(0.1, 0, 0)}, pair(2, Vector3(-1.1, 0.45, -0.6))]), SMOOTH],
		[0.6, pair(2, Vector3(-1.25, 0.42, -0.35)), SMOOTH],
		[0.9, o([{BODY_P: Vector3(0, -0.05, 0), BODY_R: Vector3(0.05, 0, 0)}, pair(2, Vector3(-1.05, 0.4, -0.9))]), LIN],
		[1.2, pair(2, Vector3(-1.05, 0.4, -0.95)), SNAP],
		[1.32, o([{BODY_R: Vector3(0.25, 0, 0), BODY_P: Vector3(0, 0.02, 0), SASH: Vector3(-0.2, 0, 0)},
			pair(2, Vector3(-1.45, 0.35, 0.0))]), SMOOTH],
		[1.5, o([{SASH: Vector3(-0.25, 0, 0)}, pair(2, Vector3(-1.5, 0.33, 0.05))]), SMOOTH],
		[2.4, rest, SMOOTH]]]

	# 8. Reflected impact: knocked back, all six arms fly up in offended surprise, paddle springs out.
	c["reflected_impact"] = [0.5, false, [
		[0.0, rest, SNAP],
		[0.06, o([{BODY_R: Vector3(-0.3, 0, 0), BODY_P: Vector3(0, 0.02, -0.05), HEAD: Vector3(-0.45, 0, 0.1),
			SASH: Vector3(-0.4, 0, 0), PADDLE: Vector3(0, 0.38, -0.3)},
			arms(Vector3(-3.2, 0.9, -0.2), Vector3(-2.9, 1.2, -0.3), Vector3(-2.5, 1.1, -0.2))]), QUICK],
		[0.2, o([{BODY_R: Vector3(-0.15, 0, 0), BODY_P: Vector3.ZERO, HEAD: Vector3(-0.2, 0.1, 0.05),
			SASH: Vector3(0.2, 0, 0), PADDLE: Vector3(0, 0.33, -0.47)},
			arms(Vector3(-2.85, 0.55, -0.6), Vector3(-2.55, 0.85, -0.7), Vector3(-2.2, 0.95, -0.5))]), SMOOTH],
		[0.5, o([exposed_pose(), {SASH: Vector3.ZERO}]), SMOOTH]]]

	# 9. Exposed (loop): flustered; arms tremble out of phase, head darts.
	c["exposed"] = [1.2, true, [
		[0.0, o([rest, exposed_pose()]), SMOOTH],
		[0.3, o([{HEAD: Vector3(-0.1, 0.25, 0)}, arm(1, "L", Vector3(-3.0, 0.65, -0.4)), arm(2, "R", Vector3(-2.5, 0.85, -0.7))]), SMOOTH],
		[0.6, o([{HEAD: Vector3(-0.05, 0, 0)}, arms(Vector3(-2.85, 0.58, -0.55), Vector3(-2.65, 0.95, -0.55), Vector3(-2.25, 1.05, -0.45))]), SMOOTH],
		[0.9, o([{HEAD: Vector3(-0.1, -0.25, 0)}, arm(1, "R", Vector3(-3.0, 0.65, -0.4)), arm(2, "L", Vector3(-2.5, 0.85, -0.7))]), SMOOTH],
		[1.2, o([rest, exposed_pose()]), SMOOTH]]]

	# 10. Chair launch: the chair accelerates out from under him; body, head, arms and sash drag behind.
	var dragged := o([{BODY_R: Vector3(-0.25, 0, 0), HEAD: Vector3(-0.35, 0, 0), SASH: Vector3(0.35, 0, 0)},
		arms(Vector3(-3.3, 0.5, -0.3), Vector3(-3.0, 0.8, -0.3), Vector3(-2.7, 0.9, -0.1))])
	c["chair_launch"] = [0.5, false, [
		[0.0, o([rest, exposed_pose()]), SNAP],
		[0.12, o([{BODY_R: Vector3(-0.35, 0, 0), HEAD: Vector3(-0.5, 0, 0), SASH: Vector3(0.5, 0, 0)},
			arms(Vector3(-3.4, 0.5, -0.2), Vector3(-3.2, 0.8, -0.2), Vector3(-2.9, 0.9, 0.0))]), SMOOTH],
		[0.5, dragged, LIN]]]

	# 11. Bell collision: sudden stop; inertia pitches him forward, rebound, he looks down at the fallen tab.
	var looked := o([{BODY_R: Vector3(0.1, 0, 0), HEAD: Vector3(0.35, 0.3, 0), SASH: Vector3.ZERO, LIFT: Vector3.ZERO, PADDLE: PADDLE_IN},
		arms(Vector3(-1.0, -0.1, -1.1), Vector3(-0.3, -0.05, -1.2), ARM_L)])
	c["bell_collision"] = [0.9, false, [
		[0.0, o([rest, exposed_pose(), dragged]), SNAP],
		[0.07, o([{BODY_R: Vector3(0.4, 0, 0), HEAD: Vector3(0.5, 0, 0.1), SASH: Vector3(-0.6, 0, 0),
			LIFT: Vector3(0, -0.04, 0), PADDLE: PADDLE_IN},
			arms(Vector3(-1.6, 0.4, -0.1), Vector3(-1.4, 0.9, 0.0), Vector3(-1.2, 0.8, 0.0))]), QUICK],
		[0.22, {BODY_R: Vector3(-0.12, 0, 0), HEAD: Vector3(-0.15, 0, 0), SASH: Vector3(0.3, 0, 0), LIFT: Vector3(0, 0.01, 0)}, SMOOTH],
		[0.45, o([{BODY_R: Vector3(0.06, 0, 0), HEAD: Vector3(0.1, 0.15, 0), SASH: Vector3(-0.1, 0, 0), LIFT: Vector3.ZERO},
			arms(Vector3(-0.9, 0.0, -1.0), Vector3(-0.4, 0.0, -1.1), Vector3(-0.1, -0.05, -0.4))]), SMOOTH],
		[0.9, looked, SMOOTH]]]

	# 12. Phase recovery: straightens his crown, smooths the waistcoat, resumes dignity.
	c["phase_recovery"] = [1.6, false, [
		[0.0, o([rest, looked]), SMOOTH],
		[0.35, o([{HEAD: Vector3(0, 0, -0.08), BODY_R: Vector3(0.03, 0, 0)}, arm(1, "L", Vector3(-2.6, -0.25, -2.0)),
			pair(2, Vector3(-0.6, 0.1, -1.6))]), SMOOTH],
		[0.6, o([{HEAD: Vector3.ZERO}, arm(1, "L", Vector3(-2.7, -0.3, -2.1))]), SMOOTH],
		[0.8, pair(2, Vector3(-0.4, 0.05, -1.5)), SMOOTH],
		[1.0, o([pair(2, Vector3(-0.3, 0.15, -1.3)), arm(1, "L", Vector3(-1.4, 0.2, -1.3))]), SMOOTH],
		[1.25, {BODY_R: Vector3(-0.05, 0, 0), HEAD: Vector3(-0.08, 0, 0)}, SMOOTH],
		[1.6, rest, SMOOTH]]]

	# 13. Defeat settle: the column telescopes down in three stepped drops while the arms fold
	# upper, middle, lower (staggered overlap); a bow, then a slow look toward the clock.
	c["defeat_settle"] = [3.0, false, [
		[0.0, rest, SNAP],
		[0.3, {LIFT: Vector3(0, -0.18, 0), BODY_R: Vector3(0.05, 0, 0)}, SMOOTH],
		[0.4, {LIFT: Vector3(0, -0.15, 0)}, SNAP],
		[0.8, o([{LIFT: Vector3(0, -0.36, 0)}, pair(1, PARKED)]), SMOOTH],
		[0.9, {LIFT: Vector3(0, -0.33, 0)}, SNAP],
		[1.3, o([{LIFT: Vector3(0, -0.55, 0)}, pair(2, PARKED)]), SMOOTH],
		[1.4, {LIFT: Vector3(0, -0.52, 0)}, SMOOTH],
		[1.7, o([{HEAD: Vector3(0.2, 0, 0), BODY_R: Vector3(0.08, 0, 0)}, pair(3, PARKED)]), HEAVY],
		[2.4, {HEAD: Vector3(0.1, 0.5, 0), BODY_R: Vector3(0.02, 0, 0)}, SMOOTH],
		[3.0, {HEAD: Vector3(0.05, 0.55, 0), LIFT: Vector3(0, -0.53, 0)}, LIN]]]

	# 14. Lowered counter idle (return visit): four arms folded, two at work.
	var counter := o([{LIFT: Vector3(0, -0.53, 0), HEAD: Vector3(0.15, 0, 0)}, pair(1, PARKED), pair(3, PARKED),
		pair(2, Vector3(-1.0, 0.1, -1.6))])
	c["counter_idle"] = [3.0, true, [
		[0.0, o([rest, counter]), SMOOTH],
		[1.0, o([{HEAD: Vector3(0.18, 0.05, 0)}, arm(2, "L", Vector3(-1.1, 0.05, -1.8)), arm(2, "R", Vector3(-0.9, 0.15, -1.4))]), SMOOTH],
		[2.0, o([{HEAD: Vector3(0.12, -0.05, 0)}, arm(2, "L", Vector3(-0.9, 0.12, -1.5)), arm(2, "R", Vector3(-1.1, 0.05, -1.7))]), SMOOTH],
		[3.0, o([rest, counter]), SMOOTH]]]
	return c


# ---------------------------------------------------------------- Ren

const PELVIS_P := "Pelvis:position"
const PELVIS_R := "Pelvis:rotation"
const LEG_L := "Pelvis/LegL:rotation"
const LEG_R := "Pelvis/LegR:rotation"
const KNEE_L := "Pelvis/LegL/KneeL:rotation"
const KNEE_R := "Pelvis/LegR/KneeR:rotation"
const TORSO := "Pelvis/Torso:rotation"
const RHEAD := "Pelvis/Torso/Head:rotation"
const ARM_L_ := "Pelvis/Torso/ArmL:rotation"
const FORE_L := "Pelvis/Torso/ArmL/ForearmL:rotation"
const ARM_R_ := "Pelvis/Torso/ArmR:rotation"
const FORE_R := "Pelvis/Torso/ArmR/ForearmR:rotation"
const SWORD := "Pelvis/Torso/ArmR/ForearmR/Sword:rotation"
const HIP_Y := 0.92


static func ren_rest() -> Dictionary:
	return {PELVIS_P: Vector3(0, HIP_Y, 0), PELVIS_R: Vector3.ZERO,
		LEG_L: Vector3(0, 0, 0.03), LEG_R: Vector3(0, 0, -0.03), KNEE_L: Vector3(0.05, 0, 0), KNEE_R: Vector3(0.05, 0, 0),
		TORSO: Vector3(0.03, 0, 0), RHEAD: Vector3.ZERO,
		ARM_L_: Vector3(0.1, 0, 0.12), FORE_L: Vector3(-0.25, 0, 0),
		ARM_R_: Vector3(-0.25, 0, -0.12), FORE_R: Vector3(-0.55, 0, 0), SWORD: Vector3(-0.9, 0, 0)}


## Guard: braced stance, Knock held level across the chest with its broad flat face toward the
## threat, left hand bracing the blade. Sword x cancels the arm chain's pitch (arm + forearm) so the
## blade stays level; z = 90 deg turns it across the body.
static func level_blade(arm_x: float, fore_x: float) -> Vector3:
	return Vector3(-(arm_x + fore_x), 0, PI / 2.0)


static func guard_pose() -> Dictionary:
	return {PELVIS_P: Vector3(0, HIP_Y - 0.07, 0), LEG_L: Vector3(-0.35, 0, 0.12), KNEE_L: Vector3(0.55, 0, 0),
		LEG_R: Vector3(0.25, 0, -0.12), KNEE_R: Vector3(0.5, 0, 0), TORSO: Vector3(0.1, 0.15, 0), RHEAD: Vector3(-0.05, -0.15, 0),
		ARM_R_: Vector3(-1.2, 0, 0), FORE_R: Vector3(-0.3, 0, 0), SWORD: level_blade(-1.2, -0.3),
		ARM_L_: Vector3(-1.15, 0, -0.3), FORE_L: Vector3(-0.55, 0, 0)}


## Fully wound heavy strike: blade cocked far behind the shoulder, torso twisted away.
static func wound_pose() -> Dictionary:
	return {PELVIS_P: Vector3(0, HIP_Y - 0.08, 0), TORSO: Vector3(-0.08, -0.75, 0), RHEAD: Vector3(0, 0.55, 0),
		LEG_L: Vector3(-0.4, 0, 0.1), KNEE_L: Vector3(0.5, 0, 0), LEG_R: Vector3(0.35, 0, -0.1), KNEE_R: Vector3(0.45, 0, 0),
		ARM_R_: Vector3(-2.85, 0, -0.7), FORE_R: Vector3(-1.2, 0, 0), SWORD: Vector3(-0.3, 0, 0),
		ARM_L_: Vector3(-0.9, 0, -0.2), FORE_L: Vector3(-0.6, 0, 0)}


static func ren_clips() -> Dictionary:
	var c := {}
	var rest := {"_rest": true}

	c["idle"] = [2.4, true, [
		[0.0, rest, SMOOTH],
		[1.2, {PELVIS_P: Vector3(0, HIP_Y - 0.012, 0), TORSO: Vector3(0.06, 0, 0), RHEAD: Vector3(0.03, 0.04, 0),
			ARM_L_: Vector3(0.12, 0, 0.13), SWORD: Vector3(-0.95, 0, 0)}, SMOOTH],
		[2.4, rest, SMOOTH]]]

	# Run: contact / passing / contact / passing at 0.6 s per two steps; pelvis drops on contact,
	# torso counter-twists, left arm swings opposite the left leg, the sword arm swings less.
	var contact_l := {PELVIS_P: Vector3(0, HIP_Y - 0.05, 0), PELVIS_R: Vector3(0, 0.12, 0),
		LEG_L: Vector3(-0.7, 0, 0.02), KNEE_L: Vector3(0.15, 0, 0), LEG_R: Vector3(0.5, 0, -0.02), KNEE_R: Vector3(0.75, 0, 0),
		TORSO: Vector3(0.18, -0.15, 0), RHEAD: Vector3(-0.08, 0.1, 0),
		ARM_L_: Vector3(0.6, 0, 0.12), FORE_L: Vector3(-0.6, 0, 0), ARM_R_: Vector3(-0.6, 0, -0.15), FORE_R: Vector3(-0.7, 0, 0)}
	var contact_r := {PELVIS_P: Vector3(0, HIP_Y - 0.05, 0), PELVIS_R: Vector3(0, -0.12, 0),
		LEG_L: Vector3(0.5, 0, 0.02), KNEE_L: Vector3(0.75, 0, 0), LEG_R: Vector3(-0.7, 0, -0.02), KNEE_R: Vector3(0.15, 0, 0),
		TORSO: Vector3(0.18, 0.15, 0), RHEAD: Vector3(-0.08, -0.1, 0),
		ARM_L_: Vector3(-0.6, 0, 0.12), FORE_L: Vector3(-0.95, 0, 0), ARM_R_: Vector3(-0.1, 0, -0.15), FORE_R: Vector3(-0.5, 0, 0)}
	c["run"] = [0.6, true, [
		[0.0, o([rest, contact_l]), SMOOTH],
		[0.15, {PELVIS_P: Vector3(0, HIP_Y + 0.03, 0), PELVIS_R: Vector3.ZERO, LEG_L: Vector3(-0.1, 0, 0.02), KNEE_L: Vector3(0.25, 0, 0),
			LEG_R: Vector3(-0.25, 0, -0.02), KNEE_R: Vector3(1.3, 0, 0), TORSO: Vector3(0.18, 0, 0),
			ARM_L_: Vector3(0.0, 0, 0.12), ARM_R_: Vector3(-0.35, 0, -0.15)}, SMOOTH],
		[0.3, contact_r, SMOOTH],
		[0.45, {PELVIS_P: Vector3(0, HIP_Y + 0.03, 0), PELVIS_R: Vector3.ZERO, LEG_L: Vector3(-0.25, 0, 0.02), KNEE_L: Vector3(1.3, 0, 0),
			LEG_R: Vector3(-0.1, 0, -0.02), KNEE_R: Vector3(0.25, 0, 0), TORSO: Vector3(0.18, 0, 0),
			ARM_L_: Vector3(0.0, 0, 0.12), ARM_R_: Vector3(-0.35, 0, -0.15)}, SMOOTH],
		[0.6, o([rest, contact_l]), SMOOTH]]]

	# Guard: snap in with a small overshoot, then hold.
	c["guard"] = [0.35, false, [
		[0.0, rest, SNAP],
		[0.07, o([guard_pose(), {TORSO: Vector3(0.16, 0.26, 0), PELVIS_P: Vector3(0, HIP_Y - 0.09, 0)}]), SMOOTH],
		[0.16, guard_pose(), LIN],
		[0.35, guard_pose(), LIN]]]

	# Reflect: from guard, punch the flat of the blade forward and return to guard.
	c["reflect"] = [0.3, false, [
		[0.0, o([rest, guard_pose()]), SNAP],
		[0.05, {ARM_R_: Vector3(-1.45, 0, 0), FORE_R: Vector3(-0.05, 0, 0), SWORD: level_blade(-1.45, -0.05), TORSO: Vector3(0.22, 0.15, 0),
			ARM_L_: Vector3(-1.4, 0, -0.3), FORE_L: Vector3(-0.2, 0, 0)}, SMOOTH],
		[0.3, guard_pose(), LIN]]]

	# Wind (0.8 s = heavy charge): three ratchet steps at the three spring clicks, each a quick pull and settle.
	c["wind"] = [0.8, false, [
		[0.0, rest, SMOOTH],
		[0.1, {PELVIS_P: Vector3(0, HIP_Y - 0.04, 0), TORSO: Vector3(0.1, -0.3, 0), RHEAD: Vector3(0, 0.25, 0)}, SNAP],
		[0.27, {ARM_R_: Vector3(-1.9, 0, -0.5), FORE_R: Vector3(-0.9, 0, 0), SWORD: Vector3(-0.4, 0, 0), TORSO: Vector3(0.0, -0.45, 0),
			RHEAD: Vector3(0, 0.35, 0), ARM_L_: Vector3(-0.6, 0, -0.15)}, SMOOTH],
		[0.32, {ARM_R_: Vector3(-1.85, 0, -0.5)}, SNAP],
		[0.53, {ARM_R_: Vector3(-2.4, 0, -0.6), FORE_R: Vector3(-1.05, 0, 0), TORSO: Vector3(-0.05, -0.6, 0), RHEAD: Vector3(0, 0.45, 0),
			PELVIS_P: Vector3(0, HIP_Y - 0.06, 0), LEG_L: Vector3(-0.3, 0, 0.08), KNEE_L: Vector3(0.4, 0, 0),
			LEG_R: Vector3(0.25, 0, -0.08), KNEE_R: Vector3(0.35, 0, 0)}, SMOOTH],
		[0.58, {ARM_R_: Vector3(-2.35, 0, -0.6)}, SNAP],
		[0.8, wound_pose(), LIN]]]

	# Heavy: unwind explosively, overshoot past the target, recover with drag.
	c["heavy"] = [0.65, false, [
		[0.0, o([rest, wound_pose()]), SNAP],
		[0.07, {TORSO: Vector3(0.35, 0.55, 0), RHEAD: Vector3(0.1, -0.2, 0), PELVIS_P: Vector3(0, HIP_Y - 0.12, 0),
			ARM_R_: Vector3(-0.9, 0, 0.4), FORE_R: Vector3(-0.2, 0, 0), SWORD: Vector3(-1.2, 0, 0),
			LEG_L: Vector3(-0.65, 0, 0.1), KNEE_L: Vector3(0.9, 0, 0), LEG_R: Vector3(0.5, 0, -0.1), KNEE_R: Vector3(0.3, 0, 0),
			ARM_L_: Vector3(0.4, 0, 0.3)}, QUICK],
		[0.16, {TORSO: Vector3(0.45, 0.7, 0), ARM_R_: Vector3(-0.4, 0, 0.7), SWORD: Vector3(-1.4, 0, 0)}, SMOOTH],
		[0.65, rest, SMOOTH]]]

	# Light: small anticipation, a quick diagonal cut, follow-through.
	c["light"] = [0.32, false, [
		[0.0, rest, QUICK],
		[0.05, {ARM_R_: Vector3(-2.0, 0, -0.5), FORE_R: Vector3(-1.0, 0, 0), TORSO: Vector3(0, -0.2, 0)}, SNAP],
		[0.12, {ARM_R_: Vector3(-0.9, 0, 0.5), FORE_R: Vector3(-0.3, 0, 0), TORSO: Vector3(0.15, 0.3, 0), SWORD: Vector3(-1.3, 0, 0)}, SMOOTH],
		[0.32, rest, SMOOTH]]]

	# Dodge: tuck low and fast, then spring back up.
	c["dodge"] = [0.28, false, [
		[0.0, rest, SNAP],
		[0.06, {PELVIS_P: Vector3(0, HIP_Y - 0.25, 0), TORSO: Vector3(0.55, 0, 0), RHEAD: Vector3(-0.2, 0, 0),
			LEG_L: Vector3(-1.0, 0, 0.05), KNEE_L: Vector3(1.6, 0, 0), LEG_R: Vector3(-0.55, 0, -0.05), KNEE_R: Vector3(1.4, 0, 0),
			ARM_L_: Vector3(-0.8, 0, -0.3), FORE_L: Vector3(-1.5, 0, 0), ARM_R_: Vector3(-0.8, 0, 0.3), FORE_R: Vector3(-1.3, 0, 0)}, LIN],
		[0.18, {PELVIS_P: Vector3(0, HIP_Y - 0.2, 0)}, SMOOTH],
		[0.28, rest, SMOOTH]]]

	# Hurt: snap back, head whips, arms thrown out, recover.
	c["hurt"] = [0.45, false, [
		[0.0, rest, SNAP],
		[0.05, {TORSO: Vector3(-0.4, 0.2, 0.1), RHEAD: Vector3(-0.5, 0, 0.2), PELVIS_P: Vector3(0, HIP_Y - 0.03, 0),
			ARM_L_: Vector3(0.4, 0, 0.6), ARM_R_: Vector3(0.3, 0, -0.6), KNEE_L: Vector3(0.3, 0, 0), KNEE_R: Vector3(0.3, 0, 0)}, QUICK],
		[0.18, {TORSO: Vector3(-0.15, 0.1, 0.05), RHEAD: Vector3(-0.15, 0, 0.05)}, SMOOTH],
		[0.45, rest, SMOOTH]]]

	# Eat: biscuit up to the chin plate, two small bites (helmet nods), lower.
	c["eat"] = [0.9, false, [
		[0.0, rest, SMOOTH],
		[0.2, {ARM_L_: Vector3(-1.9, 0, -0.35), FORE_L: Vector3(-1.9, 0, 0), RHEAD: Vector3(0.15, 0, 0), TORSO: Vector3(0.08, 0, 0),
			ARM_R_: Vector3(-0.1, 0, -0.15), SWORD: Vector3(-0.3, 0, 0)}, SMOOTH],
		[0.4, {RHEAD: Vector3(0.28, 0, 0)}, SMOOTH],
		[0.5, {RHEAD: Vector3(0.12, 0, 0)}, SMOOTH],
		[0.62, {RHEAD: Vector3(0.28, 0, 0)}, SMOOTH],
		[0.72, {RHEAD: Vector3(0.1, 0, 0)}, SMOOTH],
		[0.9, rest, SMOOTH]]]
	return c


# ---------------------------------------------------------------- clip builder

static func make_animation(length: float, loop: bool, keys: Array, rest: Dictionary) -> Animation:
	var anim := Animation.new()
	anim.length = length
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	var tracks := {}
	for path in rest:
		var t := anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(t, NodePath(path))
		anim.value_track_set_update_mode(t, Animation.UPDATE_CONTINUOUS)
		anim.track_set_interpolation_type(t, Animation.INTERPOLATION_LINEAR)
		anim.track_set_interpolation_loop_wrap(t, loop)
		tracks[path] = t
	var pose := rest.duplicate()
	for k in keys:
		var time: float = k[0]
		var over: Dictionary = k[1]
		var ease: float = k[2]
		if over.get("_rest", false):
			pose = rest.duplicate()
		for path in over:
			if path == "_rest":
				continue
			assert(rest.has(path), "Unknown animated path: " + path)
			pose[path] = over[path]
		for path in pose:
			anim.track_insert_key(tracks[path], time, pose[path], ease)
	return anim


static func build_library(clips: Dictionary, rest: Dictionary) -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	for name in clips:
		var spec: Array = clips[name]
		lib.add_animation(name, make_animation(spec[0], spec[1], spec[2], rest))
	return lib
