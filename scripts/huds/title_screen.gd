extends Control

@onready var new_game_button: Button = %NewGameButton
@onready var music_button: Button = %MusicButton
@onready var sound_button: Button = %SoundButton
@onready var livrea: Node2D = %Livrea
@onready var livrea_a: Sprite2D = %LivreaA
@onready var livrea_b: Sprite2D = %LivreaB
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var v_box_container: VBoxContainer = $Control/Control/Panel/VBoxContainer
@onready var leaderboard_panel: Panel = $LeaderboardPanel

@export var main_path:String = "res://scenes/main.tscn"

func _ready() -> void:
	new_game_button.grab_focus()
	leaderboard_panel.connect("return_pressed", _return_from_leaderboard)
	update_subviewport()


func _on_music_button_toggled(toggled_on: bool) -> void:
	Globals.music_enabled = toggled_on
	if toggled_on:
		music_button.text = "Music: ON"
		AudioServer.set_bus_mute(2,false)
	else:
		music_button.text = "Music: OFF"
		AudioServer.set_bus_mute(2,true)
		


func _on_sound_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sound_button.text = "Sound: ON"
		AudioServer.set_bus_mute(1,false)
	else:
		sound_button.text = "Sound: OFF"
		AudioServer.set_bus_mute(1,true)
		


func _on_new_game_button_pressed() -> void:
	PlayerBulletPool.reset()
	EnemyBulletPool.reset()
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


func _on_leaderboard_button_pressed() -> void:
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play_backwards("open")
	animation_player_2.play("leaderboard_slidein")
	await animation_player.animation_finished
	leaderboard_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	leaderboard_panel.return_button.grab_focus()


func _return_from_leaderboard() -> void:
	leaderboard_panel.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play("open")
	animation_player_2.play_backwards("leaderboard_slidein")
	await animation_player.animation_finished
	v_box_container.process_mode = Node.PROCESS_MODE_ALWAYS
