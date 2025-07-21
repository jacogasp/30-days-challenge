class_name BulletBase
extends Area2D

@export var damage: int = 5
@export var max_range: float = 1920
@export var speed: float = 400

var active: bool = false


func _ready():
	connect("area_entered", _on_area_2d_area_entered)
	top_level = true
	disable()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not active:
		return
	if area.has_method("hit"):
		area.call("hit", damage)
	disable()


func fire(_from: Vector2, _direction: Vector2) -> void:
	assert(false, "Method Not Implemented")


func enable() -> void:
	show()
	active = true
	set_process(true)
	set_physics_process(true)


func disable() -> void:
	hide()
	active = false
	set_process(false)
	set_physics_process(false)
