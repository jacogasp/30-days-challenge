extends CanvasLayer

@onready var current_score_label: Label = $Control/HBoxContainer/VBoxContainer/CurrentScoreLabel
@onready var current_sailors_label: Label = $Control/HSplitContainer/CurrentSailorsLabel
@onready var high_score_label: Label = $Control/HBoxContainer/VBoxContainer/HighScoreLabel

@onready var hit_count: Control = %HitCount
@onready var hit_count_number_label: Label =%HitCount/NumberLabel
@onready var hit_count_text_label: Label = %HitCount/TextLabel

@onready var spawned_enemies_label: Label = $Control/DEBUGPanel/VBoxContainer/SpawnedEnemiesLabel
@onready var defeated_enemies_label: Label = $Control/DEBUGPanel/VBoxContainer/DefeatedEnemiesLabel
@onready var difficulty_label: Label = $Control/DEBUGPanel/VBoxContainer/DifficultyLabel

func _ready() -> void:
	GameManager.score_updated.connect(update_current_score_label)
	GameManager.sailor_count_updated.connect(update_current_sailors_label)
	GameManager.hit_count_updated.connect(update_hit_count_label)
	GameManager.enemy_just_defeated.connect(update_defeated_enemies_count)
	GameManager.enemy_just_spawned.connect(update_spawned_enemies_count)
	GameManager.difficulty_changed.connect(update_difficulty)
	GameManager.update_all_hud()
	high_score_label.text = "HIGHSCORE: %09d" % GameManager.high_score()

func update_current_score_label(count: int):
	current_score_label.text = "SCORE: %09d" % count

func update_current_sailors_label(count: int):
	current_sailors_label.text = "%d" % count

func update_defeated_enemies_count(count: int):
	defeated_enemies_label.text = "Deafeted En:%d"%count

func update_spawned_enemies_count(count: int):
	spawned_enemies_label.text = "Spawned En:%d"%count

func update_difficulty(count:int):
	difficulty_label.text = "Difficulty:%d"%count

func update_hit_count_label(count: int, increasing:bool = true):
	hit_count_number_label.text = str(count)
	if count == 0:
		hit_count_number_label.visible = false
		hit_count_text_label.visible = false
		return
	else:
		hit_count_number_label.visible = true
		hit_count_text_label.visible = true
	hit_count_text_label.text = "Hit" if count == 1 else "Hits"
	const BASE_FONT_SIZE = 32
	const MAX_FONT_SIZE = 64 
	const SCALING_COUNT_MAX = 100 
	var number_font_size = BASE_FONT_SIZE
	var text_font_size = BASE_FONT_SIZE
	if count > 1:
		var clamped_count = clampi(count, 1, SCALING_COUNT_MAX)
		var progress = float(clamped_count - 1) / (SCALING_COUNT_MAX - 1)
		number_font_size = lerp(BASE_FONT_SIZE, MAX_FONT_SIZE, progress)
		text_font_size = lerp(BASE_FONT_SIZE, MAX_FONT_SIZE, progress)
	if count > 100:
		hit_count_text_label.text = "Hits!!!"
		number_font_size = 64 
		text_font_size = 48 
	hit_count_number_label.add_theme_font_size_override("font_size", int(number_font_size))
	hit_count_text_label.add_theme_font_size_override("font_size", int(text_font_size))
	if increasing:
		bounce_label()

func bounce_label():
	var bounce_tween = create_tween()
	var bounce_duration = 0.2
	var bounce_scale = Vector2(1.2, 1.2)
	var bounce_rotation_degrees = 5.0
	bounce_tween.tween_property(hit_count, "scale", bounce_scale, bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(hit_count, "rotation_degrees", bounce_rotation_degrees, bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(hit_count, "scale", Vector2(1, 1), bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(hit_count, "rotation_degrees", 0.0, bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
