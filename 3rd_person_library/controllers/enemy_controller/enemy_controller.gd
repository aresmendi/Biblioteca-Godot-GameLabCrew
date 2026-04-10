extends CharacterController3D
class_name EnemyController3D

@export var player_path : NodePath
@onready var player = get_node(player_path)

@export var detection_range : float = 10.0

func _physics_process(delta):
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance < detection_range:
		follow_player(delta)
	
	apply_gravity(delta)
	move_and_slide()

func follow_player(delta):
	var direction = (player.global_position - global_position).normalized()
	
	move(direction, delta)
