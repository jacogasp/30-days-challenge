class_name EnemyGun
extends Gun

func _ready() -> void:
	bullet_pool = EnemyBulletPool
	bullet_pool.init_pool(bullet_scene)

func fire_ring(bullet_count: int = 16) -> void:
	var angle_step: float = 2*PI / bullet_count
	for i in range(bullet_count):
		var angle = angle_step * i
		var direction = Vector2(cos(angle), sin(angle))
		var origin = global_position + direction

		var bullet: Bullet = bullet_pool.get_bullet()
		if bullet:
			_setup_bullet(bullet, origin, direction, angle)

func _setup_bullet(bullet: Bullet, origin: Vector2, direction: Vector2, rotation: float) -> void:
	bullet.scale = Vector2(0.5, 0.5)
	bullet.speed = 300
	bullet.rotation = rotation
	bullet.fire(origin, direction)
