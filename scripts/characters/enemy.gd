class_name Enemy
extends Area2D

@export var direction: Vector2 = Vector2(100, 0)
@export var health_max: int = 100
@export var starting_sailors: int = 3
@export var sailor_scene: PackedScene
@export var min_fire_time: float = 1.0
@export var max_fire_time: float = 5.0
@export var flash_duration: float = 0.1
@export var splash_samples: Array[AudioStreamMP3] = []

@onready var health = health_max
@onready var debug_label: Label = $DEBUGLabel
@onready var sailors: Node2D = $ClippingContainer/Boat/Sailors
@onready var boat: Node2D = $ClippingContainer/Boat
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var livrea: Node2D = $ClippingContainer/Boat/Sail/Livrea
@onready var livrea_a: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaA
@onready var livrea_b: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaB
@onready var gun: EnemyGun = $EnemyGun
@onready var barrel_emitter: Node2D = $BarrelEmitter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barrel_timer: Timer = $BarrelTimer
@onready var gun_timer: Timer = $GunTimer
@onready var audio_streamer: AudioStreamPlayer2D = $AudioStreamPlayer2D

var sailors_count: int
var boat_length: int = 100
var boat_height: int = 200

var is_sinking = false
var fully_visible := false
var screen_offset: int = 50
var flash_timer: Timer


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

func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)

func _physics_process(delta: float) -> void:
	position += direction * delta

	if not fully_visible and is_fully_visible():
		fully_visible = true
		gun_timer.start()
		barrel_timer.start()


func is_fully_visible() -> bool:
	if is_sinking:
		return false
	var is_in_left: bool = collision_shape_2d.global_position.x > screen_offset
	var is_in_right: bool = collision_shape_2d.global_position.x + collision_shape_2d.shape.get_rect().size.x < get_viewport_rect().size.x - screen_offset
	return is_in_left and is_in_right


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	GameManager.enemy_spawned()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func drop_sailors(drop_direction: Vector2) -> void:
	var target_sailors: int
	if health > 0:
		target_sailors = floor(starting_sailors * health / float(health_max)) + 1
	else:
		target_sailors = 0
	for i in (sailors_count - target_sailors):
		var sailor := get_random_sailor()
		if sailor:
			sailors_count -= 1
			await sailor.jump_out(drop_direction)
			GameManager.overboard_sailor(sailor.duplicate(), sailor.global_position)
			sailor.queue_free()


func hit(damage: int) -> void:
	if is_sinking:
		return
	GameManager.enemy_hit()
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	health -= damage
	debug_label.text = str(health)
	audio_streamer.stream = splash_samples[randi() % len(splash_samples)]
	audio_streamer.play()
	drop_sailors(direction)
	if (health <= 0):
		sink()
		GameManager.enemy_defeated()
		GameManager.spawn_enemy_defeated_score(global_position)


func get_random_sailor() -> Sailor:
	var sailors_list: Array[Sailor] = []
	for sailor in sailors.get_children():
		if !sailor.jumping_out:
			sailors_list.append(sailor)
	if sailors_list.size() > 0:
		return sailors_list[randi() % sailors_list.size()]
	return null


func sink() -> void:
	if is_sinking:
		return
	animation_player.play("RESET")
	set_process(false)
	collision_shape_2d.queue_free()
	is_sinking = true
	var sinking_angle = randf_range(5, 30)
	sinking_angle *= -1 if randf() < 0.5 else 1
	var tween = create_tween()
	tween.tween_property(boat, "rotation", deg_to_rad(sinking_angle), 1.0)
	await tween.finished
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(boat, "rotation", deg_to_rad(sinking_angle), 1.0)
	tween.tween_property(boat, "position:y", 2 * boat_height, 2.0)
	tween.tween_property(gpu_particles_2d, "scale", Vector2(0, 0), 2)
	await tween.finished
	queue_free()


func _on_barrel_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false:
		return
	barrel_emitter.fire()
	barrel_timer.wait_time = randf_range(barrel_emitter.min_fire_time, barrel_emitter.max_fire_time)

func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)

func _on_gun_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false:
		return
	gun.fire_spread(3, Globals.player.global_position - global_position, 30)
	gun_timer.wait_time = randf_range(min_fire_time, max_fire_time)
