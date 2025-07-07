class_name Gun
extends Node2D

@export var fire_rate: float = 5.0
var bullets_to_spawn := 0.0
var is_firing = false

func _process(delta: float):
	if (is_firing):
		bullets_to_spawn += fire_rate * delta
		if bullets_to_spawn >= 1:
			for i in int(bullets_to_spawn):
				fire_bullet()
			bullets_to_spawn -= int(bullets_to_spawn)
		is_firing = false


func fire_bullet():
	var bullet: Bullet = BulletPool.get_bullet()
	var bullet_transform := global_transform
	bullet_transform.origin = global_position
	bullet.fire(bullet_transform, 0.03)
	bullet.scale = Vector2(0.5,0.5)
	bullet.enable()


func fire():
	is_firing = true
