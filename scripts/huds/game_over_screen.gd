extends Control

@export var title_screen_path: String = "res://scenes/huds/title_screen.tscn"

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var restart_button: Button = %RestartButton
@onready var v_box_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var username: LineEdit = $Panel/MarginContainer/VBoxContainer/VBoxContainer/Username

var LEADERBOARD = "30 Days Challenge"
var is_new_high_score: bool

func update_labels() -> void:
	score_label.text = "Score: %09d" % GameManager.current_score()
	if is_new_high_score:
		high_score_label.text = "NEW HIGH SCORE!"
	else:
		high_score_label.text = "High Score: %09d" % GameManager.high_score()

func _ready() -> void:
	restart_button.grab_focus()
	update_labels()
	await $AnimationPlayer.animation_finished
	v_box_container.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	EnemyBulletPool.reset()
	PlayerBulletPool.reset()
	GameManager.reset()
	GameManager.start()
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	get_tree().change_scene_to_file(title_screen_path)


func _on_submit_button_pressed() -> void:
	await Talo.players.identify("username", username.text)
	await Talo.leaderboards.add_entry(LEADERBOARD, GameManager.current_score())
