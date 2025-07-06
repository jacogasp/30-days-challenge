extends Node2D

@export var max_speed: float = 500.
@export var fire_rate: float = 15
@export var bullet_scene: PackedScene
@export var bullet_pool_size: int = 5000
@export var sailor_scene: PackedScene
@export var starting_sailor_count: int = 5
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sailors: Node2D = $Sailors

var last_direction: Vector2 = Vector2.ZERO
var bullet_pool: Array[Bullet] = []
var pool_index: int = 0
var bullets_to_spawn = 0
var speed := max_speed
var initial_scale: Vector2 = Vector2.ONE
var particle_emitter_orig_pos: Vector2 = Vector2.ZERO
var boat_lenght:float = 100
var min_sea_limit: Vector2 = Vector2(45,200)
var max_sea_limit: Vector2 = Vector2(1800,1000)
@onready var bullet_spawner: Marker2D = $BulletSpawner


func _ready() -> void:
	particle_emitter_orig_pos = gpu_particles_2d.position
	for i in bullet_pool_size:
		bullet_pool.append(bullet_scene.instantiate())
	initial_scale = bullet_pool[0].scale

	for i in starting_sailor_count:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_lenght * 0.5, boat_lenght * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.modulate = Color.from_hsv(randf(),
										 randf_range(0.6,0.8),
										 randf_range(0.9, 1))


func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	position += direction * speed * delta
	position = position.clamp(min_sea_limit, max_sea_limit)

	if direction != Vector2.ZERO and direction != last_direction:
		var new_direction: Vector2 = direction - last_direction
		for sailor in sailors.get_children():
			sailor.snap_to(-new_direction * speed * delta * Vector2(1,0.5))
			last_direction = direction
			sailor.snap_back()

	if Input.is_action_pressed("fire"):
		bullets_to_spawn += fire_rate * delta
		if bullets_to_spawn < 1:
			pass
		for i in bullets_to_spawn:
			var bullet = bullet_pool[pool_index]
			pool_index = wrapi(pool_index + 1, 0, bullet_pool_size)
			add_child(bullet)
			var bullet_transform := global_transform
			bullet_transform.origin = bullet_spawner.global_position
			bullet.fire(bullet_transform, 0.03)
			bullet.scale = initial_scale
		bullets_to_spawn -= round(bullets_to_spawn)

	if Input.is_action_just_pressed("DEBUG_add_sailor"):
		var sailor := sailor_scene.instantiate()
		var boat_half_lenght = 0.5 * boat_lenght
		sailors.add_child(sailor)
		sailor.spawn_position = Vector2(randf_range(-boat_half_lenght, boat_half_lenght), 0)
		sailor.position = sailor.spawn_position + Vector2(0,-100)
		sailor.modulate = Color(randf(),randf(),randf())
		sailor.spawn()

	if Input.is_action_just_pressed("DEBUG_remove_sailor"):
		var sailor = get_random_sailor()
		if sailor:
			await sailor.jump_out(direction)
			sailor.queue_free()


func get_random_sailor() -> Sailor:
	var sailors_list: Array[Sailor] = []
	for sailor in sailors.get_children():
			if !sailor.jumping_out:
				sailors_list.append(sailor)
	if sailors_list.size() > 0:
		return sailors_list[randi() % sailors_list.size()]
	return null
