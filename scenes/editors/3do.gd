@tool
extends Node3D

@onready var mesh = $MeshInstance3D

func _process(delta: float) -> void:
	mesh.rotate_x(3.0 * delta)
	mesh.rotate_y(2.0 * delta)
	mesh.rotate_z(1.0 * delta)
