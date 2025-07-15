class_name Player
extends Area2D

@export var max_speed: float = 500.0
@export var sailor_scene: PackedScene
@export var starting_sailor_count: int = 5
@export var max_number_sailor: int = 30
@export var invulnerability_duration: float = 2.0 # Duration in seconds
@export var blink_interval: float = 0.1 # How fast the blinking effect
@export var flash_duration: float = 0.1 # Duration of white flash on hit

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sailors: Node2D = $ClippingContainer/Boat/Sailors
@onready var gun: Gun = $PlayerGun
@onready var boat: Node2D = $ClippingContainer/Boat
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var livrea: Node2D = $ClippingContainer/Boat/Sail/Livrea
@onready var livrea_a: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaA
@onready var livrea_b: Sprite2D = $ClippingContainer/Boat/Sail/Livrea/LivreaB

var last_direction: Vector2 = Vector2.ZERO
var speed := max_speed
var particle_emitter_orig_pos: Vector2 = Vector2.ZERO
var boat_length: float = 100
var boat_height: float = 200
var min_sea_limit: Vector2
var max_sea_limit: Vector2
var current_number_sailor: int = 5
var is_sinking

var is_invulnerable: bool = false
var invulnerability_timer: Timer
var blink_timer: Timer
var flash_timer: Timer
@onready var original_modulate: Color = self.modulate

var boat_rotation_tween: Tween = null

signal overboard
signal player_hit


func _ready() -> void:
	livrea.modulate = Globals.colors[Globals.player_livreaColor]
	livrea_a.texture = load("res://assets/livrea/livrea_a%d.png" % Globals.player_livreaA)
	livrea_b.texture = load("res://assets/livrea/livrea_b%d.png" % Globals.player_livreaB)

	min_sea_limit = get_viewport_rect().position + Vector2(0, 150)
	max_sea_limit = get_viewport_rect().size - Vector2(0, 50)
	Globals.player = self
	particle_emitter_orig_pos = gpu_particles_2d.position

	setup_invulnerability_timers()

	for i in starting_sailor_count:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_length * 0.5, boat_length * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.modulate = Globals.colors[Globals.player_livreaColor]
	current_number_sailor = starting_sailor_count
	GameManager.update_sailors_count(current_number_sailor)


func setup_invulnerability_timers() -> void:
	# Main invulnerability timer
	invulnerability_timer = Timer.new()
	invulnerability_timer.wait_time = invulnerability_duration
	invulnerability_timer.one_shot = true
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)
	add_child(invulnerability_timer)

	# Blink effect timer
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_interval
	blink_timer.timeout.connect(_on_blink_timeout)
	add_child(blink_timer)

	# Flash effect timer
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)


func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	position += direction * speed * delta
	position = position.clamp(min_sea_limit, max_sea_limit)

	# Boat Rotation Logic
	var target_rotation: float = 0.0
	if direction.x < 0:  
		target_rotation = deg_to_rad(1.5)
	elif direction.x > 0:  
		target_rotation = deg_to_rad(-2)

	if boat.rotation != target_rotation:
		if boat_rotation_tween:
			boat_rotation_tween.kill() 
		boat_rotation_tween = create_tween()
		boat_rotation_tween.tween_property(boat, "rotation", target_rotation, 0.2) 


	if direction != Vector2.ZERO and direction != last_direction:
		var new_direction: Vector2 = direction - last_direction
		for sailor in sailors.get_children():
			sailor.snap_to(-new_direction * speed * delta * Vector2(1, 0.5))
			last_direction = direction
			sailor.snap_back()

	if Input.is_action_pressed("fire"):
		gun.fire()

	if Input.is_action_just_pressed("fire"):
		gun.fire_bullet()

	if OS.is_debug_build():
		if Input.is_action_just_pressed("DEBUG_add_sailor"):
			var sailor := sailor_scene.instantiate()
			var boat_half_length = 0.5 * boat_length
			sailors.add_child(sailor)
			current_number_sailor += 1
			sailor.spawn_position = Vector2(randf_range(-boat_half_length, boat_half_length), 0)
			sailor.position = sailor.spawn_position + Vector2(0, -100)
			sailor.modulate = Color(randf(), randf(), randf())
			sailor.spawn()
		if Input.is_action_just_pressed("DEBUG_remove_sailor"):
			var sailor = get_random_sailor()
			if sailor:
				current_number_sailor -= 1
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

func load_sailor(modulation_color: Color) -> void:
	if current_number_sailor >= max_number_sailor:
		return
	current_number_sailor += 1
	Globals.tick_score_multiplier = ceil(current_number_sailor / 5.0)
	GameManager.update_sailors_count(current_number_sailor)
	var sailor := sailor_scene.instantiate()
	var boat_half_length = 0.5 * boat_length
	sailors.add_child(sailor)
	sailor.spawn_position = Vector2(randf_range(-boat_half_length, boat_half_length), 0)
	sailor.position = sailor.spawn_position + Vector2(0, -100)
	sailor.modulate = modulation_color
	sailor.spawn()


func drop_sailor(drop_direction: Vector2) -> void:
	var sailor := get_random_sailor()
	if sailor:
		current_number_sailor -= 1
		GameManager.update_sailors_count(current_number_sailor)
		await sailor.jump_out(drop_direction)
		overboard.emit(sailor.duplicate(), sailor.global_position)
		sailor.queue_free()


func hit(damage: int) -> void:
	if is_sinking or is_invulnerable:
		return
	
	player_hit.emit(damage)
	
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	start_invulnerability()

	var target_sailors: int
	if current_number_sailor > 0:
		target_sailors = current_number_sailor - damage
	else:
		target_sailors = 0
	for i in current_number_sailor - target_sailors:
		drop_sailor(last_direction)
	if (current_number_sailor <= 0):
		sink()


func start_invulnerability() -> void:
	is_invulnerable = true
	invulnerability_timer.start()
	blink_timer.start()


func _on_invulnerability_timeout() -> void:
	is_invulnerable = false
	blink_timer.stop()
	modulate = original_modulate


func _on_blink_timeout() -> void:
	modulate.a = 0.1 if modulate.a == 1.0 else 1.0


func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)


func sink() -> void:
	GameManager._game_over()
	if is_sinking:
		return
	invulnerability_timer.stop()
	_on_invulnerability_timeout()
	set_process(false)
	collision_shape_2d.queue_free()
	is_sinking = true
	var sinking_angle = randf_range(5, 30)
	var tween = create_tween()
	tween.tween_property(boat, "rotation", deg_to_rad(sinking_angle * 0.5), 1.0)
	await tween.finished
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(boat, "rotation", deg_to_rad(sinking_angle), 1.0)
	tween.tween_property(boat, "position:y", boat_height, 2.0)
	tween.tween_property(gpu_particles_2d, "scale", Vector2(0, 0), 2)
	await tween.finished
