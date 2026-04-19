extends CharacterBody3D

enum MovementState {
	e_STANDING,
	e_RUNNING,
	e_CROUCH
}

@export var standing_collision: CollisionShape3D
@export var running_collision: CollisionShape3D
@export var crouching_collision: CollisionShape3D
@export var head: Node3D
@export var raycast: RayCast3D

var current_speed = 5.0

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
const jump_velocity = 6.0

var direction = Vector3.ZERO
var air_direction = Vector3.ZERO
var lerp_speed = 10.0
var crouching_depth = -1.1

const mouse_sens = 0.25

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func set_collision_state(state: int) -> void:
	match state:
		MovementState.e_STANDING:
			running_collision.set_deferred("disabled", true)
			crouching_collision.set_deferred("disabled", true)
			standing_collision.set_deferred("disabled", false)

		MovementState.e_RUNNING:
			standing_collision.set_deferred("disabled", true)
			crouching_collision.set_deferred("disabled", true)
			running_collision.set_deferred("disabled", false)

		MovementState.e_CROUCH:
			standing_collision.set_deferred("disabled", true)
			running_collision.set_deferred("disabled", true)
			crouching_collision.set_deferred("disabled", false)

		_:
			push_warning("Stato non valido: " + str(state))

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 1.0 + crouching_depth, delta * lerp_speed)
		set_collision_state(MovementState.e_CROUCH)

	else:
		raycast.force_raycast_update()

		if !raycast.is_colliding():
			head.position.y = lerp(head.position.y, 1.0, delta * lerp_speed)

			if Input.is_action_pressed("sprint"):
				current_speed = sprinting_speed
				set_collision_state(MovementState.e_RUNNING)
			else:
				current_speed = walking_speed
				set_collision_state(MovementState.e_STANDING)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		air_direction = direction

	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	if is_on_floor():
		direction = lerp(
			direction,
			(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),
			delta * lerp_speed
		)
	else:
		direction = air_direction

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
