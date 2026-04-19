extends CollisionShape3D

@export var mesh_instance: MeshInstance3D

func _ready():
	if mesh_instance == null:
		for c in get_parent().get_children():
			if c is MeshInstance3D:
				mesh_instance = c
				break

	if mesh_instance and mesh_instance.mesh:
		var shape_box := BoxShape3D.new()
		shape_box.size = mesh_instance.mesh.get_aabb().size * mesh_instance.scale
		shape = shape_box
