class_name Sailor
extends Area2D

@export var delay := 0.2
@export var snap_duration := 0.25
@onready var spawn_position: Vector2 = position
@onready var sprite: Sprite2D = $Sprite2D

var jumping_out: bool = false
var overboard: bool = false


func _ready() -> void:
	call_deferred("set_monitoring", false)


func _process(delta: float) -> void:
	if overboard:
		position.x -= delta * Globals.world_speed * 0.5


func spawn():
	await get_tree().create_timer(delay * randf_range(0.1, 0.4)).timeout
	var tween = create_tween()
	tween.tween_property(self, "position", spawn_position, snap_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished


func snap_to(velocity: Vector2):
	if jumping_out:
		return
	var current_pos = position
	await get_tree().create_timer(delay * randf_range(0.1, 0.4)).timeout
	var tween = create_tween()
	tween.tween_property(self, "position", current_pos + velocity, snap_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished


func snap_back():
	if jumping_out:
		return
	await get_tree().create_timer(delay * randf_range(0.1, 0.99)).timeout
	var tween = create_tween()
	tween.tween_property(self, "position", spawn_position, snap_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished


func jump_out(direction: Vector2):
	jumping_out = true
	var verse = Vector2(direction.normalized().x, 1)
	var start_pos = global_position
	var jump_offset = Vector2(randf_range(-5, 0), 30 + randf_range(-45, +45))
	var jump_position = global_position + jump_offset * verse
	var jump_duration = 0.5 + randf_range(0, 0.2)
	var height = 100 # max height of the arc
	var random_rotation = deg_to_rad(randf_range(-80, 0) * verse.x)
	var tween = create_tween()
	z_index = 2
	tween.tween_method(
		func(t):
			var x = lerp(start_pos.x, jump_position.x, t)
			var y = lerp(start_pos.y, jump_position.y, t)
			var arc = -4 * height * (t - 0.5) * (t - 0.5) + height
			global_position = Vector2(x, y - arc)
	, 0.0, 1.0, jump_duration) \
	.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(self, "rotation", random_rotation, jump_duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func set_overboard() -> void:
	overboard = true
	rotation = 0
	z_index = 0
	call_deferred("set_monitoring", true)
	sprite.texture = load("res://assets/sailor_drowning.png")


func _on_area_2d_area_entered(area: Area2D) -> void:
	var player: Player = area
	var modulation_color = modulate
	player.call_deferred("load_sailor", modulation_color)
	queue_free()
