extends CharacterBody3D

# ==================================================
# Node references
# ==================================================
@export var yaw_pivot: Node3D
@export var pitch_pivot: Node3D

# ==================================================
# Movement settings
# ==================================================
@export var move_speed: float = 30.0
@export var strafe_speed: float = 4.0
@export var fly_speed: float = 3.0
@export var gravity: float = 6.0
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 6.0
@export var deceleration: float = 3.0

# ==================================================
# Tilt settings
# ==================================================
@export var max_tilt_degrees: float = 10.0
@export var tilt_sensitivity: float = 0.01
@export var tilt_smooth_speed: float = 8.0

var pitch: float = 0.0
var current_tilt: float = 0.0
var target_tilt: float = 0.0

# ==================================================
# Debug
# ==================================================
var debug: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if yaw_pivot == null:
		yaw_pivot = find_child("YawPivot", true, false) as Node3D
	if pitch_pivot == null:
		pitch_pivot = find_child("PitchPivot", true, false) as Node3D
	if debug:
		assert(yaw_pivot != null, "YawPivot non trovato")
		assert(pitch_pivot != null, "PitchPivot non trovato")


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw_pivot.rotate_y(-event.relative.x * mouse_sensitivity)

		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80.0), deg_to_rad(80.0))

		target_tilt = -event.relative.x * tilt_sensitivity
		target_tilt = clamp(target_tilt, deg_to_rad(-max_tilt_degrees), deg_to_rad(max_tilt_degrees))


func _physics_process(_delta: float) -> void:
	var forward: Vector3 = -pitch_pivot.global_transform.basis.z
	var right: Vector3 = yaw_pivot.global_transform.basis.x
	var input_velocity: Vector3 = Vector3.ZERO

	# Avanti
	if Input.is_action_pressed("forward"):
		input_velocity += forward * move_speed

	# Strafing
	if Input.is_action_pressed("left"):
		input_velocity -= right * strafe_speed
	if Input.is_action_pressed("right"):
		input_velocity += right * strafe_speed

	# Gravità
	velocity.y -= gravity * _delta

	# Movimento orizzontale e direzionale con inerzia
	var horizontal_target: Vector3 = Vector3(input_velocity.x, 0.0, input_velocity.z)
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0.0, velocity.z)

	if horizontal_target.length() > 0.0:
		horizontal_velocity = horizontal_velocity.lerp(horizontal_target, acceleration * _delta)
	else:
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, deceleration * _delta)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Movimento verticale controllato
	if Input.is_action_pressed("fly"):
		velocity.y = fly_speed

	# Tilt morbido laterale
	current_tilt = lerp(current_tilt, target_tilt, tilt_smooth_speed * _delta)

	# Ritorno graduale al centro quando il mouse smette di muoversi
	target_tilt = lerp(target_tilt, 0.0, tilt_smooth_speed * _delta)

	pitch_pivot.rotation = Vector3(pitch, 0.0, current_tilt)

	move_and_slide()
