extends Node2D

@export var bullet_scene: PackedScene
@export var bullet_pool_size: int = 200  # Lowered from 5000

@onready var bullet_spawner: Marker2D = $BulletSpawner
@onready var bullet_container: Node2D = $BulletContainer

var bullet_pool: Array[Bullet] = []
var pool_index: int = 0
var bullets_to_spawn := 0.0


func _ready() -> void:
	# Build bullet pool
	for i in bullet_pool_size:
		var bullet: Bullet = bullet_scene.instantiate()
		bullet_container.add_child(bullet)
		bullet.visible = false
		bullet.active = false
		bullet_pool.append(bullet)


func get_bullet() -> Bullet:
	var bullet: Bullet = bullet_pool[pool_index]
	pool_index = wrapi(pool_index + 1, 0, bullet_pool_size)
	return bullet
