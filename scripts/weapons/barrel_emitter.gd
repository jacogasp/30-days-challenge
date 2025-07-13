extends Node2D

@export var barrel_scene: PackedScene
@export var min_fire_time: float = 5.0
@export var max_fire_time: float = 10.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = random_time()

func fire():
	var barrel = barrel_scene.instantiate()
	add_child(barrel)
	timer.wait_time = random_time()

func random_time() -> float:
	return randf_range(min_fire_time, max_fire_time)
