class_name Enemy
extends Area2D

@export var direction: Vector2 = Vector2(100, 0)
@export var health_max: int = 100
@export var starting_sailors: int = 3
@export var sailor_scene: PackedScene
@export var min_fire_time: float = 1.0
@export var max_fire_time: float = 5.0
@export var flash_duration: float = 0.1

@onready var health = health_max
@onready var debug_label: Label = $DEBUGLabel
@onready var sailors: Node2D = $ClippingContainer/Boat/Sailors
@onready var boat: Node2D = $ClippingContainer/Boat
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var gun: EnemyGun = $EnemyGun
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gun_timer: Timer = $GunTimer
@onready var hit_audio_streamer: AudioStreamPlayer2D = $HitAudioStreamPlayer2D
@onready var sink_audio_streamer: AudioStreamPlayer2D = $SinkAudioStreamPlayer2D

var sailors_count: int
var boat_length: int = 100
var boat_height: int = 200

var is_sinking = false
var on_screen := false
var screen_offset: int = 50
var flash_timer: Timer


func _process(_delta: float) -> void:
	check_visibility()


func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)


func screen_entered() -> void:
	on_screen = true
	gun_timer.start()


func screen_exited():
	on_screen = false
	await get_tree().create_timer(3).timeout
	GameManager.enemy_screen_exited()
	queue_free()


func check_visibility() -> void:
	var viewport_rect = get_viewport().get_visible_rect()
	var min_x: float = viewport_rect.position.x - 10
	var max_x: float = viewport_rect.position.x + viewport_rect.size.x + 220
	var inside_viewport = global_position.x > min_x && global_position.x < max_x
	if on_screen and not inside_viewport:
		screen_exited()
		return
	if not on_screen and inside_viewport:
		screen_entered()


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
	drop_sailors(direction)
	if (health <= 0):
		sink()
		var points = GameManager.enemy_defeated()
		GameManager.spawn_popup(str(points), global_position)
		sink_audio_streamer.play()
	else:
		hit_audio_streamer.play()


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
	GameManager.enemy_screen_exited()
	queue_free()

func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)

func _on_gun_timer_timeout() -> void:
	if is_sinking or GameManager._game_is_running == false or not on_screen:
		return
	gun.fire_spread(3, Globals.player.global_position - global_position, 30)
	gun_timer.wait_time = randf_range(min_fire_time, max_fire_time)
	gun_timer.start()
