extends Node2D

@export var barrel_scene: PackedScene
@export var barrel_primary_scene: PackedScene
@export var barrel_secondary_scene: PackedScene
@export var min_fire_time: float = 5.0
@export var max_fire_time: float = 10.0

func fire():
	var barrel:Barrel = barrel_scene.instantiate()
	barrel.global_position = global_position
	get_parent().add_sibling(barrel)

func drop_barrel_primary():
	var barrel:Barrel = barrel_primary_scene.instantiate()
	barrel.global_position = global_position
	get_parent().add_sibling(barrel)	

func drop_barrel_secondary():
	var barrel:Barrel = barrel_secondary_scene.instantiate()
	barrel.global_position = global_position
	get_parent().add_sibling(barrel)
