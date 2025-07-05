extends Node2D

@export var enemy_scene: PackedScene
@export var vertical_offset: float = 100
@export var min_spawn_time: float = 1.0
@export var max_spawn_time: float = 5.0
@export var min_scale: float = 0.2
@export var max_scale: float = 5
@export var scale_factor: float = 1.0

var bounds = Rect2()

func _ready() -> void:
	var canvas = get_canvas_transform()
	var top_left = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	bounds = Rect2(top_left, size)

func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var enemy_span_location = $Path2D/PathFollow2D
	enemy_span_location.progress_ratio = randf()
	enemy.position = enemy_span_location.position
	var ratio = enemy.global_position.y / (bounds.position.y + bounds.size.y)
	enemy.scale = Vector2.ONE * clamp(ratio * scale_factor, min_scale, max_scale)
	$Timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	add_child(enemy)
