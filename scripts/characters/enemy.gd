class_name Enemy
extends Area2D

@export var direction: Vector2 = Vector2(100, 0)
@export var health_max: int = 100
@export var starting_sailors: int = 3
@export var sailor_scene: PackedScene
@export var min_fire_time: float = 1.0
@export var max_fire_time: float = 5.0

@onready var health = health_max
@onready var label: Label = $Label
@onready var sailors: Node2D = $ClippingContainer/Boat/Sailors
@onready var boat: Node2D = $ClippingContainer/Boat
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gun: Gun = $EnemyGun
@onready var timer: Timer = $Timer

var sailors_count: int
var boat_length: int = 100
var boat_height: int = 200

var is_sinking = false

signal enemy_spawned
signal enemy_defeated
signal overboard


func _ready() -> void:
	label.hide()
	timer.wait_time = random_time()
	var sailors_color = Color.from_hsv(randf(),
									 randf_range(0.6, 0.8),
									 randf_range(0.9, 1))
	sailors_count = starting_sailors
	for i in starting_sailors:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_length * 0.5, boat_length * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.modulate = sailors_color


func _physics_process(delta: float) -> void:
	position += direction * delta


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enemy_spawned.emit()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func drop_sailors(drop_direction: Vector2) -> void:
	var target_sailors: int
	if health > 0:
		target_sailors = ceil(starting_sailors * health / float(health_max)) + 1
	else:
		target_sailors = 0
	for i in (sailors_count - target_sailors):
		var sailor := get_random_sailor()
		if sailor:
			sailors_count -= 1
			await sailor.jump_out(drop_direction)
			overboard.emit(sailor.duplicate(), sailor.global_position)
			sailor.queue_free()

func hit(damage: int) -> void:
	if is_sinking:
		return
	if (label.hidden):
		label.show()
	Globals.current_score += Globals.hit_score * Globals.hit_score_multiplier
	health -= damage
	label.text = str(health)
	drop_sailors(direction)
	if (health <= 0):
		enemy_defeated.emit()
		sink()

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
	set_process(false)
	is_sinking = true
	Globals.current_score += Globals.sink_score * Globals.sink_score_multiplier
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
	queue_free()


func _on_timer_timeout() -> void:
	gun.fire_ring()
	timer.wait_time = random_time()


func random_time() -> float:
	return randf_range(min_fire_time, max_fire_time)
