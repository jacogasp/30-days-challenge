extends Node2D

@export var min_spawning_time: float = 1.0
@export var max_spawning_time: float = 10.0
@export var spawning_time_variance: float = 5.0


@onready var timer: Timer = $Timer

var spawners: Array[EnemySpawner] = []


func _ready() -> void:
	spawners.append($LeftSpawner)
	spawners.append($RightSpawner)
	timer.wait_time = random_time()
	timer.start()


func spawn() -> void:
	var spawner = spawners[randi() % len(spawners)]
	spawner.spawn()
	timer.wait_time = random_time()



func random_time() -> float:
	var avg_t = max_spawning_time
	var t: float = randfn(avg_t, spawning_time_variance)
	return clamp(t, min_spawning_time, max_spawning_time)
