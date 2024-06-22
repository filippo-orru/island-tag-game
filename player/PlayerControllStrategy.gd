class_name PlayerControllStrategy
extends RefCounted

func _input(event):
	pass

func get_target_vector(position: Vector2i) -> Vector2i:
	push_error("NOT IMPLEMENTED ERROR: PlayerControllStrategy.get_next_target_position")
	return Vector2i.ZERO
