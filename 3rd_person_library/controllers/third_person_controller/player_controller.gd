extends CharacterController3D
class_name PlayerController3D

# ==== CONFIGURACIÓN (editable desde editor) ====
@export var jump_force : float = 10.0

# Input actions (DESACOPLADO)
@export var input_forward := "move_forward"
@export var input_back := "move_back"
@export var input_left := "move_left"
@export var input_right := "move_right"
@export var input_jump := "jump"

func _physics_process(delta: float) -> void:
	var input_dir = get_input_direction()
	
	var direction = (-transform.basis.z * input_dir.z + -transform.basis.x * input_dir.x)
	
	move(direction, delta)
	
	# gravedad
	apply_gravity(delta)
	
	# salto
	if Input.is_action_just_pressed(input_jump) and is_on_floor():
		jump(jump_force)
	
	move_and_slide()
	
	# ==== FUNCIÓN REUTILIZABLE ====
func get_input_direction() -> Vector3:
	var input = Input.get_vector(input_left, input_right, input_forward, input_back)
	return Vector3(input.x, 0, input.y)

func _ready():
	var camera = get_node("CameraRig")
	camera.connect("rotate_player", Callable(self, "_on_rotate_player"))

func _on_rotate_player(amount):
	rotation_degrees.y += amount
