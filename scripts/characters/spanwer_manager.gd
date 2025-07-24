extends Node2D

@export var min_spawning_time: float = 1.0
@export var max_spawning_time: float = 10.0
@export_range(0., 1.) var variance_percentage: float = 0.1
@export_range(0., 1) var difficulty_multiplier: float = 0.2
@export var enemy_types: Array[EnemyType]

@onready var timer: Timer = $Timer
var spawners: Array[EnemySpawner] = []

func _ready() -> void:
	spawners.append($LeftSpawner)
	spawners.append($RightSpawner)
	timer.wait_time = random_time()
	timer.start()


func spawn() -> void:
	if GameManager._game_is_running == false:
		return
	var spawner = spawners[randi() % spawners.size()]
	var enemy_type = choose_enemy_type_weighted()
	if enemy_type:
		spawner.spawn(enemy_type.scene)
	timer.wait_time = random_time()

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

func random_time() -> float:
	var avg_t = max_spawning_time / (GameManager.current_difficulty() * difficulty_multiplier)
	var variance = avg_t * variance_percentage
	var t: float = randfn(avg_t, variance)
	return clamp(t, min_spawning_time, max_spawning_time)
