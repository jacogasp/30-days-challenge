extends Node2D

@onready var squid_spawn_marker: Marker2D = $SquidSpawnMarker
@export var min_spawning_time: float = 1.0
@export var max_spawning_time: float = 10.0
@export_range(0., 1.) var variance_percentage: float = 0.1
@export_range(0., 1) var difficulty_multiplier: float = 0.2
@export var enemy_types: Array[EnemyType]
@export var squid_scene:PackedScene
@onready var timer: Timer = $Timer
var spawners: Array[EnemySpawner] = []

var spawning: bool = true
var first_spawn: bool = true
var squid_difficulty: int = 2  # Track squid difficulty, starts at 2

func _ready() -> void:
	GameManager.squid_entered.connect(pause_spawning)
	GameManager.squid_entered.connect(spawn_squid)
	GameManager.squid_exited.connect(resume_spawning)
	spawners.append($LeftSpawner)
	spawners.append($RightSpawner)
	timer.wait_time = 0.1
	timer.start()


func spawn() -> void:
	if GameManager._game_is_running == false or not spawning:
		return
	
	var spawn_count: int
	if first_spawn:
		spawn_count = 1
		first_spawn = false
	else:
		var difficulty = GameManager.current_difficulty()
		spawn_count = choose_spawn_count_weighted(difficulty)
	
	for i in range(spawn_count):
		var spawner = spawners[randi() % spawners.size()]
		var enemy_type = choose_enemy_type_weighted()
		if enemy_type:
			spawner.spawn(enemy_type.scene)
	
	timer.wait_time = random_time()
	timer.start() 

func choose_enemy_type_weighted() -> EnemyType:
	var total_chance: float = 0.0
	for enemy_type in enemy_types:
		total_chance += enemy_type.chance
	var random_roll: float = randf_range(0.0, total_chance)
	var cumulative_chance: float = 0.0
	for enemy_type in enemy_types:
		cumulative_chance += enemy_type.chance
		if random_roll <= cumulative_chance:
			return enemy_type
	return enemy_types.back()

func choose_spawn_count_weighted(difficulty: int) -> int:
	var difficulty_factor = min(difficulty / 20.0, 1.0)  # Cap at difficulty 20
	
	var weight_1 = 0.9 - (difficulty_factor * 0.5)
	var weight_2 = 0.08 + (difficulty_factor * 0.35)
	var weight_3 = 0.02 + (difficulty_factor * 0.15)
	
	var weights = [weight_1, weight_2, weight_3]
	var random_roll = randf()
	var cumulative = 0.0
	
	for i in range(weights.size()):
		cumulative += weights[i]
		if random_roll <= cumulative:
			return i + 1
	return 1

func random_time() -> float:
	var avg_t = max_spawning_time / (GameManager.current_difficulty() * difficulty_multiplier)
	var variance = avg_t * variance_percentage
	var t: float = randfn(avg_t, variance)
	return clamp(t, min_spawning_time, max_spawning_time)

func spawn_squid() -> void:
	var squid = squid_scene.instantiate()
	squid.difficulty = squid_difficulty
	squid_difficulty = min(squid_difficulty + 1, 8)
	squid.global_position = squid_spawn_marker.global_position
	add_child(squid)

func pause_spawning() -> void:
	spawning = false

func resume_spawning() -> void:
	spawning = true
