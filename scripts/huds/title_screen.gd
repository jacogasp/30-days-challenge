extends Control

@onready var new_game_button: Button = %NewGameButton
@onready var music_button: Button = %MusicButton
@onready var sound_button: Button = %SoundButton
@onready var livrea: Node2D = %Livrea
@onready var livrea_a: Sprite2D = %LivreaA
@onready var livrea_b: Sprite2D = %LivreaB
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var main_path:String = "res://scenes/main.tscn"

func _ready() -> void:
	new_game_button.grab_focus()
	update_subviewport()


func _on_music_button_toggled(toggled_on: bool) -> void:
	Globals.music_enabled = toggled_on
	if toggled_on:
		music_button.text = "Music: ON"
	else:
		music_button.text = "Music: OFF"


func _on_sound_button_toggled(toggled_on: bool) -> void:
	Globals.sound_enabled = toggled_on
	if toggled_on:
		sound_button.text = "Sound: ON"
	else:
		sound_button.text = "Sound: OFF"


func _on_new_game_button_pressed() -> void:
	PlayerBulletPool.reset()
	EnemyBulletPool.reset()
	Globals.reset_score()
	GameManager.reset()
	GameManager.start()
	get_tree().change_scene_to_file(main_path)


func update_subviewport() -> void:
	livrea.modulate = Globals.colors[Globals.player_livreaColor]
	livrea_a.texture = load("res://assets/livrea/livrea_a%d.png" % Globals.player_livreaA)
	livrea_b.texture = load("res://assets/livrea/livrea_b%d.png" % Globals.player_livreaB)


func _on_livrea_a_prev_button_pressed() -> void:
	Globals.player_livreaA = wrapi(Globals.player_livreaA - 1, 1, 5)
	update_subviewport()


func _on_livrea_a_next_button_pressed() -> void:
	Globals.player_livreaA = wrapi(Globals.player_livreaA + 1, 1, 5)
	update_subviewport()


func _on_livrea_b_prev_button_pressed() -> void:
	Globals.player_livreaB = wrapi(Globals.player_livreaB - 1, 1, 5)
	update_subviewport()


func _on_livrea_b_next_button_pressed() -> void:
	Globals.player_livreaB = wrapi(Globals.player_livreaB + 1, 1, 5)
	update_subviewport()


func _on_livrea_color_prev_button_pressed() -> void:
	Globals.player_livreaColor = wrapi(Globals.player_livreaColor - 1, 0, Globals.colors.size())
	update_subviewport()


func _on_livrea_color_next_button_pressed() -> void:
	Globals.player_livreaColor = wrapi(Globals.player_livreaColor + 1, 0, Globals.colors.size())
	update_subviewport()
