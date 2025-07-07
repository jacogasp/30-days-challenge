class_name Player
extends Node2D

@export var max_speed: float = 500.0

@export var sailor_scene: PackedScene
@export var starting_sailor_count: int = 5
@export var max_number_sailor: int = 30

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sailors: Node2D = $ClippingContainer/Boat/Sailors
@onready var gun: Gun = $Gun

var last_direction: Vector2 = Vector2.ZERO
var speed := max_speed
var particle_emitter_orig_pos: Vector2 = Vector2.ZERO
var boat_lenght: float = 100
var min_sea_limit: Vector2 = Vector2(45, 200)
var max_sea_limit: Vector2 = Vector2(1800, 1000)
var current_number_sailor:int = 0

signal update_sailors_count

func _ready() -> void:
	particle_emitter_orig_pos = gpu_particles_2d.position

	# Spawn initial sailors
	for i in starting_sailor_count:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_lenght * 0.5, boat_lenght * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.modulate = Color.from_hsv(randf(), randf_range(0.6, 0.8), randf_range(0.9, 1))
		current_number_sailor += 1
	update_sailors_count.emit(current_number_sailor)


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
			var boat_half_lenght = 0.5 * boat_lenght
			sailors.add_child(sailor)
			sailor.spawn_position = Vector2(randf_range(-boat_half_lenght, boat_half_lenght), 0)
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
	Globals.tick_score_multiplier = ceil(current_number_sailor/5.0)
	update_sailors_count.emit(current_number_sailor)
	var sailor := sailor_scene.instantiate()
	var boat_half_lenght = 0.5 * boat_lenght
	sailors.add_child(sailor)
	sailor.spawn_position = Vector2(randf_range(-boat_half_lenght, boat_half_lenght), 0)
	sailor.position = sailor.spawn_position + Vector2(0, -100)
	sailor.modulate = modulation_color
	sailor.spawn()
