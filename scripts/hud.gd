extends CanvasLayer

@onready var spawned_enemies_label: Label = $Control/HBoxContainer/SpawnedEnemiesLabel
@onready var defeated_enemies_label: Label = $Control/HBoxContainer/DefeatedEnemiesLabel
@onready var current_score_label: Label = $Control/HBoxContainer/CurrentScoreLabel
@onready var current_sailors_label: Label = $Control/HSplitContainer/CurrentSailorsLabel


func _process(_delta: float) -> void:
	update_current_score_label()


func update_spawned_enemies_label(count):
	spawned_enemies_label.text = "S %d:" % count


func update_defeated_enemies_label(count):
	defeated_enemies_label.text = "D %d:" % count


func update_current_score_label():
	current_score_label.text = "Score %09d" % Globals.current_score


func update_current_sailors_label(count):
	current_sailors_label.text = "%d" % count
