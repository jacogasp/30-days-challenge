extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_speed: float = 100
@export var speed_randomness: float = 0.0
@export var min_spawn_time: float = 1.0
@export var max_spawn_time: float = 5.0

signal enemy_spawned
signal enemy_defeated

var bounds = Rect2()


func _ready() -> void:
	$Timer.wait_time = randf_range(min_spawn_time, max_spawn_time)


func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var enemy_span_location = $Path2D/PathFollow2D
	enemy_span_location.progress_ratio = randf()
	enemy.position = enemy_span_location.position + position
	enemy.scale = Vector2.ONE
	enemy.speed = randf_range(enemy_speed * (1 - speed_randomness), enemy_speed * (1 + speed_randomness))
	enemy.connect("enemy_spawned", _handle_enemy_spawned)
	enemy.connect("enemy_defeated", _handle_enemy_defeated)
	$Timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	add_sibling(enemy)


func _handle_enemy_spawned():
	enemy_spawned.emit()


func _handle_enemy_defeated():
	enemy_defeated.emit()
