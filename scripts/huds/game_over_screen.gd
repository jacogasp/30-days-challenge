extends Control

@export var title_screen_path: String = "res://scenes/huds/title_screen.tscn"
@onready var username_box: LineEdit = %UsernameBox

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var restart_button: Button = %RestartButton
@onready var submit_button: Button = %SubmitButton
@onready var v_box_container: VBoxContainer = $GameOverPanel/MarginContainer/VBoxContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var leaderboard_panel: Panel = $LeaderboardPanel

var LEADERBOARD = "30 Days Challenge"
var is_new_high_score: bool


func update_labels() -> void:
	score_label.text = "Score: %09d" % GameManager.current_score()
	if is_new_high_score:
		high_score_label.text = "NEW HIGH SCORE!"
	else:
		high_score_label.text = "High Score: %09d" % GameManager.high_score()


func _ready() -> void:
	username_box.grab_focus()
	update_labels()
	await $AnimationPlayer.animation_finished
	v_box_container.process_mode = Node.PROCESS_MODE_ALWAYS
	leaderboard_panel.connect("return_pressed", _return_from_leaderboard)
	

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	EnemyBulletPool.reset()
	PlayerBulletPool.reset()
	GameManager.reset()
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().reload_current_scene()
	GameManager.start()


func _on_main_menu_button_pressed() -> void:
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	get_tree().change_scene_to_file(title_screen_path)


func _on_submit_button_pressed(username: String = username_box.text) -> void:
	submit_button.disabled = true
	await Talo.players.identify("username", username)
	var result := await Talo.leaderboards.add_entry(LEADERBOARD, GameManager.current_score())
	if is_instance_valid(result):
		await leaderboard_panel._load_entries() 
		submit_button.text = "Added!"
	else:
		submit_button.disabled = false
	

func _on_username_text_changed(new_text: String) -> void:
	if new_text != "":
		submit_button.disabled = false
	else:
		submit_button.disabled = true


func _on_leaderboard_button_pressed() -> void:
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play("swap_to_leaderboard")
	await animation_player.animation_finished
	leaderboard_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	leaderboard_panel.return_button.grab_focus()


func _return_from_leaderboard() -> void:
	leaderboard_panel.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play_backwards("swap_to_leaderboard")
	await animation_player.animation_finished
	v_box_container.process_mode = Node.PROCESS_MODE_ALWAYS
