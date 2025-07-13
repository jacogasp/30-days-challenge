class_name Gun
extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 5.0


var bullet_pool: BulletPool
var bullets_to_spawn := 0.0
var is_firing = false


func _ready() -> void:
	bullet_pool = PlayerBulletPool
	bullet_pool.init_pool(bullet_scene)


func _process(delta: float):
	if (is_firing):
		bullets_to_spawn += fire_rate * delta
		if bullets_to_spawn >= 1:
			for i in int(bullets_to_spawn):
				fire_bullet()
			bullets_to_spawn -= int(bullets_to_spawn)
		is_firing = false


func fire_bullet():
	var bullet = bullet_pool.get_bullet()
	bullet.fire(global_position, Vector2.RIGHT)
	bullet.scale = Vector2(0.5, 0.5)
	bullet.enable()


func fire():
	is_firing = true

func reset():
	bullet_pool.reset()
