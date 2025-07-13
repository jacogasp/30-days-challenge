extends Control

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var resume_button: Button = %ResumeButton


func update_labels() -> void:
	score_label.text = "Score: %09d" % Globals.current_score
	high_score_label.text = "High Score: %09d" % Globals.high_score


func _ready() -> void:
	resume_button.grab_focus()
	update_labels()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		resume_button.grab_focus()
		get_tree().paused = !get_tree().paused
		visible = !visible
		update_labels()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	EnemyBulletPool.reset()
	PlayerBulletPool.reset()
	Globals.reset_score()
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
