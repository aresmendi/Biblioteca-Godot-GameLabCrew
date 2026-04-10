class_name CharacterController3D
extends CharacterBody3D

# ==== CONFIG GENERAL ====
@export var move_speed : float = 5.0
@export var gravity : float = 15.0

# ==== MOVIMIENTO BASE ====
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func move(direction: Vector3, delta: float):
	velocity.x = lerp(velocity.x, direction.x * move_speed, 0.15)
	velocity.z = lerp(velocity.z, direction.z * move_speed, 0.15)

func jump(force: float):
	if is_on_floor():
		velocity.y = force
