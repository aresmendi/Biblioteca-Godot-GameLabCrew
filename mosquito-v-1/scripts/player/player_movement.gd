# ==================================================
# SCRIPT: player_movement.gd
# TITLE: Control de movimiento y estados del jugador
# AUTHOR: Davide F.
# DATE: 17-04-2026
# VERSION: 1.1
#
# DESCRIPTION:
# Este script se aplica a un CharacterBody3D y gestiona
# el movimiento principal del jugador, la rotación de
# cámara, la transición entre vuelo y apoyo en superficies
# especiales y la comunicación visual con el mosquito y
# la interfaz.
#
# En estado de vuelo, el jugador puede desplazarse,
# orientarse con el ratón y ganar impulso con la tecla
# asignada al vuelo.
#
# En estado apoyado, el jugador queda fijado a una
# superficie especial, deja de desplazarse libremente
# y solo puede observar alrededor y despegar con un
# impulso adaptado a la normal de la superficie.
#
# Si la superficie de apoyo pertenece a un objeto móvil,
# el jugador acompaña su desplazamiento mientras permanece
# adherido a él.
#
# También actualiza el color del mosquito y el estado
# de las barras de interfaz según el tipo de colisión.
# ==================================================
extends CharacterBody3D

# ==================================================
# Referencias de nodos
# ==================================================
@export var yaw_pivot: Node3D
@export var pitch_pivot: Node3D
@export var mosquito_visual: Node3D

# ==================================================
# HUD Canvas
# ==================================================
@export var state_bar_layers: CanvasLayer

# ==================================================
# Movimiento
# ==================================================
@export var move_speed: float = 70.0
@export var strafe_speed: float = 30.0
@export var fly_speed: float = 45.0
@export var gravity: float = 60.0
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 6.0
@export var deceleration: float = 3.0

# ==================================================
# EXTRA (salto desde superficie)
# ==================================================
@export var attached_fly_speed: float = 40.0

@export var detach_force: float = 25.0
@export var align_speed: float = 6.0
@export var return_speed: float = 2.5

# ==================================================
# Tilt
# ==================================================
@export var max_tilt_degrees: float = 10.0
@export var tilt_sensitivity: float = 0.01
@export var tilt_smooth_speed: float = 8.0

var pitch: float = 0.0
var current_tilt: float = 0.0
var target_tilt: float = 0.0

# ==================================================
# Estado
# ==================================================
var is_attached: bool = false
var is_on_layer_3: bool = false
var attached_normal: Vector3 = Vector3.UP
var saved_forward: Vector3 = Vector3.FORWARD
var normal_basis: Basis
var attached_body: CollisionObject3D = null
var last_body_position: Vector3 = Vector3.ZERO

# ==================================================
# INIT
# ==================================================
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if yaw_pivot == null:
		yaw_pivot = find_child("YawPivot", true, false) as Node3D
	if pitch_pivot == null:
		pitch_pivot = find_child("PitchPivot", true, false) as Node3D
	if mosquito_visual == null:
		mosquito_visual = find_child("Mosquito", true, false) as Node3D
	if state_bar_layers == null:
		state_bar_layers = find_child("CanvasLayer", true, false) as CanvasLayer

	if state_bar_layers != null:
		if state_bar_layers.has_method("set_blood_value"):
			state_bar_layers.set_blood_value(0.30)
		if state_bar_layers.has_method("set_energy_value"):
			state_bar_layers.set_energy_value(0.75)
		if state_bar_layers.has_method("set_mosquito_state"):
			state_bar_layers.set_mosquito_state(is_on_layer_3)

	normal_basis = global_transform.basis
	_update_mosquito_color()

# ==================================================
# INPUT
# ==================================================
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw_pivot.rotate_y(-event.relative.x * mouse_sensitivity)

		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80.0), deg_to_rad(80.0))

		target_tilt = -event.relative.x * tilt_sensitivity
		target_tilt = clamp(target_tilt, deg_to_rad(-max_tilt_degrees), deg_to_rad(max_tilt_degrees))

