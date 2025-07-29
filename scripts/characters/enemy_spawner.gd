class_name EnemySpawner
extends Node2D

@export var default_enemy_scene: PackedScene
@export var enemy_speed: float = 100
@export var speed_randomness: float = 0.0

@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D


func spawn(enemy_scene: PackedScene = default_enemy_scene) -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	path_follow.progress_ratio = randf()
	enemy.position = path_follow.position + position
	enemy.scale = Vector2.ONE
	var speed = randf_range(enemy_speed * (1 - speed_randomness), enemy_speed * (1 + speed_randomness))
	enemy.direction = Vector2(speed, 0)
	add_sibling(enemy)
