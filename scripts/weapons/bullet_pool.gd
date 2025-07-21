class_name BulletPool
extends Node2D

@export var group: String = "player"
@export var bullet_pool_size: int = 200 # Lowered from 5000

var bullet_pool: Array[BulletBase] = []
var pool_index: int = 0
var bullets_to_spawn: int = 0
var initialized: bool = false


func init_pool(bullet_scene: PackedScene) -> void:
	if initialized:
		return

	for i in bullet_pool_size:
		var bullet: BulletBase = bullet_scene.instantiate()
		add_child(bullet)
		bullet.visible = false
		bullet.active = false
		bullet.add_to_group(group)
		bullet_pool.append(bullet)

	initialized = true

func reset() -> void:
	for bullet in get_children():
		bullet.visible = false
		bullet.active = false

func get_bullet() -> BulletBase:
	var bullet: BulletBase = bullet_pool[pool_index]
	pool_index = wrapi(pool_index + 1, 0, bullet_pool_size)
	return bullet
