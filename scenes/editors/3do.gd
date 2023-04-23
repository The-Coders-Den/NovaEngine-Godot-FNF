@tool
extends Node3D
@onready var mesh = $MeshInstance3D

func _process(delta):
	mesh.rotate_x(3*delta)
	mesh.rotate_y(2*delta)
	mesh.rotate_z(1*delta)
	mesh
