class_name Bullet
extends Sprite2D

var query := PhysicsShapeQueryParameters2D.new()
@onready var space_state := get_world_2d().direct_space_state

@export var max_range: float = 1920
@export var speed: float = 400
@export var damage: int = 1

var traveled_distance: float = 0
var active := false

func _ready() -> void:
	query.set_shape($Area2D/CollisionShape2D.shape)
	query.collide_with_bodies = true
	query.collision_mask = 1
	top_level = true
	hide()
	set_process(false)
	set_physics_process(false)

func fire(new_global_transform: Transform2D, random_rotation: float = 0.0) -> void:
	global_transform = new_global_transform
	scale=scale
	rotation += randf_range(-random_rotation / 2., random_rotation / 2.)
	traveled_distance = 0.
	show()
	active = true
	set_process(true)
	set_physics_process(true)

func _process(delta: float) -> void:
	if !active:
		return

	var distance := speed * delta
	var motion := transform.x * distance
	position += motion
	traveled_distance += distance

	query.transform = global_transform
	var result := space_state.intersect_shape(query, 1)

	if result or traveled_distance > max_range:
		recycle()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not active:
		return
	area.get_parent().call("hit", damage)
	recycle()

func recycle() -> void:
	hide()
	active = false
	set_process(false)
	set_physics_process(false)
