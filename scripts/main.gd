extends Node

@export var game_over_screen_scene: PackedScene

@onready var hud: CanvasLayer = $Hud

func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	var game_over_screen = game_over_screen_scene.instantiate()
	hud.add_child(game_over_screen)
