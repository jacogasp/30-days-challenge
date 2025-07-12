class_name EnemyGun
extends Gun

@export var bullets_ring_count: int = 4
@export var bullets_ring_radius: float = 50


func _ready() -> void:
	bullet_pool = EnemyBulletPool
	bullet_pool.init_pool(bullet_scene)



func fire_ring() -> void:
	var angle: float = 2 * PI / bullets_ring_count
	for i in range(bullets_ring_count):
		var alpha = angle * i
		var direction = Vector2(cos(alpha), sin(alpha))
		var origin = global_position + direction * bullets_ring_radius
		var bullet = bullet_pool.get_bullet()
		bullet.rotation = alpha
		bullet.fire(origin, direction)
