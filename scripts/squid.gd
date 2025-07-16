extends StaticBody2D
const TENTACLE = preload("res://scenes/characters/squid/tentacle.tscn")
@onready var tentacle_nodes: Node2D = $Tentacles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_range(1,8,1,"hide_slider") var difficulty: int = 2
@export var tentacle_position:Array[Vector2]
var tentacles:Array[Tentacle] = []

enum Squid_State{spawning, starting_phase1, phase1, strating_phase2, phase2}
var current_state:Squid_State = Squid_State.spawning
var emerged_count: int = 0
var submerged_count: int = 0

func _ready() -> void:
	await animate_appear()

func animate_appear() -> void:
	animation_player.play("emerge")
	await animation_player.animation_finished
	for i in range(difficulty):
		var tentacle = TENTACLE.instantiate()
		tentacle.position = tentacle_position[i]
		await get_tree().create_timer(randf_range(0,1)).timeout
		tentacle_nodes.add_child(tentacle)
		tentacle.emerged.connect(_on_tentacle_emerged)
		tentacles.append(tentacle)

func animate_start_phase_1() -> void:
	print("Starting phase 1")
	for tentacle: Tentacle in tentacles:
		tentacle.submerge()
		tentacle.submerged.connect(_on_tentacle_submerged)

func animate_start_phase_2() -> void:
	print("Starting phase 2")
	for tentacle: Tentacle in tentacles:
		tentacle.submerge()	

func _on_tentacle_emerged() -> void:
	emerged_count += 1
	if emerged_count == tentacles.size():
		animate_start_phase_1()

func _on_tentacle_submerged() -> void:
	submerged_count += 1
	if submerged_count == tentacles.size() and current_state == Squid_State.starting_phase1:
		animation_player.play("half_submerge")

func _process(_delta: float) -> void:
	pass
