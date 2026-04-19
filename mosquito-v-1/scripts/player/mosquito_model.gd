extends Node3D

var mesh_instances: Array[MeshInstance3D] = []

func _ready() -> void:
	_collect_meshes(self)

func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)
		_collect_meshes(child)

func set_color(color: Color) -> void:
	for mesh in mesh_instances:
		var surface_count := mesh.get_surface_override_material_count()

		# Se il mesh non ha override, controlliamo quante superfici ha davvero
		if surface_count == 0 and mesh.mesh != null:
			surface_count = mesh.mesh.get_surface_count()

		for i in range(surface_count):
			var mat: Material = mesh.get_active_material(i)

			if mat == null or not (mat is StandardMaterial3D):
				mat = StandardMaterial3D.new()
				mesh.set_surface_override_material(i, mat)

			(mat as StandardMaterial3D).albedo_color = color
