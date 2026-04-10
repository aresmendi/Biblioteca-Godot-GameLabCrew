extends Node3D
class_name CameraRig
# ==== CONFIG ====
@export var sensitivity : float = 0.1
@export var min_angle : float = -20
@export var max_angle : float = 20

@onready var yaw = $Yaw
@onready var pitch_node = $Yaw/Pitch

var pitch := 0.0

signal rotate_player(amount)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse = event.relative * sensitivity
				
		# Vertical (cámara)
		pitch += mouse.y
		pitch = clamp(pitch,min_angle,max_angle)
		pitch_node.rotation_degrees.x = pitch
		
		# Horizontal (jugador)
		emit_signal("rotate_player", -mouse.x)
	
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
