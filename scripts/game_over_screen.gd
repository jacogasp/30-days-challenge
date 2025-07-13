extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var v_box_container: VBoxContainer = $VBoxContainer

func update_labels() -> void:
	score_label.text = "Score: %09d" % Globals.current_score
	if Globals.current_score > Globals.high_score:
		high_score_label.text = "NEW HIGH SCORE!"
		Globals.high_score = Globals.current_score
	else:
		high_score_label.text = "High Score: %09d" % Globals.high_score

func _ready() -> void:
	update_labels()
	v_box_container.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	EnemyBulletPool.reset()
	PlayerBulletPool.reset()
	Globals.reset_score()
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	v_box_container.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
