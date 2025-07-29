extends StaticBody2D
const TENTACLE = preload("res://scenes/characters/squid/tentacle.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shield_effect: Sprite2D = $ClippingControl/Body/ShieldEffect
@onready var squid_gun: EnemyGun = $ClippingControl/Body/SquidGun
@onready var body: Node2D = $ClippingControl/Body
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var roars_audio_player: AudioStreamPlayer2D = $RoarsAudioStreamPlayer2D

@export_range(1,8,1,"hide_slider") var difficulty: int = 2
@export var health:int = 200
@export var tentacle_position:Array[Vector2]

@export var tentacle_spawn_region: Rect2 = Rect2(Vector2(750, 170), Vector2(270, 460))  # Define the spawn region for tentacles

var tentacles:Array[Tentacle] = []

enum Squid_State{spawning, phase1, phase2}
var current_state:Squid_State = Squid_State.spawning
var emerged_count: int = 0
var submerged_count: int = 0

var submerged:bool = false
var is_dying:bool = false
var flash_timer: Timer
@export var flash_duration: float = 0.1
var last_body_position: Vector2 = Vector2.ZERO  # Track position changes
var _phase1_running: bool = false

func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)

func _ready() -> void:
	_set_up_timer()
	current_state = Squid_State.spawning
	body.position = Vector2(0, 750)
	for i in range(difficulty):
		var tentacle = TENTACLE.instantiate()
		tentacle.global_position = tentacle_position[i]
		tentacle.emerged.connect(_on_tentacle_emerged)
		tentacle.submerged.connect(_on_tentacle_submerged)
		tentacle.tentacle_hit.connect(_on_tentacle_hit)
		tentacles.append(tentacle)
		add_sibling.call_deferred(tentacle)
	health = health + (200 * difficulty)
	progress_bar.max_value = health
	progress_bar.value = health
	progress_bar.visible = false
	await animate_appear()

func _process(_delta: float) -> void:
	match current_state:
		Squid_State.spawning:
			pass
		Squid_State.phase1:
			# Start phase1 loop only once
			if not _phase1_running and not is_dying:
				_phase1_running = true
				execute_phase1_loop()
		Squid_State.phase2:
			pass

var _attacks_finished_count: int = 0

func execute_phase1_loop() -> void:
	while current_state == Squid_State.phase1:
		_attacks_finished_count = 0

		# Connect all tentacles to the counter callback if not already connected
		for tentacle in tentacles:
			if not tentacle.attack_finished.is_connected(_on_tentacle_attack_finished):
				tentacle.attack_finished.connect(_on_tentacle_attack_finished)

		# Start all attacks
		for tentacle in tentacles:
			tentacle.global_position = Vector2(
				randf_range(tentacle_spawn_region.position.x, tentacle_spawn_region.position.x + tentacle_spawn_region.size.x),
				randf_range(tentacle_spawn_region.position.y, tentacle_spawn_region.position.y + tentacle_spawn_region.size.y)
			)

			if randf() < 0.5:
				tentacle.attack(tentacle.AttackType.charge)
			else:
				tentacle.attack(tentacle.AttackType.barrel)

		# Wait for all attacks to finish
		while _attacks_finished_count < tentacles.size():
			if not is_inside_tree():
				return
			await get_tree().process_frame

		print("All attacks finished!")
		roars_audio_player.play()
		animation_player.play_backwards("half_submerge")
		submerged = false
		await animation_player.animation_finished
		for i in range(ceil(difficulty/2.)):
			if not is_dying:
				await fire()
		animation_player.play("half_submerge")
		await animation_player.animation_finished
		submerged = true

		await get_tree().create_timer(1.0).timeout


	_phase1_running = false

func _on_tentacle_attack_finished() -> void:
	_attacks_finished_count += 1
	print("Attack finished count: ", _attacks_finished_count, "/", tentacles.size())


func animate_appear() -> void:
	animation_player.play("emerge")
	await get_tree().create_timer(1).timeout
	for tentacle in tentacles:
		await get_tree().create_timer(randf()).timeout
		tentacle.min_position_y = randf_range(400,300)
		tentacle.emerge()
	await animation_player.animation_finished
	animate_start_phase1()

func animate_start_phase1() -> void:
	animation_player.play("half_submerge")
	for tentacle in tentacles:
		tentacle.submerge()
	await get_tree().create_timer(1).timeout
	submerged = true


func _on_tentacle_emerged() -> void:
	emerged_count += 1
	if emerged_count == tentacles.size():
		pass

func _on_tentacle_submerged() -> void:
	print("Tentacle submerged")
	submerged_count += 1
	if submerged_count == tentacles.size() and current_state == Squid_State.spawning:
		current_state = Squid_State.phase1

func _on_area_hit(damage:int, pos:Vector2) -> void:
	if submerged && damage < 10:
		show_shield_effect(pos)
		return
	GameManager.enemy_hit()
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	health -= damage
	progress_bar.value = health
	if not progress_bar.visible:
		progress_bar.visible = true
	if (health <= 0):
		die()

func show_shield_effect(pos:Vector2) -> void:
	shield_effect.visible = true
	shield_effect.global_position = pos
	flash_timer.start()

func die():
	if is_dying:
		return
	animation_player.play("RESET")
	submerged = true
	set_process(false)
	var score = GameManager.enemy_defeated(2 + difficulty)
	GameManager.spawn_popup(str(score), global_position)
	animation_player.play("submerge")
	await animation_player.animation_finished
	GameManager.squid_defeated()
	queue_free()

func fire():
	animation_player.play("spit")
	squid_gun.fire_spread(8, Globals.player.global_position - squid_gun.global_position, 55)
	await animation_player.animation_finished

func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)
	shield_effect.visible = false

func _on_tentacle_hit(damage:int)->void:
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	health -= damage
	progress_bar.value = health
	if (health <= 0):
		die()
