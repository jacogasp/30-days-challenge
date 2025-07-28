extends Enemy

@onready var livrea: Node2D = $ClippingContainer/Boat/Sail/Livrea
@onready var livrea_a: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaA
@onready var livrea_b: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaB
@onready var barrel_emitter: Node2D = $BarrelEmitter
@onready var barrel_timer: Timer = $BarrelTimer

func _ready() -> void:
	var enemy_color = Color.from_hsv(randf(), randf_range(0.5, 0.7), randf_range(0.8, 0.9))
	livrea.modulate = enemy_color
	livrea_a.texture = load("res://assets/livrea/livrea_a%d.png" % randi_range(1, 4))
	livrea_b.texture = load("res://assets/livrea/livrea_b%d.png" % randi_range(1, 4))
	sailors_count = starting_sailors
	for i in starting_sailors:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_length * 0.5, boat_length * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.set_sprite_modulate(enemy_color)
	_set_up_timer()

func _physics_process(delta: float) -> void:
	if is_sinking:
		direction.x -= (Globals.world_speed * 0.5 * delta)
		direction.x = max(direction.x, -Globals.world_speed * 0.5)

	position += direction * delta

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	super()
	barrel_timer.start()

func _on_barrel_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false or not on_screen:
		return
	
	var barrel_type = GameManager.get_random_barrel_type()
	match barrel_type:
		GameManager.BarrelType.TNT:
			barrel_emitter.fire()
		GameManager.BarrelType.PRIMARY:
			barrel_emitter.drop_barrel_primary()
		GameManager.BarrelType.SECONDARY:
			barrel_emitter.drop_barrel_secondary()
	
	barrel_timer.wait_time = randf_range(barrel_emitter.min_fire_time, barrel_emitter.max_fire_time)
	barrel_timer.start()
