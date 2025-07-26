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

	if not fully_visible and is_fully_visible():
		fully_visible = true
		gun_timer.start()

func _on_gun_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false:
		return
	gun.fire_single(Globals.player.global_position - global_position)
	gun_timer.wait_time = randf_range(min_fire_time, max_fire_time)
