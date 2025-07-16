extends Node2D

@export var min_spawning_time: float = 1.0
@export var max_spawning_time: float = 10.0
@export_range(0., 1.) var variance_percentage: float = 0.1
@export_range(0., 1) var difficulty_multiplier: float = 0.2

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
	var spawner = spawners[randi() % len(spawners)]
	spawner.spawn()
	timer.wait_time = random_time()


func random_time() -> float:
	var avg_t = max_spawning_time / (GameManager.current_difficulty() * difficulty_multiplier)
	var variance = avg_t * variance_percentage
	var t: float = randfn(avg_t, variance)
	return clamp(t, min_spawning_time, max_spawning_time)
