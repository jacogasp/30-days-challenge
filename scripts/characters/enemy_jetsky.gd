extends Enemy

@onready var jetsky_livrea: Sprite2D = $ClippingContainer/Boat/Livrea
@onready var jetsky_sailor_texture = preload("res://assets/jetsky_sailor.png")

func _ready() -> void:
	var enemy_color = Color.from_hsv(randf(), randf_range(0.5, 0.7), randf_range(0.8, 0.9))
	jetsky_livrea.modulate = enemy_color
	sailors_count = starting_sailors
	var sailor :Sailor = sailor_scene.instantiate()
	sailors.add_child(sailor)
	sailor.sprite.texture = jetsky_sailor_texture
	sailor.spawn_position = sailor.position
	sailor.set_sprite_modulate(enemy_color)
	_set_up_timer()

func _physics_process(delta: float) -> void:
	if is_sinking:
		direction.x -= (Globals.world_speed * 0.5 * delta)
		direction.x = max(direction.x, -Globals.world_speed * 0.5)
	position += direction * delta


func _get_bullet_count_by_difficulty(difficulty: int) -> int:
	var weights = []
	for bullet_count in range(2, 6):
		var weight = pow(bullet_count - 1, difficulty / 10.0) + 0.1
		weights.append(weight)
	
	var total_weight = 0.0
	for weight in weights:
		total_weight += weight
	
	var rand_value = randf() * total_weight
	var cumulative_weight = 0.0
	
	for i in range(weights.size()):
		cumulative_weight += weights[i]
		if rand_value <= cumulative_weight:
			return i + 2
	
	return 5

func _fire_bullets_with_delay(bullet_count: int, direction_to_player: Vector2) -> void:
	for i in bullet_count:
		gun.fire_single(direction_to_player)
		await get_tree().create_timer(0.1).timeout

func _on_gun_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false or not on_screen:
		return
	
	var bullet_count = _get_bullet_count_by_difficulty(GameManager.current_difficulty())
	var direction_to_player = Globals.player.global_position - global_position
	
	_fire_bullets_with_delay(bullet_count, direction_to_player)
	
	gun_timer.wait_time = randf_range(min_fire_time, max_fire_time)
	gun_timer.start()
