class_name Bullet
extends Sprite2D

var query := PhysicsShapeQueryParameters2D.new()
@onready var space_state := get_world_2d().direct_space_state

@export var max_range: float = 1920
@export var speed: float = 400
@export var damage: int = 1

var traveled_distance: float = 0


func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := transform.x * distance
	position += motion
	traveled_distance += distance


func _ready() -> void:
	query.set_shape($Area2D/CollisionShape2D.shape)
	query.collide_with_bodies = true
	query.collision_mask = 1
	top_level = true


func _process(delta: float) -> void:
	var distance := speed * delta
	var motion := transform.x * distance
	position += motion
	traveled_distance += distance
	query.transform = global_transform
	var result := space_state.intersect_shape(query, 1)
	if result or traveled_distance > max_range:
		hide()
		set_process(false)


func fire(new_global_transform: Transform2D,
	random_rotation: float = 0.0
) -> void:
	global_transform = new_global_transform
	rotation += randf_range(-random_rotation / 2., random_rotation / 2.)
	traveled_distance = 0.


func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().call("hit", damage)
	queue_free()
