class_name Player
extends Area2D

@export var max_speed: float = 500.0
@export var sailor_scene: PackedScene
@export var starting_sailor_count: int = 5
@export var max_number_sailor: int = 30
@export var invulnerability_duration: float = 2.0  # Duration in seconds
@export var blink_interval: float = 0.1  # How fast the blinking effect
@export var flash_duration: float = 0.1  # Duration of white flash on hit

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sailors: Node2D = $ClippingContainer/Boat/Sailors
@onready var gun: Gun = $PlayerGun

var last_direction: Vector2 = Vector2.ZERO
var speed := max_speed
var particle_emitter_orig_pos: Vector2 = Vector2.ZERO
var boat_length: float = 100
var min_sea_limit: Vector2
var max_sea_limit: Vector2
var current_number_sailor: int = 5
var is_sinking

# Invulnerability variables
var is_invulnerable: bool = false
var invulnerability_timer: Timer
var blink_timer: Timer
var flash_timer: Timer
@onready var original_modulate: Color = self.modulate

signal update_sailors_count
signal game_over
signal overboard

func _ready() -> void:
	min_sea_limit = get_viewport_rect().position + Vector2(0, 90)
	max_sea_limit = get_viewport_rect().size - Vector2(0,+90)
	Globals.player = self
	particle_emitter_orig_pos = gpu_particles_2d.position
	setup_invulnerability_timers()
	for i in starting_sailor_count:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_length * 0.5, boat_length * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.modulate = Color.from_hsv(randf(), randf_range(0.6, 0.8), randf_range(0.9, 1))
	current_number_sailor = starting_sailor_count
	update_sailors_count.emit(current_number_sailor)

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

	Globals.current_score += Globals.tick_score * Globals.tick_score_multiplier * delta

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
			sailor.spawn_position = Vector2(randf_range(-boat_half_length, boat_half_length), 0)
			sailor.position = sailor.spawn_position + Vector2(0, -100)
			sailor.modulate = Color(randf(), randf(), randf())
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

func load_sailor(modulation_color: Color) -> void:
	Globals.current_score += Globals.sailor_score * Globals.sailor_score_multiplier
	if current_number_sailor >= max_number_sailor:
		return
	current_number_sailor += 1
	Globals.tick_score_multiplier = ceil(current_number_sailor / 5.0)
	update_sailors_count.emit(current_number_sailor)
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
		update_sailors_count.emit(current_number_sailor)
		await sailor.jump_out(drop_direction)
		overboard.emit(sailor.duplicate(), sailor.global_position)
		sailor.queue_free()

func hit(damage: int) -> void:
	if is_sinking or is_invulnerable:
		return
		
	modulate = Color(5,5,5)
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
		game_over.emit()
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
	modulate = original_modulate

func sink() -> void:
	pass
