extends Node

@onready var hud: CanvasLayer = $Hud

func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	const GAME_OVER_SCREEN = preload("res://scenes/game_over_screen.tscn")
	var game_over_screen = GAME_OVER_SCREEN.instantiate()
	hud.add_child(game_over_screen)
