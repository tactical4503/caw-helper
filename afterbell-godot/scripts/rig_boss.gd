@tool
extends Node3D
## Keeps the held sale sign between the Floor Manager's two upper hands, so every clip that moves
## those arms carries the sign with them (also previews correctly in the editor).

@export var sign_follows_hands := true

@onready var _body: Node3D = $Upper/Lift/Flinch/Body
@onready var _sign: Node3D = $Upper/Lift/Flinch/Body/Placard
@onready var _hand_l: Node3D = $Upper/Lift/Flinch/Body/Arm1L/Elbow/Hand
@onready var _hand_r: Node3D = $Upper/Lift/Flinch/Body/Arm1R/Elbow/Hand


func _process(_delta: float) -> void:
	if not sign_follows_hands or _sign == null:
		return
	var mid := (_hand_l.global_position + _hand_r.global_position) * 0.5
	var basis := _body.global_basis.orthonormalized()
	_sign.global_position = mid + basis.z * 0.05
	_sign.global_basis = basis
