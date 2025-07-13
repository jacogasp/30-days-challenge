extends CanvasLayer
@onready var music_button: Button = $Control/Control/Panel/VBoxContainer/MusicButton
@onready var sound_button: Button = $Control/Control/Panel/VBoxContainer/SoundButton

func _on_music_button_toggled(toggled_on: bool) -> void:
	Globals.music_enabled=toggled_on
	if toggled_on:
		music_button.text = "Music: ON"
	else:
		music_button.text = "Music: OFF"


func _on_sound_button_toggled(toggled_on: bool) -> void:
	Globals.sound_enabled=toggled_on
	if toggled_on:
		sound_button.text = "Sound: ON"
	else:
		sound_button.text = "Sound: OFF"


func _on_new_game_button_pressed() -> void:
	PlayerBulletPool.reset()
	EnemyBulletPool.reset()
	Globals.reset_score()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
