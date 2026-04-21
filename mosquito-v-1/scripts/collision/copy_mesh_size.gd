# ==================================================
# SCRIPT: copy_mesh_size.gd
# TITLE: Ajuste automático de colisión al mesh
# AUTHOR: Davide F.
# DATE: 18-04-2026
# VERSION: 1.0
#
# DESCRIPTION:
# Este script se aplica a un CollisionShape3D y ajusta
# automáticamente su forma para que coincida con el
# tamaño del MeshInstance3D asociado.
#
# Si no se asigna manualmente un MeshInstance3D,
# el script intentará encontrar uno automáticamente
# entre los hijos del nodo padre.
#
# El resultado es una BoxShape3D que replica el AABB
# del mesh, teniendo en cuenta también su escala.
# ==================================================
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
