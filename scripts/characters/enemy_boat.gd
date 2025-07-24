extends Enemy

@onready var livrea: Node2D = $ClippingContainer/Boat/Sail/Livrea
@onready var livrea_a: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaA
@onready var livrea_b: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaB
@onready var barrel_emitter: Node2D = $BarrelEmitter
@onready var barrel_timer: Timer = $BarrelTimer

var barrel_primary_chance: float = 0.3
var barrel_secondary_chance: float = 0.3

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
	barrel_secondary_chance = barrel_secondary_chance - (max(GameManager.bomb_count - 1, 0)) * 0.05
	barrel_primary_chance = barrel_primary_chance - (max(GameManager.power_level - 1, 0)) * 0.05
	_set_up_timer()

func _physics_process(delta: float) -> void:
	position += direction * delta

	if not fully_visible and is_fully_visible():
		fully_visible = true
		gun_timer.start()
		barrel_timer.start()

func _on_barrel_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false:
		return
	if randf() < barrel_primary_chance:
		if randf() < barrel_secondary_chance:
			barrel_emitter.drop_barrel_secondary()
		else:
			barrel_emitter.drop_barrel_primary()
	else:
		barrel_emitter.fire()
	barrel_timer.wait_time = randf_range(barrel_emitter.min_fire_time, barrel_emitter.max_fire_time)
