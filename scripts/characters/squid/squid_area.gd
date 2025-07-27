extends Area2D

signal area_hit

func hit_position(damage:int, pos:Vector2 = global_position) -> void:
	area_hit.emit(damage, pos)