# ==================================================
# PHYSICS
# ==================================================
func _physics_process(delta: float) -> void:
	var forward: Vector3 = -pitch_pivot.global_transform.basis.z
	var right: Vector3 = yaw_pivot.global_transform.basis.x
	var input_velocity: Vector3 = Vector3.ZERO

	# Movimiento solo en vuelo
	if !is_attached:
		if Input.is_action_pressed("forward"):
			input_velocity += forward * move_speed

		if Input.is_action_pressed("left"):
			input_velocity -= right * strafe_speed
		if Input.is_action_pressed("right"):
			input_velocity += right * strafe_speed

	# Gravedad
	if !is_attached:
		velocity.y -= gravity * delta
	else:
		velocity = Vector3.ZERO

	# Space
	if Input.is_action_just_pressed("fly"):
		if is_attached:
			velocity = attached_normal * attached_fly_speed

			is_attached = false
			is_on_layer_3 = false
			attached_body = null
			last_body_position = Vector3.ZERO
			_update_mosquito_color()
		else:
			velocity.y = fly_speed

	# Inercia
	var target: Vector3 = Vector3(input_velocity.x, 0.0, input_velocity.z)
	var current: Vector3 = Vector3(velocity.x, 0.0, velocity.z)

	current = current.lerp(target, acceleration * delta)

	if !is_attached:
		velocity.x = current.x
		velocity.z = current.z

	# Camera
	current_tilt = lerp(current_tilt, target_tilt, tilt_smooth_speed * delta)
	target_tilt = lerp(target_tilt, 0.0, tilt_smooth_speed * delta)

	pitch_pivot.rotation = Vector3(pitch, 0.0, current_tilt)

	move_and_slide()

	# Detectar superficie especial
	if !is_attached:
		is_on_layer_3 = false

		for i in range(get_slide_collision_count()):
			var c: KinematicCollision3D = get_slide_collision(i)

			if c.get_collider() is CollisionObject3D:
				var body: CollisionObject3D = c.get_collider() as CollisionObject3D
				var layer: int = body.collision_layer

				var is_layer_2: bool = (layer & (1 << 1)) != 0
				var is_layer_3_hit: bool = (layer & (1 << 2)) != 0

				if is_layer_2 or is_layer_3_hit:
					is_attached = true
					is_on_layer_3 = is_layer_3_hit
					attached_normal = c.get_normal().normalized()
					saved_forward = -global_transform.basis.z
					attached_body = body
					last_body_position = attached_body.global_position
					_update_mosquito_color()
					break

	# Seguir el movimiento del objeto al que está apoyado
	if is_attached and attached_body != null:
		var current_body_position: Vector3 = attached_body.global_position
		var delta_body_position: Vector3 = current_body_position - last_body_position

		global_position += delta_body_position
		last_body_position = current_body_position

	# Rotación
	if is_attached:
		_align_to_surface(delta)
	else:
		_restore_normal(delta)

# ==================================================
# COLOR + HUD
# ==================================================
func _update_mosquito_color() -> void:
	if mosquito_visual != null and mosquito_visual.has_method("set_color"):
		if is_attached:
			mosquito_visual.set_color(Color.RED)
		else:
			mosquito_visual.set_color(Color.GREEN)

	if state_bar_layers != null and state_bar_layers.has_method("set_mosquito_state"):
		state_bar_layers.set_mosquito_state(is_on_layer_3)

# ==================================================
# ALIGN
# ==================================================
func _align_to_surface(delta: float) -> void:
	var up: Vector3 = attached_normal.normalized()

	# Proyectar la dirección previa sobre el plano de la superficie
	var projected_forward: Vector3 = saved_forward - up * saved_forward.dot(up)

	# Si la proyección es demasiado pequeña, usar una dirección auxiliar estable
	if projected_forward.length() < 0.01:
		var world_reference: Vector3 = Vector3.FORWARD

		# Si la normal casi coincide con FORWARD/BACK, usar RIGHT como referencia
		if abs(up.dot(world_reference)) > 0.95:
			world_reference = Vector3.RIGHT

		projected_forward = world_reference - up * world_reference.dot(up)

	projected_forward = projected_forward.normalized()

	# Construir una base estable
	var right: Vector3 = projected_forward.cross(up).normalized()
	var forward: Vector3 = up.cross(right).normalized()

	var target_basis: Basis = Basis(right, up, -forward).orthonormalized()

	var current_q: Quaternion = global_transform.basis.get_rotation_quaternion()
	var target_q: Quaternion = target_basis.get_rotation_quaternion()
	var weight: float = clamp(align_speed * delta, 0.0, 1.0)
	var new_q: Quaternion = current_q.slerp(target_q, weight)

	global_transform.basis = Basis(new_q).orthonormalized()

# ==================================================
# RESTORE
# ==================================================
func _restore_normal(delta: float) -> void:
	var current_q: Quaternion = global_transform.basis.get_rotation_quaternion()
	var target_q: Quaternion = normal_basis.get_rotation_quaternion()

	var new_q: Quaternion = current_q.slerp(target_q, return_speed * delta)

	global_transform.basis = Basis(new_q).orthonormalized()
