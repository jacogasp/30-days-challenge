extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_speed: float = 100
@export var speed_randomness: float = 0.0
@export var min_spawn_time: float = 1.0
@export var max_spawn_time: float = 5.0

@onready var timer: Timer = $Timer

var bounds = Rect2()


func _on_timer_timeout() -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	var enemy_span_location = $Path2D/PathFollow2D
	enemy_span_location.progress_ratio = randf()
	enemy.position = enemy_span_location.position + position
	enemy.scale = Vector2.ONE
	var speed = randf_range(enemy_speed * (1 - speed_randomness), enemy_speed * (1 + speed_randomness))
	enemy.direction = Vector2(speed, 0)
	timer.wait_time = random_time()
	add_sibling(enemy)


func random_time() -> float:
	return randf_range(min_spawn_time, max_spawn_time)
