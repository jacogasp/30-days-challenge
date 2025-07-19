extends Node

@export var game_over_screen_scene: PackedScene
@onready var main_camera:= $MainCamera

@onready var hud: CanvasLayer = $Hud

func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)

func _on_game_over(is_new_high_score:bool) -> void:
	var game_over_screen = game_over_screen_scene.instantiate()
	game_over_screen.is_new_high_score=is_new_high_score
	hud.add_child(game_over_screen)
	


func _on_player_hit(damage:float) -> void:
	main_camera.shake(max(0.2 * damage, 0.4))
	GameManager.player_hit()
