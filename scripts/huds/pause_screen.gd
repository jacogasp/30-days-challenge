extends Control

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var resume_button: Button = %ResumeButton

@export var title_screen_path:String = "res://scenes/huds/title_screen.tscn"

func update_labels() -> void:
	score_label.text = "Score: %09d" % GameManager.current_score()
	high_score_label.text = "High Score: %09d" % GameManager.high_score()


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
	GameManager.reset()
	Globals.reset_score_multipliers()
	GameManager.start()
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	GameManager.stop()
	get_tree().paused = false
	get_tree().change_scene_to_file(title_screen_path)
