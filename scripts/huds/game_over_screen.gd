extends Control

@export var title_screen_scene: PackedScene

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var restart_button: Button = %RestartButton
@onready var v_box_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer

func update_labels() -> void:
	score_label.text = "Score: %09d" % GameManager.current_score()
	if GameManager.current_score() > GameManager.high_score():
		high_score_label.text = "NEW HIGH SCORE!"
	else:
		high_score_label.text = "High Score: %09d" % GameManager.high_score()

func _ready() -> void:
	restart_button.grab_focus()
	update_labels()
	v_box_container.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	EnemyBulletPool.reset()
	PlayerBulletPool.reset()
	GameManager.start()
	Globals.reset_score()
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	get_tree().change_scene_to_packed(title_screen_scene)
