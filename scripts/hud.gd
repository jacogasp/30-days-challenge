extends CanvasLayer

@onready var spawned_enemies_label: Label = $Control/HBoxContainer/SpawnedEnemiesLabel
@onready var defeated_enemies_label: Label = $Control/HBoxContainer/DefeatedEnemiesLabel
@onready var current_score_label: Label = $Control/HBoxContainer/CurrentScoreLabel
@onready var current_sailors_label: Label = $Control/HSplitContainer/CurrentSailorsLabel


func _ready() -> void:
	GameManager.score_updated.connect(update_current_score_label)
	GameManager.enemy_just_spawned.connect(update_spawned_enemies_label)
	GameManager.enemy_just_defeated.connect(update_defeated_enemies_label)
	GameManager.sailor_count_updated.connect(update_current_sailors_label)


func update_spawned_enemies_label(count: int) -> void:
	spawned_enemies_label.text = "S: %d" % count


func update_defeated_enemies_label(count: int) -> void:
	defeated_enemies_label.text = "D: %d" % count


func update_current_score_label(count: int):
	current_score_label.text = "Score %09d" % count


func update_current_sailors_label(count: int):
	current_sailors_label.text = "%d" % count
