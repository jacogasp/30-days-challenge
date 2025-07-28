class_name Bullet
extends BulletBase

@onready var sprite_2d: Sprite2D = $Sprite2D

var traveled_distance: float = 0
var _direction: Vector2 = Vector2.ZERO


func fire(from: Vector2, direction: Vector2) -> void:
	position = from
	_direction = direction
	traveled_distance = 0.
	enable()


func _process(delta: float) -> void:
	if not active:
		return
	var distance := speed * delta
	var motion := _direction * distance
	position += motion
	traveled_distance += distance
	if traveled_distance > max_range:
		disable()
	if global_position.y > get_viewport().size.y + 50 or global_position.y < -50:
		disable()
	if global_position.x > get_viewport().size.x + 50 or global_position.x < -50:
		disable()
