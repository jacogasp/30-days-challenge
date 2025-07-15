extends Node2D
const TENTACLE = preload("res://scenes/characters/squid/tentacle.tscn")
@onready var tentacles: Node2D = $Tentacles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("squid_emerges")
	await animation_player.animation_finished
	for i in range(2):
		var tentacle = TENTACLE.instantiate()
		tentacle.position = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		await get_tree().create_timer(randf_range(0,1)).timeout
		tentacles.add_child(tentacle)
