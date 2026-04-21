# ==================================================
# SCRIPT: human_movement.gd
# TITLE: Movimiento básico de prueba para personaje humano
# AUTHOR: Davide F.
# DATE: 21-04-2026
# VERSION: 1.0
#
# DESCRIPTION:
# Este script se aplica a un CharacterBody3D y se usa
# para probar un movimiento simple de patrulla.
#
# El personaje avanza una distancia definida en una
# dirección, se gira suavemente sobre sí mismo y
# regresa al punto inicial, repitiendo el ciclo.
#
# Incluye gravedad básica y una rotación adaptada a
# modelos cuyo frente visual está orientado hacia X.
# ==================================================
extends CharacterBody3D

# ==================================================
# Ajustes
# ==================================================
@export var distance: float = 100.0
@export var move_speed: float = 150.0
@export var turn_speed: float = 4.0
@export var gravity: float = 2000.0

# ==================================================
# Estado
# ==================================================
var point_a: Vector3
var point_b: Vector3
var current_target: Vector3

var is_turning: bool = false
var desired_forward: Vector3 = Vector3.ZERO

func _ready() -> void:
	point_a = global_position
	point_b = point_a + (global_transform.basis.x * distance)
	current_target = point_b

func _physics_process(delta: float) -> void:
	# Gravedad
	if !is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if is_turning:
		_turn(delta)
	else:
		_move()

	move_and_slide()

# ==================================================
# Movimiento
# ==================================================
func _move() -> void:
	var to_target: Vector3 = current_target - global_position
	to_target.y = 0.0

	var dist: float = to_target.length()

	if dist <= 1.0:
		velocity.x = 0.0
		velocity.z = 0.0
		_start_turn()
		return

	var dir: Vector3 = to_target.normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed

# ==================================================
# Empezar giro
# ==================================================
func _start_turn() -> void:
	is_turning = true

	if current_target.is_equal_approx(point_b):
		current_target = point_a
	else:
		current_target = point_b

	desired_forward = current_target - global_position
	desired_forward.y = 0.0

	if desired_forward.length() > 0.001:
		desired_forward = desired_forward.normalized()

# ==================================================
# Giro suave
# ==================================================
func _turn(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	if desired_forward.length() <= 0.001:
		is_turning = false
		return

	# El personaje mira hacia +X
	var target_x: Vector3 = desired_forward
	var target_y: Vector3 = Vector3.UP
	var target_z: Vector3 = target_x.cross(target_y).normalized()

	# Reconstruir Y para asegurar base ortonormal
	target_y = target_z.cross(target_x).normalized()

	var target_basis: Basis = Basis(target_x, target_y, target_z).orthonormalized()

	var current_q: Quaternion = global_transform.basis.get_rotation_quaternion()
	var target_q: Quaternion = target_basis.get_rotation_quaternion()

	var weight: float = clamp(turn_speed * delta, 0.0, 1.0)
	var new_q: Quaternion = current_q.slerp(target_q, weight)

	global_transform.basis = Basis(new_q).orthonormalized()

	# Como la cara está en +X, comprobamos alignment con basis.x
	var new_forward: Vector3 = global_transform.basis.x
	new_forward.y = 0.0

	if new_forward.length() > 0.001:
		new_forward = new_forward.normalized()

	var alignment: float = new_forward.dot(desired_forward)

	if alignment >= 0.999:
		is_turning = false
